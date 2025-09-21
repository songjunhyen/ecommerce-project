package com.example.demo.vo;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Category {
	private int categoryId;       // PK
	private String categoryName;  // 카테고리 이름
	private Integer parentId;     // 상위 카테고리 ID (self-reference)
	private String description;   // 카테고리 설명

	public Category(String categoryName, Integer parentId, String description) {
		this.categoryName = categoryName;
		this.parentId = parentId;
		this.description = description;
	}
}
