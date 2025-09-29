<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>비회원 주문/배송 조회</title>
  <style>
    .wrap{max-width:520px;margin:40px auto;padding:24px;border:1px solid #eee;border-radius:12px}
    .row{margin-bottom:12px}
    label{display:block;font-weight:600;margin-bottom:6px}
    input{width:100%;padding:10px;border:1px solid #ddd;border-radius:8px}
    .btn{width:100%;padding:12px;border:0;border-radius:10px;background:#111;color:#fff;cursor:pointer}
    .err{color:#c00;margin:8px 0 0 0}
    .hint{color:#666;font-size:12px;margin-top:6px}
  </style>
</head>
<body>
  <div class="wrap">
    <h2>비회원 주문/배송 조회</h2>

    <c:if test="${not empty error}">
      <p class="err">${error}</p>
    </c:if>

    <form method="post" action="<c:url value='/track'/>">
      <div class="row">
        <label for="orderNumber">주문번호</label>
        <input id="orderNumber" name="orderNumber" placeholder="예) 1234-xxxxxxxx..." required>
      </div>
      <div class="row">
        <label for="email">이메일</label>
        <input id="email" name="email" type="email" placeholder="you@example.com" required>
      </div>
      <div class="row">
        <label for="phone">휴대폰</label>
        <input id="phone" name="phone" placeholder="010-1234-5678" required>
        <p class="hint">주문 시 입력한 이메일·휴대폰이 일치해야 조회됩니다.</p>
      </div>
      <button class="btn" type="submit">조회하기</button>
    </form>
  </div>
</body>
</html>
