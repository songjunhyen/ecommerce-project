package com.example.demo.vo;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import lombok.Data;

@Data
public class PurchaseInfo {
    private String orderNumber;

    private String userid;

    // 단건 결제일 때만 사용 (nullable)
    private Integer productid;

    // 장바구니/복수 결제일 때 사용 (콤마 구분 문자열 저장을 계속 쓴다면 유지)
    private String productids;

    // UI·영수증 표시용 제목(예: "티셔츠 외 3개")
    private String productname;

    /** 단건일 때 옵션값 (예: "M-Black") */
    private String sizecolor;

    /** 복수 옵션일 때(장바구니) 원본 그대로 보존 (예: "M-Black;L-White;...") */
    private String sizecolors;  // 🔸신규

    /** 총 수량 (단건이면 count, 복수면 모든 라인 합계) */
    private Integer quantity;   // primitive → 래퍼로 변경

    /** 총 금액 */
    private BigDecimal price;   // int → BigDecimal

    private LocalDateTime requestDate;

    private String cartids;     // 장바구니 ID 묶음(회원 전용)

    private String email;       // 서버에서 채움
}