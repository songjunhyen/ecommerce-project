<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>배송</title>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<meta name="_csrf" content="${_csrf.token}">
<meta name="_csrf_header" content="${_csrf.headerName}">
</head>

<body>
    <h1>배송 확인</h1>
    
	판매자가 배송 보내야할 리스트 확인
	id랑 상품 등록자 조회해서 일치하는 상품들의 결제완료인 리스트 
    주문번호 제품 옵션 수량 주소 연락처 배송
    배송 클릭하면 송장번호 입력할 수 있게 하고 가능하면 송장번호로 조회되면 배송중으로 바뀌게
    배송중 클릭하면 자동으로 등록된 송장번호로 조회하여 완료 됬으면 배송완료로 상태 변경
    
    상태 중에 회수요청도 있도록. 반품했을경우 사용
    
    <!-- 결제 정보 출력 -->
    <p>주문 번호: ${payinfo.orderNumber}</p>
    <p>금액: ${payinfo.amount}</p>
    <p>상태: ${payinfo.status}</p>
    
    
</body>

</html>