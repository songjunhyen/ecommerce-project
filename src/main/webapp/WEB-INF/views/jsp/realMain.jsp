<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags"%>

<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>Main</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<style>
  html, body { height: 100%; margin:0; }
  body { display: flex; flex-direction: column; min-height: 100vh; font-family: sans-serif; }
  main { flex: 1; }

  /* 헤더 */
  .top-bar { display:flex; justify-content:flex-end; align-items:center; background:#333; padding:10px 20px; }
  .top-bar ul { display:flex; align-items:center; list-style:none; margin:0; padding:0; }
  .top-bar li { margin-left:20px; }
  .top-bar a { color:#fff; text-decoration:none; padding:6px 10px; display:flex; align-items:center; }
  .top-bar a:hover { background:#ddd; color:#000; border-radius:5px; }
  .logout-button { background:none; border:none; color:#fff; cursor:pointer; }
  .logout-button:hover { background:#ddd; color:#000; border-radius:5px; }
  .title { text-align:center; margin:20px 0; }
  .title a { font-size:24px; color:#333; text-decoration:none; }

  /* 슬라이드 */
  .slideshow-container { position: relative; max-width: 1200px; margin: 0 auto; aspect-ratio: 21/7; overflow: hidden; border-radius: 12px; }
  .mySlides { display:none; width:100%; height:100%; }
  .main_slideImg { width: 100%; height: 100%; object-fit: cover; }
  .prev, .next { cursor: pointer; position: absolute; top: 50%; transform: translateY(-50%); width: 40px; height: 40px; display:flex; align-items:center; justify-content:center; background:rgba(0,0,0,0.5); color:#fff; font-size:20px; border-radius:50%; }
  .prev { left: 10px; } .next { right: 10px; }
  .dot-container { text-align:center; margin:10px 0; }
  .dot { cursor:pointer; height:10px; width:10px; margin:0 4px; background:#bbb; border-radius:50%; display:inline-block; }
  .active, .dot:hover { background:#111; }

  /* 상품 */
  #productContainer { width:80%; margin:40px auto; text-align:center; }
  #productTable { width:100%; border-collapse: collapse; }
  #productTable th, #productTable td { border:1px solid #ddd; padding:8px; }
  #productTable th { background:#f2f2f2; }
  #productTable td button { background:none; border:none; color:blue; text-decoration:underline; cursor:pointer; }

  /* 페이징 */
  #pagingContainer { text-align:center; margin:24px 0; }
  #pagingContainer a, #pagingContainer span { min-width:30px; display:inline-block; margin:0 4px; padding:6px 10px; border:1px solid #ddd; border-radius:6px; text-decoration:none; }
  #pagingContainer a:hover { background:#ddd; }
  #pagingContainer span { background:#111; color:#fff; border-color:#111; }

  /* 공지 */
  #articleContainer { width:80%; margin:40px auto; }

  /* 푸터 */
  footer { background:#111; color:#ddd; text-align:center; padding:20px; margin-top:auto; }
  footer ul { margin:0; padding:0; list-style:none; }
  footer li { display:inline; margin:0 10px; }
  footer a { color:#ddd; text-decoration:none; }
  footer a:hover { text-decoration:underline; color:#fff; }
  footer .copy { margin-top:10px; font-size:12px; color:#aaa; }
</style>
</head>

<body>

<!-- 헤더 -->
<nav class="top-bar">
  <ul>
    <li><a href="/">Home</a></li>
    <sec:authorize access="isAuthenticated()">
      <c:choose>
        <c:when test="${userRole == 'user'}">
          <li>
            <form action="/Home/logout" method="post" style="display:inline;">
              <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
              <input type="submit" value="Logout" class="logout-button" />
            </form>
          </li>
          <li><a href="/user/Check">내 정보</a></li>
          <li><a href="/Cart/List">Cart</a></li>
        </c:when>
        <c:when test="${userRole == 'admin'}">
          <li>
            <form action="/Home/logout" method="post" style="display:inline;">
              <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
              <input type="submit" value="Logout" class="logout-button" />
            </form>
          </li>
          <li><a href="/product/add">상품등록</a></li>
          <c:if test="${adminClass == 1}">
            <li><a href="/admin/Dashboard">관리자페이지</a></li>
          </c:if>
        </c:when>
      </c:choose>
    </sec:authorize>
    <sec:authorize access="!isAuthenticated()">
      <li><a href="/Home/login">Login</a></li>
      <li><a href="/user/Signup">Join</a></li>
      <li><a href="/temp/Cart">Cart</a></li>
    </sec:authorize>
    <li><a href="/product/list">Product</a></li>
    <li><a href="#">Help</a></li>
  </ul>
</nav>

<div class="title">
  <a href="/Home/Main">E-커머스 프로젝트</a>
</div>

<main>
  <!-- 슬라이드 -->
  <div class="slideshow-container">
    <div class="mySlides"><img class="main_slideImg" src="${pageContext.request.contextPath}/event/banner1.jpg"></div>
    <div class="mySlides"><img class="main_slideImg" src="${pageContext.request.contextPath}/event/banner2.jpg"></div>
    <div class="mySlides"><img class="main_slideImg" src="${pageContext.request.contextPath}/event/banner3.jpg"></div>
    <a class="prev" onclick="plusSlides(-1)">❮</a>
    <a class="next" onclick="plusSlides(1)">❯</a>
  </div>
  <div class="dot-container">
    <span class="dot" onclick="currentSlide(1)"></span>
    <span class="dot" onclick="currentSlide(2)"></span>
    <span class="dot" onclick="currentSlide(3)"></span>
  </div>

  <!-- 상품 -->
  <div id="productContainer">
    <h2>상품 목록</h2>
    <c:choose>
      <c:when test="${not empty products}">
        <table id="productTable">
          <thead>
            <tr><th>이미지</th><th>번호</th><th>카테고리</th><th>제품명</th><th>금액</th><th>조회수</th><th>작성일</th></tr>
          </thead>
          <tbody>
            <c:forEach var="product" items="${products}">
              <tr>
                <td>
                  <c:choose>
                    <c:when test="${not empty product.imageUrl}">
                      <c:set var="imageUrls" value="${fn:split(product.imageUrl, ',')}" />
                      <img src="${imageUrls[0]}" style="max-width:120px; max-height:120px; object-fit:cover;" />
                    </c:when>
                    <c:otherwise><span style="color:#888;">이미지 없음</span></c:otherwise>
                  </c:choose>
                </td>
                <td>${product.id}</td>
                <td>${product.category}</td>
                <td>
                  <form action="${pageContext.request.contextPath}/product/Detail" method="post">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                    <input type="hidden" name="id" value="${product.id}">
                    <button type="submit">${product.name}</button>
                  </form>
                </td>
                <td>${product.price}</td>
                <td>${product.viewcount}</td>
                <td>${product.regDate}</td>
              </tr>
            </c:forEach>
          </tbody>
        </table>
      </c:when>
      <c:otherwise><p style="color:#777;">표시할 상품이 없습니다.</p></c:otherwise>
    </c:choose>
  </div>

  <!-- 페이징 -->
  <div id="pagingContainer">
    <c:if test="${currentPage != null && totalPages != null}">
      <c:if test="${currentPage > 1}">
        <a href="?page=${currentPage - 1}">이전</a>
      </c:if>
      <c:forEach var="i" begin="${startPage}" end="${endPage}">
        <c:choose>
          <c:when test="${i == currentPage}"><span>${i}</span></c:when>
          <c:otherwise><a href="?page=${i}">${i}</a></c:otherwise>
        </c:choose>
      </c:forEach>
      <c:if test="${currentPage < totalPages}">
        <a href="?page=${currentPage + 1}">다음</a>
      </c:if>
    </c:if>
  </div>

  <!-- 공지 -->
  <div id="articleContainer">
    <h2>공지사항</h2>
    <c:choose>
      <c:when test="${not empty articles}">
        <table id="articletable">
          <thead><tr><th>번호</th><th>제목</th><th>조회수</th><th>작성일</th></tr></thead>
          <tbody>
            <c:forEach var="article" items="${articles}">
              <tr>
                <td>${article.id}</td>
                <td>
                  <form action="${pageContext.request.contextPath}/article/Detail" method="post">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                    <input type="hidden" name="id" value="${article.id}">
                    <button type="submit" style="background:none;border:none;color:blue;cursor:pointer;text-decoration:underline;">${article.name}</button>
                  </form>
                </td>
                <td>${article.viewcount}</td>
                <td>${article.regDate}</td>
              </tr>
            </c:forEach>
          </tbody>
        </table>
      </c:when>
      <c:otherwise><p style="color:#777;">등록된 공지사항이 없습니다.</p></c:otherwise>
    </c:choose>
  </div>
</main>

<!-- 푸터 -->
<footer>
  <ul>
    <li><a href="#">소개</a></li><li>|</li>
    <li><a href="#">개인정보 처리 방침</a></li><li>|</li>
    <li><a href="#">이용약관</a></li><li>|</li>
    <li><a href="#">입점/제휴 문의</a></li><li>|</li>
    <li><a href="#">고객지원</a></li>
  </ul>
  <div class="copy">© 2025 E-커머스 프로젝트 · 고객센터 02-0000-0000</div>
</footer>

<script>
  var slideIndex = 1;
  function showSlides(n) {
    var slides = document.getElementsByClassName("mySlides");
    var dots   = document.getElementsByClassName("dot");
    if (!slides.length) return;
    if (n > slides.length) { slideIndex = 1; }
    if (n < 1) { slideIndex = slides.length; }
    for (var i = 0; i < slides.length; i++) { slides[i].style.display = "none"; }
    for (var i = 0; i < dots.length; i++) { dots[i].className = dots[i].className.replace(" active", ""); }
    slides[slideIndex-1].style.display = "block";
    if (dots.length) dots[slideIndex-1].className += " active";
  }
  function plusSlides(n) { showSlides(slideIndex += n); }
  function currentSlide(n) { showSlides(slideIndex = n); }
  function autoSlide() { plusSlides(1); setTimeout(autoSlide, 4000); }
  showSlides(slideIndex); autoSlide();
</script>

</body>
</html>
