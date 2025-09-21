<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form"%>
<%@ page import="com.example.demo.vo.Cart"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>결제완료</title>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<meta name="_csrf" content="${_csrf.token}">
<meta name="_csrf_header" content="${_csrf.headerName}">
</head>

<body>
    <h1>결제 확인</h1>
    
    네이버랑 카카오페이랑 다르니깐 그거 
    
    <!-- 결제 정보 출력 -->
    <p>주문 번호: ${payinfo.orderNumber}</p>
    <p>금액: ${payinfo.amount}</p>
    <p>상태: ${payinfo.status}</p>
    
    사용한 주소로 저장된 사용자 주소로 업데이트할 수 있는 버튼 생성
    전화번호도...유저 테이블에 전화번호 컬럼 추가
    
    비회원은 구매페이지에 연락처나 이메일로 주소 가져올 수 있도록 
    
</body>

</html>