<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags"%>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <title>제품 상세보기</title>

  <!-- jQuery (head1.jsp에서 이미 로드한다면 이 줄 제거 가능) -->
  <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>

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

    /* 이미지 영역 */
    #productDetailPage .images { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 10px; }
    #productDetailPage .images img { width: 100%; height: 220px; object-fit: cover; border-radius: 10px; border: 1px solid #eee; }
    #productDetailPage .no-image { padding: 24px; text-align: center; border: 1px dashed #ddd; border-radius: 10px; color: #999; }

    /* 정보 테이블 */
    #productDetailPage table.detail { width: 100%; border-collapse: collapse; }
    #productDetailPage table.detail th,
    #productDetailPage table.detail td { border: 1px solid #e5e7eb; padding: 10px; }
    #productDetailPage table.detail th { background: #f8fafc; text-align: left; width: 120px; }

    /* 폼/버튼 */
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

    /* 섹션 */
    #productDetailPage .section { margin-top: 28px; }
    #productDetailPage .section h3 { margin: 0 0 10px; }

    /* 리뷰 박스 */
    #productDetailPage .review-box { border:1px solid #eee; border-radius:10px; padding:10px; }
    #productDetailPage .review-item { border-top:1px solid #eee; padding:10px 0; }
    #productDetailPage .review-item:first-child { border-top:none; }
    #productDetailPage .review-writer { font-weight:600; }
    #productDetailPage .review-date { font-size:12px; color:#888; }

    /* 안내 라벨 */
    #productDetailPage .note { font-size: 13px; color:#666; margin-top:8px; }

    /* 모달 */
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

  <script>
    var productId  = "${product.id}";
    var csrfToken, csrfHeader;

    $(function(){
      csrfToken  = $('meta[name="_csrf"]').attr('content');
      csrfHeader = $('meta[name="_csrf_header"]').attr('content');

      /* ===== 회원: 바로구매 즉시 처리 ===== */
      $("#buybutton").on("click", function(e){
        e.preventDefault();
        var $f    = $("#memberForm");
        var size  = $f.find("select[name='size']").val();
        var color = $f.find("select[name='color']").val();
        var qty   = parseInt($f.find("input[name='count']").val() || "1", 10);
        var price = parseInt($f.find("input[name='price']").val() || "0", 10);
        var total = qty * price;
        buyMember(productId, size, color, total);
      });

      /* ===== 비회원: 바로구매 → 모달 오픈 ===== */
      $("#guestBuyNowBtn").on("click", function(e){
        e.preventDefault();

        // 선택값 캡처
        var $f    = $("#guestForm");
        var size  = $f.find("select[name='size']").val();
        var color = $f.find("select[name='color']").val();
        var qty   = parseInt($f.find("input[name='count']").val() || "1", 10);
        var price = parseInt($f.find("input[name='price']").val() || "0", 10);
        var total = qty * price;

        // 모달 열기
        $("#emailPhoneModalBackdrop").css("display","flex");

        // 확인 버튼(중복 바인딩 방지)
        $("#submitEmailPhone").off("click").on("click", function(){
          var email    = $("#email").val();
          var phonenum = $("#phonenum").val();
          buyGuest(email, phonenum, productId, size, color, total);
        });
      });

      // 모달 닫기 (취소/백드롭/ESC)
      $("#closeModal").on("click", function(){ $("#emailPhoneModalBackdrop").hide(); });
      $("#emailPhoneModalBackdrop").on("click", function(e){
        if (e.target.id === "emailPhoneModalBackdrop") { $(this).hide(); }
      });
      $(document).on("keydown", function(e){
        if (e.key === "Escape") { $("#emailPhoneModalBackdrop").hide(); }
      });

      // 리뷰 로딩
      loadReviews();
      loadAverageStar();
    });

    /* === AJAX 함수들 === */
    function buyMember(productId, size, color, totalPrice){
      $.ajax({
        url: '../buying',
        type: 'POST',
        data: { productid: productId, sizecolor: size + '-' + color, priceall: totalPrice },
        beforeSend: function(xhr){ if(csrfToken && csrfHeader){ xhr.setRequestHeader(csrfHeader, csrfToken); } },
        success: function(){ location.href = "/confirmation"; },
        error: function(e){ console.error(e); }
      });
    }

    function buyGuest(email, phonenum, productId, size, color, totalPrice){
      $.ajax({
        url: '../buying',
        type: 'POST',
        data: { email: email, phonenum: phonenum, productid: productId, sizecolor: size + '-' + color, priceall: totalPrice },
        beforeSend: function(xhr){ if(csrfToken && csrfHeader){ xhr.setRequestHeader(csrfHeader, csrfToken); } },
        success: function(){ $("#emailPhoneModalBackdrop").hide(); location.href = "/confirmation"; },
        error: function(e){ console.error(e); }
      });
    }

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
</head>

<body>
  <%@ include file="../includes/head1.jsp"%>

  <div id="productDetailPage">
    <div class="title">제품 상세보기</div>

    <div class="grid">
      <!-- 이미지 영역 -->
      <div>
        <c:choose>
          <c:when test="${not empty product.imageUrl}">
            <c:set var="imageUrls" value="${fn:split(product.imageUrl, ',')}"/>
            <div class="images">
              <c:forEach var="url" items="${imageUrls}">
                <img src="${url}" alt="Product Image" />
              </c:forEach>
            </div>
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
              <form action="/product/modify" method="get" style="display:inline;">
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
            <form action="/product/modify" method="get" style="display:inline;">
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

  <%@ include file="../includes/foot1.jsp"%>
</body>
</html>
