<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form"%>

<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>상품 수정</title>
<style>
  .error-message{color:#d00;display:none}
  .thumb{width:120px;aspect-ratio:1/1;object-fit:cover;border:1px solid #ddd;border-radius:8px}
  .thumb-wrap{display:inline-flex;flex-direction:column;gap:6px;align-items:center;margin:6px}
  .file-drop{border:2px dashed #bbb;border-radius:8px;padding:16px;text-align:center}
</style>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script>
$(function(){
  // 새 파일 선택시 미리보기
  $("#imageFiles").on("change", function(e){
    const box = $("#newPreview").empty();
    const files = e.target.files || [];
    Array.from(files).forEach(f=>{
      const url = URL.createObjectURL(f);
      box.append($("<img>").addClass("thumb").attr("src", url));
    });
  });

  // 간단 유효성 (비어있음 확인)
  function checkEmpty(id, msgId, msg){
    const v = $("#"+id).val().trim();
    if(!v){ $("#"+msgId).text(msg).show(); return false; }
    $("#"+msgId).hide(); return true;
  }
  $("#name").blur(()=>checkEmpty("name","nameError","상품명을 입력해주세요."));
  $("#price").blur(()=>checkEmpty("price","priceError","거래액을 입력해주세요."));
  $("#description").blur(()=>checkEmpty("description","descriptionError","설명을 입력해주세요."));
  $("#count").blur(()=>checkEmpty("count","countError","수량을 입력해주세요."));
  $("#category").blur(()=>checkEmpty("category","categoryError","카테고리를 입력해주세요."));
  $("#maker").blur(()=>checkEmpty("maker","makerError","메이커를 입력해주세요."));
  $("#color").blur(()=>checkEmpty("color","colorError","색상을 입력해주세요."));
  $("#size").blur(()=>checkEmpty("size","sizeError","사이즈를 입력해주세요."));
  $("#options").blur(()=>checkEmpty("options","optionsError","기타옵션을 입력해주세요."));

  // 전송 전: 기존 이미지 URL들을 hidden에 직렬화(콤마로)
  $("#modifyForm").on("submit", function(){
    const urls = [];
    $(".existing-img[data-url]").each(function(){ urls.push($(this).data("url")); });
    $("#existingImageUrls").val(urls.join(","));
  });

  // 기존 이미지 삭제 체크 시, 시각적 표시
  $("input[name='removeImages']").on("change", function(){
    const wrap = $(this).closest(".thumb-wrap");
    wrap.css("opacity", this.checked ? 0.5 : 1);
  });
});
</script>
</head>

<%@ include file="../includes/head1.jsp"%>

<body>
<form id="modifyForm" action="/product/Modify" method="post" enctype="multipart/form-data">
  <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
  <input type="hidden" id="productId" name="productId" value="${productId}">
  <!-- 기존 이미지 URL 직렬화해서 서버로 보냄 -->
  <input type="hidden" id="existingImageUrls" name="existingImageUrls" value="${product.imageUrl}">

  <h2>상품 기본 정보</h2>

  <label for="name">상품명</label><br>
  <input type="text" id="name" name="name" value="${product.name}" placeholder="상품명을 입력해주세요"><br>
  <div id="nameError" class="error-message"></div><br>

  <label for="price">거래액</label><br>
  <input type="number" id="price" name="price" value="${product.price}" placeholder="금액을 입력해주세요"><br>
  <div id="priceError" class="error-message"></div><br>

  <label for="description">상품 설명</label><br>
  <input type="text" id="description" name="description" value="${product.description}" placeholder="입력해주세요"><br>
  <div id="descriptionError" class="error-message"></div><br>

  <label for="count">수량</label><br>
  <input type="number" id="count" name="count" value="${product.count}" placeholder="수량을 입력해주세요"><br>
  <div id="countError" class="error-message"></div><br>

  <label for="category">카테고리</label><br>
  <input type="text" id="category" name="category" value="${product.category}" placeholder="카테고리를 입력해주세요"><br>
  <div id="categoryError" class="error-message"></div><br>

  <label for="maker">메이커</label><br>
  <input type="text" id="maker" name="maker" value="${product.maker}" placeholder="메이커를 입력해주세요"><br>
  <div id="makerError" class="error-message"></div><br>

  <label for="color">색상</label><br>
  <input type="text" id="color" name="color" value="${product.color}" placeholder="색상을 입력해주세요"><br>
  <div id="colorError" class="error-message"></div><br>

  <label for="size">사이즈</label><br>
  <input type="text" id="size" name="size" value="${product.size}" placeholder="사이즈를 입력해주세요"><br>
  <div id="sizeError" class="error-message"></div><br>

  <label for="options">기타옵션</label><br>
  <input type="text" id="options" name="options" value="${product.additionalOptions}" placeholder="기타옵션을 입력해주세요"><br>
  <div id="optionsError" class="error-message"></div><br>

  <hr>

<h3>기존 이미지</h3>
<div>
  <c:if test="${not empty product.imageUrl}">
    <c:set var="imgs" value="${fn:split(product.imageUrl, ',')}" />
    <c:forEach var="img" items="${imgs}">
      <c:if test="${not empty img}">
        <div class="thumb-wrap">
          <img class="thumb existing-img" data-url="${img}" src="${img}" alt="기존 이미지">
          <label><input type="checkbox" name="removeImages" value="${img}"> 삭제</label>
        </div>
      </c:if>
    </c:forEach>
  </c:if>
  <c:if test="${empty product.imageUrl}">
    <div>등록된 이미지가 없습니다.</div>
  </c:if>
</div>


  <h3>새 이미지 추가 (다중 선택 가능)</h3>
  <div class="file-drop">
    <input type="file" id="imageFiles" name="imageFiles" multiple accept="image/*">
    <div id="newPreview" style="margin-top:10px; display:flex; gap:8px; flex-wrap:wrap;"></div>
  </div>

  <br>
  <input type="submit" value="수정하기">
</form>

<c:if test="${not empty errorMessage}">
  <script>alert("${errorMessage}");</script>
</c:if>

<%@ include file="../includes/foot1.jsp"%>
</body>
</html>
