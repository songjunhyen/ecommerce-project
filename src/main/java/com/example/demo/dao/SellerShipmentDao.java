package com.example.demo.dao;

import com.example.demo.vo.SellerShipment;
import com.example.demo.vo.SellerShipmentUpdateRequest;
import org.apache.ibatis.annotations.*;

import java.time.LocalDateTime;
import java.util.List;

@Mapper
public interface SellerShipmentDao {

    // 1) 단건 UPSERT (운송장/택배사/시각 필드 보존)
    @Insert("""
      INSERT INTO seller_shipments (
        order_number, seller_id, receiver_name, phone, address,
        total_quantity, total_amount, payment_method, payment_status,
        status, tracking_no, carrier, shipped_at, delivered_at
      ) VALUES (
        #{orderNumber}, #{sellerId}, #{receiverName}, #{phone}, #{address},
        #{totalQuantity}, #{totalAmount}, #{paymentMethod}, #{paymentStatus},
        #{status}, #{trackingNo}, #{carrier}, #{shippedAt}, #{deliveredAt}
      )
      ON DUPLICATE KEY UPDATE
        receiver_name  = VALUES(receiver_name),
        phone          = VALUES(phone),
        address        = VALUES(address),
        total_quantity = VALUES(total_quantity),
        total_amount   = VALUES(total_amount),
        payment_method = VALUES(payment_method),
        payment_status = VALUES(payment_status),
        status         = VALUES(status),
        -- ▼ 판매자 입력 보존 (NULL 들어오면 기존값 유지)
        tracking_no    = COALESCE(VALUES(tracking_no), tracking_no),
        carrier        = COALESCE(VALUES(carrier), carrier),
        shipped_at     = COALESCE(VALUES(shipped_at), shipped_at),
        delivered_at   = COALESCE(VALUES(delivered_at), delivered_at),
        updated_at     = CURRENT_TIMESTAMP
      """)
    int upsert(SellerShipment shipment);

    // 2) 판매자 기준 목록 조회
    @Select("""
        SELECT
          id,
          order_number   AS orderNumber,
          seller_id      AS sellerId,
          receiver_name  AS receiverName,
          phone,
          address,
          total_quantity AS totalQuantity,
          total_amount   AS totalAmount,
          payment_method AS paymentMethod,
          payment_status AS paymentStatus,
          status,
          tracking_no    AS trackingNo,
          carrier,
          shipped_at     AS shippedAt,
          delivered_at   AS deliveredAt,
          created_at     AS createdAt,
          updated_at     AS updatedAt
        FROM seller_shipments
        WHERE seller_id = #{sellerId}
        ORDER BY created_at DESC
        """)
    List<SellerShipment> findBySellerId(@Param("sellerId") String sellerId);

    // 3) 특정 주문+판매자 단건 조회
    @Select("""
        SELECT
          id,
          order_number   AS orderNumber,
          seller_id      AS sellerId,
          receiver_name  AS receiverName,
          phone,
          address,
          total_quantity AS totalQuantity,
          total_amount   AS totalAmount,
          payment_method AS paymentMethod,
          payment_status AS paymentStatus,
          status,
          tracking_no    AS trackingNo,
          carrier,
          shipped_at     AS shippedAt,
          delivered_at   AS deliveredAt,
          created_at     AS createdAt,
          updated_at     AS UpdatedAt
        FROM seller_shipments
        WHERE order_number = #{orderNumber}
          AND seller_id    = #{sellerId}
        """)
    SellerShipment findOne(@Param("orderNumber") String orderNumber,
                           @Param("sellerId") String sellerId);

    // 4) 운송장번호/상태 갱신
    @Update("""
        UPDATE seller_shipments
        SET tracking_no = #{trackingNo},
            carrier     = #{carrier},
            status      = #{status},
            shipped_at  = #{shippedAt},
            delivered_at= #{deliveredAt},
            updated_at  = CURRENT_TIMESTAMP
        WHERE order_number = #{orderNumber}
          AND seller_id    = #{sellerId}
        """)
    int updateTrackingAndStatus(SellerShipmentUpdateRequest req);

