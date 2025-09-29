package com.example.demo.vo;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import lombok.Data;

@Data
public class NonMemberPurchaseInfo {
    private String orderNumber;

    // 단건
    private Integer productid;   // int → Integer

    // 복수(장바구니 유사)
    private String productids;   // 컨트롤러/서비스에서 콤마 구분으로 유지 시

    // UI 표시용 제목
    private String productname;

    /** 단건 옵션 */
    private String sizecolor;

    /** 복수 옵션 원본 */
    private String sizecolors;   // 🔸신규

    /** 총 수량 */
    private Integer quantity;    // int → Integer

    /** 총 금액 */
    private BigDecimal price;    // int → BigDecimal

    private LocalDateTime requestDate;

    // 게스트 정보
    private String guestName;     // 모달에서 별도 받거나 null 허용
    private String email;         // guest_email
    private String phonenum;      // guest_phone
    private String guestAddress;  // guest_address
}
