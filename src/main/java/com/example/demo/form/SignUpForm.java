package com.example.demo.form;

import lombok.Data;

@Data
public class SignUpForm {
    private String userid;
    private String pw;
    private String name;
    private String email;

    // JSP의 name/path와 동일해야 합니다.
    private String postcode;        // name="postcode"
    private String frontaddress;    // name="frontaddress"  (전부 소문자!)
    private String detailAddress;   // name="detailAddress"
    private String address;         // hidden address

    // ★ _csrf는 DTO에 넣지 마세요
}
