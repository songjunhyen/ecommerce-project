<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>배송 상세</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <style>
    :root{
      --ink:#111; --ink-2:#374151; --muted:#6b7280; --line:#e5e7eb; --bg:#fafafa;
      --brand:#111; --ok:#10b981; --warn:#f59e0b; --danger:#ef4444;
      --chip:#f3f4f6;
    }
    *{box-sizing:border-box}
    body{font-family:system-ui, -apple-system, Segoe UI, Roboto, sans-serif; color:var(--ink); margin:0; background:#fff}
    .container{max-width:980px; margin:28px auto; padding:0 16px}
    .breadcrumb{font-size:14px; color:var(--muted); margin-bottom:10px}
    .breadcrumb a{color:var(--muted); text-decoration:none}
    h2{margin:8px 0 16px}
    .grid{display:grid; grid-template-columns:1.1fr 1fr; gap:16px}
    @media(max-width:900px){ .grid{grid-template-columns:1fr} }
    .card{border:1px solid var(--line); border-radius:14px; padding:16px; background:#fff}
    .row{display:flex; gap:12px; flex-wrap:wrap}
    .col{flex:1 1 240px; min-width:230px}
    label{display:block; font-weight:600; margin:8px 0 6px}
    input,select,textarea{width:100%; padding:12px; border:1px solid var(--line); border-radius:10px; font-size:15px}
    .muted{color:var(--muted)}
    .chip{display:inline-flex; align-items:center; gap:6px; padding:4px 10px; border-radius:999px; background:var(--chip); font-size:12px}
    .chip.ok{background:#ecfdf5; color:#065f46}
    .chip.ship{background:#eff6ff; color:#1e40af}
    .chip.done{background:#f0fdf4; color:#14532d}
    .meta{display:grid; grid-template-columns:repeat(2,minmax(0,1fr)); gap:8px}
    @media(max-width:560px){ .meta{grid-template-columns:1fr} }
    .meta p{margin:4px 0}
    .money{font-weight:700}
    .btns{display:flex; gap:8px; flex-wrap:wrap; margin-top:12px}
    .btn{padding:10px 14px; border:0; border-radius:10px; background:var(--brand); color:#fff; cursor:pointer}
    .btn.secondary{background:#374151}
    .btn.ghost{background:#fff; color:var(--ink); border:1px solid var(--line)}
    .btn.warn{background:var(--warn)}
    .btn.ok{background:var(--ok)}
    .btn:disabled{opacity:.6; cursor:not-allowed}
    .toolbar{display:flex; justify-content:space-between; align-items:center; margin:10px 0 16px}
    .link{color:#2563eb; text-decoration:none}
    .kv{display:grid; grid-template-columns:120px 1fr; gap:8px; font-size:14px}
    .kv div{padding:4px 0; border-bottom:1px dashed #f1f5f9}
    .toast{position:fixed; left:50%; transform:translateX(-50%); bottom:24px; background:#111; color:#fff; padding:10px 14px; border-radius:10px; display:none}
  </style>

  <script>
    let busy = false;

    function showToast(msg){
      const t = document.getElementById('toast');
      t.textContent = msg;
      t.style.display = 'block';
      setTimeout(()=> t.style.display='none', 1600);
    }

    function fmtUrl(carrier, inv){
      if(!carrier || !inv) return null;
      const c = carrier.trim().toLowerCase();
      const n = encodeURIComponent(inv.trim());
      // 필요에 따라 추가
      if(c.includes('cj')) return `https://trace.cjlogistics.com/web/detail.jsp?slipno=${n}`;
      if(c.includes('로젠')) return `https://www.ilogen.com/web/personal/trace/${n}`;
      if(c.includes('우체국') || c.includes('post')) return `https://service.epost.go.kr/trace.RetrieveDomRigiTraceList.comm?sid1=${n}`;
      if(c.includes('한진')) return `https://www.hanjin.co.kr/kor/CMS/DeliveryMgr/WaybillResult.do?mCode=MN038&wblnum=${n}`;
      return null;
    }

    async function save() {
      if(busy) return;
      const orderNumber = document.getElementById('orderNumber').textContent.trim();
      const trackingNo  = document.getElementById('trackingNo').value.trim();
      const carrier     = document.getElementById('carrier').value.trim();
      const status      = document.getElementById('status').value;

      // 간단 검증
      if(trackingNo && !carrier){
        showToast('택배사를 선택/입력해주세요.');
        document.getElementById('carrier').focus();
        return;
      }

      const body = { orderNumber, trackingNo: trackingNo || null, carrier: carrier || null, status: status || null };

      busy = true;
      toggleButtons(true);
      try{
        const res = await fetch('<c:url value="/seller/ship/update"/>', {
          method:'POST', headers:{'Content-Type':'application/json'}, body: JSON.stringify(body)
        });
        if (res.ok) { showToast('저장되었습니다.'); setTimeout(()=>location.reload(), 650); }
        else { showToast('저장 실패'); }
      }catch(e){
        showToast('네트워크 오류');
      }finally{
        busy = false; toggleButtons(false);
      }
    }

    async function setStatus(status) {
      if(busy) return;
      const orderNumber = document.getElementById('orderNumber').textContent.trim();
      busy = true; toggleButtons(true);
      try{
        const res = await fetch('<c:url value="/seller/ship"/>' + '/' + encodeURIComponent(orderNumber) + '/status?status=' + encodeURIComponent(status), { method:'POST' });
        if (res.ok) { showToast('상태 변경: ' + status); setTimeout(()=>location.reload(), 650); }
        else { showToast('변경 실패'); }
      }catch(e){
        showToast('네트워크 오류');
      }finally{
        busy = false; toggleButtons(false);
      }
    }

    function toggleButtons(disabled){
      for(const b of document.querySelectorAll('button')) b.disabled = disabled;
    }

    function openTrack(){
      const carrier = document.getElementById('carrier').value;
      const inv = document.getElementById('trackingNo').value;
      const url = fmtUrl(carrier, inv);
      if(url) window.open(url, '_blank');
      else showToast('지원하지 않는 택배사이거나 운송장 정보가 없습니다.');
    }

    function copyText(id){
      const txt = document.getElementById(id).textContent || document.getElementById(id).value;
      navigator.clipboard.writeText((txt||'').trim()).then(()=>showToast('복사됨'));
    }
  </script>
</head>
<body>
<div class="container">

  <div class="breadcrumb">
    <a href="<c:url value='/seller/ship'/>">배송관리</a> &nbsp;/&nbsp; 상세
  </div>

  <h2>배송 상세</h2>

  <c:if test="${empty row}">
    <div class="card">
      <p class="muted">해당 주문의 스냅샷이 없습니다. 목록 화면에서 <b>조회(집계)</b>를 먼저 실행해주세요.</p>
      <p style="margin-top:8px"><a class="link" href="<c:url value='/seller/ship'/>">← 목록으로</a></p>
    </div>
  </c:if>

  <c:if test="${not empty row}">
    <!-- 상단 요약 -->
    <div class="card">
      <div class="toolbar">
        <div class="row" style="align-items:center">
          <div class="chip" style="background:#eef2ff;color:#3730a3">주문</div>
          <div id="orderNumber" style="font-weight:700">${row.orderNumber}</div>
          <button class="btn ghost" type="button" onclick="copyText('orderNumber')">주문번호 복사</button>
        </div>
        <div>
          <span class="chip
            <c:if test='${row.status eq "배송중"}'> ship</c:if>
            <c:if test='${row.status eq "배송완료"}'> done</c:if>">
            상태: ${row.status}
          </span>
        </div>
      </div>

      <div class="meta">
        <p>수취인: <b>${row.receiverName}</b> <span class="muted">(${row.phone})</span></p>
        <p>결제: ${row.paymentMethod} / <b>${row.paymentStatus}</b></p>
        <p>주소: <span class="muted">${row.address}</span></p>
        <p>수량/금액:
          <b>${row.totalQuantity}</b>개 /
          <span class="money"><fmt:formatNumber value="${row.totalAmount}" type="number"/>원</span>
        </p>
      </div>

      <div class="kv" style="margin-top:10px">
        <div class="muted">스냅샷 생성</div><div>${row.createdAt}</div>
        <div class="muted">출고(배송중)</div><div><c:out value="${row.shippedAt}"/>&nbsp;</div>
        <div class="muted">배송완료</div><div><c:out value="${row.deliveredAt}"/>&nbsp;</div>
      </div>
    </div>

    <!-- 배송정보 편집 -->
    <div class="card">
      <div class="row">
        <div class="col">
          <label for="carrier">택배사</label>
          <input id="carrier" value="${row.carrier}" placeholder="예: CJ대한통운, 로젠, 우체국, 한진">
        </div>
        <div class="col">
          <label for="trackingNo">운송장번호</label>
          <div class="row" style="gap:8px">
            <input id="trackingNo" value="${row.trackingNo}" placeholder="숫자 또는 영문 포함 송장번호">
            <button class="btn ghost" type="button" onclick="copyText('trackingNo')">복사</button>
            <button class="btn secondary" type="button" onclick="openTrack()">배송추적</button>
          </div>
        </div>
        <div class="col">
          <label for="status">상태</label>
          <select id="status">
            <c:set var="st" value="${row.status}" />
            <option value="배송 전"   ${st=='배송 전' ? 'selected' : ''}>배송 전</option>
            <option value="배송중"     ${st=='배송중' ? 'selected' : ''}>배송중</option>
            <option value="배송완료"   ${st=='배송완료' ? 'selected' : ''}>배송완료</option>
            <option value="반품요청"   ${st=='반품요청' ? 'selected' : ''}>반품요청</option>
          </select>
        </div>
      </div>

      <div class="btns">
        <button class="btn" type="button" onclick="save()">저장</button>
        <button class="btn ok" type="button" onclick="setStatus('배송중')">배송중</button>
        <button class="btn warn" type="button" onclick="setStatus('배송완료')">배송완료</button>
        <a class="btn ghost" href="<c:url value='/seller/ship'/>">목록으로</a>
      </div>
    </div>
  </c:if>
</div>

<div id="toast" class="toast" role="status" aria-live="polite"></div>
</body>
</html>
