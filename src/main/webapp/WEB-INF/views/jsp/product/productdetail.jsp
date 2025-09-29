<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags"%>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <title>제품 상세보기</title>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

  <!-- CSRF -->
  <meta name="_csrf"        content="${_csrf.token}">
  <meta name="_csrf_header" content="${_csrf.headerName}">

  <style>
    /* ===== 페이지 네임스페이스로 헤더/푸터와 충돌 방지 ===== */
    #productDetailPage { max-width: 1200px; margin: 0 auto; padding: 16px; }
    #productDetailPage .title { font-size: 22px; font-weight: 700; margin-bottom: 12px; }

    /* 레이아웃 */
    #productDetailPage .grid {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 24px;
    }
    @media (max-width: 900px){
      #productDetailPage .grid { grid-template-columns: 1fr; }
    }

    /* ===================== 이미지 영역 (반응형 고정 크기 느낌) ===================== */
    /* 캐러셀 컨테이너: 화면폭의 90%까지만 쓰고 최대 480px로 제한, 정사각형 유지 */
    #productDetailPage .pd-carousel {
      position: relative;
      border-radius: 10px;
      width: 90%;
      max-width: 480px;     /* 최대 크기 */
      aspect-ratio: 1 / 1;  /* 정사각형 유지 */
      margin: 0 auto;       /* 가운데 정렬 */
    }
    /* 뷰포트는 컨테이너에 맞춰 꽉 채움 */
    #productDetailPage .pd-carousel-viewport {
      width: 100%;
      height: 100%;
      overflow: hidden;
      border: 1px solid #eee;
      border-radius: 10px;
      background: #f8f8f8;
    }
    /* 트랙은 높이를 100%로 유지 */
    #productDetailPage .pd-carousel-track {
      display: flex;
      transition: transform 0.4s ease;
      will-change: transform;
      height: 100%;
    }
    /* 각 슬라이드는 컨테이너 크기와 동일한 폭/높이 */
    #productDetailPage .pd-slide {
      min-width: 100%;
      height: 100%;
    }
    /* 이미지: 컨테이너를 꽉 채우되 잘릴 수 있음(cover) → contain으로 바꾸면 여백 포함 */
    #productDetailPage .pd-slide img {
      width: 100%;
      height: 100%;
      object-fit: cover;  /* 필요시 contain 으로 변경 */
      display: block;
    }

    /* 1장만 있을 때도 같은 규격으로 보여주기 */
    #productDetailPage .images {
      width: 90%;
      max-width: 480px;
      aspect-ratio: 1 / 1;
      margin: 0 auto;
      border-radius: 10px;
      overflow: hidden;
      border: 1px solid #eee;
      background: #f8f8f8;
    }
    #productDetailPage .images img {
      width: 100%;
      height: 100%;
      object-fit: cover;  /* 필요시 contain */
      display: block;
    }

    /* 네비게이션 버튼 */
    #productDetailPage .pd-nav {
      position: absolute;
      top: 50%;
      transform: translateY(-50%);
      background: rgba(0,0,0,.45);
      color: #fff;
      border: 0;
      width: 34px;
      height: 34px;
      border-radius: 999px;
      cursor: pointer;
      display: flex;
      align-items: center;
      justify-content: center;
      z-index: 5;
    }
    #productDetailPage .pd-prev { left: 8px; }
    #productDetailPage .pd-next { right: 8px; }
    #productDetailPage .pd-nav:hover { background: rgba(0,0,0,.6); }

    /* 하단 점 표시 */
    #productDetailPage .pd-dots {
      position: absolute;
      left: 50%;
      transform: translateX(-50%);
      bottom: 8px;
      display: flex;
      gap: 6px;
    }
    #productDetailPage .pd-dot {
      width: 8px;
      height: 8px;
      border-radius: 50%;
      border: 0;
      cursor: pointer;
      background: rgba(255,255,255,.6);
    }
    #productDetailPage .pd-dot.is-active { background: #fff; }

    /* 모바일에서 살짝 더 작게 */
    @media (max-width: 480px){
      #productDetailPage .pd-carousel,
      #productDetailPage .images {
        width: 95%;
        max-width: 360px;
      }
    }

    /* ===================== 정보 테이블 ===================== */
    #productDetailPage table.detail { width: 100%; border-collapse: collapse; }
    #productDetailPage table.detail th,
    #productDetailPage table.detail td { border: 1px solid #e5e7eb; padding: 10px; }
    #productDetailPage table.detail th { background: #f8fafc; text-align: left; width: 120px; }

    /* ===================== 폼/버튼 ===================== */
    #productDetailPage .form-row { display:flex; gap:8px; align-items:center; flex-wrap: wrap; }
    #productDetailPage select,
    #productDetailPage input[type="number"] {
      border: 1px solid #ddd; border-radius: 8px; padding: 8px 10px;
    }
    #productDetailPage .btn {
      border: 1px solid #111; background: #111; color: #fff;
      padding: 10px 14px; border-radius: 10px; cursor: pointer;
    }
    #productDetailPage .btn.ghost { background:#fff; color:#111; }
    #productDetailPage .btn:hover { opacity: 0.95; }
    #productDetailPage .actions { margin-top: 14px; display:flex; gap:10px; flex-wrap: wrap; }

    /* ===================== 섹션 ===================== */
    #productDetailPage .section { margin-top: 28px; }
    #productDetailPage .section h3 { margin: 0 0 10px; }

    /* ===================== 리뷰 박스 ===================== */
    #productDetailPage .review-box { border:1px solid #eee; border-radius:10px; padding:10px; }
    #productDetailPage .review-item { border-top:1px solid #eee; padding:10px 0; }
    #productDetailPage .review-item:first-child { border-top:none; }
    #productDetailPage .review-writer { font-weight:600; }
    #productDetailPage .review-date { font-size:12px; color:#888; }

    /* ===================== 안내 라벨 ===================== */
    #productDetailPage .note { font-size: 13px; color:#666; margin-top:8px; }

    /* ===================== 모달 ===================== */
    #productDetailPage .modal-backdrop {
      display: none; position: fixed; inset: 0; background: rgba(0,0,0,.45);
      align-items: center; justify-content: center; z-index: 999;
    }
    #productDetailPage .modal {
      background: #fff; width: 100%; max-width: 420px; border-radius: 12px; overflow: hidden;
      box-shadow: 0 10px 30px rgba(0,0,0,.2);
    }
    #productDetailPage .modal-body { padding: 16px; }
    #productDetailPage .field { display: grid; gap: 6px; margin-bottom: 10px; }
    #productDetailPage .field input {
      border: 1px solid #ddd; border-radius: 8px; padding: 8px 10px;
    }
    #productDetailPage .modal-actions { display:flex; justify-content:flex-end; gap:8px; margin-top: 10px; }
  </style>


