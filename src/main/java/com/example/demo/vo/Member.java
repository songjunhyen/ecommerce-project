package com.example.demo.vo;

import java.time.LocalDateTime;
import java.util.List;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Member {
  private int id;                     // PK
  private LocalDateTime regDate;      // 가입일 (DATETIME → LocalDateTime)
  private String userid;              // 아이디
  private String userpw;              // 비밀번호 (암호화 저장)
  private String name;                // 이름
  private String email;               // 이메일
  private String address;             // 주소
  private int memberClass;            // 회원 구분 (일반=0, 관리자=1 …)
  private List<Product> products;     // 구매/작성한 상품 (관계 매핑 필요)

  // 회원 가입 시 사용할 생성자
  public Member(String userid, String userpw, String name, String email, String address) {
    this.userid = userid;
    this.userpw = userpw;
    this.name = name;
    this.email = email;
    this.address = address;
    this.regDate = LocalDateTime.now();
    this.memberClass = 0; // 기본 회원 등급
  }
}
