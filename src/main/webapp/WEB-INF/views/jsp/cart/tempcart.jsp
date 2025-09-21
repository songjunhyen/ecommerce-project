<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
    import="java.util.List, com.example.demo.vo.CartItem" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>장바구니 목록</title>
<script src="https://code.jquery.com/jquery-3.6.4.min.js"></script>
<meta name="_csrf" content="${_csrf.token}">
<meta name="_csrf_header" content="${_csrf.headerName}">

<style>
  /* sticky footer 기본 레이아웃 */
  html, body { height:100%; }
  body {
    min-height:100dvh; /* 100vh 써도 됨 */
    display:flex; flex-direction:column;
    margin:0;
  }
  /* 본문 영역이 남는 공간을 차지 -> 푸터를 아래로 밀어냄 */
  main#page { flex:1 0 auto; }

  /* 페이지 자체 스타일 */
  #cartPage .container { max-width: 1000px; margin: 0 auto; padding: 16px; }
  #cartPage table { width:100%; border-collapse:collapse; }
  #cartPage th, #cartPage td { border:1px solid #ddd; padding:8px; text-align:center; }
  #cartPage th { background:#f4f4f4; }
  #cartPage button { padding:5px 10px; margin:5px; cursor:pointer; }
  /* 모달 간단 스타일 */
  #emailPhoneModal { display:none; }
</style>

<%
String sizeColors = "";
String productIds = "";
int totalPrice = 0;
List<CartItem> cartList = (List<CartItem>) request.getAttribute("carts");
if (cartList != null && !cartList.isEmpty()) {
    for (CartItem cart : cartList) {
        totalPrice += cart.getPrice() * cart.getCount();
        sizeColors += cart.getSize() + "-" + cart.getColor() + ";"; // 하이픈으로 구분 권장
        productIds += cart.getProductid() + ";";
    }
}
%>

<script>
var csrfToken, csrfHeader;
var sizeColors, productIds;
var totalPrice = <%= totalPrice %>;

$(function() {
  csrfToken = $('meta[name="_csrf"]').attr('content');
  csrfHeader = $('meta[name="_csrf_header"]').attr('content');

  $("#buybutton").on("click", function(e){
    e.preventDefault();
    $("#emailPhoneModal").show();
  });

  $("#submitEmailPhone").on("click", function(){
    var email = $("#email").val();
    var phonenum = $("#phonenum").val();
    buybutton(email, phonenum);
  });

  $("#closeModal").on("click", function(){ $("#emailPhoneModal").hide(); });

  <%-- JS에 배열로 전달 --%>
  <%
    StringBuilder sizeColorsString = new StringBuilder();
    List<CartItem> carts = (List<CartItem>) request.getAttribute("carts");
    if (carts != null) {
      for (CartItem cart : carts) {
        sizeColorsString.append(cart.getSize()).append("-").append(cart.getColor()).append(";");
      }
    }
  %>
  sizeColors = "<%= sizeColorsString.toString() %>".split(";").filter(Boolean);
  productIds = "<%= productIds %>".split(";").filter(Boolean);
});

function buybutton(email, phonenum) {
  $.ajax({
    url: '../buying',
    type: 'POST',
    data: {
      email: email,
      phonenum: phonenum,
      productIds: JSON.stringify(productIds),
      sizeColors: JSON.stringify(sizeColors),
      priceall: totalPrice
    },
    beforeSend: function(xhr){
      if (csrfToken && csrfHeader) xhr.setRequestHeader(csrfHeader, csrfToken);
    },
    success: function(){
      $("#emailPhoneModal").hide();
      window.location.href = "/confirmation";
    },
    error: function(e){ console.error(e); }
  });
}
</script>
</head>

<body>
  <%-- ✅ 헤더 include는 반드시 body 안쪽에 --%>
  <%@ include file="../includes/head1.jsp"%>

  <main id="page">
    <div id="cartPage">
      <div class="container">
        <div id="cartListContainer">
          <table>
            <thead>
              <tr>
                <th>번호</th>
                <th>제품명</th>
                <th>수량</th>
                <th>금액</th>
                <th>색상</th>
                <th>사이즈</th>
                <th>삭제</th>
              </tr>
            </thead>
            <tbody>
              <c:forEach var="cart" items="${carts}">
                <tr>
                  <td>${cart.productid}</td>
                  <td>${cart.name}</td>
                  <td>
                    <form action="/Temporarily/Cart/Modify" method="post">
                      <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                      <input type="hidden" name="productid" value="${cart.productid}">
                      <input type="hidden" name="color" value="${cart.color}">
                      <input type="hidden" name="size"  value="${cart.size}">
                      <input type="number" name="count" step="1" min="1" max="100" value="${cart.count}">
                      <input type="hidden" name="price" value="${cart.price}">
                      <button type="submit">수정</button>
                    </form>
                  </td>
                  <td>${cart.price * cart.count}</td>
                  <td>${cart.color}</td>
                  <td>${cart.size}</td>
                  <td>
                    <form action="/Temporarily/Cart/Delete" method="post">
                      <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                      <input type="hidden" name="productid" value="${cart.productid}">
                      <input type="hidden" name="color" value="${cart.color}">
                      <input type="hidden" name="size"  value="${cart.size}">
                      <button type="submit">삭제</button>
                    </form>
                  </td>
                </tr>
              </c:forEach>
            </tbody>
          </table>
        </div>

        <!-- 비회원 구매 모달 -->
        <div id="emailPhoneModal">
          <div style="position: fixed; top: 50%; left: 50%; transform: translate(-50%, -50%);
                      background: white; padding: 20px; border: 1px solid #ddd;">
            <h3>이메일 및 전화번호 입력</h3>
            <label for="email">이메일:</label>
            <input type="email" id="email" name="email" required><br><br>
            <label for="phonenum">전화번호:</label>
            <input type="text" id="phonenum" name="phonenum" required><br><br>
            <button id="submitEmailPhone">확인</button>
            <button id="closeModal">취소</button>
          </div>
        </div>

        <div style="margin-top:12px;">
          금액 : <strong><%= totalPrice %></strong> 원<br>
          <button id="buybutton">구매하기</button>
        </div>
      </div>
    </div>
  </main>

  <%-- ✅ 푸터 include는 body 맨 끝, sticky 는 body flex로 해결 --%>
  <%@ include file="../includes/foot1.jsp"%>
</body>
</html>
