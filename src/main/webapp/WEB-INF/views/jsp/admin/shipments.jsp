<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>배송관리(판매자)</title>
  <style>
    .container{max-width:1100px;margin:28px auto;padding:0 16px}
    form.filter{display:flex;gap:8px;flex-wrap:wrap;margin-bottom:12px}
    input,select{padding:8px;border:1px solid #ddd;border-radius:8px}
    .btn{padding:8px 12px;border:0;border-radius:8px;background:#111;color:#fff;cursor:pointer}
    table{width:100%;border-collapse:collapse;margin-top:10px}
    th,td{border:1px solid #eee;padding:10px}
    th{background:#fafafa;text-align:left}
    .tag{display:inline-block;padding:3px 8px;border-radius:999px;background:#f3f4f6;font-size:12px}
    .muted{color:#666}
    .row-actions a{margin-right:8px}
  </style>
  <script>
    async function consolidate() {
      const params = new URLSearchParams();
      const f = document.querySelector('form.filter');
      for (const el of f.elements) {
        if (!el.name) continue;
        if (el.value) params.append(el.name, el.value);
      }
      const res = await fetch('<c:url value="/seller/ship/consolidate"/>', {
        method:'POST',
        headers:{'Content-Type':'application/x-www-form-urlencoded'},
        body: params.toString()
      });
      const n = await res.text();
      alert('집계/동기화: ' + n + '건 반영');
      location.reload();
    }
  </script>
</head>
<body class="layout-sticky">

 <%@ include file="../includes/head1.jsp"%>
 <main id="page">
<div class="container">
  <h2>배송관리</h2>

  <form class="filter" method="get" action="<c:url value='/seller/ship'/>">
    <select name="status">
      <option value="">상태(전체)</option>
      <c:set var="st" value="${param.status}" />
      <option value="배송 전"   ${st=='배송 전'   ? 'selected' : ''}>배송 전</option>
      <option value="배송중"     ${st=='배송중'     ? 'selected' : ''}>배송중</option>
      <option value="배송완료"   ${st=='배송완료'   ? 'selected' : ''}>배송완료</option>
      <option value="반품요청"   ${st=='반품요청'   ? 'selected' : ''}>반품요청</option>
    </select>
    <input type="date" name="from" value="${from}">
    <input type="date" name="to"   value="${to}">
    <input type="text" name="q" placeholder="주문번호/수취인/주소/전화" value="${q}">
    <button class="btn" type="submit">검색</button>
    <button class="btn" type="button" onclick="consolidate()">조회(집계)</button>
  </form>

  <c:choose>
    <c:when test="${empty rows}">
      <p class="muted">표시할 배송 건이 없습니다.</p>
    </c:when>
    <c:otherwise>
      <table>
        <thead>
        <tr>
          <th>주문번호</th>
          <th>수취인</th>
          <th>주소</th>
          <th>수량/금액</th>
          <th>결제</th>
          <th>상태</th>
          <th>운송장</th>
          <th>관리</th>
        </tr>
        </thead>
        <tbody>
        <c:forEach var="s" items="${rows}">
          <tr>
            <td><a href="<c:url value='/seller/ship/${s.orderNumber}'/>">${s.orderNumber}</a></td>
            <td>${s.receiverName} (${s.phone})</td>
            <td>${s.address}</td>
            <td>${s.totalQuantity}개 / ${s.totalAmount}원</td>
            <td>${s.paymentMethod} / ${s.paymentStatus}</td>
            <td><span class="tag">${s.status}</span></td>
            <td>
              <c:choose>
                <c:when test="${not empty s.trackingNo}">
                  ${s.carrier} / ${s.trackingNo}
                </c:when>
                <c:otherwise><span class="muted">미등록</span></c:otherwise>
              </c:choose>
            </td>
            <td class="row-actions">
              <a href="<c:url value='/seller/ship/${s.orderNumber}'/>">상세</a>
            </td>
          </tr>
        </c:forEach>
        </tbody>
      </table>
    </c:otherwise>
  </c:choose>
</div>

</main>
  <%@ include file="../includes/foot1.jsp"%>
</body>
</html>
