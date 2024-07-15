<%@ page language="java" contentType="text/html; charset=EUC-KR"
    pageEncoding="EUC-KR"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
 <style>
        .error-message {
            color: red;
            display: none;
        }
    </style>
    <script>
        $(document).ready(function() {
            // �Է� �ʵ忡�� ��Ŀ���� �Ҿ��� �� ��ȿ�� �˻�
            $("#userid").blur(function() {
                checkEmptyInput("userid", "useridError", "���̵� �Է����ּ���.");
            });

            $("#userpw").blur(function() {
                checkEmptyInput("userpw", "userpwError", "��й�ȣ�� �Է����ּ���.");
            });

            // �Է� �ʵ� ���� �޽��� ǥ�� �Լ�
            function showError(errorId, errorMessage) {
                $("#" + errorId).html(errorMessage);
                $("#" + errorId).show();
            }

            // �Է� �ʵ� ���� �޽��� ����� �Լ�
            function hideError(errorId) {
                $("#" + errorId).html("");
                $("#" + errorId).hide();
            }

            // ���̵�, ��й�ȣ�� ��� �ִ��� Ȯ���ϴ� �Լ�
            function checkEmptyInput(fieldId, errorMessageId, errorMessage) {
                var fieldValue = $("#" + fieldId).val().trim();
                var errorMessageElement = $("#" + errorMessageId);

                if (fieldValue === "") {
                    errorMessageElement.html(errorMessage);
                    errorMessageElement.show();
                    return false; // �Է°��� �������
                } else {
                    errorMessageElement.html("");
                    errorMessageElement.hide();
                    return true; // �Է°��� ����
                }
            }           
        });
    </script>
</head>
<body>
<a href="/">Home</a>
<br>
<form id="loginForm" action="/user/login" method="post">
    <label for="userid">���̵�:</label><br>
    <input type="text" id="userid" name="userid" placeholder="���̵� �Է����ּ���"><br>
    <div id="useridError" class="error-message"></div><br>

    <label for="pw">��й�ȣ:</label><br>
    <input type="password" id="pw" name="pw" placeholder="��й�ȣ�� �Է����ּ���"><br>
    <div id="userpwError" class="error-message"></div><br>

    <input type="submit" value="�α���">
</form>
</body>
</html>