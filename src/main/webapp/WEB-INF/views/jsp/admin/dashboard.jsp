<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <title>Admin Dashboard</title>

  <style>
    /* ===== 페이지 네임스페이스 (전역 충돌 방지) ===== */
    #adminDashboard { max-width: 1200px; margin: 0 auto; padding: 16px; }

    /* 카드 */
    #adminDashboard .ad-card {
      border:1px solid #e5e7eb; border-radius:12px; background:#fff;
      padding:16px; box-shadow: 0 2px 6px rgba(0,0,0,.03);
    }
    #adminDashboard .ad-card + .ad-card { margin-top:16px; }

    /* 그리드 */
    #adminDashboard .ad-grid { display:grid; gap:16px; grid-template-columns: 1.2fr .8fr; }
    @media (max-width: 980px){ #adminDashboard .ad-grid { grid-template-columns: 1fr; } }

    /* 테이블 */
    #adminDashboard table.ad-table { width:100%; border-collapse:collapse; }
    #adminDashboard .ad-table th,
    #adminDashboard .ad-table td { border:1px solid #e5e7eb; padding:10px; text-align:left; }
    #adminDashboard .ad-table th { background:#f8fafc; font-weight:600; }

    /* 버튼 */
    #adminDashboard .ad-btn { display:inline-block; padding:9px 14px; border-radius:8px; text-decoration:none; cursor:pointer; }
    #adminDashboard .ad-btn-primary { background:#111; color:#fff; border:1px solid #111; }
    #adminDashboard .ad-btn-ghost   { background:#fff; color:#111; border:1px solid #ddd; }
    #adminDashboard .ad-btn-danger  { background:#b91c1c; color:#fff; border:1px solid #b91c1c; }
    #adminDashboard .ad-btn + .ad-btn { margin-left:8px; }

    /* 알럿 */
    #adminDashboard .ad-alert { border:1px solid; border-radius:10px; padding:14px 16px; }
    #adminDashboard .ad-alert-info    { background:#eef6ff; border-color:#d6e8ff; }
    #adminDashboard .ad-alert-warning { background:#fff8eb; border-color:#fde7b5; }
    #adminDashboard .ad-alert-danger  { background:#ffecec; border-color:#f7c0c0; }

    /* 텍스트/레이아웃 유틸 */
    #adminDashboard .ad-section-title { font-size:18px; font-weight:700; margin:0 0 10px; }
    #adminDashboard .ad-muted { color:#6b7280; font-size:12px; }
    #adminDashboard .ad-stack > * + * { margin-top:8px; }
  </style>
</head>

<body>
  <%@ include file="../includes/head1.jsp"%>

  <div id="adminDashboard">

    <!-- admin null 가드 -->
    <c:if test="${empty admin}">
      <div class="ad-alert ad-alert-danger">
        관리자 정보를 불러오지 못했습니다. 세션을 확인하거나 다시 시도해 주세요.
      </div>
    </c:if>

    <c:if test="${not empty admin}">
      <!-- 상단 그리드: 프로필 카드 + 공통 링크 -->
      <div class="ad-grid">
        <!-- 프로필 -->
        <div class="ad-card">
          <div class="ad-section-title">관리자 정보</div>
          <table class="ad-table">
            <thead>
              <tr>
                <th>번호</th>
                <th>권한</th>
                <th>ID</th>
                <th>이메일</th>
                <th>가입일</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td>${admin.id}</td>
                <td>
                  <c:choose>
                    <c:when test="${admin.adminclass == 1}">최고 관리자</c:when>
                    <c:when test="${admin.adminclass == 2}">시스템 관리자</c:when>
                    <c:when test="${admin.adminclass == 3}">운영 관리자</c:when>
                    <c:when test="${admin.adminclass == 4}">고객지원 관리자</c:when>
                    <c:when test="${admin.adminclass == 5}">일반 관리자</c:when>
                    <c:otherwise>권한 등급 ${admin.adminclass}</c:otherwise>
                  </c:choose>
                </td>
                <td>${admin.adminId}</td>
                <td>${admin.email}</td>
                <td>${fn:replace(admin.regDate, 'T', ' ')}</td>
              </tr>
            </tbody>
          </table>
          <div class="ad-muted" style="margin-top:8px;">* 권한 표기는 내부 정책에 맞게 조정하세요.</div>
        </div>

        <!-- 공통 링크 -->
        <div class="ad-card">
          <div class="ad-section-title">빠른 실행</div>
          <div class="ad-stack">
            <a class="ad-btn ad-btn-primary" href="<c:url value='/admin/Search'/>">관리자 검색</a>
            <span class="ad-muted">고객지원에서도 사용 예정</span>
            <a class="ad-btn ad-btn-ghost" href="<c:url value='/user/Search'/>">유저 검색</a>

            <!-- 공지사항 관리 버튼 -->
            <a class="ad-btn ad-btn-primary" href="<c:url value='/article/list'/>">공지사항 관리</a>
          </div>
        </div>
      </div>

      <!-- 권한별 작업 -->
      <div class="ad-card">
        <div class="ad-section-title">관리자 권한 및 작업</div>

        <c:choose>
          <c:when test="${admin.adminclass == 1}">
            <div class="ad-stack">
              <div>
                <a href="<c:url value='/admin/Signup'/>" class="ad-btn ad-btn-primary">Add</a>
                <a href="<c:url value='/admin/Modify'/>" class="ad-btn ad-btn-ghost">UserModify</a>
                <a href="<c:url value='/admin/ModifyAdmin'/>" class="ad-btn ad-btn-ghost">AdminModify</a>
              </div>
              <div>
                <a href="<c:url value='/admin/Signout'/>" class="ad-btn ad-btn-danger">Delete</a>
                <span class="ad-muted">(!) 주의: 계정/데이터가 영구 삭제될 수 있습니다.</span>
              </div>
            </div>
          </c:when>

          <c:when test="${admin.adminclass == 4}">
            <div class="ad-stack">
              <div class="ad-alert ad-alert-warning">
                고객지원 권한입니다. 민감 작업은 제한될 수 있어요.
              </div>
              <div>
                <a href="<c:url value='/admin/Search'/>" class="ad-btn ad-btn-primary">티켓/관리자 검색</a>
                <a href="<c:url value='/user/Search'/>" class="ad-btn ad-btn-ghost">유저 검색</a>
              </div>
            </div>
          </c:when>

          <c:otherwise>
            <div class="ad-stack">
              <div class="ad-alert ad-alert-info">
                현재 권한(등급 ${admin.adminclass})에서 사용 가능한 메뉴만 표시됩니다.
              </div>
              <div>
                <a href="<c:url value='/user/Search'/>" class="ad-btn ad-btn-ghost">유저 검색</a>
              </div>
              <div>
                <a href="<c:url value='/admin/Signout'/>" class="ad-btn ad-btn-danger">Delete</a>
              </div>
            </div>
          </c:otherwise>
        </c:choose>
      </div>

      <!-- 공지/상태 -->
      <div class="ad-card">
        <div class="ad-section-title">알림</div>

        <div class="ad-alert ad-alert-info" style="margin-bottom:12px;">
          <strong>환영합니다, ${admin.name}님!</strong>
          <div class="ad-muted" style="margin-top:6px;">정책과 규정을 준수해 주세요.</div>
          <ul style="margin:10px 0 0 18px;">
            <li>모든 변경은 승인 절차를 거칩니다.</li>
            <li>데이터 보안과 사용자 프라이버시를 우선합니다.</li>
            <li>정기적으로 로그를 검토하고 이상 징후를 모니터링합니다.</li>
          </ul>
        </div>

        <div class="ad-alert ad-alert-info" style="margin-bottom:12px;">
          <strong>현재 시스템 상태</strong>
          <ul style="margin:10px 0 0 18px;">
            <li>시스템 상태: 양호</li>
            <li>최근 업데이트: 보안 패치, 가입 기능 개선</li>
          </ul>
        </div>

        <div class="ad-alert ad-alert-warning">
          <strong>시스템 업데이트 예정</strong>
          <ul style="margin:10px 0 0 18px;">
            <li>유지보수 기간: 2025-08-05 02:00 ~ 06:00</li>
            <li>영향: 일시적 서비스 중단 가능</li>
            <li>내용: 서버 성능 향상 및 보안 패치</li>
          </ul>
        </div>
      </div>
    </c:if>
  </div>

  <%@ include file="../includes/foot1.jsp"%>
</body>
</html>
