<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"    uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form"%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>회원가입</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">

  <!-- jQuery & Daum Postcode -->
  <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
  <script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>

  <!-- CSRF (Spring Security) -->
  <meta name="_csrf"        content="${_csrf.token}">
  <meta name="_csrf_header" content="${_csrf.headerName}">

  <style>
    :root { --line:#e5e7eb; --danger:#d93025; --ink:#111; }
    body { margin:0; font:14px/1.45 system-ui, -apple-system, Segoe UI, Roboto, "Noto Sans KR", sans-serif; color:var(--ink); }
    .wrap { max-width:640px; margin:32px auto; padding:0 16px; }
    h1 { margin:0 0 16px; font-size:22px; }
    form { border:1px solid var(--line); border-radius:12px; padding:20px; }
    .field { margin-bottom:14px; }
    .field label { display:block; margin-bottom:6px; font-weight:600; }
    .row { display:flex; gap:8px; align-items:center; flex-wrap:wrap; }
    .row input[type="text"], .row input[type="password"], .row input[type="email"] { flex:1; }
    input[type="text"], input[type="password"], input[type="email"] {
      width:100%; padding:10px 12px; border:1px solid #ddd; border-radius:8px; outline:none;
    }
    input:focus { border-color:#111; }
    .error-message { color:var(--danger); font-size:12px; margin-top:6px; display:none; }
    .helper { font-size:12px; color:#666; margin-top:4px; }
    .btn { display:inline-block; padding:10px 14px; border-radius:8px; border:1px solid #111; background:#111; color:#fff; cursor:pointer; text-decoration:none; }
    .btn.secondary { background:#fff; color:#111; }
    .btn.small { padding:8px 10px; }
    .actions { margin-top:16px; display:flex; gap:8px; }
  </style>

  <%@ include file="../includes/head1.jsp"%>

  <script>
    $(function(){
      // CSRF
      const CSRF_TOKEN  = $('meta[name="_csrf"]').attr('content');
      const CSRF_HEADER = $('meta[name="_csrf_header"]').attr('content');
      $(document).ajaxSend(function (e, xhr) {
        if (CSRF_TOKEN && CSRF_HEADER) xhr.setRequestHeader(CSRF_HEADER, CSRF_TOKEN);
      });

      // 유틸
      function showError(id, msg){ const $el = $('#'+id); $el.text(msg).show(); }
      function hideError(id){ const $el = $('#'+id); $el.text('').hide(); }

      // 검증(프런트 UX용)
      function checkEmpty(id, errId, msg){
        const v = $.trim($('#'+id).val());
        if (!v){ showError(errId, msg); return false; }
        hideError(errId); return true;
      }
      function checkPassword(){
        const v = $('#pw').val();
        if(!v){ showError('pwError','비밀번호를 입력해주세요.'); return false; }
        if(v.indexOf(' ')>=0){ showError('pwError','공백을 사용할 수 없습니다.'); return false; }
        hideError('pwError'); return true;
      }
      function checkPasswordMatch(){
        const a = $('#pw').val().trim();
        const b = $('#userpw2').val().trim();
        if(a!==b){ showError('pw2Error','비밀번호가 일치하지 않습니다.'); return false; }
        hideError('pw2Error'); return true;
      }
      function checkUserid(){
        const id = $('#userid').val();
        const special = /[^a-zA-Z0-9]/;
        if(!id){ showError('useridError','아이디를 입력해주세요.'); return false; }
        if(id.indexOf(' ')>=0 || special.test(id)){ showError('useridError','아이디에는 공백/특수문자를 사용할 수 없습니다.'); return false; }
        hideError('useridError'); return true;
      }
      function checkEmail(){
        const v = $('#email').val().trim();
        const re = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
        if(!v){ showError('emailError','이메일을 입력해주세요.'); return false; }
        if(!re.test(v)){ showError('emailError','유효한 이메일 주소가 아닙니다.'); return false; }
        hideError('emailError'); return true;
      }
      function checkAddress(){
        const f = $('#frontaddress').val().trim();
        const d = $('#detailAddress').val().trim();
        if(!f || !d){ showError('addressError','주소와 상세주소를 입력해주세요.'); return false; }
        hideError('addressError'); return true;
      }

      // blur 이벤트
      $('#userid').on('blur', checkUserid);
      $('#pw').on('blur', checkPassword);
      $('#userpw2').on('blur', checkPasswordMatch);
      $('#name').on('blur', function(){ checkEmpty('name','nameError','닉네임을 입력해주세요.'); });
      $('#email').on('blur', checkEmail);
      $('#frontaddress, #detailAddress').on('blur', checkAddress);

      // 통합 주소 생성
      function updateFullAddress(){
        const p = $('#postcode').val().trim();
        const f = $('#frontaddress').val().trim();
        const d = $('#detailAddress').val().trim();
        const full = [p, f, d].filter(Boolean).join(' ');
        $('#address').val(full);
      }

      // 폼 제출
      $('#signupForm').on('submit', function(e){
        const ok =
          checkUserid() &&
          checkPassword() &&
          checkPasswordMatch() &&
          checkEmpty('name','nameError','닉네임을 입력해주세요.') &&
          checkEmail() &&
          checkAddress();

        if(!ok){ e.preventDefault(); return; }

        // pw2는 서버로 보내지 않음(안전빵)
        $('#userpw2').removeAttr('name'); // 실제로 name이 없지만 혹시 대비

        updateFullAddress();
        $('#submitBtn').prop('disabled', true).text('처리 중...');
      });

      // 아이디/이메일 중복확인
      $('#checkUseridButton').on('click', function(){
        if(!checkUserid()) return;
        const userid = $('#userid').val().trim();
        $.ajax({
          url: '<c:url value="/user/checkId.do"/>',
          type: 'POST',
          data: { userid },
          success: function(data){
            let $msg = $('#userid').next('.checkIdSpan');
            if (data.cnt > 0){
              $('#userid').attr('status','no');
              if($msg.length) $msg.text('이미 존재하는 아이디입니다.').css('color','red');
              else $('#userid').after("<span class='checkIdSpan' style='color:red'>이미 존재하는 아이디입니다.</span>");
            }else{
              $('#userid').attr('status','yes');
              if($msg.length) $msg.text('사용 가능한 아이디입니다.').css('color','blue');
              else $('#userid').after("<span class='checkIdSpan' style='color:blue'>사용 가능한 아이디입니다.</span>");
            }
          },
          error: function(){ alert('아이디 중복 확인 중 오류가 발생했습니다.'); }
        });
      });

      $('#checkEmailButton').on('click', function(){
        if(!checkEmail()) return;
        const email = $('#email').val().trim();
        $.ajax({
          url: '<c:url value="/user/checkEmail.do"/>',
          type: 'POST',
          data: { email },
          success: function(data){
            let $msg = $('#email').next('.checkEmailSpan');
            if (data.cnt > 0){
              $('#email').attr('status','no');
              if($msg.length) $msg.text('이미 등록된 이메일입니다.').css('color','red');
              else $('#email').after("<span class='checkEmailSpan' style='color:red'>이미 등록된 이메일입니다.</span>");
            }else{
              $('#email').attr('status','yes');
              if($msg.length) $msg.text('사용 가능한 이메일입니다.').css('color','blue');
              else $('#email').after("<span class='checkEmailSpan' style='color:blue'>사용 가능한 이메일입니다.</span>");
            }
          },
          error: function(){ alert('이메일 중복 확인 중 오류가 발생했습니다.'); }
        });
      });

      // 우편번호
      window.openPostcodePopup = function(){
        new daum.Postcode({
          oncomplete: function(data){
            var addr = (data.userSelectedType === 'R') ? data.roadAddress : data.jibunAddress;
            $('#postcode').val(data.zonecode);
            $('#frontaddress').val(addr);
            $('#detailAddress').focus();
          }
        }).open();
      };
    });
  </script>
</head>

<body>
  <div class="wrap">
    <h1>회원가입</h1>

    <!-- novalidate 없음: 브라우저 기본 검증 사용 -->
    <form:form id="signupForm" modelAttribute="SignUpForm" action="<c:url value='/user/signup'/>" method="post">
      <!-- CSRF -->
      <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>

      <!-- 아이디 -->
      <div class="field">
        <label for="userid">아이디</label>
        <div class="row">
          <input type="text" id="userid" name="userid"
                 placeholder="아이디를 입력해주세요"
                 autocomplete="username"
                 required pattern="^[a-zA-Z0-9]{4,20}$"
                 minlength="4" maxlength="20">
          <button id="checkUseridButton" type="button" class="btn small">중복확인</button>
        </div>
        <div id="useridError" class="error-message"></div>
        <form:errors path="userid" cssClass="error-message"/>
      </div>

      <!-- 비밀번호 -->
      <div class="field">
        <label for="pw">비밀번호</label>
        <input type="password" id="pw" name="pw"
               placeholder="비밀번호를 입력해주세요"
               autocomplete="new-password"
               required minlength="8" maxlength="64">
        <div id="pwError" class="error-message"></div>
        <form:errors path="pw" cssClass="error-message"/>
      </div>

      <!-- 비밀번호 확인 (전송 안 함: name 속성 없음) -->
      <div class="field">
        <label for="userpw2">비밀번호 확인</label>
        <input type="password" id="userpw2"
               placeholder="비밀번호를 다시 입력해주세요"
               autocomplete="new-password"
               required minlength="8" maxlength="64">
        <div id="pw2Error" class="error-message"></div>
        <%-- form:errors(path="userpw2") 제거 --%>
      </div>

      <!-- 닉네임 -->
      <div class="field">
        <label for="name">닉네임</label>
        <input type="text" id="name" name="name"
               placeholder="닉네임을 입력해주세요"
               required maxlength="30">
        <div id="nameError" class="error-message"></div>
        <form:errors path="name" cssClass="error-message"/>
      </div>

      <!-- 이메일 -->
      <div class="field">
        <label for="email">이메일</label>
        <div class="row">
          <input type="email" id="email" name="email"
                 placeholder="이메일을 입력해주세요"
                 autocomplete="email"
                 required maxlength="254">
          <button id="checkEmailButton" type="button" class="btn small">중복확인</button>
        </div>
        <div id="emailError" class="error-message"></div>
        <form:errors path="email" cssClass="error-message"/>
      </div>

      <!-- 주소 -->
      <div class="field">
        <label for="postcode">우편번호</label>
        <div class="row">
          <input type="text" id="postcode" name="postcode" placeholder="우편번호" readonly required>
          <button type="button" class="btn small" onclick="openPostcodePopup()">우편번호 찾기</button>
        </div>
        <form:errors path="postcode" cssClass="error-message"/>
      </div>

      <div class="field">
        <label for="frontaddress">도로명 주소</label>
        <input type="text" id="frontaddress" name="frontaddress" placeholder="도로명 주소" readonly required>
        <form:errors path="frontaddress" cssClass="error-message"/>
      </div>

      <div class="field">
        <label for="detailAddress">상세주소</label>
        <input type="text" id="detailAddress" name="detailAddress" placeholder="상세주소" required>
        <div id="addressError" class="error-message"></div>
        <div class="helper">우편번호 찾기 후 상세주소까지 입력해주세요.</div>
        <form:errors path="detailAddress" cssClass="error-message"/>
      </div>

      <!-- 서버로 보낼 통합 주소 -->
      <input type="hidden" id="address" name="address">

      <!-- 제출 -->
      <div class="actions">
        <button id="submitBtn" type="submit" class="btn">회원가입</button>
        <a class="btn secondary" href="<c:url value='/'/>">취소</a>
      </div>
    </form:form>
  </div>

  <%@ include file="../includes/foot1.jsp"%>
</body>
</html>
