package com.example.demo.vo;

import java.time.LocalDateTime;
import lombok.Data;

@Data
public class PurchaseInfo {
    private String orderNumber;
    private String userid;
    private String cartids;      // 장바구니 ID (회원 구매용)
    private int productid;
    private String productids;   // 복수 제품 ID
    private String productname;
    private String sizecolor;    // DB 컬럼 optionin 과 매칭됨
    private int price;
    private LocalDateTime requestDate;
    private int quantity;        // 수량
    private String email;        // 사용자 이메일 (서비스에서 채움)

    // phone, address는 PaymentRecords 전용이라면 PaymentInfo로 옮기는 게 더 적절합니다.
}
