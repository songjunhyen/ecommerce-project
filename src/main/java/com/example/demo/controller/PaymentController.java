package com.example.demo.controller;

import java.math.BigDecimal;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.*;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import com.example.demo.service.PaymentService;
import com.example.demo.service.SellerShipmentService; // ✅ 추가
import com.example.demo.vo.PaymentInfo;

@Controller
public class PaymentController {

	private static final Logger log = LoggerFactory.getLogger(PaymentController.class);
	private final PaymentService paymentService;
	private final SellerShipmentService sellerShipmentService; // ✅ 추가

	// ✅ 생성자에 주입 추가
	public PaymentController(PaymentService paymentService,
							 SellerShipmentService sellerShipmentService) {
		this.paymentService = paymentService;
		this.sellerShipmentService = sellerShipmentService;
	}

	/** 카카오(Iamport) 결제 완료 콜백 */
	@PostMapping("/pay/completePurchase")
	public ResponseEntity<?> completePayment(@RequestParam String imp_uid,
											 @RequestParam String merchant_uid) {
		try {
			if (imp_uid.isBlank() || merchant_uid.isBlank()) {
				return ResponseEntity.status(HttpStatus.BAD_REQUEST)
						.body(Map.of("result","fail","message","잘못된 요청입니다."));
			}

			paymentService.setImpUid(imp_uid, merchant_uid);

			PaymentInfo paymentInfo = paymentService.getPaymentInfoByOrderNumber(merchant_uid);
			if (paymentInfo == null) {
				paymentInfo = paymentService.getPaymentInfoByImpUid(imp_uid);
			}
			if (paymentInfo == null) {
				return ResponseEntity.status(HttpStatus.BAD_REQUEST)
						.body(Map.of("result","fail","message","결제 정보를 찾을 수 없습니다."));
			}

			BigDecimal price = paymentInfo.getPrice();
			if (price == null || price.signum() <= 0) {
				return ResponseEntity.status(HttpStatus.BAD_REQUEST)
						.body(Map.of("result","fail","message","결제 금액이 유효하지 않습니다."));
			}

			boolean ok = paymentService.verifyPayment(imp_uid, merchant_uid, price);
			if (ok) {
				paymentService.completePayment(merchant_uid, paymentInfo);

				// ✅ 판매자별 배송 스냅샷 생성/갱신
				sellerShipmentService.snapshotFromOrder(merchant_uid);

				// (선택 1) JSON 반환 유지
				return ResponseEntity.ok(Map.of("result","success"));

				// (선택 2) 결제완료 페이지로 이동하려면 위 한 줄 대신 아래 한 줄:
				// return ResponseEntity.status(HttpStatus.FOUND)
				//        .header("Location", "/payend?ordernumber=" + merchant_uid).build();

			} else {
				paymentService.removePayAuth(imp_uid);
				return ResponseEntity.status(HttpStatus.BAD_REQUEST)
						.body(Map.of("result","fail","message","결제 검증 실패"));
			}

		} catch (Exception e) {
			log.error("[PAY] completePurchase error: imp_uid={}, merchant_uid={}", imp_uid, merchant_uid, e);
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
					.body(Map.of("result","error","message","서버 오류"));
		}
	}

	/** 네이버페이 인증 완료 콜백(검증) */
	@PostMapping("/validPurchaseNaver")
	public ResponseEntity<?> compPaymentNaver(@RequestParam String imp_uid,
											  @RequestParam String orderNumber) {
		try {
			if (imp_uid.isBlank() || orderNumber.isBlank()) {
				return ResponseEntity.status(HttpStatus.BAD_REQUEST)
						.body(Map.of("result","fail","message","잘못된 요청입니다."));
			}

			paymentService.setImpUid(imp_uid, orderNumber);

			PaymentInfo paymentInfo = paymentService.getPaymentInfoByOrderNumber(orderNumber);
			if (paymentInfo == null) {
				paymentInfo = paymentService.getPaymentInfoByImpUid(imp_uid);
			}
			if (paymentInfo == null) {
				return ResponseEntity.status(HttpStatus.BAD_REQUEST)
						.body(Map.of("result","fail","message","결제 정보를 찾을 수 없습니다."));
			}

			BigDecimal price = paymentInfo.getPrice();
			if (price == null || price.signum() <= 0) {
				return ResponseEntity.status(HttpStatus.BAD_REQUEST)
						.body(Map.of("result","fail","message","결제 금액이 유효하지 않습니다."));
			}

			boolean ok = paymentService.verifyPaymentNaver(imp_uid, orderNumber, price);
			if (ok) {
				paymentService.completePayment(orderNumber, paymentInfo);

				// ✅ 판매자별 배송 스냅샷 생성/갱신
				sellerShipmentService.snapshotFromOrder(orderNumber);

				// (선택 1) JSON
				return ResponseEntity.ok(Map.of("result","success"));

				// (선택 2) 결제완료 페이지 이동
				// return ResponseEntity.status(HttpStatus.FOUND)
				//        .header("Location", "/payend?ordernumber=" + orderNumber).build();

			} else {
				paymentService.removePayAuth(imp_uid);
				return ResponseEntity.status(HttpStatus.BAD_REQUEST)
						.body(Map.of("result","fail","message","결제 검증 실패"));
			}

		} catch (Exception e) {
			log.error("[NPAY] verify error: imp_uid={}, orderNumber={}", imp_uid, orderNumber, e);
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
					.body(Map.of("result","error","message","서버 오류"));
		}
	}

	@GetMapping("/payend")
	public String showConfirmationPage(Model model, @RequestParam String ordernumber) {
		if (ordernumber == null || ordernumber.isBlank()) {
			model.addAttribute("errorMessage", "유효하지 않은 주문번호입니다.");
			return "Payend";
		}
		PaymentInfo payinfo = paymentService.getPaymentDATA(ordernumber);
		if (payinfo == null) {
			model.addAttribute("errorMessage", "결제 정보를 찾을 수 없습니다.");
			return "Payend";
		}
		model.addAttribute("payinfo", payinfo);
		return "Payend";
	}

	@GetMapping("/naverPay")
	public String naverReturnPage(@RequestParam(required = false) String ordernumber) {
		return "redirect:/payend?ordernumber=" + (ordernumber != null ? ordernumber : "");
	}
}
