<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form"%>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>상품 등록</title>

  <style>
    /* 페이지 네임스페이스: 다른 공통 스타일과 충돌 방지 */
    #productAddPage { max-width: 920px; margin: 0 auto; padding: 16px; }
    #productAddPage .page-title { font-size: 22px; font-weight: 700; margin: 4px 0 16px; }

    #productAddPage form { display: grid; gap: 14px; }
    #productAddPage .field { display: grid; gap: 6px; }
    #productAddPage label { font-weight: 600; }
    #productAddPage input[type="text"],
    #productAddPage input[type="number"],
    #productAddPage input[type="file"] {
      border: 1px solid #ddd; border-radius: 8px; padding: 10px 12px; font-size: 14px;
    }
    #productAddPage .hint { font-size: 12px; color: #777; }
    #productAddPage .error-message { color: #e11; display: none; font-size: 13px; }
    #productAddPage .row { display: grid; gap: 14px; grid-template-columns: 1fr 1fr; }
    @media (max-width: 768px){ #productAddPage .row { grid-template-columns: 1fr; } }

    #productAddPage .image-grid { display: grid; gap: 12px; grid-template-columns: repeat(3, 1fr); }
    @media (max-width: 768px){ #productAddPage .image-grid { grid-template-columns: 1fr; } }
    #productAddPage .preview {
      display: none; border: 1px dashed #ddd; border-radius: 8px; padding: 8px; text-align: center;
    }
    #productAddPage .preview img { max-width: 100%; max-height: 160px; object-fit: cover; border-radius: 6px; }

    #productAddPage .actions { display: flex; gap: 10px; align-items: center; }
    #productAddPage .btn {
      border: 1px solid #111; background: #111; color: #fff; padding: 10px 16px; border-radius: 10px; cursor: pointer;
    }
    #productAddPage .btn.ghost { background: #fff; color: #111; }
    #productAddPage .btn:disabled { opacity: .5; cursor: not-allowed; }
  </style>

  <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

  <script>
    $(function(){
      const $form = $("#addForm");
      const $submit = $("#submitBtn");

      // 공통 유효성
      function showErr(id, msg){ $("#"+id).text(msg).show(); }
      function hideErr(id){ $("#"+id).hide().text(""); }

      function notEmpty(id, errId, label){
        const v = $("#"+id).val().trim();
        if(!v){ showErr(errId, label + "을(를) 입력해주세요."); return false; }
        hideErr(errId); return true;
      }
      function isPositiveNumber(id, errId, label){
        const v = $("#"+id).val().trim();
        if(!v || isNaN(v) || Number(v) <= 0){ showErr(errId, label + "은(는) 0보다 큰 숫자여야 합니다."); return false; }
        hideErr(errId); return true;
      }

      // 파일 검증 + 미리보기
      const maxSize = 5 * 1024 * 1024; // 5MB
      const allow = /\.(jpg|jpeg|png|gif)$/i;
      function validateFile($input, errId, previewId){
        const f = $input[0].files[0];
        if(!f){ hideErr(errId); $("#"+previewId).hide().find("img").attr("src",""); return true; }

        if(f.size > maxSize){ showErr(errId, "파일 크기는 5MB를 초과할 수 없습니다."); return false; }
        if(!allow.test(f.name)){ showErr(errId, "이미지 파일만 업로드 가능 (JPG, JPEG, PNG, GIF)"); return false; }

        hideErr(errId);
        const reader = new FileReader();
        reader.onload = e => {
          $("#"+previewId).show().find("img").attr("src", e.target.result);
        };
        reader.readAsDataURL(f);
        return true;
      }

      $("#imgurl1").on("change", function(){ validateFile($(this), "imgurlError1", "preview1"); });
      $("#imgurl2").on("change", function(){ validateFile($(this), "imgurlError2", "preview2"); });
      $("#imgurl3").on("change", function(){ validateFile($(this), "imgurlError3", "preview3"); });

      // blur 이벤트로 즉시 피드백
      $("#name").on("blur", function(){ notEmpty("name","nameError","상품명"); });
      $("#price").on("blur", function(){ isPositiveNumber("price","priceError","거래액"); });
      $("#description").on("blur", function(){ notEmpty("description","descriptionError","상품 설명"); });
      $("#count").on("blur", function(){ isPositiveNumber("count","countError","수량"); });
      $("#category").on("blur", function(){ notEmpty("category","categoryError","카테고리"); });
      $("#maker").on("blur", function(){ notEmpty("maker","makerError","메이커"); });
      $("#color").on("blur", function(){ notEmpty("color","colorError","색상"); });
      $("#size").on("blur", function(){ notEmpty("size","sizeError","사이즈"); });
      $("#options").on("blur", function(){ notEmpty("options","optionsError","기타옵션"); });

      // 최종 제출 검증
      $form.on("submit", function(e){
        let ok = true;
        ok &= notEmpty("name","nameError","상품명");
        ok &= isPositiveNumber("price","priceError","거래액");
        ok &= notEmpty("description","descriptionError","상품 설명");
        ok &= isPositiveNumber("count","countError","수량");
        ok &= notEmpty("category","categoryError","카테고리");
        ok &= notEmpty("maker","makerError","메이커");
        ok &= notEmpty("color","colorError","색상");
        ok &= notEmpty("size","sizeError","사이즈");
        ok &= notEmpty("options","optionsError","기타옵션");

        ok &= validateFile($("#imgurl1"), "imgurlError1", "preview1");
        ok &= validateFile($("#imgurl2"), "imgurlError2", "preview2");
        ok &= validateFile($("#imgurl3"), "imgurlError3", "preview3");

        if(!ok){
          e.preventDefault();
          // 첫 번째 에러 위치로 스크롤
          const $firstErr = $("#productAddPage .error-message:visible").first();
          if($firstErr.length){
            window.scrollTo({ top: $firstErr.offset().top - 90, behavior: "smooth" });
          }
        }
      });
    });
  </script>