    // 5) 상태만 간단 변경
    @Update("""
        UPDATE seller_shipments
        SET status = #{status},
            updated_at = CURRENT_TIMESTAMP
        WHERE order_number = #{orderNumber}
          AND seller_id    = #{sellerId}
        """)
    int updateStatus(@Param("orderNumber") String orderNumber,
                     @Param("sellerId") String sellerId,
                     @Param("status") String status);

    // 6) 스냅샷 집계 대상 조회 (원본 조인)
    @Select("""
    SELECT
      o.order_number                       AS orderNumber,
      oi.seller_id                         AS sellerId,
    
      COALESCE(g.guest_name, u.name)       AS receiverName,
      g.guest_phone                        AS phone,
      COALESCE(g.guest_address, u.address) AS address,
    
      SUM(oi.quantity)                     AS totalQuantity,
      SUM(oi.quantity * oi.price)          AS totalAmount,
    
      pay.payment_method                   AS paymentMethod,
      pay.payment_status                   AS paymentStatus,
    
      COALESCE(o.status, g.status, '배송 전') AS status,
    
      NULL AS trackingNo,
      NULL AS carrier,
      NULL AS shippedAt,
      NULL AS deliveredAt,
      NULL AS createdAt,
      NULL AS updatedAt
    
    FROM
    (
      SELECT
        pr.order_number,
        p.writer       AS seller_id,
        pr.product_id  AS product_id,
        pr.quantity    AS quantity,
        p.price        AS price
      FROM PurchaseRecords pr
      JOIN product p ON p.id = pr.product_id
      WHERE pr.product_id IS NOT NULL
    
      UNION ALL
    
      SELECT
        pr.order_number,
        p.writer        AS seller_id,
        c.productid     AS product_id,
        c.`count`       AS quantity,
        p.price         AS price
      FROM PurchaseRecords pr
      JOIN cart c ON pr.cartids IS NOT NULL
                 AND pr.cartids <> ''
                 AND FIND_IN_SET(c.id, pr.cartids) > 0
      JOIN product p ON p.id = c.productid
    ) oi
    JOIN PurchaseRecords o             ON o.order_number = oi.order_number
    LEFT JOIN `user` u                 ON u.userid       = o.userid
    LEFT JOIN GuestPurchaseRecords g   ON g.order_number = o.order_number
    LEFT JOIN PaymentRecords pay       ON pay.order_number = o.order_number
    
    WHERE
      (#{sellerId} IS NULL OR oi.seller_id = #{sellerId})
      AND (#{from}   IS NULL OR o.created_at >= #{from})
      AND (#{to}     IS NULL OR o.created_at <  #{to})
      AND (
            #{status} IS NULL OR #{status} = ''
            OR COALESCE(o.status, g.status, '배송 전') = #{status}
          )
      AND (
            #{q} IS NULL OR #{q} = ''
            OR (
              o.order_number = #{q}
              OR COALESCE(g.guest_name, u.name)       LIKE CONCAT('%', #{q}, '%')
              OR COALESCE(g.guest_address, u.address) LIKE CONCAT('%', #{q}, '%')
              OR g.guest_phone                        LIKE CONCAT('%', #{q}, '%')
            )
          )
    
    GROUP BY
      o.order_number, oi.seller_id,
      receiverName, phone, address,
      pay.payment_method, pay.payment_status,
      status
    
    ORDER BY o.created_at DESC
    """)
    List<SellerShipment> selectForConsolidation(
            @Param("sellerId") String sellerId,
            @Param("from") LocalDateTime from,
            @Param("to") LocalDateTime to,
            @Param("status") String status,
            @Param("q") String q
    );


    // 7) 주문번호로 모든 판매자 스냅샷 조회 (비회원/고객 배송조회용)
    @Select("""
      SELECT
        id,
        order_number   AS orderNumber,
        seller_id      AS sellerId,
        receiver_name  AS receiverName,
        phone,
        address,
        total_quantity AS totalQuantity,
        total_amount   AS totalAmount,
        payment_method AS paymentMethod,
        payment_status AS paymentStatus,
        status,
        tracking_no    AS trackingNo,
        carrier,
        shipped_at     AS shippedAt,
        delivered_at   AS deliveredAt,
        created_at     AS createdAt,
        updated_at     AS updatedAt
      FROM seller_shipments
      WHERE order_number = #{orderNumber}
      ORDER BY seller_id
    """)
    List<SellerShipment> findByOrderNumber(@Param("orderNumber") String orderNumber);
}