</head>

<body class="layout-sticky">
  <%@ include file="../includes/head1.jsp"%>
 <main id="page">
  <div id="productDetailPage">
    <div class="title">제품 상세보기</div>

    <div class="grid">
<!-- 이미지 영역 -->
<div>
  <c:choose>
    <c:when test="${not empty product.imageUrl}">
      <c:set var="imageUrls" value="${fn:split(product.imageUrl, ',')}"/>

      <!-- 1장일 때: 그대로 표시 -->
      <c:if test="${fn:length(imageUrls) == 1}">
        <div class="images">
          <img src="${imageUrls[0]}" alt="Product Image" loading="lazy"/>
        </div>
      </c:if>

      <!-- 2장 이상일 때: 슬라이드 -->
      <c:if test="${fn:length(imageUrls) > 1}">
        <div class="pd-carousel" aria-roledescription="carousel">
          <div class="pd-carousel-viewport">
            <div class="pd-carousel-track">
              <c:forEach var="url" items="${imageUrls}">
                <div class="pd-slide"><img src="${url}" alt="Product Image" loading="lazy"/></div>
              </c:forEach>
            </div>
          </div>

          <button type="button" class="pd-nav pd-prev" aria-label="Previous">&#10094;</button>
          <button type="button" class="pd-nav pd-next" aria-label="Next">&#10095;</button>

          <div class="pd-dots">
            <c:forEach var="url" items="${imageUrls}" varStatus="st">
              <button type="button" class="pd-dot" data-index="${st.index}" aria-label="Go to slide ${st.index + 1}"></button>
            </c:forEach>
          </div>
        </div>
      </c:if>

    </c:when>
    <c:otherwise>
      <div class="no-image">이미지가 없습니다.</div>
    </c:otherwise>
  </c:choose>
