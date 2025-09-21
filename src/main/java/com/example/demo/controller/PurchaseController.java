package com.example.demo.controller;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model; // ✅ 스프링 Model로 정정
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.example.demo.service.PurchaseService;
import com.example.demo.util.SecurityUtils;
import com.example.demo.vo.NonMemberPurchaseInfo;
import com.example.demo.vo.PaymentInfo;
import com.example.demo.vo.PurchaseInfo;

import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@Controller
public class PurchaseController {

	private static final Logger logger = LoggerFactory.getLogger(PurchaseController.class);

	@Autowired
	private PurchaseService purchaseService;

	@PostMapping("/buying")
	public ResponseEntity<Map<String, Object>> processPurchase(
			@RequestParam(required = false) String userid,
			@RequestParam(required = false) String email,
			@RequestParam(required = false) String phonenum,
			@RequestParam(required = false) String productid,
			@RequestParam(required = false) String productname,
			@RequestParam(required = false) String sizecolor,
			@RequestParam(required = false) List<String> productIds,
			@RequestParam(required = false) List<String> cartIds,
			@RequestParam(required = false) List<String> sizeColors,
			@RequestParam(required = false) Integer priceall,
			HttpSession session) {

		LocalDateTime now = LocalDateTime.now();
		Map<String, Object> response = new HashMap<>();

		// ===== 입력 로깅 =====
		logger.info("Received request to process purchase");
		logger.info("User ID(param): {}", userid);
		logger.info("Email: {}", email);
		logger.info("Phone Number: {}", phonenum);
		logger.info("Product ID: {}", productid);
		logger.info("Product Name(param): {}", productname);
		logger.info("Size Color(param): {}", sizecolor);
		logger.info("Product IDs: {}", productIds);
		logger.info("Cart IDs: {}", cartIds);
		logger.info("Size Colors: {}", sizeColors);
		logger.info("Total Price(param): {}", priceall);

		// ===== 회원 여부 판정(1순위: 인증 계정) =====
		String currentUserId = SecurityUtils.getCurrentUserId();
		boolean isAuthenticated = currentUserId != null && !"Anonymous".equals(currentUserId);
		String effectiveUserId = (userid != null && !userid.isBlank()) ? userid : currentUserId;

		// ===== 컬렉션 → 문자열 변환(널 안전) =====
		String cartIdsString = (cartIds == null) ? "" : String.join(",", cartIds);
		String sizeColorsString = (sizeColors == null) ? "" : String.join(";", sizeColors);
		String productIdsString = (productIds == null) ? "" : String.join(",", productIds);
		logger.info("productIdsString: {}", productIdsString);

		// ===== sizeColorsString 내 숫자 합산(예: "M-2;L-3" → 5) =====
		int sum = 0;
		if (!sizeColorsString.isBlank()) {
			Pattern pattern = Pattern.compile("\\d+");
			Matcher matcher = pattern.matcher(sizeColorsString);
			while (matcher.find()) {
				try {
					sum += Integer.parseInt(matcher.group());
				} catch (NumberFormatException ignore) { /* skip */ }
			}
		}
		String sumAsString = String.valueOf(sum);

		// ===== 제품명 보정 =====
		String Nproductname = "";
		String Pproductname = "";
		if (productid != null && !productid.isBlank()) {
			// 단건 구매(직접 productid 전달)
			productname = purchaseService.getproductname(productid);
			logger.info("productname(single): {}", productname);
		} else if (!productIdsString.isBlank()) {
			// 비회원 장바구니 (productIds 기반)
			String[] productIdsArray = productIdsString.split(",");
			String firstProductId = productIdsArray[0].replace("[", "").replace("]", "").replace("\"", "").trim();
			logger.info("firstProductId(nonmember): {}", firstProductId);
			Nproductname = purchaseService.getproductname(firstProductId) + " 포함 " + productIdsArray.length + "개의 제품";
			logger.info("productname(nonmember): {}", Nproductname);
		} else if (!cartIdsString.isBlank()) {
			// 회원 장바구니 (cartIds 기반) — 문자열 정리
			String cleanedCartIds = cartIdsString.replaceAll("[\\[\\]\"]", "").trim();
			logger.info("cartIdsString(cleaned): {}", cleanedCartIds);
			String[] cartIdsArray = cleanedCartIds.split(",");
			String firstCartId = cartIdsArray[0].trim();
			logger.info("firstCartId(member): {}", firstCartId);
			Pproductname = purchaseService.getproductnamebyC(firstCartId) + " 포함 " + sumAsString + "개의 제품";
			logger.info("productname(member): {}", Pproductname);
		}

		// ===== 가격 가드(컨트롤러 레벨 — 서비스에서 재계산/검증 필수) =====
		if (priceall == null || priceall < 0) {
			logger.warn("Invalid total price: {}", priceall);
			return ResponseEntity.status(HttpStatus.BAD_REQUEST)
					.body(Map.of("result", "fail", "message", "유효하지 않은 결제 금액입니다."));
		}

		// ===== 회원/비회원 분기 =====
		if (!isAuthenticated) {
			// ==== 비회원 처리 ====
			if (email == null || email.isBlank() || phonenum == null || phonenum.isBlank()) {
				logger.warn("Non-member missing email/phonenum.");
				return ResponseEntity.status(HttpStatus.BAD_REQUEST)
						.body(Map.of("result", "fail", "message", "이메일/전화번호가 필요합니다."));
			}

			NonMemberPurchaseInfo NPinfo = new NonMemberPurchaseInfo();
			NPinfo.setEmail(email);
			NPinfo.setPhonenum(phonenum);

			if (productid != null && !productid.isBlank()) {
				try {
					NPinfo.setProductid(Integer.parseInt(productid));
					NPinfo.setProductname(productname);
				} catch (NumberFormatException e) {
					logger.error("Invalid product ID format(non-member): {}", productid);
					NPinfo.setProductid(0);
					String cleanedString = productIdsString.replaceAll("[\\[\\]\"\\s]", "");
					logger.info("cleaned productIdsString: {}", cleanedString);
					NPinfo.setProductids(cleanedString);
				}
			} else {
				NPinfo.setProductname(Nproductname);
				String cleanedString = productIdsString.replaceAll("[\\[\\]\"\\s]", "");
				logger.info("cleaned productIdsString: {}", cleanedString);
				NPinfo.setProductids(cleanedString);
			}

			NPinfo.setSizecolor((sizecolor != null && !sizecolor.isBlank()) ? sizecolor : sumAsString);
			NPinfo.setPrice(priceall);                 // 실제 결제 전 서비스에서 서버 기준 금액 재계산/검증 필수
			NPinfo.setRequestDate(now);
			NPinfo.setGuestName(phonenum);
			NPinfo.setGuestAddress("입력대기");

			purchaseService.nonmemreqPurchase(NPinfo);
			response.put("NPinfo", NPinfo);

		} else {
			// ==== 회원 처리 ====
			PurchaseInfo Pinfo = new PurchaseInfo();
			Pinfo.setUserid(effectiveUserId);
			Pinfo.setCartids((cartIds != null && !cartIds.isEmpty()) ? cartIdsString : "");

			if (productid != null && !productid.isBlank()) {
				try {
					Pinfo.setProductid(Integer.parseInt(productid));
					Pinfo.setProductname(productname);
				} catch (NumberFormatException e) {
					logger.error("Invalid product ID format(member): {}", productid);
					return ResponseEntity.status(HttpStatus.BAD_REQUEST)
							.body(Map.of("result", "fail", "message", "유효하지 않은 제품 ID입니다."));
				}
			} else {
				// 서버 기준으로 cartIds → productids 매핑
				String productIdsByCart = purchaseService.getproductidbyC(cartIdsString);
				Pinfo.setProductids(productIdsByCart);
				Pinfo.setProductname(Pproductname);
			}

			Pinfo.setSizecolor((sizecolor != null && !sizecolor.isBlank()) ? sizecolor : sumAsString);
			Pinfo.setPrice(priceall);                  // 실제 결제 전 서비스에서 서버 기준 금액 재계산/검증 필수
			Pinfo.setRequestDate(now);

			if (email == null || email.isBlank()) {
				String serverEmail = purchaseService.getemail(effectiveUserId);
				Pinfo.setEmail(serverEmail);
			} else {
				Pinfo.setEmail(email);
			}

			purchaseService.requestPurchase(Pinfo);
			response.put("Pinfo", Pinfo);
		}

		// 세션 보관(필요 시)
		session.setAttribute("purchaseInfo", response);

		return ResponseEntity.ok(response);
	}

