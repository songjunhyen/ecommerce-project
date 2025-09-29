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
    /* ===== 페이지 전용 스코프 ===== */
    #productListPage { max-width: 1200px; margin: 0 auto; padding: 16px; }
    #productListPage h1 { margin: 0 0 12px; font-size: 20px; }

    /* 검색 폼 */
    #productListPage .searchbar { margin: 0 0 12px; display:flex; gap:8px; }
    #productListPage .searchbar input[type="text"]{
      flex:1; padding:8px; border:1px solid #e5e7eb; border-radius:8px;
    }
    /* 페이지 전용 버튼 클래스 (헤더/푸터와 충돌 방지) */
    #productListPage .pl-btn {
      padding:8px 12px; border-radius:8px; border:1px solid #111; background:#111; color:#fff;
      cursor:pointer; text-decoration:none; display:inline-block;
    }
    #productListPage .pl-btn.secondary { background:#fff; color:#111; }

    /* 테이블 */
    #productTable { width:100%; border-collapse: collapse; }
    #productTable th, #productTable td { border:1px solid #e5e7eb; padding:10px; text-align:center; }
    #productTable th { background:#f8fafc; font-weight:600; }
    #productTable .thumb { width:120px; }
    #productTable .thumb img { max-width:110px; max-height:110px; object-fit:cover; display:block; margin:0 auto; }

    /* 페이지네이션 */
    #productListPage .pagination { margin-top:14px; display:flex; gap:8px; align-items:center; flex-wrap:wrap; }
    #productListPage .pagination a, #productListPage .pagination strong {
      padding:6px 10px; border:1px solid #e5e7eb; border-radius:6px; text-decoration:none; color:#111;
    }
    #productListPage .pagination strong { background:#111; color:#fff; border-color:#111; }

    #productListPage .actions { margin-top:16px; display:flex; gap:8px; }
  </style>
</head>

<!-- sticky footer가 필요하면 layout-sticky 클래스 유지 -->
<body class="layout-sticky">
  <%@ include file="../includes/head1.jsp"%>

  <main>
    <div id="productListPage">
      <h1>상품 목록</h1>

      <%-- 검색 입력값(모델 q 우선, 없으면 param.q) --%>
      <c:set var="searchQuery" value="${empty q ? param.q : q}"/>

      <%-- 검색 폼 --%>
      <form class="searchbar" action="<c:url value='/product/search'/>" method="get" role="search" aria-label="상품 검색">
        <input type="text" name="q" placeholder="상품명, 설명, 카테고리, 제조사 등 검색"
               value="${fn:escapeXml(searchQuery)}">
        <button type="submit" class="pl-btn">검색</button>
        <c:if test="${not empty searchQuery}">
          <a class="pl-btn secondary" href="<c:url value='/product/list'/>">전체보기</a>
        </c:if>
      </form>

      <%-- 검색 결과 건수 안내 --%>
      <c:if test="${not empty searchQuery}">
        <p style="margin:8px 0 12px; color:#666;">
          ‘<strong><c:out value='${searchQuery}'/></strong>’ 검색 결과
          <strong>${totalCount}</strong>건
        </p>
      </c:if>

      <c:choose>
        <c:when test="${empty products}">
          <p>
            <c:choose>
              <c:when test="${not empty searchQuery}">검색 결과가 없습니다.</c:when>
              <c:otherwise>등록된 상품이 없습니다.</c:otherwise>
            </c:choose>
          </p>
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
                      <button type="submit" class="pl-btn secondary" style="padding:6px 10px;">${product.name}</button>
                    </form>
                  </td>

                  <!-- 금액/조회수 -->
                  <td><fmt:formatNumber value="${product.price}" type="number" /></td>
                  <td>${product.viewcount}</td>

                  <!-- 작성일(LocalDateTime -> 문자열) -->
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

          <%-- 페이지네이션: 검색이면 /product/search, 아니면 /product/list --%>
          <c:set var="baseUrl" value="${empty searchQuery ? '/product/list' : '/product/search'}"/>

          <div class="pagination">
            <c:if test="${currentPage > 1}">
              <c:url var="prevUrl" value="${baseUrl}">
                <c:param name="page" value="${currentPage - 1}"/>
                <c:if test="${not empty searchQuery}">
                  <c:param name="q" value="${searchQuery}"/>
                </c:if>
              </c:url>
              <a href="${prevUrl}">이전</a>
            </c:if>

            <c:forEach var="p"
                       begin="${startPage != null ? startPage : 1}"
                       end="${endPage   != null ? endPage   : totalPages}">
              <c:choose>
                <c:when test="${p == currentPage}">
                  <strong>${p}</strong>
                </c:when>
                <c:otherwise>
                  <c:url var="pageUrl" value="${baseUrl}">
                    <c:param name="page" value="${p}"/>
                    <c:if test="${not empty searchQuery}">
                      <c:param name="q" value="${searchQuery}"/>
                    </c:if>
                  </c:url>
                  <a href="${pageUrl}">${p}</a>
                </c:otherwise>
              </c:choose>
            </c:forEach>

            <c:if test="${currentPage < totalPages}">
              <c:url var="nextUrl" value="${baseUrl}">
                <c:param name="page" value="${currentPage + 1}"/>
                <c:if test="${not empty searchQuery}">
                  <c:param name="q" value="${searchQuery}"/>
                </c:if>
              </c:url>
              <a href="${nextUrl}">다음</a>
            </c:if>
          </div>
        </c:otherwise>
      </c:choose>

      <div class="actions">
        <a class="pl-btn" href="<c:url value='/Home/Main'/>">메인으로</a>
        <c:if test="${memberClass == 1 || adminClass == 1}">
          <a class="pl-btn secondary" href="<c:url value='/product/add'/>">상품 등록</a>
        </c:if>
      </div>
    </div>
  </main>

  <%@ include file="../includes/foot1.jsp"%>
</body>
</html>
