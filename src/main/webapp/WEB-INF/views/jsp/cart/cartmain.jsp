<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"
    import="java.util.List, com.example.demo.vo.Cart" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>장바구니</title>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<meta name="_csrf" content="${_csrf.token}">
<meta name="_csrf_header" content="${_csrf.headerName}">

<%
    String userId    = "";
    String cartIds   = "";
    String sizeColors= "";
    int totalPrice   = 0;

    List<Cart> cartList = (List<Cart>) request.getAttribute("carts");
    if (cartList != null && !cartList.isEmpty()) {
        userId = cartList.get(0).getUserid();
        for (Cart cart : cartList) {
            totalPrice += cart.getPriceall();
            cartIds    += cart.getId() + ",";
            sizeColors += cart.getSize() + "_" + cart.getColor() + "_" + cart.getCount() + ";";
        }
    }
%>

<script>
  var csrfToken  = null;
  var csrfHeader = null;

  var userid     = "<%= userId %>";
  var cartIds    = "<%= cartIds %>".split(",").filter(Boolean);
  var sizeColors = "<%= sizeColors %>".split(";").filter(Boolean);
  var totalPrice = <%= totalPrice %>;

  $(function() {
    csrfToken  = $('meta[name="_csrf"]').attr('content');
    csrfHeader = $('meta[name="_csrf_header"]').attr('content');

    $("#buybutton").on("click", function(e){
      e.preventDefault();
      buybutton();
    });
  });

  function loadCartList() {
    $.ajax({
      url: '/Cart/List',
      type: 'GET',
      success: function(html) { $('#cartListContainer').html(html); },
      error: function(err){ console.error(err); }
    });
  }

  function submitModifyForm(form) {
    $.ajax({
      url: form.action,
      type: form.method,
      data: $(form).serialize(),
      success: function(){ loadCartList(); },
      error: function(err){ console.error(err); }
    });
    return false;
  }

  function submitDeleteForm(form) {
    $.ajax({
      url: form.action,
      type: form.method,
      data: $(form).serialize(),
      success: function(){ loadCartList(); },
      error: function(err){ console.error(err); }
    });
    return false;
  }

  function buybutton() {
    $.ajax({
      url: '../buying',
      type: 'POST',
      data: {
        userid: userid,
        cartIds: JSON.stringify(cartIds),
        sizeColors: JSON.stringify(sizeColors),
        priceall: totalPrice
      },
      beforeSend: function(xhr){
        if (csrfToken && csrfHeader) xhr.setRequestHeader(csrfHeader, csrfToken);
      },
      success: function(){
        window.location.href = '/confirmation';
      },
      error: function(e){
        console.error("결제 요청 중 오류:", e);
      }
    });
  }
</script>

<style>
  :root {
    --footer-h: 60px; /* foot1.jsp가 fixed(60px)면 여백 보장 */
  }

  /* 전역 충돌 방지: 페이지 범위 한정 */
  #cartPage {
    max-width: 1200px;
    margin: 0 auto;
    padding: 16px;
    padding-bottom: calc(var(--footer-h) + 16px); /* 고정 푸터 가림 방지 */
    /* 헤더가 fixed라면 주석 해제하고 값 맞춰 주세요 */
    /* margin-top: 60px; */
  }

  #cartPage table {
    width: 100%;
    border-collapse: collapse;
  }
  #cartPage th, #cartPage td {
    border: 1px solid #ddd;
    padding: 8px;
    text-align: left;
  }
  #cartPage th {
    background: #f4f4f4;
  }

  #cartPage .btn {
    background: #4CAF50;
    color: #fff;
    border: none;
    padding: 10px 14px;
    font-size: 14px;
    cursor: pointer;
  }
  #cartPage .btn:hover {
    background: #45a049;
  }

  /* 셀렉트/인풋도 페이지 내부로만 */
  #cartPage select,
  #cartPage input[type="number"] {
    padding: 6px 8px;
    border: 1px solid #ddd;
    border-radius: 6px;
  }

  /* 액션 버튼 묶음 */
  #cartPage .actions {
    margin-top: 12px;
  }
</style>
</head>

<body class="layout-sticky">
  <%@ include file="../includes/head1.jsp"%>
 <main id="page">
  <div id="cartPage">
    <div id="cartListContainer">
      <table>
        <thead>
          <tr>
            <th>제품명</th>
            <th>수량</th>
            <th>금액</th>
            <th>색상</th>
            <th>사이즈</th>
            <th>수정</th>
            <th>삭제</th>
          </tr>
        </thead>
        <tbody>
          <c:forEach var="cart" items="${carts}">
            <tr>
              <td>${cart.productname}</td>
              <td>${cart.count}</td>
              <td>${cart.priceall}</td>
              <td>${cart.color}</td>
              <td>${cart.size}</td>
              <td>
                <form onsubmit="return submitModifyForm(this)" action="/Cart/Modify" method="post">
                  <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                  <input type="hidden" name="id" value="${cart.id}">
                  <input type="hidden" name="productid" value="${cart.productid}">
                  <input type="hidden" name="price" value="${cart.price}">
                  <input type="hidden" name="productname" value="${cart.productname}">
                  <input type="hidden" name="a_size" value="${cart.size}">
                  <input type="hidden" name="a_color" value="${cart.color}">

                  <select name="size">
                    <option value="xs">XS</option>
                    <option value="s">S</option>
                    <option value="m">M</option>
                    <option value="l">L</option>
                    <option value="xl">XL</option>
                  </select>

                  <select name="color">
                    <option value="Red">Red</option>
                    <option value="Black">Black</option>
                    <option value="White">White</option>
                    <option value="Blue">Blue</option>
                  </select>

                  <input type="number" name="count" step="1" min="1" max="100" value="${cart.count}">
                  <button type="submit" class="btn">수정</button>
                </form>
              </td>
              <td>
                <form onsubmit="return submitDeleteForm(this)" action="/Cart/Delete" method="post">
                  <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                  <input type="hidden" name="id" value="${cart.id}">
                  <input type="hidden" name="productid" value="${cart.productid}">
                  <input type="hidden" name="size" value="${cart.size}">
                  <input type="hidden" name="color" value="${cart.color}">
                  <button type="submit" class="btn">삭제</button>
                </form>
              </td>
            </tr>
          </c:forEach>
        </tbody>
      </table>
    </div>

    <div class="actions">
      금액 : <strong><%= totalPrice %></strong> 원
      <br>
      <button id="buybutton" class="btn">구매하기</button>
    </div>
  </div>
</main>
  <%@ include file="../includes/foot1.jsp"%>
</body>
</html>
