<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>배송조회 결과(비회원)</title>
  <style>
    .container{max-width:900px;margin:36px auto;padding:0 16px}
    table{width:100%;border-collapse:collapse;margin-top:14px}
    th,td{border:1px solid #eee;padding:10px}
    th{background:#fafafa;text-align:left}
    .muted{color:#666}
    .tag{display:inline-block;padding:3px 8px;border-radius:999px;background:#f3f4f6;font-size:12px}
    .actions a{font-size:13px}
  </style>
</head>
<body>
<div class="container">
  <h2>주문번호: ${orderNumber}</h2>

  <c:choose>
    <c:when test="${empty shipments}">
      <p class="muted">아직 배송 데이터가 준비되지 않았습니다. 결제 직후이거나 판매자측 집계 전일 수 있어요.</p>
    </c:when>
    <c:otherwise>
      <table>
        <thead>
        <tr>
          <th>판매자</th>
          <th>수취인</th>
          <th>연락처</th>
          <th>주소</th>
          <th>수량/금액</th>
          <th>결제</th>
          <th>상태</th>
          <th>운송장</th>
        </tr>
        </thead>
        <tbody>
        <c:forEach var="s" items="${shipments}">
          <tr>
            <td>${s.sellerId}</td>
            <td>${s.receiverName}</td>
            <td>${s.phone}</td>
            <td>${s.address}</td>
            <td>${s.totalQuantity}개 / ${s.totalAmount}원</td>
            <td>${s.paymentMethod} / ${s.paymentStatus}</td>
            <td><span class="tag">${s.status}</span></td>
            <td>
              <c:choose>
                <c:when test="${not empty s.trackingNo}">
                  ${s.carrier} / ${s.trackingNo}
                </c:when>
                <c:otherwise>
                  <span class="muted">등록 대기</span>
                </c:otherwise>
              </c:choose>
            </td>
          </tr>
        </c:forEach>
        </tbody>
      </table>
    </c:otherwise>
  </c:choose>

  <p class="actions" style="margin-top:12px">
    <a href="<c:url value='/track'/>">다시 조회</a>
  </p>
</div>
</body>
</html>
