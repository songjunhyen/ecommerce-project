<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <title>회원 정보 확인</title>

  <style>
    :root { --line:#e5e7eb; --ink:#111; --muted:#666; }
    body { margin:0; font:14px/1.45 system-ui,-apple-system,Segoe UI,Roboto,"Noto Sans KR",sans-serif; color:var(--ink); }
    .wrap { max-width:520px; margin:32px auto; padding:0 16px; }
    h1 { margin:0 0 16px; font-size:22px; }
    .card { border:1px solid var(--line); border-radius:12px; padding:20px; }
    .profile { background:#fafafa; border:1px solid var(--line); border-radius:10px; padding:12px 14px; margin-bottom:16px; }
    .profile p { margin:4px 0; color:#333; }
    .muted { color:var(--muted); }
    .field { margin-top:12px; }
    label { display:block; font-weight:600; margin-bottom:6px; }
    input[type="password"] {
      width:100%; padding:10px 12px; border:1px solid #ddd; border-radius:8px; outline:none;
    }
    input[type="password"]:focus { border-color:#111; }
    .actions { margin-top:16px; display:flex; gap:8px; }
    .btn { padding:10px 14px; border-radius:8px; border:1px solid #111; background:#111; color:#fff; cursor:pointer; text-decoration:none; }
    .btn.secondary { background:#fff; color:#111; }
    .help { margin-top:8px; font-size:12px; color:#666; }
  </style>

  <%@ include file="../includes/head1.jsp"%>
</head>

<body>
  <div class="wrap">
    <h1>회원 정보 확인</h1>

    <div class="card">
      <div class="profile">
        <c:choose>
          <c:when test="${not empty member}">
            <p><strong>아이디</strong> : <c:out value="${member.userid}"/></p>
            <p><strong>닉네임</strong> : <c:out value="${member.name}"/></p>
            <p class="muted">이메일 : <c:out value="${member.email}"/></p>
          </c:when>
          <c:otherwise>
            <p class="muted">표시할 프로필 정보가 없습니다. (로그인/바인딩 필요)</p>
          </c:otherwise>
        </c:choose>
      </div>

      <form action="<c:url value='/user/Checking'/>" method="post" autocomplete="off">
        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
        <div class="field">
          <label for="pw">본인 확인 비밀번호</label>
          <input type="password" id="pw" name="pw" placeholder="비밀번호를 입력하세요" required minlength="8" maxlength="64" />
          <div class="help">정보 수정을 진행하려면 비밀번호를 확인합니다.</div>
        </div>
        <div class="actions">
          <button type="submit" class="btn">확인</button>
          <a href="<c:url value='/'/>" class="btn secondary">취소</a>
        </div>
      </form>
    </div>
  </div>

  <%@ include file="../includes/foot1.jsp"%>

  <script>
    // UX: 페이지 열리면 비밀번호 입력에 포커스
    (function(){ try{ document.getElementById('pw').focus(); }catch(e){} })();
  </script>
</body>
</html>
