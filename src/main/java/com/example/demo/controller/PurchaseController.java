package com.example.demo.controller;

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
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

import com.example.demo.service.PurchaseService;
import com.example.demo.util.SecurityUtils;
import com.example.demo.vo.NonMemberPurchaseInfo;
import com.example.demo.vo.PaymentInfo;
import com.example.demo.vo.PurchaseInfo;

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
			@RequestParam(required = false) String guestname,
			@RequestParam(required = false) String productid,        // 단건
			@RequestParam(required = false) String productname,      // UI표시용(서버 보정)
			@RequestParam(required = false) String sizecolor,        // 단건 옵션 (예: "M-Black")
			@RequestParam(required = false) List<String> productIds, // 복수 결제(비회원 유사-장바구니)
			@RequestParam(required = false) List<String> cartIds,    // 복수 결제(회원 장바구니)
			@RequestParam(required = false) List<String> sizeColors, // 복수 옵션 (예: ["M-2","L-3"] or ["M-Black","L-White"])
			@RequestParam(required = false) Integer priceall,        // 총액(프런트 계산 → 서비스에서 재검증)
			@RequestParam(required = false) Integer count,           // 단건 수량
			HttpSession session
	) {
		LocalDateTime now = LocalDateTime.now();
		Map<String, Object> response = new HashMap<>();

		// ===== 인증 여부(정확) =====
		Authentication auth = SecurityContextHolder.getContext().getAuthentication();
		boolean isAuthenticated = auth != null && auth.isAuthenticated()
				&& !(auth instanceof AnonymousAuthenticationToken);

		String currentUserId = isAuthenticated ? auth.getName() : null;
		String effectiveUserId = (userid != null && !userid.isBlank()) ? userid : currentUserId;

		// ===== 문자열/리스트 정리 =====
		String cartIdsString    = (cartIds == null) ? "" : String.join(",", cartIds);
		String productIdsString = (productIds == null) ? "" : String.join(",", productIds);
		String sizeColorsString = (sizeColors == null) ? null : String.join(";", sizeColors);

		// ===== 총 수량 계산 =====
		int totalQty = 0;
		if (count != null && count > 0) {
			totalQty = count;
		} else if (sizeColors != null && !sizeColors.isEmpty()) {
			int sum = 0;
			Pattern p = Pattern.compile("\\d+");
			for (String sc : sizeColors) {
				Matcher m = p.matcher(sc);
				sum += (m.find() ? Integer.parseInt(m.group()) : 1);
			}
			totalQty = (sum > 0 ? sum : sizeColors.size());
		} else {
			totalQty = 1; // 안전값
		}

		// ===== 가격 가드 =====
		if (priceall == null || priceall < 0) {
			return ResponseEntity.status(HttpStatus.BAD_REQUEST)
					.body(Map.of("result", "fail", "message", "유효하지 않은 결제 금액입니다."));
		}

		// ===== 제품명 보정 =====
		String Nproductname = null;  // 비회원 복수 결제 표기
		String Pproductname = null;  // 회원 복수 결제 표기
		if (productid != null && !productid.isBlank()) {
			productname = purchaseService.getproductname(productid);
		} else if (!productIdsString.isBlank()) {
			String[] arr = productIdsString.split(",");
			String firstProductId = arr[0].replace("[", "").replace("]", "").replace("\"", "").trim();
			Nproductname = purchaseService.getproductname(firstProductId) + " 포함 " + arr.length + "개의 제품";
		} else if (!cartIdsString.isBlank()) {
			String cleanedCartIds = cartIdsString.replaceAll("[\\[\\]\"]", "").trim();
			String[] arr = cleanedCartIds.split(",");
			String firstCartId = arr[0].trim();
			Pproductname = purchaseService.getproductnamebyC(firstCartId) + " 포함 " + totalQty + "개의 제품";
		}

		logger.info("POST /buying isAuthenticated={}, email={}, productid={}, priceall={}",
				isAuthenticated, email, productid, priceall);

		// ===== 회원/비회원 분기 =====
		if (!isAuthenticated) {
			// ==== 비회원 ====
			if (email == null || email.isBlank() || phonenum == null || phonenum.isBlank()) {
				return ResponseEntity.status(HttpStatus.BAD_REQUEST)
						.body(Map.of("result", "fail", "message", "이메일/전화번호가 필요합니다."));
			}

			NonMemberPurchaseInfo NPinfo = new NonMemberPurchaseInfo();
			NPinfo.setEmail(email);
			NPinfo.setPhonenum(phonenum);
			NPinfo.setRequestDate(now);
			NPinfo.setQuantity(totalQty);
			NPinfo.setPrice(BigDecimal.valueOf(priceall.longValue()));
			NPinfo.setGuestName(guestname);
			NPinfo.setGuestAddress("입력대기");

			if (productid != null && !productid.isBlank()) {
				try {
					NPinfo.setProductid(Integer.valueOf(productid));
					NPinfo.setProductname(productname);
					NPinfo.setSizecolor(sizecolor);
				} catch (NumberFormatException e) {
					NPinfo.setProductid(null);
					NPinfo.setProductids(productIdsString.replaceAll("[\\[\\]\"\\s]", ""));
					NPinfo.setProductname(Nproductname);
					NPinfo.setSizecolors(sizeColorsString);
				}
			} else {
				NPinfo.setProductid(null);
				NPinfo.setProductids(productIdsString.replaceAll("[\\[\\]\"\\s]", ""));
				NPinfo.setProductname(Nproductname);
				NPinfo.setSizecolors(sizeColorsString);
				NPinfo.setSizecolor(null);
			}

			purchaseService.nonmemreqPurchase(NPinfo);
			response.put("NPinfo", NPinfo);

		} else {
			// ==== 회원 ====
			PurchaseInfo Pinfo = new PurchaseInfo();
			Pinfo.setUserid(effectiveUserId);
			Pinfo.setCartids((cartIds != null && !cartIds.isEmpty()) ? cartIdsString : "");
			Pinfo.setRequestDate(now);
			Pinfo.setQuantity(totalQty);
			Pinfo.setPrice(BigDecimal.valueOf(priceall.longValue()));

			if (productid != null && !productid.isBlank()) {
				try {
					Pinfo.setProductid(Integer.valueOf(productid));
					Pinfo.setProductname(productname);
					Pinfo.setSizecolor(sizecolor);
				} catch (NumberFormatException e) {
					return ResponseEntity.status(HttpStatus.BAD_REQUEST)
							.body(Map.of("result", "fail", "message", "유효하지 않은 제품 ID입니다."));
				}
			} else {
				String productIdsByCart = purchaseService.getproductidbyC(cartIdsString);
				Pinfo.setProductid(null);
				Pinfo.setProductids(productIdsByCart);
				Pinfo.setProductname(Pproductname);
				Pinfo.setSizecolors(sizeColorsString);
				Pinfo.setSizecolor(null);
			}

			if (email == null || email.isBlank()) {
				Pinfo.setEmail(purchaseService.getemail(effectiveUserId));
			} else {
				Pinfo.setEmail(email);
			}

			purchaseService.requestPurchase(Pinfo);
			response.put("Pinfo", Pinfo);
		}

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
