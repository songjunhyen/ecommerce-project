package com.example.demo.controller;

import java.io.IOException;
import java.net.URISyntaxException;
import java.net.http.HttpResponse;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import com.example.demo.service.PaymentService;
import com.example.demo.vo.PaymentInfo;

@Controller
public class PaymentController {

	private static final Logger log = LoggerFactory.getLogger(PaymentController.class);

	@Autowired
	private PaymentService paymentService;

	@PostMapping("/pay/completePurchase") // 결제 성공 시 호출 -> 결제 검증
	public ResponseEntity<?> completePayment(@RequestParam String imp_uid, @RequestParam String merchant_uid) {

		/*
		 * 결제 성공 후 결제 정보를 받아오기: 결제 시스템(카카오페이, 네이버페이, 토스페이)에서 제공하는 결제 성공 응답 데이터를 받아옵니다. 이
		 * 데이터에는 거래 고유 ID, 결제
		 *
		 * 금액, 결제 상태 등의 정보가 포함됩니다. 서버에서 결제 내역 검증 요청: 결제 시스템의 서버로 실제 결제가 이루어졌는지 확인하는 요청을
		 * 보냅니다. 예를 들어, 카카오페이의 경우 imp_uid나 merchant_uid를 사용하여 결제 내역을 조회하고, 그 응답을 통해 검증을
		 * 진행합니다.
		 *
		 * 결제 금액 및 상태 확인: 검증 요청에 대한 응답에서 결제 금액, 결제 상태 등을 확인하여 정상 결제인지 여부를 판별합니다. 이 때,
		 * 서버에서 기록된 주문 정보와 비교하여 금액이 일치하는지, 결제 상태가 "성공"인지 등을 체크합니다.
		 *
		 * 검증 결과 처리: 검증이 완료되면 해당 결과를 바탕으로 결제 완료 처리를 진행하거나, 문제가 있을 경우 사용자에게 오류를 알리고 추가
		 * 조치를 취합니다.
		 */

		// 1) 입력값 선검증
		if (imp_uid == null || imp_uid.isBlank() || merchant_uid == null || merchant_uid.isBlank()) {
			log.warn("[PAY] completePurchase bad request: imp_uid='{}', merchant_uid='{}'", imp_uid, merchant_uid);
			return ResponseEntity.status(HttpStatus.BAD_REQUEST)
					.body(Map.of("result", "fail", "message", "잘못된 요청입니다."));
		}

		try {
			log.info("[PAY] completePurchase start: imp_uid={}, merchant_uid={}", imp_uid, merchant_uid);

			// 컨텍스트 세팅(필요 시)
			paymentService.setImpUid(imp_uid, merchant_uid);

			// 2) 결제 정보 조회(서버 저장 기준)
			PaymentInfo paymentInfo = paymentService.getPaymentInfoByImpUid(imp_uid);
			if (paymentInfo == null) {
				log.warn("[PAY] PaymentInfo not found: imp_uid={}", imp_uid);
				return ResponseEntity.status(HttpStatus.BAD_REQUEST)
						.body(Map.of("result", "fail", "message", "결제 정보를 찾을 수 없습니다."));
			}

			// 3) 서버- PG 검증 (금액/상태 대조는 서비스 내부에서 수행)
			boolean isVerified = paymentService.verifyPayment(imp_uid, merchant_uid, paymentInfo.getPrice());

			if (isVerified) {
				// 4) 검증 성공 → 완료 처리
				paymentService.completePayment(merchant_uid, paymentInfo);
				log.info("[PAY] completePurchase success: merchant_uid={}", merchant_uid);
				return ResponseEntity.ok(Map.of("result", "success"));
			} else {
				// 검증 실패 시 정리
				paymentService.removePayAuth(imp_uid);
				log.warn("[PAY] completePurchase verification failed: imp_uid={}, merchant_uid={}", imp_uid, merchant_uid);
				return ResponseEntity.status(HttpStatus.BAD_REQUEST)
						.body(Map.of("result", "fail", "message", "결제 검증 실패"));
			}

		} catch (Exception e) {
			log.error("[PAY] completePurchase error: imp_uid={}, merchant_uid={}", imp_uid, merchant_uid, e);
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
					.body(Map.of("result", "error", "message", "서버 오류"));
		}
	}

	@PostMapping("/naverPay") // 네이버 페이 결제 요청
	public ResponseEntity<?> navercompletePayment(@RequestParam String paymentId) {

		if (paymentId == null || paymentId.isBlank()) {
			log.warn("[NPAY] approve bad request: paymentId is blank");
			return ResponseEntity.status(HttpStatus.BAD_REQUEST)
					.body(Map.of("result", "fail", "message", "잘못된 요청입니다."));
		}

		try {
			log.info("[NPAY] approve start: paymentId={}", paymentId);

			HttpResponse<String> response = paymentService.approvePayment(paymentId);

			int statusCode = response.statusCode();
			String responseBody = response.body();

			log.info("[NPAY] approve done: status={}, bodyLen={}", statusCode,
					responseBody != null ? responseBody.length() : 0);

			// 일관된 JSON 응답으로 래핑
			return ResponseEntity.status(statusCode).body(
					Map.of("status", statusCode, "body", responseBody)
			);

		} catch (URISyntaxException | IOException | InterruptedException e) {
			log.error("[NPAY] approve error: paymentId={}", paymentId, e);
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
					.body(Map.of("result", "error", "message", "서버 오류 발생"));
		}
	}

	@PostMapping("/validPurchaseNaver")
	public ResponseEntity<?> compPaymentNaver(@RequestParam String imp_uid, @RequestParam String ordernumber) {

		if (imp_uid == null || imp_uid.isBlank() || ordernumber == null || ordernumber.isBlank()) {
			log.warn("[NPAY] verify bad request: imp_uid='{}', ordernumber='{}'", imp_uid, ordernumber);
			return ResponseEntity.status(HttpStatus.BAD_REQUEST)
					.body(Map.of("result", "fail", "message", "잘못된 요청입니다."));
		}

		try {
			log.info("[NPAY] verify start: imp_uid={}, ordernumber={}", imp_uid, ordernumber);

			paymentService.setImpUid(imp_uid, ordernumber);

			PaymentInfo paymentInfo = paymentService.getPaymentInfoByImpUid(imp_uid);
			if (paymentInfo == null) {
				log.warn("[NPAY] PaymentInfo not found: imp_uid={}", imp_uid);
				return ResponseEntity.status(HttpStatus.BAD_REQUEST)
						.body(Map.of("result", "fail", "message", "결제 정보를 찾을 수 없습니다."));
			}

			boolean isVerified = paymentService.verifyPaymentNaver(imp_uid, ordernumber, paymentInfo.getPrice());

			if (isVerified) {
				paymentService.completePayment(ordernumber, paymentInfo);
				log.info("[NPAY] verify success: ordernumber={}", ordernumber);
				return ResponseEntity.ok(Map.of("result", "success"));
			} else {
				paymentService.removePayAuth(imp_uid);
				log.warn("[NPAY] verify failed: imp_uid={}, ordernumber={}", imp_uid, ordernumber);
				return ResponseEntity.status(HttpStatus.BAD_REQUEST)
						.body(Map.of("result", "fail", "message", "결제 검증 실패"));
			}

		} catch (Exception e) {
			log.error("[NPAY] verify error: imp_uid={}, ordernumber={}", imp_uid, ordernumber, e);
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
					.body(Map.of("result", "error", "message", "서버 오류"));
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
}