</div>


      <!-- 정보 영역 -->
      <div>
        <table class="detail">
          <tbody>
            <tr><th>번호</th>     <td>${product.id}</td></tr>
            <tr><th>카테고리</th> <td>${product.category}</td></tr>
            <tr><th>제품명</th>   <td>${product.name}</td></tr>
            <tr><th>금액</th>     <td><strong><c:out value="${product.price}"/></strong> 원</td></tr>
            <tr><th>제조사</th>   <td>${product.maker}</td></tr>
            <tr><th>색상</th>     <td>${product.color}</td></tr>
            <tr><th>사이즈</th>   <td>${product.size}</td></tr>
            <tr><th>제품설명</th> <td style="white-space:pre-line;">${product.description}</td></tr>
            <tr><th>조회수</th>   <td>${product.viewcount}</td></tr>
            <tr><th>작성일</th>   <td>${fn:replace(product.regDate, 'T', ' ')}</td></tr>
          </tbody>
        </table>

        <!-- 비회원 영역 -->
        <sec:authorize access="!isAuthenticated()">
          <form id="guestForm" action="/Temporarily/Cart/add" method="post" class="section">
            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
            <input type="hidden" name="productid" value="${product.id}">
            <input type="hidden" name="name"      value="${product.name}">
            <input type="hidden" name="price"     value="${product.price}">

            <div class="form-row" style="margin-top:6px;">
              <label>사이즈</label>
              <select name="size">
                <option value="xs">XS</option><option value="s">S</option>
                <option value="m">M</option><option value="l">L</option><option value="xl">XL</option>
              </select>

              <label>색상</label>
              <select name="color">
                <option value="Red">Red</option><option value="Black">Black</option>
                <option value="White">White</option><option value="Blue">Blue</option>
              </select>

              <label>수량</label>
              <input type="number" name="count" step="1" min="1" max="${product.count}" value="1" style="width:90px;">
            </div>

            <div class="actions">
              <!-- 카트 담기: submit -->
              <button id="guestAddToCartBtn" type="submit" class="btn ghost">카트에 담기</button>
              <!-- 바로 구매: 모달 오픈 -->
              <button id="guestBuyNowBtn" type="button" class="btn">바로 구매</button>
            </div>
          </form>
        </sec:authorize>

        <!-- 회원 영역 -->
        <sec:authorize access="isAuthenticated()">
          <form id="memberForm" action="/Cart/add" method="post" class="section">
            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
            <input type="hidden" name="productid" value="${product.id}">
            <input type="hidden" name="name"      value="${product.name}">
            <input type="hidden" name="price"     value="${product.price}">

            <div class="form-row" style="margin-top:6px;">
              <label>사이즈</label>
              <select name="size">
                <option value="xs">XS</option><option value="s">S</option>
                <option value="m">M</option><option value="l">L</option><option value="xl">XL</option>
              </select>

              <label>색상</label>
              <select name="color">
                <option value="Red">Red</option><option value="Black">Black</option>
                <option value="White">White</option><option value="Blue">Blue</option>
              </select>

              <label>수량</label>
              <input type="number" name="count" step="1" min="1" max="${product.count}" value="1" style="width:90px;">
            </div>

            <div class="actions">
              <button type="submit" class="btn ghost">카트에 담기</button>
              <button id="buybutton" type="button" class="btn">바로 구매</button>
            </div>
          </form>
        </sec:authorize>

        <!-- 관리자/작성자 액션 (필요 시 유지) -->
        <div class="section" style="display:flex; gap:8px; flex-wrap:wrap;">
          <sec:authorize access="isAuthenticated()">
            <c:if test="${userRole == 'admin' && adminClass == 1}">
              <form action="/product/Modify" method="get" style="display:inline;">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                <input type="hidden" name="id" value="${product.id}">
                <button type="submit" class="btn ghost">수정</button>
              </form>
              <form action="/product/delete" method="post" style="display:inline;">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                <input type="hidden" name="id" value="${product.id}">
                <button type="submit" class="btn ghost" onclick="return confirm('정말 삭제하시겠습니까?');">삭제</button>
              </form>
            </c:if>
          </sec:authorize>

          <c:if test="${userid eq product.writer}">
            <form action="/product/Modify" method="get" style="display:inline;">
              <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
              <input type="hidden" name="id" value="${product.id}">
              <button type="submit" class="btn ghost">수정</button>
            </form>
            <form action="/product/delete" method="post" style="display:inline;">
              <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
              <input type="hidden" name="id" value="${product.id}">
              <button type="submit" class="btn ghost" onclick="return confirm('정말 삭제하시겠습니까?');">삭제</button>
            </form>
          </c:if>

          <button class="btn" onclick="location.href='/product/list'">목록으로</button>
        </div>
      </div>
    </div>

    <!-- 별점 & 리뷰 -->
    <div class="section">
      <h3>평균 별점: <span id="averageStar">0.0</span></h3>
      <div class="note">리뷰는 <strong>구매자만</strong> 작성할 수 있으며, 마이페이지 &gt; 구매내역에서 작성해주세요.</div>
    </div>

    <div class="section">
      <h3>리뷰</h3>
      <div id="reviewsContainer" class="review-box"></div>
    </div>

    <!-- 비회원 구매 모달 (오버레이) -->
    <div id="emailPhoneModalBackdrop" class="modal-backdrop">
      <div class="modal" role="dialog" aria-modal="true">
        <div class="modal-body">
          <h3 style="margin:0 0 12px;">비회원 구매 정보</h3>
          <div class="field">
            <label for="guestname">이름</label>
            <input type="text" id="guestname" name="guestname" required>
          </div>
          <div class="field">
            <label for="email">이메일</label>
            <input type="email" id="email" name="email" required>
          </div>
          <div class="field">
            <label for="phonenum">전화번호</label>
            <input type="text" id="phonenum" name="phonenum" required>
          </div>

          <div class="modal-actions">
            <button id="closeModal" type="button" class="btn ghost">취소</button>
            <button id="submitEmailPhone" type="button" class="btn">확인</button>
          </div>
        </div>
      </div>
    </div>
  </div>
