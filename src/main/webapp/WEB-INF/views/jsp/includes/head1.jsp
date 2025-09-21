<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags"%>

<style>
  /* ===== Header Scoped Styles ===== */
  #siteHeader .topbar {
    background:#111; color:#fff; font-size:12px; padding:8px 0;
  }
  #siteHeader .container { max-width:1200px; margin:0 auto; padding:0 16px; }
  #siteHeader .topbar .links { display:flex; gap:16px; justify-content:flex-end; }
  #siteHeader .topbar a { color:#ddd; text-decoration:none; }
  #siteHeader .topbar a:hover { color:#fff; }

  #siteHeader .header {
    background:#fff; border-bottom:1px solid #eee;
  }
  #siteHeader .header-row {
    display:grid; grid-template-columns:220px 1fr 280px; align-items:center; gap:16px; padding:14px 0;
  }
  #siteHeader .brand a { display:flex; align-items:center; gap:8px; text-decoration:none; color:#111; }
  #siteHeader .brand-logo {
    width:36px; height:36px; border-radius:8px; background:#111; display:inline-block;
  }
  #siteHeader .brand-title { font-size:20px; font-weight:700; letter-spacing:0.2px; }

  #siteHeader .search {
    display:flex; align-items:center; gap:8px; border:1px solid #ddd; border-radius:10px; padding:8px 10px;
    background:#fafafa;
  }
  #siteHeader .search input {
    flex:1; border:none; outline:none; background:transparent; font-size:14px;
  }
  #siteHeader .search button {
    border:none; background:#111; color:#fff; padding:8px 14px; border-radius:8px; cursor:pointer;
  }
  #siteHeader .search button:hover { opacity:0.9; }

  #siteHeader .actions { display:flex; justify-content:flex-end; align-items:center; gap:10px; }
  #siteHeader .actions a,
  #siteHeader .actions button {
    border:1px solid #ddd; background:#fff; color:#111; padding:8px 12px; border-radius:8px; text-decoration:none; cursor:pointer;
  }
  #siteHeader .actions a:hover,
  #siteHeader .actions button:hover { background:#111; color:#fff; }

  /* (선택) 카테고리 네비가 있을 경우에만 사용 */
  #siteHeader .catnav { border-top:1px solid #eee; border-bottom:1px solid #eee; background:#fff; }
  #siteHeader .catnav .nav-row { display:flex; gap:18px; padding:10px 0; overflow:auto; }
  #siteHeader .catnav a { color:#444; text-decoration:none; padding:6px 10px; border-radius:6px; white-space:nowrap; }
  #siteHeader .catnav a:hover { background:#f3f4f6; }

  @media (max-width: 900px){
    #siteHeader .header-row { grid-template-columns:1fr; gap:10px; }
    #siteHeader .actions { justify-content:flex-start; }
  }
</style>

<div id="siteHeader">
  <!-- 상단 알림/바로가기 -->
  <div class="topbar">
    <div class="container">
      <div class="links">
        <a href="#"><small>고객센터</small></a>
        <a href="#"><small>공지사항</small></a>
        <a href="#"><small>FAQ</small></a>
      </div>
    </div>
  </div>

  <!-- 메인 헤더 -->
  <header class="header">
    <div class="container">
      <div class="header-row">
        <div class="brand">
          <a href="<c:url value='/'/>">
            <span class="brand-logo"></span>
            <span class="brand-title">E-커머스 프로젝트</span>
          </a>
        </div>

        <form class="search" action="<c:url value='/product/list'/>" method="get">
          <input type="text" name="q" placeholder="검색어를 입력하세요" value="${param.q}">
          <button type="submit">검색</button>
        </form>

        <div class="actions">
          <sec:authorize access="isAuthenticated()">
            <form action="<c:url value='/Home/logout'/>" method="post" style="display:inline;">
              <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
              <button type="submit">로그아웃</button>
            </form>
            <a href="<c:url value='/Cart/List'/>">장바구니</a>
            <a href="<c:url value='/user/Check'/>">내 정보</a>
            <c:if test="${adminClass == 1}">
              <a href="<c:url value='/admin/Dashboard'/>">대시보드</a>
            </c:if>
          </sec:authorize>

          <sec:authorize access="!isAuthenticated()">
            <a href="<c:url value='/Home/login'/>">로그인</a>
            <a href="<c:url value='/user/Signup'/>">회원가입</a>
            <a href="<c:url value='/temp/Cart'/>">장바구니</a>
          </sec:authorize>
        </div>
      </div>
    </div>
  </header>
</div>