</head>

<body>
  <%@ include file="../includes/head1.jsp"%>

  <div id="productAddPage">
    <div class="page-title">상품 등록</div>

    <form id="addForm" action="/product/ADD" method="post" enctype="multipart/form-data">
      <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">

      <div class="field">
        <label for="name">상품명 *</label>
        <input type="text" id="name" name="name" placeholder="예) 코튼 오버핏 티셔츠">
        <div id="nameError" class="error-message"></div>
      </div>

      <div class="row">
        <div class="field">
          <label for="price">거래액(원) *</label>
          <input type="number" id="price" name="price" min="1" step="1" placeholder="예) 19900">
          <div id="priceError" class="error-message"></div>
        </div>

        <div class="field">
          <label for="count">수량 *</label>
          <input type="number" id="count" name="count" min="1" step="1" placeholder="예) 10">
          <div id="countError" class="error-message"></div>
        </div>
      </div>

      <div class="field">
        <label for="description">상품 설명 *</label>
        <input type="text" id="description" name="description" placeholder="소재/핏/특징 등을 간단히 입력">
        <div id="descriptionError" class="error-message"></div>
      </div>

      <div class="row">
        <div class="field">
          <label for="category">카테고리 *</label>
          <input type="text" id="category" name="category" placeholder="예) 상의/셔츠/바지 등">
          <div id="categoryError" class="error-message"></div>
        </div>

        <div class="field">
          <label for="maker">메이커 *</label>
          <input type="text" id="maker" name="maker" placeholder="예) 브랜드/제조사">
          <div id="makerError" class="error-message"></div>
        </div>
      </div>

      <div class="row">
        <div class="field">
          <label for="color">색상 *</label>
          <input type="text" id="color" name="color" placeholder="예) Black, White">
          <div id="colorError" class="error-message"></div>
        </div>

        <div class="field">
          <label for="size">사이즈 *</label>
          <input type="text" id="size" name="size" placeholder="예) S, M, L">
          <div id="sizeError" class="error-message"></div>
        </div>
      </div>

      <div class="field">
        <label for="options">기타옵션 *</label>
        <input type="text" id="options" name="options" placeholder="예) 선물포장 가능, 추가 스트랩 포함 등">
        <div id="optionsError" class="error-message"></div>
      </div>

      <div class="field">
        <label>상품 이미지 (최대 3장 · JPG/PNG/GIF, 5MB 이하)</label>
        <div class="image-grid">
          <div>
            <input type="file" id="imgurl1" name="imageFiles" accept=".jpg,.jpeg,.png,.gif">
            <div id="imgurlError1" class="error-message"></div>
            <div id="preview1" class="preview"><img alt="미리보기 1"></div>
          </div>
          <div>
            <input type="file" id="imgurl2" name="imageFiles" accept=".jpg,.jpeg,.png,.gif">
            <div id="imgurlError2" class="error-message"></div>
            <div id="preview2" class="preview"><img alt="미리보기 2"></div>
          </div>
          <div>
            <input type="file" id="imgurl3" name="imageFiles" accept=".jpg,.jpeg,.png,.gif">
            <div id="imgurlError3" class="error-message"></div>
            <div id="preview3" class="preview"><img alt="미리보기 3"></div>
          </div>
        </div>
        <div class="hint">이미지들은 서버에서 콤마로 합쳐 저장하도록 컨트롤러/서비스 로직과 맞춰주세요.</div>
      </div>

      <div class="actions">
        <button id="submitBtn" type="submit" class="btn">등록하기</button>
        <a href="<c:url value='/product/list'/>" class="btn ghost">목록으로</a>
      </div>
    </form>
  </div>

  <c:if test="${not empty errorMessage}">
    <script>alert("${errorMessage}");</script>
  </c:if>

  <%@ include file="../includes/foot1.jsp"%>
</body>
</html>