	@GetMapping("/confirmation")
	public String showConfirmationPage(Model model) {
		// ((RedirectAttributes) model).addAttribute("additionalMessage", "Thank you for your purchase!");
		return "confirmation";
	}

	@RequestMapping(value = "/validatePurchase", method = RequestMethod.POST)
	@ResponseBody
	public String validatePurchase(@RequestParam String orderNumber,
								   @RequestParam int price,
								   @RequestParam String phone,
								   @RequestParam String address,
								   @RequestParam String paymentMethod) {

		try {
			// 주문 타입 조회
			String PN = purchaseService.Searchis(orderNumber);

			Object orderInfo = null;
			if ("Member".equals(PN)) {
				orderInfo = purchaseService.getOrderInfoByPInfo(orderNumber);
			} else if ("Nonmember".equals(PN)) {
				orderInfo = purchaseService.getOrderInfoByNInfo(orderNumber);
			} else {
				return "잘못된 주문 정보 타입입니다.";
			}

			if (orderInfo == null) {
				return "주문 정보를 찾을 수 없습니다.";
			}

			String paymentStatus = purchaseService.getPaymentStatus(orderNumber);
			if ("completed".equals(paymentStatus)) {
				return "이미 결제가 완료된 주문입니다.";
			}

			// 결제 정보 저장/갱신 (※ price는 서비스단에서 서버 기준으로 재검증 필요)
			PaymentInfo paymentInfo = new PaymentInfo();
			paymentInfo.setOrderNumber(orderNumber);
			paymentInfo.setPrice(BigDecimal.valueOf(price));
			paymentInfo.setPhone(phone);
			paymentInfo.setAddress(address);
			paymentInfo.setPaymentMethod(paymentMethod);
			paymentInfo.setPaymentStatus("pending");
			paymentInfo.setPaymentDate(LocalDateTime.now());

			purchaseService.saveupPaymentInfo(paymentInfo);

			return "success";

		} catch (Exception e) {
			logger.error("validatePurchase error. orderNumber={}", orderNumber, e);
			return "검증 요청 처리 중 오류가 발생했습니다.";
		}
	}

	@PostMapping("/cart/removeItems")
	public String removing(@RequestParam String ordernumber, HttpSession session) {
		try {
			purchaseService.removing(ordernumber, session);
			return "success";
		} catch (Exception e) {
			logger.error("cart/removeItems error. ordernumber={}", ordernumber, e);
			return "오류가 발생했습니다.";
		}
	}
}
