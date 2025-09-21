<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>배송조회</title>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<meta name="_csrf" content="${_csrf.token}">
<meta name="_csrf_header" content="${_csrf.headerName}">
</head>

<body>
    <h1>배송 확인</h1>
    구매자의 배송확인
    
    구매자 id로 주문정보 조회, 시간이나 주문번호 일치하는거 묶어서 상태보여줌
    주문번호 제품명 주소 연락처 금액 배송조회
    배송조회누르면 자동으로 송장조회해서 새창으로 상태 보여주기
        
    <!-- 결제 정보 출력 -->
    <p>주문 번호: ${payinfo.orderNumber}</p>
    <p>금액: ${payinfo.amount}</p>
    <p>상태: ${payinfo.status}</p>

</body>

</html>