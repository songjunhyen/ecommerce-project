package com.example.demo.service;

import java.io.IOException;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.demo.dao.PurchaseDao;
import com.example.demo.util.SessionFileUtil;
import com.example.demo.vo.CartItem;
import com.example.demo.vo.NonMemberPurchaseInfo;
import com.example.demo.vo.PaymentInfo;
import com.example.demo.vo.PurchaseInfo;

import jakarta.servlet.http.HttpSession;

@Service
public class PurchaseService {

	private static final Logger log = LoggerFactory.getLogger(PurchaseService.class);

	// 결제 상태 상수 (컨트롤러/DAO와 동일하게 사용할 것)
	public static final String PAYMENT_STATUS_PENDING   = "pending";
	public static final String PAYMENT_STATUS_COMPLETED = "completed";

	@Autowired
	private PurchaseDao purchaseDao;

	// ===================== 멤버/비회원 주문 요청 =====================

	@Transactional
	public void requestPurchase(PurchaseInfo pinfo) {
		String orderNumber = generateUniqueOrderNumberWithHyphen(4); // 앞 4자 + 하이픈
		pinfo.setOrderNumber(orderNumber);

		purchaseDao.requestPurchase(pinfo);
		log.info("Member purchase requested. orderNumber={}, userId={}", orderNumber, pinfo.getUserid());
	}

	@Transactional
	public void nonmemreqPurchase(NonMemberPurchaseInfo nPinfo) {
		String orderNumber = generateUniqueOrderNumberWithHyphen(5); // 앞 5자 + 하이픈
		nPinfo.setOrderNumber(orderNumber);

		purchaseDao.nonmemreqPurchase(nPinfo);
		log.info("Non-member purchase requested. orderNumber={}, email={}", orderNumber, nPinfo.getEmail());
	}

	// 최종 문자열(하이픈 포함) 기준으로 유일성 체크
	private String generateUniqueOrderNumberWithHyphen(int head) {
		int tries = 3;
		while (tries-- > 0) {
			String raw = UUID.randomUUID().toString().replaceAll("-", "");
			String candidate = raw.substring(0, head) + "-" + raw.substring(head);
			if (!isOrderNumberExists(candidate)) {
				return candidate;
			}
		}
		// 마지막 fallback
		String raw = UUID.randomUUID().toString().replaceAll("-", "");
		String candidate = raw.substring(0, head) + "-" + raw.substring(head);
		log.warn("Order number collision retries exceeded. Using fallback: {}", candidate);
		return candidate;
	}

	private boolean isOrderNumberExists(String orderNumber) {
		return purchaseDao.countPurchaseByOrderNumber(orderNumber) > 0
				|| purchaseDao.countGuestPurchaseByOrderNumber(orderNumber) > 0;
	}

	// ===================== 조회 유틸 =====================

	public String Searchis(String orderNumber) {
		boolean isMember = purchaseDao.countMemberOrders(orderNumber) > 0;
		boolean isNonMember = purchaseDao.countNonMemberOrders(orderNumber) > 0;
		if (isMember) return "Member";
		if (isNonMember) return "NonMember";
		return "Unknown";
	}

	public PurchaseInfo getOrderInfoByPInfo(String orderNumber) {
		return purchaseDao.getOrderInfoByPInfo(orderNumber);
	}

	public NonMemberPurchaseInfo getOrderInfoByNInfo(String orderNumber) {
		return purchaseDao.getOrderInfoByNInfo(orderNumber);
	}

	public String getPaymentStatus(String orderNumber) {
		String status = purchaseDao.getPaymentStatus(orderNumber);
		return status == null ? null : status.toLowerCase(); // 비교 일원화
	}


	// ===================== 결제 상태 저장/갱신 =====================

	@Transactional
	public void saveupPaymentInfo(PaymentInfo paymentInfo) {
		String incoming = paymentInfo.getPaymentStatus();
		paymentInfo.setPaymentStatus(incoming == null ? PAYMENT_STATUS_PENDING : incoming.toLowerCase());

		String orderNumber = paymentInfo.getOrderNumber();
		int exists = purchaseDao.getPayment(orderNumber);

		if (exists > 0) {
			String status = getPaymentStatus(orderNumber);
			if (!PAYMENT_STATUS_COMPLETED.equals(status)) {
				purchaseDao.updateStatus(orderNumber);
				log.info("Payment status updated. orderNumber={}, status(before)={}", orderNumber, status);
			} else {
				log.info("Payment already completed. orderNumber={}", orderNumber);
			}
		} else {
			purchaseDao.insertStatus(paymentInfo);
			log.info("Payment status inserted. orderNumber={}, status={}", orderNumber, paymentInfo.getPaymentStatus());
		}
	}

