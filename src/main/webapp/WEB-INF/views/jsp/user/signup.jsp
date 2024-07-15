<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>ȸ������</title>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<style>
    .error-message {
        color: red;
        display: none;
    }
</style>
<script>
    $(document).ready(function() {
        // ���̵� �Է� �ʵ忡�� ��Ŀ���� �Ҿ��� �� ��ȿ�� �˻�
        $("#userid").blur(function() {
            checkEmptyInput("userid", "useridError", "���̵� �Է����ּ���.");
        });

        // ��й�ȣ �Է� �ʵ忡�� ��Ŀ���� �Ҿ��� �� ��ȿ�� �˻�
        $("#pw").blur(function() {
            checkEmptyInput("pw", "pwError", "��й�ȣ�� �Է����ּ���.");
        });

        // ��й�ȣ Ȯ�� �Է� �ʵ忡�� ��Ŀ���� �Ҿ��� �� ��й�ȣ ��ġ ���� Ȯ��
        $("#userpw2").blur(function() {
            checkPasswordMatch();
        });

        // �г��� �Է� �ʵ忡�� ��Ŀ���� �Ҿ��� �� ��ȿ�� �˻�
        $("#name").blur(function() {
            checkEmptyInput("name", "nameError", "�г����� �Է����ּ���.");
        });

        // �̸��� �Է� �ʵ忡�� ��Ŀ���� �Ҿ��� �� ��ȿ�� �˻�
        $("#email").blur(function() {
            checkEmptyInput("email", "emailError", "�̸����� �Է����ּ���.");
        });

        // �ּ� �Է� �ʵ忡�� ��Ŀ���� �Ҿ��� �� ��ȿ�� �˻�
        $("#address").blur(function() {
            checkEmptyInput("address", "addressError", "�ּҸ� �Է����ּ���.");
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

        // �ʵ尡 ��� �ִ��� Ȯ���ϴ� �Լ�
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

        // ��й�ȣ�� ��й�ȣ Ȯ���� ��ġ�ϴ��� Ȯ���ϴ� �Լ�
        function checkPasswordMatch() {
            var pw = $("#pw").val().trim();
            var userpw2 = $("#userpw2").val().trim();
            var pw2Error = $("#pw2Error");

            if (pw !== userpw2) {
                pw2Error.html("��й�ȣ�� ��ġ���� �ʽ��ϴ�.");
                pw2Error.show();
                return false;
            } else {
                pw2Error.html("");
                pw2Error.hide();
                return true;
            }
        }
    });
</script>
</head>
<body>
<form id="signupForm" action="/user/signup" method="post">
    <label for="userid">���̵�:</label><br>
    <input type="text" id="userid" name="userid" placeholder="���̵� �Է����ּ���"><br>
    <div id="useridError" class="error-message"></div><br>

    <label for="pw">��й�ȣ:</label><br>
    <input type="password" id="pw" name="pw" placeholder="��й�ȣ�� �Է����ּ���"><br>
    <div id="pwError" class="error-message"></div><br>

    <label for="userpw2">��й�ȣ Ȯ��:</label><br>
    <input type="password" id="userpw2" name="userpw2" placeholder="��й�ȣ�� �Է����ּ���"><br>
    <div id="pw2Error" class="error-message"></div><br>

    <label for="name">�г���:</label><br>
    <input type="text" id="name" name="name" placeholder="�г����� �Է����ּ���"><br>
    <div id="nameError" class="error-message"></div><br>

    <label for="email">�̸���:</label><br>
    <input type="text" id="email" name="email" placeholder="�̸����� �Է����ּ���"><br>
    <div id="emailError" class="error-message"></div><br>

    <label for="address">�ּ�:</label><br>
    <input type="text" id="address" name="address" placeholder="�ּҸ� �Է����ּ���"><br>
    <div id="addressError" class="error-message"></div><br>

    <input type="submit" value="ȸ������">
</form>
</body>
</html>