</main>
  <%@ include file="../includes/foot1.jsp"%>

  <script>
     var productId  = "${product.id}";
      var csrfToken  = $('meta[name="_csrf"]').attr('content');
      var csrfHeader = $('meta[name="_csrf_header"]').attr('content');
      const BUY_URL  = "<c:url value='/buying'/>";

    // jQuery가 한 번만 로드되도록: head1.jsp에 이미 있으면 이 페이지의 jQuery <script>는 제거
    console.log("[jQuery]", $.fn && $.fn.jquery);

    // ── 위임 바인딩(안전) ───────────────────────────────────────────
    $(document).on("click", "#buybutton", function(e){
        e.preventDefault();
        const $f    = $("#memberForm");
        const size  = $f.find("select[name='size']").val();
        const color = $f.find("select[name='color']").val();
        const qty   = parseInt($f.find("input[name='count']").val() || "1", 10);
        const price = parseInt($f.find("input[name='price']").val() || "0", 10);
        const total = qty * price;
        buyMember(productId, size, color, total, qty);
      });

      $(document).on("click", "#guestBuyNowBtn", function(e){
        e.preventDefault();
        $("#emailPhoneModalBackdrop").css("display","flex");
      });

    $(document).on("click", "#submitEmailPhone", function(e){
        e.preventDefault();
        const $f    = $("#guestForm");
        const size  = $f.find("select[name='size']").val();
        const color = $f.find("select[name='color']").val();
        const qty   = parseInt($f.find("input[name='count']").val() || "1", 10);
        const price = parseInt($f.find("input[name='price']").val() || "0", 10);
        const total = qty * price;

        const email     = $("#email").val().trim();
        const phonenum  = $("#phonenum").val().trim();
        const guestname = $("#guestname").val().trim();

        if(!guestname || !email || !phonenum){
          alert("이름/이메일/전화번호를 모두 입력해주세요.");
          return;
        }

        buyGuest(guestname, email, phonenum, productId, size, color, total, qty);
      });

      $(document).on("click", "#closeModal", function(){
        $("#emailPhoneModalBackdrop").hide();
      });

      $(document).on("click", "#emailPhoneModalBackdrop", function(e){
        if (e.target.id === "emailPhoneModalBackdrop") $(this).hide();
      });

      $(document).on("keydown", function(e){
        if (e.key === "Escape") $("#emailPhoneModalBackdrop").hide();
      });

    // ── AJAX 함수 ───────────────────────────────────────────────────
    function setCsrf(xhr){
        if (csrfToken && csrfHeader) xhr.setRequestHeader(csrfHeader, csrfToken);
      }

  function buyMember(productId, size, color, totalPrice, qty){
    $.ajax({
      url: BUY_URL,
      type: "POST",
      data: {
        productid: productId,
        sizecolor: `${size}-${color}`,
        priceall: totalPrice,
        count: qty
      },
      beforeSend: setCsrf,
      success: function(){
        location.href = "<c:url value='/confirmation'/>";
      },
      error: function(xhr){
        console.error("buyMember error:", xhr.status, xhr.responseText);
        alert("구매 처리 중 오류가 발생했습니다.");
      }
    });
  }

  function buyGuest(guestname, email, phonenum, productId, size, color, totalPrice, qty){
    $.ajax({
      url: BUY_URL,
      type: "POST",
      data: {
        guestname,
        email,
        phonenum,
        productid: productId,
        sizecolor: `${size}-${color}`,
        priceall: totalPrice,
        count: qty
      },
      beforeSend: setCsrf,
      success: function(){
        $("#emailPhoneModalBackdrop").hide();
        location.href = "<c:url value='/confirmation'/>";
      },
      error: function(xhr){
        console.error("buyGuest error:", xhr.status, xhr.responseText);
        alert("구매 처리 중 오류가 발생했습니다.");
      }
    });
  }

    // (선택) 초기 데이터 로드
    $(function(){
      loadReviews();
      loadAverageStar();
    });

    function loadReviews(){
      $.get("/Review/list", { productid: productId }, function(list){
        let html = '';
        $.each(list, function(_, r){
          html += '<div class="review-item">';
          html +=   '<div class="review-writer">'+ (r.writer || '') +'</div>';
          html +=   '<div style="margin:6px 0;">'+ (r.reviewText || '') +'</div>';
          html +=   '<div class="review-date">'+ (r.regDate || '') +'</div>';
          html += '</div>';
        });
        $("#reviewsContainer").html(html || '<div style="color:#888;">리뷰가 없습니다.</div>');
      });
    }

    function loadAverageStar(){
      $.get("/Review/getstar", { productid: productId }, function(avg){
        $("#averageStar").text(Number(avg || 0).toFixed(1));
      });
    }
  </script>

</body>
</html>