	// ===================== 상품/이메일 조회 (안전 파싱) =====================

	public String getproductname(String productid) {
		Integer pid = parseIntSafe(productid);
		if (pid == null) {
			log.warn("Invalid productId string: {}", productid);
			return null;
		}
		return purchaseDao.getproductname(pid);
	}

	public String getproductnamebyC(String firstCartId) {
		Integer id = parseIntSafe(firstCartId);
		if (id == null) {
			log.warn("Invalid cartId string: {}", firstCartId);
			return null;
		}
		return purchaseDao.getproductnamebyC(id);
	}

	public String getemail(String userId) {
		return purchaseDao.getemail(userId);
	}

	// cartIds CSV -> productIds CSV
	public String getproductidbyC(String cartIdsString) {
		if (cartIdsString == null || cartIdsString.isBlank()) return "";
		String[] ids = cartIdsString.split(",");
		List<String> productIds = new ArrayList<>();

		for (String raw : ids) {
			String trimmed = raw == null ? "" : raw.trim();
			if (trimmed.isEmpty()) continue;
			String productId = purchaseDao.getproductidbyC(trimmed);
			if (productId != null && !productId.isBlank()) {
				productIds.add(productId.trim());
			}
		}
		return String.join(",", productIds);
	}

	// ===================== 장바구니 정리 =====================

	@Transactional
	public void removing(String ordernumber, HttpSession session) {
		String who = isMember(ordernumber);
		if ("member".equals(who)) {
			PurchaseInfo memPur = purchaseDao.getmember(ordernumber);
			String ids = memPur == null ? null : memPur.getCartids();
			if (ids != null && !ids.isBlank()) {
				String[] stringArray = ids.split(",");
				for (String s : stringArray) {
					Integer cartId = parseIntSafe(s);
					if (cartId != null) {
						purchaseDao.delcartid(cartId);
					}
				}
				log.info("Removed member cart items. orderNumber={}, cartIds={}", ordernumber, ids);
			}
		} else if ("nonmem".equals(who)) {
			NonMemberPurchaseInfo nm = purchaseDao.getnonmem(ordernumber);
			if (nm != null) {
				String sessionId = session.getId();
				List<CartItem> cartItems = (List<CartItem>) session.getAttribute("cartItems");

				if (cartItems == null) {
					try {
						cartItems = SessionFileUtil.loadSession(sessionId);
					} catch (IOException | NoSuchAlgorithmException e) {
						log.error("Failed to load session cartItems. sessionId={}", sessionId, e);
						cartItems = new ArrayList<>();
					}
					session.setAttribute("cartItems", cartItems);
				}

				// 비회원: productids 전체 제거 (단건 구매 시 productid 사용)
				List<Integer> productIds = new ArrayList<>();
				if (nm.getProductids() != null && !nm.getProductids().isBlank()) {
					String[] arr = nm.getProductids().split(",");
					for (String s : arr) {
						Integer pid = parseIntSafe(s);
						if (pid != null) productIds.add(pid);
					}
				} else if (nm.getProductid() != 0) {
					productIds.add(nm.getProductid());
				}

				if (!productIds.isEmpty()) {
					cartItems.removeIf(item -> productIds.contains(item.getProductid()));
					try {
						SessionFileUtil.saveSession(sessionId, cartItems);
					} catch (IOException e) {
						log.error("Failed to save session cartItems. sessionId={}", sessionId, e);
					}
					log.info("Removed non-member cart items. orderNumber={}, productIds={}", ordernumber, productIds);
				}
			}
		} else {
			log.warn("Unknown order type. orderNumber={}", ordernumber);
		}
	}

	public String isMember(String ordernumber) {
		if (purchaseDao.isMember(ordernumber) > 0) {
			return "member";
		} else if (purchaseDao.isNonmember(ordernumber) > 0) {
			return "nonmem";
		} else {
			return "unknown";
		}
	}

	// ===================== 내부 유틸 =====================

	private Integer parseIntSafe(String s) {
		if (s == null) return null;
		try {
			return Integer.parseInt(s.trim());
		} catch (NumberFormatException e) {
			return null;
		}
	}
}
