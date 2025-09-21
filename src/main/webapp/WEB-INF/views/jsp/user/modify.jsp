<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>회원 정보 수정</title>

  <!-- jQuery & Daum Postcode -->
  <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
  <script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>

  <style>
    :root { --line:#e5e7eb; --ink:#111; --danger:#d93025; }
    body { margin:0; font:14px/1.45 system-ui, -apple-system, Segoe UI, Roboto, "Noto Sans KR", sans-serif; color:var(--ink); }
    .wrap { max-width:640px; margin:32px auto; padding:0 16px; }
    h1 { margin:0 0 16px; font-size:22px; }
    .notice { background:#fff7ed; border:1px solid #fed7aa; color:#7c2d12; padding:12px; border-radius:8px; margin-bottom:16px; }
    .card { border:1px solid var(--line); border-radius:12px; padding:20px; }
    .field { margin-bottom:14px; }
    .field label { display:block; margin-bottom:6px; font-weight:600; }
    input[type="text"], input[type="password"], input[type="email"] {
      width:100%; padding:10px 12px; border:1px solid #ddd; border-radius:8px; outline:none;
    }
    input:focus { border-color:#111; }
    .error-message { color:var(--danger); font-size:12px; margin-top:6px; display:none; }
    .row { display:flex; gap:8px; flex-wrap:wrap; align-items:center; }
    .btn { padding:10px 14px; border-radius:8px; border:1px solid #111; background:#111; color:#fff; cursor:pointer; }
    .btn.secondary { background:#fff; color:#111; }
    .actions { display:flex; gap:8px; margin-top:16px; }
    .danger { border-color:#b91c1c; background:#b91c1c; }
  </style>

  <script>
    $(function() {
      // 서버에서 온 result("true"/"false")로 접근 허용 제어
      var result = '${result}';
      if (result === 'true') {
        $('#accountManagement').show();
      } else {
        $('#accountManagement').hide();
      }

      // 수정 폼 제출 핸들러(이 페이지에 다른 form도 있으니 #modifyForm에만 바인딩)
      $('#modifyForm').on('submit', function(e) {
        if (!validateForm()) {
          e.preventDefault();
          return;
        }
        updateFullAddress(); // 제출 직전에 통합 주소 구성
      });
    });

    // ======= 유효성 검사 유틸 =======
    function showError(id, msg) { $('#' + id).text(msg).show(); }
    function hideError(id) { $('#' + id).text('').hide(); }

    function checkPassword() {
      var pw = $('#pw').val();
      if (!pw) { // 비밀번호는 '선택 변경'
        hideError('pwError');
        return true;
      }
      if (pw.indexOf(' ') >= 0) {
        showError('pwError', '비밀번호에 공백을 사용할 수 없습니다.');
        return false;
      }
      if (pw.length < 8 || pw.length > 64) {
        showError('pwError', '비밀번호는 8~64자여야 합니다.');
        return false;
      }
      hideError('pwError');
      return true;
    }

    function checkNameRequired() {
      var name = $('#name').val().trim();
      if (!name) {
        showError('nameError', '이름을 입력해주세요.');
        return false;
      }
      hideError('nameError');
      return true;
    }

    function checkEmailRequired() {
      var email = $('#email').val().trim();
      var re = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
      if (!email) {
        showError('emailError', '이메일을 입력해주세요.');
        return false;
      }
      if (!re.test(email)) {
        showError('emailError', '유효한 이메일 주소가 아닙니다.');
        return false;
      }
      hideError('emailError');
      return true;
    }

    // 주소는 '선택 변경': 아무 것도 안 적으면 통과, 일부만 적으면 에러
    function checkAddressOptional() {
      var p = $('#postcode').val().trim();
      var f = $('#frontaddress').val().trim();
      var d = $('#detailAddress').val().trim();
      if (!p && !f && !d) {
        hideError('addressError');
        return true; // 주소 변경 안함
      }
      if (p && f && d) {
        hideError('addressError');
        return true;
      }
      showError('addressError', '우편번호/도로명/상세주소를 모두 입력하거나 모두 비워두세요.');
      return false;
    }

    function validateForm() {
      var ok = true;
      if (!checkPassword()) ok = false;
      if (!checkNameRequired()) ok = false;
      if (!checkEmailRequired()) ok = false;
      if (!checkAddressOptional()) ok = false;
      return ok;
    }

    // ======= 주소 팝업 & 통합 =======
    function openPostcodePopup() {
      new daum.Postcode({
        oncomplete: function(data) {
          var addr = (data.userSelectedType === 'R') ? data.roadAddress : data.jibunAddress;
          $('#postcode').val(data.zonecode);
          $('#frontaddress').val(addr);
          $('#detailAddress').focus();
        }
      }).open();
    }
    window.openPostcodePopup = openPostcodePopup;

    function updateFullAddress() {
      var p = $('#postcode').val().trim();
      var f = $('#frontaddress').val().trim();
      var d = $('#detailAddress').val().trim();
      var full = '';
      if (p && f && d) full = [p, f, d].join(' ');
      $('#address').val(full); // 모두 채운 경우만 통합 세팅
    }

    // ======= 계정 삭제 =======
    function confirmDelete() {
      if (confirm('정말로 계정을 삭제하시겠습니까?\n이 작업은 복구할 수 없습니다.')) {
        document.getElementById('deleteForm').submit();
      }
    }
    window.confirmDelete = confirmDelete;
  </script>
</head>

<body>
  <%@ include file="../includes/head1.jsp"%>

  <div class="wrap">
    <h1>회원 정보 수정</h1>

    <div class="notice">
      계정 삭제의 경우 복구가 불가능합니다.<br>
      계정 관리 창이 보이지 않는다면 올바른 경로로 접근하지 않은 것입니다.
    </div>

    <div id="accountManagement" class="card" style="display:none;">
      <form id="modifyForm" action="<c:url value='/user/modify'/>" method="post" autocomplete="off">
        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />

        <!-- 비밀번호(선택 변경) -->
        <div class="field">
          <label for="pw">비밀번호 (변경 시에만 입력)</label>
          <input type="password" id="pw" name="pw" placeholder="새 비밀번호(선택)" minlength="8" maxlength="64">
          <div id="pwError" class="error-message"></div>
        </div>

        <!-- 이름(필수) -->
        <div class="field">
          <label for="name">이름</label>
          <input type="text" id="name" name="name" placeholder="이름을 입력해주세요" required>
          <div id="nameError" class="error-message"></div>
        </div>

        <!-- 이메일(필수) -->
        <div class="field">
          <label for="email">이메일</label>
          <input type="email" id="email" name="email" placeholder="이메일을 입력해주세요" required>
          <div id="emailError" class="error-message"></div>
        </div>

        <!-- 주소(선택 변경) -->
        <div class="field">
          <label for="postcode">우편번호</label>
          <div class="row">
            <input type="text" id="postcode" name="postcode" placeholder="우편번호" readonly>
            <button type="button" class="btn secondary" onclick="openPostcodePopup()">우편번호 찾기</button>
          </div>
        </div>

        <div class="field">
          <label for="frontaddress">도로명 주소</label>
          <input type="text" id="frontaddress" name="frontaddress" placeholder="도로명 주소" readonly>
        </div>

        <div class="field">
          <label for="detailAddress">상세주소</label>
          <input type="text" id="detailAddress" name="detailAddress" placeholder="상세주소">
          <div id="addressError" class="error-message"></div>
        </div>

        <!-- 서버로 보낼 통합 주소 -->
        <input type="hidden" id="address" name="address">

        <div class="actions">
          <button type="submit" class="btn">수정</button>
          <a href="<c:url value='/'/>" class="btn secondary">취소</a>
        </div>
      </form>

      <!-- 계정 삭제: 세션 id가 있을 때만 id 파라미터로 전달 -->
      <c:if test="${not empty sessionScope.id}">
        <form id="deleteForm" action="<c:url value='/user/Signout'/>" method="get" style="margin-top:16px;">
          <input type="hidden" name="id" value="${sessionScope.id}">
          <button type="button" class="btn danger" onclick="confirmDelete()">계정 삭제</button>
        </form>
      </c:if>
    </div>
  </div>

  <%@ include file="../includes/foot1.jsp"%>
</body>
</html>
