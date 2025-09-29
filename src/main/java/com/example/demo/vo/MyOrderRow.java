package com.example.demo.vo;

import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class MyOrderRow {
    private String orderNumber;
    private String productname;
    private Integer quantity;
    private BigDecimal price;
    private String status;
    private LocalDateTime createdAt;
}