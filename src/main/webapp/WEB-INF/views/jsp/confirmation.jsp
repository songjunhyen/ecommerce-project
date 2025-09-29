<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <title>구매 정보 추가입력</title>

  <!-- 주소검색 -->
  <script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>

  <!-- jQuery -->
  <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

  <!-- iamport.js (카카오페이 등 PG 연동) -->
  <script src="https://cdn.iamport.kr/js/iamport.payment-1.1.5.js"></script>

  <!-- 네이버페이 (테스트 SDK, 실제키 교체 필요) -->
  <script src="https://nsp.pay.naver.com/sdk/js/naverpay.min.js"></script>

  <!-- 토스페이 (사용 시 구현 추가) -->
  <script src="https://js.tosspayments.com/v2/standard"></script>

  <!-- CSRF -->
  <meta name="_csrf" content="${_csrf.token}">
  <meta name="_csrf_header" content="${_csrf.headerName}">

  <!-- ====== 세션 값 정리 (공용 변수) ====== -->
  <c:set var="pmap" value="${sessionScope.purchaseInfo}" />
  <c:set var="P" value="${pmap.Pinfo}" />
  <c:set var="N" value="${pmap.NPinfo}" />

  <c:set var="orderNumber" value="${not empty P ? P.orderNumber : (not empty N ? N.orderNumber : '')}" />
  <c:set var="productName" value="${not empty P ? P.productname : (not empty N ? N.productname : '')}" />
  <c:set var="totalPrice"  value="${not empty P ? P.price : (not empty N ? N.price : 0)}" />
  <c:set var="emailVal"    value="${not empty P ? P.email : (not empty N ? N.email : '')}" />
  <c:set var="phoneVal"    value="${not empty N ? N.phonenum : ''}" />
  <c:set var="totalQty"    value="${not empty P ? P.quantity : (not empty N ? N.quantity : 0)}" />

  <style>
    /* ---------- Base ---------- */
    :root{
      --bg:#f6f7fb;
      --card:#fff;
      --line:#e5e7eb;
      --text:#111;
      --muted:#6b7280;
      --brand:#111;
      --radius:14px;
    }
    *{box-sizing:border-box}
    body{
      margin:0; font-family: system-ui, -apple-system, Segoe UI, Roboto, 'Noto Sans KR', sans-serif;
      background:var(--bg); color:var(--text); line-height:1.55;
    }

    /* ---------- Layout ---------- */
    .page{
      max-width: 960px;
      margin: 40px auto;
      padding: 0 16px;
    }
    .page h1{
      margin:0 0 16px; font-size:28px; font-weight:800;
    }
    .sub{
      color:var(--muted); margin-bottom:22px;
    }

    .grid{
      display:grid; gap:18px;
      grid-template-columns: 1fr 1fr;
    }
    @media (max-width: 900px){ .grid{ grid-template-columns: 1fr; } }

    .card{
      background:var(--card);
      border:1px solid var(--line);
      border-radius: var(--radius);
      padding: 18px;
      box-shadow: 0 6px 18px rgba(0,0,0,.04);
    }
    .card h2{
      margin:0 0 12px; font-size:18px;
    }

    /* ---------- Summary ---------- */
    .summary{ display:grid; gap:10px; }
    .kv{ display:flex; justify-content:space-between; gap:10px; border-bottom:1px dashed var(--line); padding:8px 0; }
    .kv:last-child{ border-bottom:0; padding-bottom:0; }
    .badge{
      display:inline-block; padding:4px 8px; border-radius:999px;
      background:#111; color:#fff; font-size:12px; letter-spacing:.2px;
    }
    .total-price{ font-weight:800; font-size:20px; }

    /* ---------- Form ---------- */
    .form-grid{
      display:grid; gap:14px;
      grid-template-columns: 1fr 1fr;
    }
    @media (max-width: 700px){ .form-grid{ grid-template-columns: 1fr; } }

    .field{ display:grid; gap:6px; }
    .label{ font-size:13px; color:var(--muted); }
    .req::after{ content:" *"; color:#ef4444; }
    input[type="text"], input[type="email"]{
      width:100%; padding:12px 12px; border:1px solid var(--line); border-radius:10px; background:#fff;
    }
    input[readonly]{ background:#fafafa; color:#555; }

    .address-row{ display:grid; grid-template-columns: 2fr auto; gap:8px; }
    .btn{
      padding:11px 14px; border-radius:10px; border:1px solid var(--brand);
      background:var(--brand); color:#fff; cursor:pointer; font-weight:600;
    }
    .btn.ghost{ background:#fff; color:var(--brand); }
    .btn.full{ width:100%; }
    .actions{ display:flex; gap:10px; margin-top:10px; }

    /* ---------- Modal ---------- */
    #paymentMethodModal{
      display:none; position:fixed; inset:0; z-index:999;
      align-items:center; justify-content:center;
      background: rgba(0,0,0,.45);
      padding:16px;
    }
    .modal{
      width:100%; max-width:420px; background:#fff; border-radius:16px; overflow:hidden;
      border:1px solid var(--line); box-shadow: 0 10px 30px rgba(0,0,0,.2);
      animation: pop .18s ease-out;
    }
    @keyframes pop{ from{ transform: translateY(6px); opacity:.8;} to{ transform:none; opacity:1;} }
    .modal-head{ display:flex; align-items:center; justify-content:space-between; padding:14px 16px; border-bottom:1px solid var(--line); }
    .modal-body{ padding:16px; }
    .close-x{ border:0; background:transparent; font-size:20px; line-height:1; cursor:pointer; }

    /* ---------- small helpers ---------- */
    .muted{ color:var(--muted); font-size:13px; }
    .space{ height:8px; }
  </style>

  <script>
    var csrfToken, csrfHeader;

    // JSP → JS 상수 (EL은 여기서만 1회 사용)
    const ORDER_NO    = "<c:out value='${orderNumber}'/>";
    const PRODUCT_NM  = "<c:out value='${productName}'/>";
    const TOTAL_PRICE = Number("<c:out value='${totalPrice}'/>");

    $(function(){
      csrfToken  = $('meta[name="_csrf"]').attr('content');
      csrfHeader = $('meta[name="_csrf_header"]').attr('content');

      // 결제 전 검증 + 결제수단 선택 노출
      $("#payButton").on("click", function(e){
        e.preventDefault();
        updateFullAddress();
        Payment(TOTAL_PRICE, ORDER_NO, PRODUCT_NM);
      });

      // 각 결제수단 핸들러
      $("#payWithKakaoPay").on("click", onKakaoPay);
      $("#payWithNaverPay").on("click", onNaverPay);
      $("#payWithTossPay").on("click", function(e){
        e.preventDefault();
        alert("토스페이는 아직 구현되지 않았습니다.");
      });

      // 모달 닫기
      $("#closeModal, #paymentMethodModal").on("click", function(e){
        if (e.target.id === "paymentMethodModal" || e.target.id === "closeModal"){
          $("#paymentMethodModal").hide();
        }
      });
    });

    // ====== 서버 검증 (/validatePurchase) ======
    function Payment(price, orderNumber, productname){
      if (!validateInputs()) return;

      $.ajax({
        url: '/validatePurchase',
        type: 'POST',
        data: {
          orderNumber: orderNumber,
          price: price,
          phone: $('#phone').val(),
          address: $('#address').val(),
          paymentMethod: "kakao",    // 검증용 기본값(실결제 선택은 모달에서)
          productname: productname
        },
        beforeSend: setCsrfHeader,
        success: function(resp){
          if (resp === "success") {
            $("#paymentMethodModal").css("display","flex"); // 디자인상 flex로 표시
          } else {
            alert("검증 실패: " + resp);
          }
        },
        error: function(){
          alert('검증 요청 중 오류가 발생했습니다.');
        }
      });
    }

    function validateInputs(){
      if ($("#phone").val().trim() === "") {
        alert("전화번호를 입력해주세요.");
        $("#phone").focus();
        return false;
      }
      if (!ORDER_NO || !TOTAL_PRICE) {
        alert("주문번호/금액 정보가 없습니다. 다시 시도해주세요.");
        return false;
      }
      return true;
    }

    // ====== 카카오페이 (Iamport) ======
    function onKakaoPay(e){
      e.preventDefault();
      var IMP = window.IMP;
      IMP.init("imp30108185"); // TODO: 가맹점 식별코드 교체

      IMP.request_pay({
        pg: "kakaopay.TC0ONETIME",
        pay_method: "card",
        merchant_uid: ORDER_NO,
        name: PRODUCT_NM,
        amount: TOTAL_PRICE,
        buyer_email: $('#email').val(),
        buyer_name:  $('#name').val(),
        buyer_tel:   $('#phone').val(),
        buyer_addr:  $("#frontaddress").val(),
        buyer_postcode: $("#postcode").val()
      }, function (rsp) {
        if (rsp.success) {
          $.ajax({
            url: "/pay/completePurchase",
            method: "POST",
            dataType: "json",
            data: { imp_uid: rsp.imp_uid, merchant_uid: rsp.merchant_uid },
            beforeSend: setCsrfHeader,
            success: function(data){
              if ((typeof data === "string" && data === "success") ||
                  (typeof data === "object" && data.result === "success")) {
                alert('결제 완료!');
                afterPaidCleanup();
              } else {
                alert('결제는 승인되었으나 DB 저장에 실패했습니다. 관리자에게 문의해주세요.');
              }
            },
            error: function(){ alert('결제 저장 중 오류가 발생했습니다.'); }
          });
        } else {
          alert(rsp.error_msg || '결제가 취소되었거나 실패했습니다.');
        }
      });
    }

    // ====== 네이버페이 ======
    function onNaverPay(e){
      e.preventDefault();

      var oPay = Naver.Pay.create({
        mode: "development",
        clientId: "HN3GGCMDdTgGUfl0kFCo",  // TODO: 교체
        chainId:  "RjVXMjFTbjhoeSs",       // TODO: 교체
        openType: "popup",
        onAuthorize: function(oData){
          if (oData && oData.resultCode === "Success") {
            $.ajax({
              url: '/validPurchaseNaver',
              type: 'POST',
              data: {
                imp_uid: oData.paymentId,
                orderNumber: ORDER_NO,
                price: TOTAL_PRICE,
                phone: $('#phone').val(),
                address: $('#address').val(),
                paymentMethod: "naver",
                productname: PRODUCT_NM
              },
              beforeSend: setCsrfHeader,
              success: function(resp){
                if ((typeof resp === "string" && resp === "success") ||
                    (resp && resp.result === "success")) {
                  alert('결제 완료!');
                  afterPaidCleanup();
                } else {
                  alert('검증 실패: ' + resp);
                }
              },
              error: function(){
                alert('검증 요청 중 오류가 발생했습니다.');
              }
            });
          } else {
            alert('네이버페이 인증이 실패했습니다.');
          }
        }
      });

      oPay.open({
        merchantUserKey: "development",
        merchantPayKey:  ORDER_NO,
        productName:     PRODUCT_NM,
        totalPayAmount:  TOTAL_PRICE,
        taxScopeAmount:  0,
        taxExScopeAmount: TOTAL_PRICE,
        returnUrl: "http://localhost:8082/naverPay?ordernumber=" + encodeURIComponent(ORDER_NO)
      });
    }

    // ====== 결제 후 장바구니/세션 정리 → 완료 페이지 이동 ======
    function afterPaidCleanup(){
      const nextUrl = "/payend?ordernumber=" + encodeURIComponent(ORDER_NO);
      if (!ORDER_NO) { window.location.replace(nextUrl); return; }

      $.ajax({
        url: "/cart/removeItems",
        type: "POST",
        data: { ordernumber: ORDER_NO },
        beforeSend: setCsrfHeader,
        complete: function(){ window.location.replace(nextUrl); }
      });
    }

    function setCsrfHeader(xhr){
      if (csrfToken && csrfHeader) xhr.setRequestHeader(csrfHeader, csrfToken);
    }

    // ====== 주소검색/주소 합치기 ======
    function openPostcodePopup(){
      new daum.Postcode({
        oncomplete: function(data){
          var addr = (data.userSelectedType === 'R') ? data.roadAddress : data.jibunAddress;
          $("#postcode").val(data.zonecode);
          $("#frontaddress").val(addr);
          $("#detailAddress").focus();
        }
      }).open();
    }
    function updateFullAddress(){
      var postcode = $("#postcode").val().trim();
      var front    = $("#frontaddress").val().trim();
      var detail   = $("#detailAddress").val().trim();
      $("#address").val( (postcode ? postcode + ' ' : '') + front + (detail ? ' ' + detail : '') );
    }
    window.openPostcodePopup = openPostcodePopup;
    window.updateFullAddress = updateFullAddress;
  </script>
</head>

<body>
  <main class="page">
    <h1>구매 정보 확인</h1>
    <div class="sub">배송지 정보 입력 후 결제 방법을 선택해 주세요.</div>

    <div class="grid">
      <!-- 주문 요약 -->
      <section class="card">
        <h2>주문 정보</h2>
        <div class="summary">
          <div class="kv"><span>주문번호</span><span><span class="badge">${orderNumber}</span></span></div>
          <div class="kv"><span>상품명</span><strong>${productName}</strong></div>
          <div class="kv"><span>수량</span><strong>${totalQty} 개</strong></div>
          <div class="kv"><span>결제 금액</span><strong class="total-price"><c:out value="${totalPrice}"/> 원</strong></div>
        </div>
        <div class="space"></div>
        <p class="muted">주문 정보는 결제 직전에 한 번 더 검증됩니다.</p>
      </section>

      <!-- 배송/연락처 & 결제 -->
      <section class="card">
        <h2>추가 정보 입력</h2>
        <form id="purchaseForm" action="" method="post" autocomplete="on">
          <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
          <input type="hidden" id="address" name="address">
          <input type="hidden" id="email"   name="email"  value="${emailVal}">

          <div class="form-grid">
            <div class="field">
              <label class="label" for="name">받는 분 성함</label>
              <input type="text" id="name" name="name" placeholder="홍길동">
            </div>

            <div class="field">
              <label class="label req" for="phone">전화번호</label>
              <input type="text" id="phone" name="phone" class="required" value="${phoneVal}" placeholder="010-0000-0000">
            </div>

            <div class="field" style="grid-column:1/-1">
              <label class="label" for="postcode">우편번호</label>
              <div class="address-row">
                <input type="text" id="postcode" name="postcode" placeholder="우편번호" readonly>
                <button type="button" class="btn ghost" onclick="openPostcodePopup()">우편번호 찾기</button>
              </div>
            </div>

            <div class="field" style="grid-column:1/-1">
              <label class="label" for="frontaddress">도로명 주소</label>
              <input type="text" id="frontaddress" name="frontaddress" placeholder="도로명 주소" readonly>
            </div>

            <div class="field" style="grid-column:1/-1">
              <label class="label" for="detailAddress">상세주소</label>
              <input type="text" id="detailAddress" name="detailAddress" placeholder="상세주소">
            </div>
          </div>

          <div class="actions">
            <button id="payButton" class="btn full" type="button" onclick="updateFullAddress()">결제하기</button>
          </div>
          <p class="muted" style="text-align:center;margin-top:10px;">
            <a href="<c:url value='/product/list'/>" class="btn ghost">상품 목록으로</a>
          </p>
          <p class="muted">결제 버튼 클릭 시, 입력한 정보로 검증 후 결제수단을 선택할 수 있습니다.</p>
        </form>
      </section>
    </div>
  </main>

  <!-- 결제수단 선택 모달 -->
  <div id="paymentMethodModal" aria-hidden="true">
    <div class="modal" role="dialog" aria-modal="true" aria-labelledby="payTitle">
      <div class="modal-head">
        <strong id="payTitle">결제 방법 선택</strong>
        <button id="closeModal" class="close-x" aria-label="닫기">×</button>
      </div>
      <div class="modal-body">
        <div class="actions" style="flex-direction:column">
          <button id="payWithKakaoPay" class="btn"   type="button">카카오페이로 결제</button>
          <button id="payWithNaverPay" class="btn ghost" type="button">네이버페이로 결제</button>
          <button id="payWithTossPay"  class="btn ghost" type="button">토스페이 (준비중)</button>
        </div>
        <div class="space"></div>
        <p class="muted">결제 진행 중 페이지를 새로고침하지 마세요.</p>
      </div>
    </div>
  </div>
</body>
</html>
