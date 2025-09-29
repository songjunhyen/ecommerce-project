<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div style="max-width:1000px;margin:24px auto;padding:0 16px">
  <h1>내 주문/배송</h1>

  <c:choose>
    <c:when test="${empty orders}">
      <p>주문 내역이 없습니다.</p>
    </c:when>
    <c:otherwise>
      <table border="1" cellspacing="0" cellpadding="8" style="width:100%;border-collapse:collapse">
        <thead>
          <tr>
            <th>주문번호</th>
            <th>상품명</th>
            <th>수량</th>
            <th>결제금액</th>
            <th>상태</th>
            <th>액션</th>
          </tr>
        </thead>
        <tbody>
          <c:forEach var="row" items="${orders}">
            <tr>
              <td><code>${row.orderNumber}</code></td>
              <td>${row.productname}</td>
              <td style="text-align:right">${row.quantity}</td>
              <td style="text-align:right"><fmt:formatNumber value="${row.price}" type="number"/> 원</td>
              <td>${row.status}</td>
              <td>
                <a href="<c:url value='/my/orders'/>/${row.orderNumber}/track">배송조회</a>
              </td>
            </tr>
          </c:forEach>
        </tbody>
      </table>
    </c:otherwise>
  </c:choose>
</div>
