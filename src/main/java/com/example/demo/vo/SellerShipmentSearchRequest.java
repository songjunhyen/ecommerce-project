package com.example.demo.vo;

import java.time.LocalDate;
import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SellerShipmentSearchRequest {
    private String sellerId;          // 필수: 로그인한 판매자
    private String status;            // 선택: "배송 전" 등
    private String q;                 // 선택: 주문번호/수취인/전화 등 검색어
    private LocalDate from;           // 선택: 시작일
    private LocalDate to;             // 선택: 종료일(미포함)
    private int page;                 // 페이징
    private int size;                 // 페이징
}