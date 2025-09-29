package com.example.demo.service;

import com.example.demo.dao.SellerShipmentDao;
import com.example.demo.vo.SellerShipment;
import com.example.demo.vo.SellerShipmentSearchRequest;
import com.example.demo.vo.SellerShipmentUpdateRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

@Service
public class SellerShipmentService {

    private final SellerShipmentDao dao;

    // 명시적 생성자 주입
    public SellerShipmentService(SellerShipmentDao dao) {
        this.dao = dao;
    }

    /**
     * 조회(집계) 버튼 액션:
     * - 주문 원본(orders/order_items/user/guest/payment) → 판매자별 스냅샷(seller_shipments) upsert
     * - 운송장/택배사/시각은 판매자 입력 보존을 위해 null로 세팅하여 COALESCE가 기존값 유지
     */
    @Transactional
    public int consolidateSnapshots(SellerShipmentSearchRequest req) {
        LocalDateTime from = req.getFrom() != null ? req.getFrom().atStartOfDay() : null;
        LocalDateTime to   = req.getTo()   != null ? req.getTo().plusDays(1).atStartOfDay() : null;

        var rows = dao.selectForConsolidation(
                req.getSellerId(), from, to, req.getStatus(), req.getQ());

        int affected = 0;
        for (SellerShipment r : rows) {
            // ▼ 판매자 입력 보존: null로 넣어 COALESCE(VALUES(x), x)에서 기존값 유지
            r.setTrackingNo(null);
            r.setCarrier(null);
            r.setShippedAt(null);
            r.setDeliveredAt(null);
            affected += dao.upsert(r);
        }
        return affected;
    }

    /**
     * 스냅샷 목록 조회(판매자 전용)
     * - 간단한 필터/정렬/페이징은 메모리 처리
     * - 대용량이면 DAO에 동적 페이징 쿼리로 확장 권장
     */
    @Transactional(readOnly = true)
    public List<SellerShipment> list(SellerShipmentSearchRequest req) {
        List<SellerShipment> all = dao.findBySellerId(req.getSellerId());

        LocalDateTime from = req.getFrom() != null ? req.getFrom().atStartOfDay() : null;
        LocalDateTime to   = req.getTo()   != null ? req.getTo().plusDays(1).atStartOfDay() : null;

        var filtered = all.stream()
                .filter(s -> req.getStatus() == null || req.getStatus().isBlank()
                        || req.getStatus().equals(s.getStatus()))
                .filter(s -> from == null || (s.getCreatedAt() != null && !s.getCreatedAt().isBefore(from)))
                .filter(s -> to   == null || (s.getCreatedAt() != null && s.getCreatedAt().isBefore(to)))
                .filter(s -> {
                    String q = req.getQ();
                    if (q == null || q.isBlank()) return true;
                    return containsIgnoreCase(s.getOrderNumber(), q)
                            || containsIgnoreCase(s.getReceiverName(), q)
                            || containsIgnoreCase(s.getPhone(), q)
                            || containsIgnoreCase(s.getAddress(), q);
                })
                .sorted(Comparator
                        .comparing(SellerShipment::getCreatedAt, Comparator.nullsLast(Comparator.reverseOrder()))
                        .thenComparing(SellerShipment::getId, Comparator.nullsLast(Comparator.reverseOrder()))
                )
                .collect(Collectors.toList());

        int page = Math.max(req.getPage(), 0);
        int size = req.getSize() > 0 ? req.getSize() : 20;
        int fromIdx = Math.min(page * size, filtered.size());
        int toIdx   = Math.min(fromIdx + size, filtered.size());
        return filtered.subList(fromIdx, toIdx);
    }

    /** 단건 상세(주문번호+판매자) */
    @Transactional(readOnly = true)
    public SellerShipment getOne(String orderNumber, String sellerId) {
        return dao.findOne(orderNumber, sellerId);
    }

    /**
     * 운송장/상태 업데이트
     * - "배송중" 최초 전환 시 shippedAt 자동 세팅
     * - "배송완료/DELIVERED" 전환 시 deliveredAt 자동 세팅
     */
    @Transactional
    public void updateTrackingAndStatus(SellerShipmentUpdateRequest req) {
        LocalDateTime now = LocalDateTime.now();
        String status = req.getStatus();

        if (status != null) {
            if (status.contains("배송중") && req.getShippedAt() == null) {
                req.setShippedAt(now);
            }
            if ((status.contains("완료") || "DELIVERED".equalsIgnoreCase(status))
                    && req.getDeliveredAt() == null) {
                req.setDeliveredAt(now);
            }
        }
        dao.updateTrackingAndStatus(req);
    }

    /** 상태만 간단 변경 */
    @Transactional
    public void updateStatus(String orderNumber, String sellerId, String status) {
        dao.updateStatus(orderNumber, sellerId, status);
    }

    /**
     * 특정 주문만 재집계 후 단건 반환
     * - 상세 화면 "새로고침" 같은 액션에 유용
     */
    @Transactional
    public SellerShipment consolidateOneOrder(String orderNumber, String sellerId) {
        var rows = dao.selectForConsolidation(
                sellerId, null, null, null, orderNumber);

        rows.removeIf(r -> !Objects.equals(orderNumber, r.getOrderNumber()));

        for (SellerShipment r : rows) {
            // 덮어쓰기 방지
            r.setTrackingNo(null);
            r.setCarrier(null);
            r.setShippedAt(null);
            r.setDeliveredAt(null);
            dao.upsert(r);
        }
        return dao.findOne(orderNumber, sellerId);
    }

    /**
     * 고객/비회원 배송조회용: 주문번호로 모든 판매자 스냅샷 반환
     * - 컨트롤러에서 주문자 인증(회원: 세션, 비회원: 이메일+휴대폰) 후 호출 권장
     */
    @Transactional(readOnly = true)
    public List<SellerShipment> findByOrderNumber(String orderNumber) {
        return dao.findByOrderNumber(orderNumber);
    }

    // ---- helpers ----
    private boolean containsIgnoreCase(String src, String q) {
        return src != null && q != null && src.toLowerCase().contains(q.toLowerCase());
    }

    public int snapshotFromOrder(String orderNumber) {
        var rows = dao.selectForConsolidation(
                null,  // ✅ sellerId 없음
                null,  // from
                null,  // to
                null,  // status
                orderNumber // q에 주문번호 전달 (매퍼에서 order_number = q 조건 처리)
        );

        int affected = 0;
        for (SellerShipment r : rows) {
            // 판매자 입력 보존
            r.setTrackingNo(null);
            r.setCarrier(null);
            r.setShippedAt(null);
            r.setDeliveredAt(null);
            affected += dao.upsert(r);
        }
        return affected;
    }
}
