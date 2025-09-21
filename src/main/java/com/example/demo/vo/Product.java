package com.example.demo.vo;

import java.time.LocalDateTime;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Product {
	private int id;                 // PK (AUTO_INCREMENT)
	private String writer;          // 작성자(userid)
	private String name;
	private int price;
	private String description;     // 설명
	private String imageUrl;        // 이미지 경로(콤마 구분 문자열 가능)
	private int count;              // 재고량
	private String category;        // 카테고리
	private String maker;           // 제조사
	private String color;
	private String size;
	private String additionalOptions;
	private LocalDateTime regDate;  // DB: DATETIME
	private int viewcount;

	// 기존 코드에 있던 편의 생성자 유지 (필요 시 사용)
	public Product(int id, String writer, String name, int price, String description, String imageUrl,
				   int count, String category, String maker, String color, String size, String additionalOptions) {
		this.id = id;
		this.writer = writer;
		this.name = name;
		this.price = price;
		this.description = description;
		this.imageUrl = imageUrl;
		this.count = count;
		this.category = category;
		this.maker = maker;
		this.color = color;
		this.size = size;
		this.additionalOptions = additionalOptions;
		this.regDate = LocalDateTime.now(); // DATETIME과 호환
		this.viewcount = 0;
	}
}
