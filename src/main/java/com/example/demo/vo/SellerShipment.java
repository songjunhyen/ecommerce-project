package com.example.demo.vo;

import java.time.LocalDateTime;
import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SellerShipment {
    private Long id;

    private String orderNumber;     // order_number
    private String sellerId;        // seller_id

    private String receiverName;    // receiver_name
    private String phone;           // phone (회원 주문이면 null 가능)
    private String address;         // address (회원: user.address / 비회원: guest_address)

    private Integer totalQuantity;  // total_quantity
    private Integer totalAmount;    // total_amount

    private String paymentMethod;   // payment_method
    private String paymentStatus;   // payment_status

    private String status;          // status ("배송 전"/"배송중"/"배송완료"/"반품요청"...)

    private String trackingNo;      // tracking_no (판매자 입력)
    private String carrier;         // carrier     (판매자 입력)
    private LocalDateTime shippedAt;      // shipped_at
    private LocalDateTime deliveredAt;    // delivered_at

    private LocalDateTime createdAt;      // created_at
    private LocalDateTime updatedAt;      // updated_at
}