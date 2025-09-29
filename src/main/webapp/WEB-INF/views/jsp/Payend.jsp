<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>결제완료</title>
  <style>
    body { font-family: system-ui, sans-serif; max-width: 820px; margin: 32px auto; }
    .box { border:1px solid #e5e7eb; border-radius:8px; padding:16px; margin-bottom:16px; }
    .muted { color:#6b7280; font-size:14px; }
    .btn {
      padding: 10px 20px;
      border: none;
      border-radius: 6px;
      font-size: 15px;
      cursor: pointer;
      margin: 0 6px;
    }
    .btn-primary {
      background-color: #2563eb;
      color: white;
    }
    .btn-outline {
      background-color: white;
      border: 1px solid #cbd5e1;
      color: #374151;
    }
    .btn:hover { opacity: 0.9; }

  </style>
  <!-- 필요 없으면 아래 두 줄 삭제 가능 -->
  <meta name="_csrf"        content="${_csrf.token}">
  <meta name="_csrf_header" content="${_csrf.headerName}">
</head>
<body>
  <h1>결제 확인</h1>

  <!-- 오류 메시지 표시 -->
  <c:if test="${not empty errorMessage}">
    <div class="box" style="background:#fef2f2; border-color:#fecaca;">
      <strong>오류</strong><br/>
      <c:out value="${errorMessage}" />
    </div>
  </c:if>

  <!-- payinfo가 존재할 때만 상세 표시 -->
  <c:if test="${empty errorMessage && not empty payinfo}">
    <!-- PG 표시는 컨트롤러에서 model.addAttribute("pg", "...") 했을 때만 노출됨 -->
    <div class="box">
      <div class="muted">
        PG:
        <c:choose>
          <c:when test="${pg == 'naver'}">네이버페이</c:when>
          <c:when test="${pg == 'kakao'}">카카오페이</c:when>
          <c:otherwise>일반결제/기타</c:otherwise>
        </c:choose>
      </div>
        <p>주문 번호: <strong><c:out value="${payinfo.orderNumber}" /></strong></p>
        <p>금액: <strong><c:out value="${payinfo.price}" /></strong></p>
        <p>상태: <strong><c:out value="${payinfo.paymentStatus}" /></strong></p>

    </div>

    <!-- 필요시: 주문 시 사용한 배송지 출력 (컨트롤러에서 usedAddress 넣었을 때만) -->
    <c:if test="${not empty usedAddress}">
      <div class="box">
        <h3>주문 시 사용한 배송지</h3>
        <p>수령인: <c:out value="${usedAddress.receiverName}" /></p>
        <p>전화번호: <c:out value="${usedAddress.phone}" /></p>
        <p>우편번호: <c:out value="${usedAddress.zipcode}" /></p>
        <p>주소: <c:out value="${usedAddress.addr1}" /> <c:out value="${usedAddress.addr2}" /></p>
      </div>
    </c:if>

    <!-- 여기 아래는 메모였던 문구를 HTML 주석으로 정리 -->
    <!--
      네이버/카카오 결제흐름은 다름 → 컨트롤러에서 pg 파라미터로 구분해 표기.
      회원: "이번 배송지/전화번호를 내 계정에 저장" 버튼 추가 가능.
      비회원: 주문번호+이메일+전화로 배송지 조회(AJAX) 가능.
    -->
  </c:if>

  <div class="box" style="text-align:center; margin-top:24px;">
    <button onclick="location.href='/'" class="btn btn-outline">메인으로 돌아가기</button>
    <button onclick="location.href='/product/list'" class="btn btn-primary">상품 목록 보기</button>
  </div>

</body>
</html>
