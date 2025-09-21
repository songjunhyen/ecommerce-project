package com.example.demo.vo;

import java.time.LocalDateTime;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Review {
	private int id;              // 리뷰 id
	private int productId;       // 상품 id (DB: productid)
	private String writer;       // 작성자
	private LocalDateTime regDate; // 작성일 (DB: DATETIME)
	private String reviewText;   // 리뷰 텍스트 (DB: reviewtext)
	private double star;         // 별점 (1~5, 소수점 허용)
}
