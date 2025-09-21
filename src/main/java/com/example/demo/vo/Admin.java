package com.example.demo.vo;

import java.time.LocalDateTime;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data
@NoArgsConstructor  // MyBatis/JPA용
@AllArgsConstructor // 필요 시 전체 생성자
public class Admin {
    private int id;
    private String adminId;
    private String adminPw;
    private String name;
    private String email;
    private int adminclass = 1;
    private LocalDateTime regDate;

    public Admin(String adminId, String adminPw, String name, String email) {
        this.adminId = adminId;
        this.adminPw = adminPw;
        this.name = name;
        this.email = email;
        this.regDate = LocalDateTime.now();
    }
}
