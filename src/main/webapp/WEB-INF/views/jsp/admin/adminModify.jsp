<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>관리자 수정</title>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <meta name="_csrf" content="${_csrf.token}">
    <meta name="_csrf_header" content="${_csrf.headerName}">
    <!-- 가능하면 head1.jsp는 </head> 전에 include -->
    <%@ include file="../includes/head1.jsp"%>
    <style>
      /* PW 토글은 제거되므로 이 스타일도 불필요하지만 남겨둬도 동작엔 문제 없습니다 */
      .password-field { position: relative; display: flex; align-items: center; }
      .toggle-password { position: absolute; right: 0; top: 0; padding: 5px; }
    </style>
    <script>
      var csrfToken, csrfHeader;
      const ctx = '${pageContext.request.contextPath}';

      $(function() {
        csrfToken  = $('meta[name="_csrf"]').attr('content');
        csrfHeader = $('meta[name="_csrf_header"]').attr('content');

        // Enter로 제출되는 경우도 포함해서 하나로 처리
        $('#searchForm').on('submit', function(e) {
          e.preventDefault();
          performSearch();
        });

        // 클릭 시에도 동일 처리
        $('#searchbutton').on('click', function() {
          $('#searchForm').trigger('submit');
        });

        // 초기화 버튼(동적)
        $(document).on('click', '.reset-AD', function(e) {
          e.preventDefault();
          const adminid = $(this).data('adminid');
          resetAD(adminid);
        });
      });

      function performSearch() {
        const adminclass = $('select[name="adminclass"]').val().trim();
        const name = $('#name').val().trim();
        const email = $('#email').val().trim();

        $.ajax({
          url: ctx + '/admin/Searching',
          type: 'POST',
          dataType: 'json',
          data: { adminclass, name, email },
          beforeSend: function(xhr) { if (csrfToken && csrfHeader) xhr.setRequestHeader(csrfHeader, csrfToken); },
          success: function(data) { renderResults(Array.isArray(data) ? data : []); },
          error: function(e) {
            console.error('검색 중 오류:', e);
            $('#searchResults').empty().append($('<p>').text('검색 중 오류가 발생했습니다.'));
          }
        });
      }

      function renderResults(list) {
        const $root = $('#searchResults').empty();

        if (!list.length) {
          $root.append($('<p>').text('검색 결과가 없습니다.'));
          return;
        }

        const $table = $('<table>')
          .attr({ border: 1, cellpadding: 5, cellspacing: 0 })
          .css('width', '100%');

        const $thead = $('<thead>').append(
          $('<tr>')
            .append($('<th>').text('클래스'))
            .append($('<th>').text('관리자ID'))
            .append($('<th>').text('이름'))
            .append($('<th>').text('이메일'))
            .append($('<th>').text('ID/PW 초기화'))
        );

        const $tbody = $('<tbody>');

        list.forEach(function(admin) {
          const $tr = $('<tr>');
          $tr.append($('<td>').text(admin.adminclass ?? ''));
          $tr.append($('<td>').text(admin.adminId ?? ''));
          $tr.append($('<td>').text(admin.name ?? ''));
          $tr.append($('<td>').text(admin.email ?? ''));

          const $btn = $('<button>')
            .addClass('reset-AD')
            .attr('type', 'button')
            .data('adminid', admin.adminId)
            .text('초기화');

          $tr.append($('<td>').append($btn));
          $tbody.append($tr);
        });

        $table.append($thead, $tbody);
        $root.append($table);
      }

      function resetAD(adminid) {
        if (!adminid) return;

        $.ajax({
          url: ctx + '/admin/resetAD',
          type: 'POST',
          dataType: 'json',
          data: { adminid },
          beforeSend: function(xhr) { if (csrfToken && csrfHeader) xhr.setRequestHeader(csrfHeader, csrfToken); },
          success: function(res) {
            alert('초기화되었습니다.');
            performSearch();
          },
          error: function(e) {
            console.error('초기화 중 오류:', e);
            alert('초기화 중 오류가 발생했습니다.');
          }
        });
      }
    </script>
</head>
<body>
  <div>
    <form id="searchForm">
      <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
      <label for="adminclass">클래스:</label>
      <select name="adminclass">
        <option value="">전체</option>
        <option value="2">고객지원팀</option>
        <option value="3">사용자 관리팀</option>
        <option value="4">결제문의팀</option>
        <option value="5">상품관리팀</option>
        <option value="6">기타</option>
      </select>
      <br>
      <label for="name">이름:</label>
      <input type="text" id="name" name="name" placeholder="이름을 입력해주세요" />
      <br>
      <label for="email">이메일:</label>
      <input type="text" id="email" name="email" placeholder="이메일을 입력해주세요" />
      <br>
      <!-- 버튼은 submit이 아닌 button으로 (submit은 폼 onSubmit에서 처리) -->
      <button id="searchbutton" type="button">Search</button>
    </form>
  </div>

  <br><br><br>
  <div id="searchResults"><!-- 검색 결과 --></div>
  <br><br>

  <%@ include file="../includes/foot1.jsp"%>
</body>
</html>
