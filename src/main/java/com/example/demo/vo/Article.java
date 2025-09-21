package com.example.demo.vo;

import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.Builder;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Article {
    private Long id;                 // PK (DB: INT UNSIGNED → 매핑 OK)
    private String title;            // 제목 (DB: VARCHAR)
    private String body;             // 본문 (DB: TEXT)
    private String writerId;         // 작성자 ID (DB: writer_id)
    private LocalDateTime regDate;   // 등록일 (DB: DATETIME)
    private LocalDateTime updateDate;// 수정일 (DB: DATETIME)
    private int viewCount;           // 조회수 (DB: viewcount)

    // 글 작성 시 사용하는 보조 생성자
    public Article(String title, String body, String writerId) {
        this.title = title;
        this.body = body;
        this.writerId = writerId;
        this.regDate = LocalDateTime.now();
        this.updateDate = LocalDateTime.now();
        this.viewCount = 0;
    }
}

