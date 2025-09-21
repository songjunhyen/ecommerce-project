package com.example.demo.vo;

import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class CartItem {
    // member 장바구니 쿼리(id, userid …)도 커버되도록 확장
    private Integer id;        // cart.id (선택)
    private String  userid;    // cart.userid (선택)

    private Integer productid;
    private String  name;      // 화면에서 사용하는 이름 필드
    private String  color;
    private String  size;
    private Integer count;
    private Integer price;
    private Integer priceall;  // cart.priceall(계산컬럼) 있을 때 받기(선택)

    public CartItem(int productid, String name, String color, String size, int count, int price) {
        this.productid = productid;
        this.name = name;
        this.color = color;
        this.size = size;
        this.count = count;
        this.price = price;
    }

    public void setProductname(String productname) {
        this.name = productname;
    }

    // 편의: priceall이 없으면 계산해서 반환하고 싶을 때 사용할 수 있음(선택)
    public int getTotalPrice() {
        if (priceall != null) return priceall;
        if (price != null && count != null) return price * count;
        return 0;
    }
}
