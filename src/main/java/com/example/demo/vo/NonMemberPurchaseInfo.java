package com.example.demo.vo;

import java.time.LocalDateTime;

import lombok.Data;

@Data
public class NonMemberPurchaseInfo {
    private String orderNumber;   // order_number
    private int productid;        // product_id
    private int quantity;         // quantity
    private String sizecolor;     // optionin
    private LocalDateTime requestDate; // created_at
    private String guestName;     // guest_name
    private String email;         // guest_email
    private String phonenum;      // guest_phone
    private String guestAddress;  // guest_address

    // ⚠️ DB에는 없지만 서비스/컨트롤러에서 사용하는 임시 필드
    private String productids;    // 장바구니 여러 상품 처리용
    private String productname;   // UI 표시용
    private int price;            // 결제 금액 (PaymentRecords와 매핑 필요)
}
