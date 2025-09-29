<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags"%>

<c:set var="uri" value="${pageContext.request.requestURI}" />

<style>
  #siteHeader .topbar { background:#111; color:#fff; font-size:12px; padding:8px 0; }
  #siteHeader .container { max-width:1200px; margin:0 auto; padding:0 16px; }
  #siteHeader .topbar .links { display:flex; gap:16px; justify-content:flex-end; }
  #siteHeader .topbar a { color:#ddd; text-decoration:none; }
  #siteHeader .topbar a:hover { color:#fff; text-decoration:underline; }

  #siteHeader .header { background:#fff; border-bottom:1px solid #eee; }
  #siteHeader .header-row { display:grid; grid-template-columns:220px 1fr 360px; align-items:center; gap:16px; padding:14px 0; }

  #siteHeader .brand a { display:flex; align-items:center; gap:8px; text-decoration:none; color:#111; }
  #siteHeader .brand-logo { width:36px; height:36px; border-radius:8px; background:#111; display:inline-block; }
  #siteHeader .brand-title { font-size:20px; font-weight:700; letter-spacing:0.2px; }

  #siteHeader .search { display:flex; align-items:center; gap:8px; border:1px solid #ddd; border-radius:10px; padding:8px 10px; background:#fafafa; }
  #siteHeader .search input { flex:1; border:none; outline:none; background:transparent; font-size:14px; }
  #siteHeader .search button { border:none; background:#111; color:#fff; padding:8px 14px; border-radius:8px; cursor:pointer; }
  #siteHeader .search button:hover { opacity:0.9; }

  #siteHeader .actions { display:flex; justify-content:flex-end; align-items:center; gap:10px; flex-wrap:wrap; }
  #siteHeader .actions a, #siteHeader .actions button {
    font-size:13px; border:1px solid #ddd; background:#fff; color:#111; padding:6px 10px; border-radius:8px; text-decoration:none; cursor:pointer;
  }
  #siteHeader .actions a:hover, #siteHeader .actions button:hover { background:#111; color:#fff; }
  #siteHeader .actions a.active { background:#111; color:#fff; }

  @media (max-width: 900px){
    #siteHeader .header-row { grid-template-columns:1fr; gap:10px; }
    #siteHeader .actions { justify-content:flex-start; }
  }
</style>

<div id="siteHeader">
  <div class="topbar">
    <div class="container">
      <div class="links" aria-label="바로가기 링크">
        <a href="<c:url value='/help/center'/>"><small>고객센터</small></a>
        <a href="<c:url value='/notice/list'/>"><small>공지사항</small></a>
        <a href="<c:url value='/help/faq'/>"><small>FAQ</small></a>
      </div>
    </div>
  </div>

  <header class="header">
    <div class="container">
      <div class="header-row">
        <div class="brand">
          <a href="<c:url value='/'/>" aria-label="홈으로 이동">
            <span class="brand-logo" aria-hidden="true"></span>
            <span class="brand-title">E-커머스 프로젝트</span>
          </a>
        </div>

        <form class="search" action="<c:url value='/product/search'/>" method="get" role="search" aria-label="상품 검색">
          <input type="text" name="q" placeholder="검색어를 입력하세요" value="${param.q}">
          <button type="submit">검색</button>
        </form>

        <div class="actions">
          <sec:authorize access="!isAuthenticated()">
            <a href="<c:url value='/Home/login'/>" class="${uri eq '/Home/login' ? 'active' : ''}">로그인</a>
            <a href="<c:url value='/user/Signup'/>" class="${uri eq '/user/Signup' ? 'active' : ''}">회원가입</a>
            <a href="<c:url value='/product/list'/>" class="${uri eq '/product/list' ? 'active' : ''}">제품</a>
            <a href="<c:url value='/temp/Cart'/>" class="${uri eq '/temp/Cart' ? 'active' : ''}">장바구니</a>

             <a href="<c:url value='/track'/>" class="${uri eq '/track' ? 'active' : ''}">주문/배송 조회</a>
              </sec:authorize>

          <sec:authorize access="isAuthenticated()">
            <a href="<c:url value='/product/list'/>" class="${uri eq '/product/list' ? 'active' : ''}">제품</a>

            <c:choose>
              <c:when test="${userRole == 'user'}">
                <a href="<c:url value='/Cart/List'/>" class="${uri eq '/Cart/List' ? 'active' : ''}">장바구니</a>
                <a href="<c:url value='/mypage/orders'/>" class="${fn:startsWith(uri, '/mypage') ? 'active' : ''}">주문/배송</a>
                <a href="<c:url value='/user/Check'/>" class="${uri eq '/user/Check' ? 'active' : ''}">내 정보</a>
              </c:when>

              <c:when test="${userRole == 'admin'}">
                <a href="<c:url value='/Cart/List'/>" class="${uri eq '/Cart/List' ? 'active' : ''}">장바구니</a>
                <a href="<c:url value='/product/add'/>" class="${uri eq '/product/add' ? 'active' : ''}">상품등록</a>

                <a href="<c:url value='/seller/ship'/>" class="${fn:startsWith(uri, '/seller/ship') ? 'active' : ''}">배송관리</a>

                <c:if test="${adminClass == 1}">
                  <a href="<c:url value='/admin/Dashboard'/>" class="${fn:startsWith(uri, '/admin') ? 'active' : ''}">관리자페이지</a>
                </c:if>
              </c:when>

              <c:otherwise>
                <a href="<c:url value='/user/Check'/>" class="${uri eq '/user/Check' ? 'active' : ''}">내 정보</a>
              </c:otherwise>
            </c:choose>

            <form action="<c:url value='/Home/logout'/>" method="post" style="display:inline;">
              <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
              <button type="submit">로그아웃</button>
            </form>
          </sec:authorize>
        </div>
      </div>
    </div>
  </header>
</div>
