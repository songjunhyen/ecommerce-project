
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>구매 정보 추가입력</title>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<script
	src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>

<!-- jQuery -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<!-- iamport.js -->
<script type="text/javascript"
	src="https://cdn.iamport.kr/js/iamport.payment-1.1.5.js"></script>
<!-- 네이버페이 -->
<script src="https://nsp.pay.naver.com/sdk/js/naverpay.min.js"></script>
<!-- 토스페이 -->
<script src="https://js.tosspayments.com/v2/standard"></script>

<meta name="_csrf" content="${_csrf.token}">
<meta name="_csrf_header" content="${_csrf.headerName}">

<script>
    var csrfToken;
    var csrfHeader;
    
    $(document).ready(function() {
        csrfToken = $('meta[name="_csrf"]').attr('content');
        csrfHeader = $('meta[name="_csrf_header"]').attr('content');    
        
        const orderNumber = "${purchaseInfo.Pinfo != null ? purchaseInfo.Pinfo.orderNumber : (purchaseInfo.NPinfo != null ? purchaseInfo.NPinfo.orderNumber : '')}";
        const price = "${purchaseInfo.Pinfo != null ? purchaseInfo.Pinfo.price : (purchaseInfo.NPinfo != null ? purchaseInfo.NPinfo.price : '')}";
        const sizecolor = "${purchaseInfo.Pinfo != null ? purchaseInfo.Pinfo.sizecolor : (purchaseInfo.NPinfo != null ? purchaseInfo.NPinfo.sizecolor : '')}";
        const productname = "${purchaseInfo.Pinfo != null ? purchaseInfo.Pinfo.productname : (purchaseInfo.NPinfo != null ? purchaseInfo.NPinfo.productname : '')}";
        const productid = "${purchaseInfo.Pinfo != null ? purchaseInfo.Pinfo.productid : (purchaseInfo.NPinfo != null ? purchaseInfo.NPinfo.productid : '')}";
        
        console.log("orderNumber:", orderNumber);
        console.log("price:", price);
        console.log("sizecolor:", sizecolor);
        console.log("productname:", productname);
        console.log("productid:", productid);
    
        $("#payButton").on("click", function() {
            event.preventDefault();
            updateFullAddress(); 
            Payment(price, orderNumber, productname);
        });
    
        $("#payWithKakaoPay").on("click", function(event) {    
            event.preventDefault();
            var IMP = window.IMP;
            IMP.init("imp30108185"); // 가맹점 식별코드 입력

            // 카카오페이 결제 요청
            IMP.request_pay({
                pg: "kakaopay.TC0ONETIME", // 카카오페이
                pay_method: "card",
                merchant_uid: "${purchaseInfo.Pinfo != null ? purchaseInfo.Pinfo.orderNumber : (purchaseInfo.NPinfo != null ? purchaseInfo.NPinfo.orderNumber : '')}",
                name: "${purchaseInfo.Pinfo != null ? purchaseInfo.Pinfo.productname : (purchaseInfo.NPinfo != null ? purchaseInfo.NPinfo.productname : '')}", // 결제창에서 보여질 이름
                amount: "${purchaseInfo.Pinfo != null ? purchaseInfo.Pinfo.price : (purchaseInfo.NPinfo != null ? purchaseInfo.NPinfo.price : '')}", // 가격
                buyer_email: $('#email').val(),
                buyer_name: $('#name').val(), // 구매자 이름
                buyer_tel: $('#phone').val(), // 구매자 전화번호
                buyer_addr: $("#frontaddress").val(),
                buyer_postcode: $("#postcode").val()
            }, async function (rsp) { // callback
                if (rsp.success) { // 결제 성공시
                    console.log(rsp);
                
                    // DB에 저장하기
                    $.ajax({
                        url: "/pay/completePurchase",
                        method: "POST",
                        dataType: "JSON",
                        data: {
                            imp_uid: rsp.imp_uid,
                            merchant_uid: rsp.merchant_uid,
                        },
                        beforeSend: function(xhr) {
                            // CSRF 토큰을 헤더에 추가
                            if (csrfToken && csrfHeader) {
                                xhr.setRequestHeader(csrfHeader, csrfToken);
                            }
                        },
                        success: function(data) {
                            if (response.status == 200) { // DB저장 성공시
                                alert('결제 완료!');
                            	//카트에서 데이터 삭제
                            	    $.ajax({
						                url: "/cart/removeItems",
						                method: "POST",
						                dataType: "JSON",
						                data: {
						                	ordernumber:"${purchaseInfo.Pinfo != null ? purchaseInfo.Pinfo.orderNumber : (purchaseInfo.NPinfo != null ? purchaseInfo.NPinfo.orderNumber : '')}",
						                },
						                beforeSend: function(xhr) {
						                    if (csrfToken && csrfHeader) {
						                        xhr.setRequestHeader(csrfHeader, csrfToken);
						                    }
						                },
						                success: function(response) {
						                    if (response.status == 200) { // 삭제 성공 시
						                        alert('카트에서 아이템이 삭제되었습니다!');
						                        // 결제완료 페이지로 이동
						                        window.location.href = "/Payend"
						                    } else {
						                        alert('카트 아이템 삭제 실패: ' + response.error_msg);
						                    }
						                },
						                error: function(xhr, status, error) {
						                    console.error('카트 아이템 삭제 중 오류 발생: ' + error);
						                }
                                    });
                                    
                                } else { // 결제완료 후 DB저장 실패시
                                    alert(`error:[${data.status}]\n결제요청이 승인된 경우 관리자에게 문의바랍니다.`);
                                }
                            },
                            error: function(xhr, status, error) {
                                console.error('DB 저장 중 오류 발생: ' + error);
                            }
                        });      
                    } else { // 결제 실패시
                        alert(rsp.error_msg);
                    }
                });	    
    });
    
    function Payment(price, orderNumber, productname) { 
        if (validateInputs()) {
            $.ajax({
                url: '/validatePurchase',
                type: 'POST',
                data: {
                    orderNumber: orderNumber,
                    price: price,
                    phone: $('#phone').val(),
                    address: $('#address').val(),
                    paymentMethod: "kakao",
                    productname: productname
                },
                beforeSend: function(xhr) {
                    // CSRF 토큰을 헤더에 추가
                    if (csrfToken && csrfHeader) {
                        xhr.setRequestHeader(csrfHeader, csrfToken);
                    }
                },
                success: function(response) {
                    // 서버에서 받은 응답이 문자열임을 고려합니다.
                    if (response === "success") {
                        $('#paymentMethodModal').show();
                    } else {
                        // 응답 메시지를 알림으로 표시합니다.
                        alert(`검증 실패: ${response}`);
                    }
                },
                error: function() {
                    alert('검증 요청 중 오류가 발생했습니다.');
                }
            });
        }
    }	
	
    function validateInputs() {
        let isValid = true;

        $(".required").each(function() {
            if ($(this).val().trim() === "") {
                alert("필수 입력 필드를 모두 채워주세요.");
                isValid = false;
                return false; // Loop break
            }
        });

        // Changed to use arguments
        const orderNumber = "${purchaseInfo.Pinfo != null ? purchaseInfo.Pinfo.orderNumber : (purchaseInfo.NPinfo != null ? purchaseInfo.NPinfo.orderNumber : '')}";
        const price = "${purchaseInfo.Pinfo != null ? purchaseInfo.Pinfo.price : (purchaseInfo.NPinfo != null ? purchaseInfo.NPinfo.price : '')}";
            
        if (orderNumber === "" || price === "") {
            alert("주문번호와 금액 정보가 없습니다. 다시 시도해 주세요.");
            isValid = false;
        }

        return isValid;
    }    

	 
    $("#payWithNaverPay").on("click", function() {	
        event.preventDefault();
   	 var oPay = Naver.Pay.create({
            "mode": "development", 
            "clientId": "HN3GGCMDdTgGUfl0kFCo", // clientId
            "chainId" : "RjVXMjFTbjhoeSs", // chainId
            "openType": "popup", // 팝업 타입으로 결제 창을 열기
            "onAuthorize": function(oData) {
                if (oData.resultCode === "Success") {
                    // 결제 성공 시, 결제 ID를 서버로 전송하여 검증
                	 $.ajax({
                         url: '/validPurchaseNaver',
                         type: 'POST',
                         data: {
                        	 imp_uid: oData.paymentId,
                             orderNumber: "${purchaseInfo.Pinfo != null ? purchaseInfo.Pinfo.orderNumber : (purchaseInfo.NPinfo != null ? purchaseInfo.NPinfo.orderNumber : '')}",
                             price: "${purchaseInfo.Pinfo != null ? purchaseInfo.Pinfo.price : (purchaseInfo.NPinfo != null ? purchaseInfo.NPinfo.price : '')}";,
                             phone: $('#phone').val(),
                             address: $('#address').val(),
                             paymentMethod: "naver",
                             productname: "${purchaseInfo.Pinfo != null ? purchaseInfo.Pinfo.productname : (purchaseInfo.NPinfo != null ? purchaseInfo.NPinfo.productname : '')}"
                         },
                         beforeSend: function(xhr) {
                             // CSRF 토큰을 헤더에 추가
                             if (csrfToken && csrfHeader) {
                                 xhr.setRequestHeader(csrfHeader, csrfToken);
                             }
                         },
                         success: function(response) {
                             // 서버에서 받은 응답이 문자열임을 고려합니다.
                             if (response === "success") {// DB저장도 같이함
                                     alert('결제 완료!');
                                 	//카트에서 데이터 삭제
                                 	    $.ajax({
     						                url: "/cart/removeItems",
     						                method: "POST",
     						                dataType: "JSON",
     						                data: {
     						                	ordernumber:"${purchaseInfo.Pinfo != null ? purchaseInfo.Pinfo.orderNumber : (purchaseInfo.NPinfo != null ? purchaseInfo.NPinfo.orderNumber : '')}",
     						                },
     						                beforeSend: function(xhr) {
     						                    if (csrfToken && csrfHeader) {
     						                        xhr.setRequestHeader(csrfHeader, csrfToken);
     						                    }
     						                },
     						                success: function(response) {
     						                    if (response.status == 200) { // 삭제 성공 시
     						                        alert('카트에서 아이템이 삭제되었습니다!');
     						                        // 결제완료 페이지로 이동
     						                        window.location.href = "/Payend"
     						                    } else {
     						                        alert('카트 아이템 삭제 실패: ' + response.error_msg);
     						                    }
     						                },
     						                error: function(xhr, status, error) {
     						                    console.error('카트 아이템 삭제 중 오류 발생: ' + error);
     						                }
                                         });
                                         
                                     } else { // 결제완료 후 DB저장 실패시
                                         alert(`error:[${data.status}]\n결제요청이 승인된 경우 관리자에게 문의바랍니다.`);
                                     }
                                 },
                                 error: function(xhr, status, error) {
                                     console.error('DB 저장 중 오류 발생: ' + error);
                                 }
                             } else {
                                 // 응답 메시지를 알림으로 표시합니다.
                                 alert(`검증 실패: ${response}`);
                             }
                         },
                         error: function() {
                             alert('검증 요청 중 오류가 발생했습니다.');
                         }
                     });
                 }
            }
        });

   	 oPay.open({
            "merchantUserKey": "development",
            "merchantPayKey": "${purchaseInfo.Pinfo != null ? purchaseInfo.Pinfo.orderNumber : (purchaseInfo.NPinfo != null ? purchaseInfo.NPinfo.orderNumber : '')}",
            "productName": "${purchaseInfo.Pinfo != null ? purchaseInfo.Pinfo.productname : (purchaseInfo.NPinfo != null ? purchaseInfo.NPinfo.productname : '')}",
            "totalPayAmount": "${purchaseInfo.Pinfo != null ? purchaseInfo.Pinfo.price : (purchaseInfo.NPinfo != null ? purchaseInfo.NPinfo.price : '')}",
            "taxScopeAmount": "0",
            "taxExScopeAmount": "${purchaseInfo.Pinfo != null ? purchaseInfo.Pinfo.price : (purchaseInfo.NPinfo != null ? purchaseInfo.NPinfo.price : '')}",
            "returnUrl": "http://localhost:8082/naverPay"                // 결제 승인 요청 처리
		});
	});
    });

