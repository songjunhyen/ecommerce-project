<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

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

  .container { max-width:1200px; margin:0 auto; padding:0 16px; }

  /* 슬라이드 */
  .slideshow-container {
    position: relative;
    max-width: 1200px;
    margin: 20px auto 0;
    aspect-ratio: 21/7;
    overflow: hidden;
    border-radius: 12px;
    background:#000;
  }
  @media (max-width: 768px){
    .slideshow-container { aspect-ratio: 16/9; }
  }
  .mySlides { display:flex; align-items:center; justify-content:center; width:100%; height:100%; }
  .main_slideImg { width:100%; height:100%; object-fit: contain; }

  .prev, .next {
    cursor: pointer; position: absolute; top: 50%; transform: translateY(-50%);
    width: 40px; height: 40px; display:flex; align-items:center; justify-content:center;
    background:rgba(0,0,0,0.5); color:#fff; font-size:20px; border-radius:50%;
  }
  .prev { left: 10px; } .next { right: 10px; }
  .dot-container { text-align:center; margin:10px 0; }
  .dot { cursor:pointer; height:10px; width:10px; margin:0 4px; background:#bbb; border-radius:50%; display:inline-block; }
  .active, .dot:hover { background:#111; }

  /* 상품 */
    .products-grid{
      display:grid;
      grid-template-columns: repeat(5, minmax(0,1fr)); /* 4 → 5 */
      gap:16px;
    }
    @media (max-width: 1024px){ .products-grid{ grid-template-columns: repeat(3,1fr);} }
    @media (max-width: 768px){  .products-grid{ grid-template-columns: repeat(2,1fr);} }
    @media (max-width: 480px){  .products-grid{ grid-template-columns: 1fr;} }


  .product-card{ border:1px solid #eee; border-radius:12px; overflow:hidden; text-align:left; background:#fff; }
  .product-thumb{ aspect-ratio: 1/1; width:100%; object-fit:cover; display:block; }
  .product-body{ padding:12px; }
  .product-title{ margin:0 0 6px; font-size:14px; line-height:1.3; }
  .product-meta{ display:flex; justify-content:space-between; align-items:center; font-size:12px; color:#666; }
  .product-price{ font-weight:700; color:#111; }
  .product-card form button{ width:100%; margin-top:8px; padding:8px 10px; border-radius:8px; border:1px solid #ddd; background:#fff; cursor:pointer; }
  .product-card form button:hover{ background:#111; color:#fff; }

  /* 페이징 */
  .pagination{ display:flex; justify-content:center; gap:6px; margin:24px 0; }
  .pagination a, .pagination span{
    min-width:36px; padding:8px 12px; border:1px solid #ddd; border-radius:8px; text-decoration:none; color:#111; display:inline-block;
  }
  .pagination a:hover{ background:#111; color:#fff; }
  .pagination .current{ background:#111; color:#fff; border-color:#111; }

  /* 공지 */
  .table-wrap { overflow:auto; border:1px solid #eee; border-radius:10px; }
  #articletable th, #articletable td { white-space:nowrap; }


</style>
</head>

<body>

<!-- 헤더 -->
<jsp:include page="/WEB-INF/views/jsp/includes/head1.jsp"/>

<main>
  <div class="container">
    <!-- 슬라이드 -->
    <div class="slideshow-container">
      <div class="mySlides">
        <img class="main_slideImg" src="${pageContext.request.contextPath}/event/banner1.png" loading="lazy" decoding="async" alt="배너 1">
      </div>
      <div class="mySlides">
        <img class="main_slideImg" src="${pageContext.request.contextPath}/event/banner2.png" loading="lazy" decoding="async" alt="배너 2">
      </div>
      <div class="mySlides">
        <img class="main_slideImg" src="${pageContext.request.contextPath}/event/banner3.png" loading="lazy" decoding="async" alt="배너 3">
      </div>
      <a class="prev" onclick="plusSlides(-1)">❮</a>
      <a class="next" onclick="plusSlides(1)">❯</a>
    </div>
    <div class="dot-container">
      <span class="dot" onclick="currentSlide(1)"></span>
      <span class="dot" onclick="currentSlide(2)"></span>
      <span class="dot" onclick="currentSlide(3)"></span>
    </div>

    <!-- 상품 (중복 .container 제거) -->
    <div id="productContainer">
      <h2>추천 상품</h2>
      <c:choose>
        <c:when test="${not empty products}">
          <div class="products-grid">
            <c:forEach var="product" items="${products}">
              <div class="product-card">
                <c:choose>
                  <c:when test="${not empty product.imageUrl}">
                    <c:set var="imageUrls" value="${fn:split(product.imageUrl, ',')}" />
                    <img class="product-thumb" src="${imageUrls[0]}" loading="lazy" decoding="async" alt="${product.name}">
                  </c:when>
                  <c:otherwise>
                    <div class="product-thumb" style="display:flex;align-items:center;justify-content:center;background:#f8f8f8;">이미지 없음</div>
                  </c:otherwise>
                </c:choose>

                <div class="product-body">
                  <h3 class="product-title">${product.name}</h3>
                  <div class="product-meta">
                    <span class="product-price"><fmt:formatNumber value="${product.price}" type="number"/>원</span>
                    <small>${product.category}</small>
                  </div>
                  <form action="${pageContext.request.contextPath}/product/Detail" method="post">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                    <input type="hidden" name="id" value="${product.id}">
                    <button type="submit">자세히 보기</button>
                  </form>
                </div>
              </div>
            </c:forEach>
          </div>
        </c:when>
        <c:otherwise><p style="color:#777;">표시할 상품이 없습니다.</p></c:otherwise>
      </c:choose>
    </div>

    <!-- 페이징 -->
    <div id="pagingContainer" class="pagination">
      <c:if test="${currentPage > 1}">
        <a href="?page=${currentPage - 1}">이전</a>
      </c:if>

      <c:forEach var="i" begin="${startPage}" end="${endPage}">
        <c:choose>
          <c:when test="${i == currentPage}"><span class="current">${i}</span></c:when>
          <c:otherwise><a href="?page=${i}">${i}</a></c:otherwise>
        </c:choose>
      </c:forEach>

      <c:if test="${currentPage < totalPages}">
        <a href="?page=${currentPage + 1}">다음</a>
      </c:if>
    </div>

    <!-- 공지 (중복 .container 제거 + 닫는 div 정리) -->
    <div id="articleContainer">
      <h2>공지사항</h2>
      <c:choose>
        <c:when test="${not empty articles}">
          <div class="table-wrap">
            <table id="articletable" style="width:100%; border-collapse:collapse;">
              <thead>
                <tr>
                  <th style="text-align:left; padding:8px; border-bottom:1px solid #ddd; width:5%;">번호</th>
                  <th style="text-align:left; padding:8px; border-bottom:1px solid #ddd;">제목</th>
                  <th style="text-align:left; padding:8px; border-bottom:1px solid #ddd; width:10%;">조회수</th>
                  <th style="text-align:left; padding:8px; border-bottom:1px solid #ddd; width:18%;">작성일</th>
                </tr>
              </thead>
              <tbody>
                <c:forEach var="article" items="${articles}">
                  <tr>
                    <td style="padding:8px; border-bottom:1px solid #f1f1f1;">${article.id}</td>
                    <td style="padding:8px; border-bottom:1px solid #f1f1f1;">
                      <form action="${pageContext.request.contextPath}/article/Detail" method="post" style="display:inline;">
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                        <input type="hidden" name="id" value="${article.id}" />
                        <button type="submit" style="background:none;border:none;color:#1a73e8;cursor:pointer;text-decoration:underline;padding:0;font-size:inherit;">
                          ${article.title}
                        </button>
                      </form>
                    </td>
                    <td style="padding:8px; border-bottom:1px solid #f1f1f1;">${article.viewCount}</td>
                    <td style="padding:8px; border-bottom:1px solid #f1f1f1;">${article.regDate}</td>
                  </tr>
                </c:forEach>
              </tbody>
            </table>
          </div>
        </c:when>
        <c:otherwise>
          <p style="color:#777;">등록된 공지사항이 없습니다.</p>
        </c:otherwise>
      </c:choose>
    </div>

  </div> <!-- /.container -->
</main>

<!-- 푸터 -->
<jsp:include page="/WEB-INF/views/jsp/includes/foot1.jsp"/>


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
