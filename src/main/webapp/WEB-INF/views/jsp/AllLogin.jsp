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

  <!-- (선택) Google One Tap을 쓸 때만 유지. Spring OAuth2 링크만 쓸 거면 삭제해도 됩니다. -->
  <meta name="google-signin-client_id" content="228463015999-drdvgd3jcm635f8u8j8hp7g0cp3ha988.apps.googleusercontent.com">
  <script src="https://accounts.google.com/gsi/client" async defer></script>

  <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

  <%-- 헤더 공통 포함이 <head> 안에 있어야 한다면 여기에 둠 --%>
  <%@ include file="includes/head1.jsp"%>

  <style>
    :root { --ink:#111; --muted:#777; --line:#e5e7eb; }
    html, body { height:100%; }
    body { margin:0; min-height:100vh; display:flex; flex-direction:column; font:14px/1.45 system-ui, -apple-system, Segoe UI, Roboto, "Noto Sans KR", sans-serif; color:var(--ink); }
    main { flex:1 0 auto; display:flex; align-items:center; justify-content:center; padding:24px 16px; }

    .card {
      width:100%; max-width:420px; border:1px solid var(--line); border-radius:12px; padding:24px; background:#fff;
      box-shadow:0 6px 18px rgba(0,0,0,.04);
    }
    .card h1 { margin:0 0 16px; font-size:20px; }
    .field { margin-bottom:14px; }
    .field label { display:block; margin-bottom:6px; font-weight:600; }
    .field input[type="text"], .field input[type="password"] {
      width:100%; padding:10px 12px; border:1px solid #ddd; border-radius:8px; outline:none;
    }
    .field input:focus { border-color:#111; }
    .error-message {
      color:#d93025; font-size:12px; margin-top:6px; display:none;
    }
    .actions { margin-top:16px; display:flex; gap:8px; }
    .btn {
      flex:1; display:inline-block; text-align:center; padding:10px 12px; border-radius:8px; text-decoration:none; cursor:pointer; border:1px solid #111; background:#111; color:#fff;
    }
    .btn.secondary { background:#fff; color:#111; }
    .oauth { margin-top:16px; display:flex; flex-direction:column; gap:8px; }
    .oauth a { display:block; text-align:center; padding:10px 12px; border:1px solid #ddd; border-radius:8px; text-decoration:none; color:#111; background:#fff; }
    .oauth a:hover { background:#111; color:#fff; border-color:#111; }

    footer { margin-top:auto; background:#111; color:#ddd; text-align:center; padding:16px; font-size:12px; }
  </style>

  <script>
    $(function () {
      const csrfToken  = $('meta[name="_csrf"]').attr('content');
      const csrfHeader = $('meta[name="_csrf_header"]').attr('content');

      // 폼 검증
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

        // 중복 제출 방지
        $('#submitBtn').prop('disabled', true).text('로그인 중...');
      });

      // Ajax 요청이 있을 경우를 대비한 전역 CSRF 설정 (이 페이지는 기본적으로 폼 POST만 사용)
      $(document).ajaxSend(function (e, xhr) {
        if (csrfToken && csrfHeader) xhr.setRequestHeader(csrfHeader, csrfToken);
      });
    });
  </script>
</head>

<body>
  <main>
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

  <%-- 푸터(선택: 공통 include 대신 여기서 바로 출력) --%>
  <footer>
    © 2025 E-커머스 프로젝트
  </footer>

  <%-- 푸터 공통을 쓰고 싶으면 아래 include로 대체하세요
  <%@ include file="includes/foot1.jsp"%>
  --%>
</body>
</html>
