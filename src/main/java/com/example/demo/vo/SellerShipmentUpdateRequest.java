package com.example.demo.vo;

import java.time.LocalDateTime;
import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SellerShipmentUpdateRequest {
    private String orderNumber;       // 어떤 주문의
    private String sellerId;          // 어떤 판매자의 (복합키)
    private String trackingNo;        // 운송장번호(등록/수정)
    private String carrier;           // 택배사
    private String status;            // "배송중"/"배송완료"/"반품요청" 등 문자열
    private LocalDateTime shippedAt;  // 옵션: 수동 세팅 시
    private LocalDateTime deliveredAt;// 옵션: 수동 세팅 시
}