</script>


</head>
<body>
	<h1>구매 정보</h1>

	보여줄거 구매정보 주문 번호 요청일 제품명 갯수 합친것(총 상품수) 금액 배송 정보 입력 받는 분 연락처(무조건 입력하도록)
	주소 얘도 입력 배송정보 가져오기 버튼 (회원은 그냥 작은 창나오게 비회원은 연락처 이메일 입력해야 나오게 작은창에는 이전
	배송건 회원의 경우는 저장된 주소랑 같이) 가져오기 누르면 입력필드에 자동으로 들어가도록 갯수부분은 따로 합해서 count로
	컨트롤러에서 갯수 합친걸로 하도록 변경 카트->구매하기 면 count는0이고 사이즈색상에 합쳐놨으니 분해해서 쓰면되고 제품명은
	장바구니 아이디나 제품id로 검색하도록 제품id가 0이면 cartid로 검색하도록하면 될긋


	<!-- 회원 구매 정보 -->
	<c:if test="${not empty sessionScope.purchaseInfo}">
		<c:set var="purchaseInfo" value="${sessionScope.purchaseInfo}" />

		<c:choose>
			<c:when test="${not empty purchaseInfo.Pinfo}">
				<h2>회원 구매 정보</h2>
				<p>주문 번호: ${purchaseInfo.Pinfo.orderNumber}</p>
				<p>제품명: ${purchaseInfo.Pinfo.productname}</p>
				<p>총 상품 수 : ${purchaseInfo.Pinfo.sizecolor}</p>
				<p>결제 금액 : ${purchaseInfo.Pinfo.price} 원</p>
			</c:when>
			<c:otherwise>
				<h2>비회원 구매 정보</h2>
				<p>주문 ID: ${purchaseInfo.NPinfo.orderNumber}</p>
				<p>제품명: ${purchaseInfo.NPinfo.productname}</p>
				<p>총 상품 수: ${purchaseInfo.NPinfo.sizecolor}</p>
				<p>가격: ${purchaseInfo.NPinfo.price} 원</p>
			</c:otherwise>
		</c:choose>
	</c:if>

	<form id="purchaseForm" action="" method="post">
		<input type="hidden" name="${_csrf.parameterName}"
			value="${_csrf.token}">

		<h2>추가 정보 입력</h2>
		<br> <label for="name">받는 분 성함:</label> <input type="text"
			id="name" name="name"> <br> <input type="hidden"
			id="email" name="email"
			value="${not empty purchaseInfo.Pinfo.email ? purchaseInfo.Pinfo.email : (not empty purchaseInfo.NPinfo.email ? purchaseInfo.NPinfo.email : '')}">
		<br>
		<!-- 전화번호 입력 필드 -->
		<label for="phone">전화번호:</label> <input type="text" id="phone"
			name="phone" class="required"
			value="${not empty purchaseInfo.Pinfo.phone ? purchaseInfo.Pinfo.phone : (not empty purchaseInfo.NPinfo.phonenum ? purchaseInfo.NPinfo.phonenum : '')}" />
		<br> <br>
		<!-- 주소 입력 필드 -->
		<label for="address">주소:</label> <input type="hidden" id="address"
			name="address"><br> <label for="postcode">우편번호:</label>
		<br> <input type="text" id="postcode" name="postcode"
			placeholder="우편번호" readonly> <input type="button"
			onclick="openPostcodePopup()" value="우편번호 찾기"> <br> <label
			for="frontaddress">도로명 주소:</label> <input type="text"
			id="frontaddress" name="frontaddress" placeholder="도로명 주소" readonly>
		<br> <label for="detailAddress">상세주소:</label> <input type="text"
			id="detailAddress" name="detailAddress" placeholder="상세주소"> <br>

		<br>
		<button id="payButton">결제하기</button>
		<br>
	</form>
	<div id="paymentMethodModal" style="display: none;">
		<h2>결제 방법 선택</h2>
		<button id="payWithKakaoPay">카카오페이</button>
		<button id="payWithNaverPay">네이버페이</button>
		<button id="payWithTossPay">토스페이</button>
	</div>

	<script>
		function openPostcodePopup() {
			new daum.Postcode(
					{
						oncomplete : function(data) {
							var addr = '';
							var extraAddr = '';

							if (data.userSelectedType === 'R') {
								addr = data.roadAddress;
							} else {
								addr = data.jibunAddress;
							}

							if (data.userSelectedType === 'R') {
								if (data.bname !== ''
										&& /[동|로|가]$/g.test(data.bname)) {
									extraAddr += data.bname;
								}
								if (data.buildingName !== ''
										&& data.apartment === 'Y') {
									extraAddr += (extraAddr !== '' ? ', '
											+ data.buildingName
											: data.buildingName);
								}
								if (extraAddr !== '') {
									extraAddr = ' (' + extraAddr + ')';
								}
							} else {
								extraAddr = '';
							}

							$("#postcode").val(data.zonecode);
							$("#frontaddress").val(addr);
							$("#extraAddress").val(extraAddr); // 사용하지 않음
							$("#detailAddress").focus();
						}
					}).open();
		}

		function updateFullAddress() {
			var postcode = $("#postcode").val().trim(); // 우편번호
			var frontAddress = $("#frontaddress").val().trim(); // 도로명 주소
			var detailAddress = $("#detailAddress").val().trim(); // 상세 주소

			var fullAddress = postcode + ' ' + frontAddress
					+ (detailAddress ? ' ' + detailAddress : ''); // 전체 주소 생성

			$("#address").val(fullAddress); // 통합된 주소를 `address` 필드에 설정
		}
	</script>
</body>
</html>