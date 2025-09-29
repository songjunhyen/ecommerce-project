<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<html><head><meta charset="UTF-8"><title>공지사항 관리</title>
<style>
  .wrap{max-width:1100px;margin:0 auto;padding:16px}
  table{width:100%;border-collapse:collapse}
  th,td{border:1px solid #e5e7eb;padding:10px}
  th{background:#f8fafc}
  .actions a,.actions form{display:inline-block;margin-right:6px}
  .topbar{display:flex;justify-content:space-between;gap:8px;margin-bottom:12px}
  .btn{padding:8px 12px;border-radius:8px;border:1px solid #111;background:#111;color:#fff;text-decoration:none}
  .btn.ghost{background:#fff;color:#111;border:1px solid #ddd}
  .pagi a{margin:0 4px;text-decoration:none}
  .pagi .cur{font-weight:700}
</style>
</head><body>
<%@ include file="../includes/head1.jsp"%>
<div class="wrap">

  <h2>공지사항 관리</h2>

  <div class="topbar">
    <form action="<c:url value='/article/list'/>" method="get" style="display:flex;gap:6px">
      <input type="text" name="q" value="${query}" placeholder="제목/본문 검색" />
      <button class="btn ghost" type="submit">검색</button>
    </form>
    <a class="btn" href="<c:url value='/article/add'/>">새 공지 등록</a>
  </div>

  <c:if test="${empty articles}">
    <div>등록된 공지사항이 없습니다.</div>
  </c:if>

  <c:if test="${not empty articles}">
    <table>
      <thead>
        <tr>
          <th style="width:80px">ID</th>
          <th>제목</th>
          <th style="width:160px">작성자</th>
          <th style="width:200px">등록일</th>
          <th style="width:200px">수정일</th>
          <th style="width:160px">조회수</th>
          <th style="width:220px">관리</th>
        </tr>
      </thead>
      <tbody>
        <c:forEach var="a" items="${articles}">
          <tr>
            <td>${a.id}</td>
            <td><a href="<c:url value='/article/view'/>?id=${a.id}">${fn:escapeXml(a.title)}</a></td>
            <td>${a.writerId}</td>
            <td>${fn:replace(a.regDate,'T',' ')}</td>
            <td>${fn:replace(a.updateDate,'T',' ')}</td>
            <td>${a.viewCount}</td>
            <td class="actions">
              <a class="btn ghost" href="<c:url value='/article/view'/>?id=${a.id}">보기</a>
              <a class="btn ghost" href="<c:url value='/article/modify'/>?id=${a.id}">수정</a>
              <form action="<c:url value='/article/delete'/>" method="get" style="display:inline">
                <input type="hidden" name="id" value="${a.id}">
                <button class="btn ghost" type="submit">삭제</button>
              </form>
            </td>
          </tr>
        </c:forEach>
      </tbody>
    </table>

    <!-- 페이지네이션 -->
    <c:set var="totalPages" value="${(total + pageSize - 1) / pageSize}"/>
    <div class="pagi" style="margin-top:12px">
      <c:forEach begin="1" end="${totalPages}" var="p">
        <c:choose>
          <c:when test="${p == currentPage}">
            <span class="cur">[${p}]</span>
          </c:when>
          <c:otherwise>
            <a href="<c:url value='/article/list'/>?page=${p}&size=${pageSize}&q=${fn:escapeXml(query)}">[${p}]</a>
          </c:otherwise>
        </c:choose>
      </c:forEach>
    </div>
  </c:if>

</div>
<%@ include file="../includes/foot1.jsp"%>
</body></html>
