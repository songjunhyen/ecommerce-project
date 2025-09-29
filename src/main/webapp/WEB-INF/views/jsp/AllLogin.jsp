<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <title>Login</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />

  <!-- CSRF (Spring Security) -->
  <meta name="_csrf" content="${_csrf.token}">
  <meta name="_csrf_header" content="${_csrf.headerName}">

  <!-- (선택) Google One Tap -->
  <meta name="google-signin-client_id" content="228463015999-drdvgd3jcm635f8u8j8hp7g0cp3ha988.apps.googleusercontent.com">
  <script src="https://accounts.google.com/gsi/client" async defer></script>

  <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<style>
  /* ===== Login page scoped overrides ===== */
  html, body { height:100%; }
  body { margin:0; }

  /* 중앙 정렬 컨테이너 */
  #loginPage {
    flex:1 0 auto;
    min-height:calc(100vh - 0px);
    display:grid;
    place-items:center;
    padding:24px 16px;
  }

  /* 카드 사이즈 업 + 여백 업 */
  #loginPage .card {
    width:100%;
    max-width:560px;             /* 420 → 560 */
    padding:28px;                /* 24 → 28 */
    border:1px solid #e5e7eb;
    border-radius:14px;          /* 12 → 14 */
    background:#fff;
    box-shadow:0 6px 18px rgba(0,0,0,.06);
    box-sizing:border-box;
    font:14px/1.45 system-ui,-apple-system,Segoe UI,Roboto,"Noto Sans KR",sans-serif; color:#111;
  }

  #loginPage .card h1 {
    margin:0 0 18px;
    font-size:24px;              /* 20 → 24 */
    font-weight:700;
  }

  #loginPage .field { margin-bottom:14px; }
  #loginPage .field label { display:block; margin-bottom:6px; font-weight:600; }

  #loginPage .field input[type="text"],
  #loginPage .field input[type="password"] {
    width:90%;
    padding:12px 14px;           /* 10x12 → 12x14 */
    border:1px solid #ddd;
    border-radius:8px;
    outline:none;
    font-size:15px;              /* 14 → 15 */
  }
  #loginPage .field input:focus { border-color:#111; }

  #loginPage .error-message { color:#d93025; font-size:12px; margin-top:6px; display:none; }

  #loginPage .actions { margin-top:16px; display:flex; gap:8px; }
  #loginPage .btn {
    flex:1;
    display:inline-block;
    text-align:center;
    padding:12px 14px;           /* 10x12 → 12x14 */
    font-size:15px;
    border-radius:10px;
    text-decoration:none;
    cursor:pointer;
    border:1px solid #111;
    background:#111;
    color:#fff;
  }
  #loginPage .btn.secondary { background:#fff; color:#111; }

  #loginPage .oauth { margin-top:16px; display:flex; flex-direction:column; gap:8px; }
  #loginPage .oauth a {
    display:block; text-align:center; padding:12px 14px;
    border:1px solid #ddd; border-radius:8px; text-decoration:none; color:#111; background:#fff;
    font-size:15px;
  }
  #loginPage .oauth a:hover { background:#111; color:#fff; border-color:#111; }

  /* 큰 화면에서는 더 여유 */
  @media (min-width: 1280px) {
    #loginPage .card {
      max-width:640px;           /* 데스크탑에서 640 */
      padding:32px;
    }
  }
</style>


  <script>
    $(function () {
      const csrfToken  = $('meta[name="_csrf"]').attr('content');
      const csrfHeader = $('meta[name="_csrf_header"]').attr('content');

      function showError(id, msg){ const $el = $('#'+id); $el.text(msg).show(); }
      function hideError(id){ const $el = $('#'+id); $el.text('').hide(); }
      function checkEmpty($input, errId, msg){
        const v = $.trim($input.val());
        if(!v){ showError(errId, msg); return false; }
        hideError(errId); return true;
      }

      $('#userid').on('blur', function(){ checkEmpty($(this), 'useridError', '아이디를 입력해주세요.'); });
      $('#pw').on('blur', function(){ checkEmpty($(this), 'pwError', '비밀번호를 입력해주세요.'); });

      $('#loginForm').on('submit', function(e){
        const okId = checkEmpty($('#userid'), 'useridError', '아이디를 입력해주세요.');
        const okPw = checkEmpty($('#pw'), 'pwError', '비밀번호를 입력해주세요.');
        if(!okId || !okPw){ e.preventDefault(); return; }
        $('#submitBtn').prop('disabled', true).text('로그인 중...');
      });

      $(document).ajaxSend(function (e, xhr) {
        if (csrfToken && csrfHeader) xhr.setRequestHeader(csrfHeader, csrfToken);
      });
    });
  </script>
</head>

<body class="layout-sticky"><%-- 공통 sticky 규칙을 쓰는 경우 --%>
  <%@ include file="includes/head1.jsp"%>

  <main id="loginPage">
    <div class="card" role="form" aria-labelledby="loginTitle">
      <h1 id="loginTitle">로그인</h1>

      <form id="loginForm" action="<c:url value='/Home/Login'/>" method="post" novalidate>
        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />

        <div class="field">
          <label for="userid">아이디</label>
          <input type="text" id="userid" name="userid" placeholder="아이디를 입력해주세요" autocomplete="username" />
          <div id="useridError" class="error-message"></div>
        </div>

        <div class="field">
          <label for="pw">비밀번호</label>
          <input type="password" id="pw" name="pw" placeholder="비밀번호를 입력해주세요" autocomplete="current-password" />
          <div id="pwError" class="error-message"></div>
        </div>

        <div class="actions">
          <button id="submitBtn" class="btn" type="submit">Login</button>
          <a class="btn secondary" href="<c:url value='/user/Signup'/>">Sign up</a>
        </div>
      </form>

      <div class="oauth" aria-label="SNS 로그인">
        <a href="<c:url value='/oauth2/authorization/google'/>">Google로 로그인</a>
        <a href="<c:url value='/oauth2/authorization/kakao'/>">Kakao로 로그인</a>
      </div>
    </div>
  </main>

  <%@ include file="includes/foot1.jsp"%>
</body>
</html>
