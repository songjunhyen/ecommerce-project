<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Report</title>
</head>
<%@ include file="../includes/head1.jsp"%>
<script>
	function copy(id) {
	    var copyTxt = document.getElementById(id);
	
	    if (copyTxt) {
	        var range = document.createRange();
	        range.selectNodeContents(copyTxt);
	        window.getSelection().removeAllRanges();
	        window.getSelection().addRange(range);
	
	        navigator.clipboard.writeText(copyTxt.textContent).then(function() {
	            alert("복사되었습니다.");
	        }).catch(function(error) {
	            console.error("복사 오류:", error);
	            alert("복사 실패.");
	        });
	    } else {
	        console.error("Element with id " + id + " not found");
	        alert("복사할 내용이 없습니다.");
	    }
	}
</script>
<body>

    <div id="addresult">
        <br>
        <h1>Report</h1>
        <p id="copyTxt1">Admin ID: ${admin.adminId}</p>
        <button onclick="copy('copyTxt1')">COPY</button>
        <p id="copyTxt2">Admin Password: ${admin.adminPw}</p>
        <button onclick="copy('copyTxt2')">COPY</button>
        <p>Admin Name: ${admin.name}</p>
        <p>Admin Email: ${admin.email}</p>
    </div>
	
</body>
<%@ include file="../includes/foot1.jsp"%>
</html>