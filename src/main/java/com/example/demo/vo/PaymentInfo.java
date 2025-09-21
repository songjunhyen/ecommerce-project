package com.example.demo.vo;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import lombok.Data;

@Data
public class PaymentInfo {
    private String impUid;            // imp_uid (컬럼 추가 시 사용) - 카멜케이스 사용
    private String orderNumber;       // order_number
    private BigDecimal price;         // DECIMAL(10,2) → BigDecimal 권장
    private String paymentMethod;     // payment_method
    private String paymentStatus;     // payment_status (대문자 사용 권장: PENDING/COMPLETED)
    private LocalDateTime paymentDate;// payment_date

    // 아래는 결제레코드가 아닌 주문/검증 입력값이면 별도 DTO로 분리 권장
    private String phone;             // ❗ PaymentRecords에 없음
    private String address;           // ❗ PaymentRecords에 없음
}
