	<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>관리자 추가</title>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

    <meta name="_csrf" content="${_csrf.token}">
    <meta name="_csrf_header" content="${_csrf.headerName}">

<script>

var csrfToken;
var csrfHeader;
	$(document).ready(function() {

        csrfToken = $('meta[name="_csrf"]').attr('content');
        csrfHeader = $('meta[name="_csrf_header"]').attr('content');

		
	    function checkFormValidity() {
	        var isNameValid = checkEmptyInput("name", "nameError", "이름을 입력해주세요.");
	        var isEmailValid = checkEmail();
	        return isNameValid && isEmailValid;
	    }
	
	    function toggleSubmitButton() {
	        if (checkFormValidity()) {
	            $("#submitButton").prop("disabled", false);
	        } else {
	            $("#submitButton").prop("disabled", true);
	        }
	    }
	
	    $("#name, #email").on("input", function() {
	        toggleSubmitButton();
	    });
	
	    $("#name").blur(function() {
	        checkEmptyInput("name", "nameError", "이름을 입력해주세요.");
	        toggleSubmitButton();
	    });
	
	    $("#email").blur(function() {
	        checkEmail();
	        toggleSubmitButton();
	    });
	
	    function showError(errorId, errorMessage) {
	        $("#" + errorId).html(errorMessage);
	        $("#" + errorId).show();
	    }
	
	    function hideError(errorId) {
	        $("#" + errorId).html("");
	        $("#" + errorId).hide();
	    }
	
	    function checkEmail() {
	        var email = $("#email").val().trim();
	        var emailPattern = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
	
	        if (email === "") {
	            showError("emailError", "이메일을 입력해주세요.");
	            return false;
	        }
	
	        if (!emailPattern.test(email)) {
	            showError("emailError", "유효한 이메일 주소가 아닙니다.");
	            return false;
	        }
	
	        hideError("emailError");
	        return true;
	    }
	
	    function checkEmptyInput(fieldId, errorMessageId, errorMessage) {
	        var fieldValue = $("#" + fieldId).val().trim();
	        if (fieldValue === "") {
	            showError(errorMessageId, errorMessage);
	            return false;
	        } else {
	            hideError(errorMessageId);
	            return true;
	        }
	    }
	
	    // 초기 제출 버튼 비활성화
	    toggleSubmitButton();
	});
</script>
</head>
<%@ include file="../includes/head1.jsp"%>
<body>

	생성 버튼 눌러서 만들어지면 비동기적으로 만들어진 id, pw 접속에 관련된 정보 출력
	<form action="/admin/signup" method="post">
        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
		<p>부서(class)선택</p>
		<select name="adminclass">
			<option value="2">2</option>
			<option value="3">3</option>
			<option value="4">4</option>
			<option value="5">5</option>
			<option value="6">6</option>
		</select>
	
		<p>정보 입력</p>
		<label for="name">이름:</label>
		 <br> 
		 <input type="text" id="name" name="name" placeholder="이름을 입력해주세요" />
		 <div id="nameError" class="error-message"></div>
			         <br> <br> 
		<label for="email">이메일 : (중복 불가)</label> 
		<br> 
		<input type="text" id="email"  name="email" placeholder="사용할 E-mail 주소를 입력해주세요" />
		<br>
        <button id="checkUseridButton" type="button">중복확인</button>
        <br>
		<div id="emailError" class="error-message"></div>
		<p>사용할 버튼</p>
    <button type="submit" id="submitButton">Add</button>
	</form>

<script>

function checkEmailap() {            
    var email = $("#email").val().trim();

    $.ajax({
        url: 'checkEmail_do',
        type: 'POST',
        data: {
           email: email
        },
        beforeSend: function(xhr) {
            // CSRF 토큰을 헤더에 추가
            if (csrfToken && csrfHeader) {
                xhr.setRequestHeader(csrfHeader, csrfToken);
            }
        },
        success: function(data) {
            // 존재한다면
           var $message = $('#email').next('.checkEmailSpan');
        
            if (data.cnt > 0) {
                $('#email').attr('status', 'no');
                if ($message.length) {
                    // 메시지가 이미 존재하면 업데이트
                    $message.text('이미 등록된 이메일입니다.').css('color', 'red');
                } else {
                    // 메시지가 존재하지 않으면 새로 추가
                    $('#email').after("<span class='checkEmailSpan' style='color:red'>이미 존재하는 이메일입니다.</span>");
                }
            } else {
                $('#email').attr('status', 'yes');
                if ($message.length) {
                    // 메시지가 이미 존재하면 업데이트
                    $message.text('사용 가능한 이메일입니다.').css('color', 'blue');
                } else {
                    // 메시지가 존재하지 않으면 새로 추가
                    $('#email').after("<span class='checkEmailSpan' style='color:blue'>사용 가능한 이메일입니다.</span>");
                }
            }
        },
        error: function(e) {
            alert("아이디 중복 확인 중 오류가 발생했습니다.");
        }
    });
}

$("#checkUseridButton").click(function() {
    checkEmailap();
});
</script>
</body>
<%@ include file="../includes/foot1.jsp"%>
</html>