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


  <script>
    $(function(){
      // ====== CSRF 공통 헤더 ======
      const CSRF_TOKEN  = $('meta[name="_csrf"]').attr('content');
      const CSRF_HEADER = $('meta[name="_csrf_header"]').attr('content');
      $(document).ajaxSend(function (e, xhr) {
        if (CSRF_TOKEN && CSRF_HEADER) xhr.setRequestHeader(CSRF_HEADER, CSRF_TOKEN);
      });

      // ====== 에러 표시 유틸 ======
      function setError($el, msg, errorId){
        if ($el && $el[0]) $el[0].setCustomValidity(msg || '');
        if (errorId){
          const $err = $('#'+errorId);
          if (msg) $err.text(msg).show(); else $err.text('').hide();
        }
      }

      // ====== 필드별 즉시 검증 ======
      // 아이디: 영/숫자 4~20 (공백/특수문자 X)
      $('#userid').on('input blur', function(){
        const $t=$(this); let v=$t.val();
        if (/\s/.test(v)) { v=v.replace(/\s+/g,''); $t.val(v); } // 공백 제거
        const ok=/^[A-Za-z0-9]{4,20}$/.test(v);
        setError($t, ok?'':'아이디는 영문/숫자 4~20자만 가능합니다.', 'useridError');
      });

      // 비밀번호: 영/숫자 포함 8~64, 공백 X
      $('#pw').on('input blur', function(){
        const $t=$(this); let v=$t.val();
        if (/\s/.test(v)) { v=v.replace(/\s+/g,''); $t.val(v); } // 공백 제거
        const ok=/^(?=.*[A-Za-z])(?=.*\d)\S{8,64}$/.test(v);
        setError($t, ok?'':'비밀번호는 영문/숫자 포함 8~64자, 공백 불가입니다.', 'pwError');
      });

      // 비밀번호 확인: 일치 확인
      function checkPwMatch(){
        const $a=$('#pw'), $b=$('#userpw2');
        const same = $a.val() && $a.val() === $b.val();
        setError($b, same?'':'비밀번호가 일치하지 않습니다.', 'pw2Error');
        return same;
      }
      $('#userpw2,#pw').on('input blur', checkPwMatch);

      // 닉네임: 2~20자 (한/영/숫자/스페이스/_/-)
      $('#name').on('input blur', function(){
        const $t=$(this), v=$t.val().trim();
        const ok=/^[가-힣A-Za-z0-9 _-]{2,20}$/.test(v);
        setError($t, ok?'':'닉네임은 2~20자(한/영/숫자/_/-/스페이스)만 가능합니다.', 'nameError');
      });

      // 이메일: 간단 RFC 체크
      $('#email').on('input blur', function(){
        const $t=$(this), v=$t.val().trim();
        const ok=/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/.test(v);
        setError($t, ok?'':'유효한 이메일 주소가 아닙니다.', 'emailError');
      });

      // 주소: 우편번호(5자리) + 도로명 + 상세주소 존재
      function checkAddress(){
        const p=$('#postcode').val().trim();
        const f=$('#frontaddress').val().trim();
        const d=$('#detailAddress').val().trim();
        const ok = /^\d{5}$/.test(p) && f.length>0 && d.length>0;
        $('#addressError').text(ok?'':'주소와 상세주소를 입력해주세요.').toggle(!ok);
        return ok;
      }
      $('#postcode,#frontaddress,#detailAddress').on('input blur', checkAddress);

      // 서버로 보낼 통합 주소 만들기
      function updateFullAddress(){
        const full = [$('#postcode').val().trim(), $('#frontaddress').val().trim(), $('#detailAddress').val().trim()]
                      .filter(Boolean).join(' ').slice(0,300);
        $('#address').val(full);
      }

      // ====== 제출 시 최종 검증 ======
      $('#signupForm').on('submit', function(e){
        const nativeOK = this.checkValidity();     // HTML5 속성 기반
        const customOK = checkPwMatch() && checkAddress(); // 커스텀
        if (!(nativeOK && customOK)) {
          e.preventDefault();
          this.reportValidity();
          return;
        }
        // 비번확인 필드는 전송 불필요
        $('#userpw2').removeAttr('name');

        updateFullAddress();
        $('#submitBtn').prop('disabled', true).text('처리 중...');
      });

      // ====== 중복확인 (기존 로직 유지) ======
      $('#checkUseridButton').on('click', function(){
        // 아이디 기본 검증 통과 시에만
        const v=$('#userid').val();
        if (!/^[A-Za-z0-9]{4,20}$/.test(v)) { $('#userid').focus(); return; }
        $.ajax({
          url: '<c:url value="/user/checkId.do"/>',
          type: 'POST',
          data: { userid: v.trim() },
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
        const v=$('#email').val().trim();
        if (!/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/.test(v)) { $('#email').focus(); return; }
        $.ajax({
          url: '<c:url value="/user/checkEmail.do"/>',
          type: 'POST',
          data: { email: v },
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

      // ====== 우편번호 팝업 ======
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
  <%@ include file="../includes/head1.jsp"%>
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
                 required
                 pattern="^[A-Za-z0-9]{4,20}$"
                 minlength="4" maxlength="20" inputmode="latin-prose">
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
               required
               pattern="^(?=.*[A-Za-z])(?=.*\d)\S{8,64}$"
               minlength="8" maxlength="64">
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
        <%-- form:errors(path="userpw2")는 전송하지 않으므로 불필요 --%>
      </div>

      <!-- 닉네임 -->
      <div class="field">
        <label for="name">닉네임</label>
        <input type="text" id="name" name="name"
               placeholder="닉네임을 입력해주세요"
               required
               pattern="^[가-힣A-Za-z0-9 _-]{2,20}$"
               minlength="2" maxlength="20">
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
          <input type="text" id="postcode" name="postcode" placeholder="우편번호"
                 readonly required pattern="^\d{5}$" minlength="5" maxlength="5" inputmode="numeric">
          <button type="button" class="btn small" onclick="openPostcodePopup()">우편번호 찾기</button>
        </div>
        <form:errors path="postcode" cssClass="error-message"/>
      </div>

      <div class="field">
        <label for="frontaddress">도로명 주소</label>
        <input type="text" id="frontaddress" name="frontaddress" placeholder="도로명 주소"
               readonly required maxlength="200">
        <form:errors path="frontaddress" cssClass="error-message"/>
      </div>

      <div class="field">
        <label for="detailAddress">상세주소</label>
        <input type="text" id="detailAddress" name="detailAddress" placeholder="상세주소"
               required maxlength="100">
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
