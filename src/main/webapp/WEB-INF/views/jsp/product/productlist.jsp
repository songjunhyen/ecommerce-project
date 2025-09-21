<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"    uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn"   uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt"  uri="http://java.sun.com/jsp/jstl/fmt"%>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <title>상품 목록</title>

  <style>
    /* 페이지 스코프 래퍼로 헤더/푸터와 스타일 충돌 방지 */
    #productListPage { max-width: 1200px; margin: 0 auto; padding: 16px; }
    #productListPage h1 { margin: 0 0 12px; font-size: 20px; }

    #productTable { width:100%; border-collapse: collapse; }
    #productTable th, #productTable td { border:1px solid #e5e7eb; padding:10px; text-align:center; }
    #productTable th { background:#f8fafc; font-weight:600; }

    #productTable .thumb { width:120px; }
    #productTable .thumb img { max-width:110px; max-height:110px; object-fit:cover; display:block; margin:0 auto; }

    .pagination { margin-top:14px; display:flex; gap:8px; align-items:center; flex-wrap:wrap; }
    .pagination a, .pagination strong {
      padding:6px 10px; border:1px solid #e5e7eb; border-radius:6px; text-decoration:none; color:#111;
    }
    .pagination strong { background:#111; color:#fff; border-color:#111; }

    .actions { margin-top:16px; display:flex; gap:8px; }
    .btn { padding:8px 12px; border-radius:8px; border:1px solid #111; background:#111; color:#fff; cursor:pointer; }
    .btn.secondary { background:#fff; color:#111; }
  </style>
</head>

<body>
  <%@ include file="../includes/head1.jsp"%>

  <div id="productListPage">
    <h1>상품 목록</h1>

    <c:choose>
      <c:when test="${empty products}">
        <p>등록된 상품이 없습니다.</p>
      </c:when>
      <c:otherwise>
        <table id="productTable">
          <thead>
            <tr>
              <th class="thumb"></th>
              <th>번호</th>
              <th>카테고리</th>
              <th>제품명</th>
              <th>금액</th>
              <th>조회수</th>
              <th>작성일</th>
            </tr>
          </thead>
          <tbody>
            <c:forEach var="product" items="${products}">
              <tr>
                <!-- 이미지 -->
                <td class="thumb">
                  <c:choose>
                    <c:when test="${not empty product.imageUrl}">
                      <c:set var="imageUrls" value="${fn:split(product.imageUrl, ',')}" />
                      <c:if test="${fn:length(imageUrls) > 0}">
                        <img src="${imageUrls[0]}" alt="Product Image" />
                      </c:if>
                    </c:when>
                    <c:otherwise>
                      <span>이미지 없음</span>
                    </c:otherwise>
                  </c:choose>
                </td>

                <!-- 번호/카테고리 -->
                <td>${product.id}</td>
                <td>${product.category}</td>

                <!-- 상세보기(POST) -->
                <td>
                  <form action="<c:url value='/product/Detail'/>" method="post" style="margin:0">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                    <input type="hidden" name="id" value="${product.id}" />
                    <button type="submit" class="btn secondary" style="padding:6px 10px;">${product.name}</button>
                  </form>
                </td>

                <!-- 금액/조회수 -->
                <td><fmt:formatNumber value="${product.price}" type="number" /></td>
                <td>${product.viewcount}</td>

                <!-- 작성일: LocalDateTime은 fmt:formatDate 금지 -> 문자열로 표시 -->
                <td>
                  <c:choose>
                    <c:when test="${not empty product.regDate}">
                      ${fn:replace(product.regDate, 'T', ' ')}
                    </c:when>
                    <c:otherwise>-</c:otherwise>
                  </c:choose>
                </td>
              </tr>
            </c:forEach>
          </tbody>
        </table>

        <!-- 페이지네이션 (var로 안전하게 생성) -->
        <div class="pagination">
          <c:if test="${currentPage > 1}">
            <c:url var="prevUrl" value="/product/list">
              <c:param name="page" value="${currentPage - 1}"/>
            </c:url>
            <a href="${prevUrl}">이전</a>
          </c:if>

          <c:forEach begin="1" end="${totalPages}" var="p">
            <c:choose>
              <c:when test="${p == currentPage}">
                <strong>${p}</strong>
              </c:when>
              <c:otherwise>
                <c:url var="pageUrl" value="/product/list">
                  <c:param name="page" value="${p}"/>
                </c:url>
                <a href="${pageUrl}">${p}</a>
              </c:otherwise>
            </c:choose>
          </c:forEach>

          <c:if test="${currentPage < totalPages}">
            <c:url var="nextUrl" value="/product/list">
              <c:param name="page" value="${currentPage + 1}"/>
            </c:url>
            <a href="${nextUrl}">다음</a>
          </c:if>
        </div>
      </c:otherwise>
    </c:choose>

    <div class="actions">
      <a class="btn" href="<c:url value='/Home/Main'/>">메인으로</a>
      <c:if test="${memberClass == 1 || adminClass == 1}">
        <a class="btn secondary" href="<c:url value='/product/add'/>">상품 등록</a>
      </c:if>
    </div>
  </div>

  <%@ include file="../includes/foot1.jsp"%>
</body>
</html>
