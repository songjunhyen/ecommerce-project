package com.example.demo.controller;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.Collections;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.security.web.authentication.logout.SecurityContextLogoutHandler;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.example.demo.service.AllService;
import com.example.demo.service.ProductService;
import com.example.demo.util.SecurityUtils;
import com.example.demo.vo.Product;

import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@Controller
public class MainController {
	private final AllService allService;
	private final ProductService productService;
	private static final Logger logger = LoggerFactory.getLogger(MainController.class);

	MainController(ProductService productService, AllService allService) {
		this.productService = productService;
		this.allService = allService;
	}

	@GetMapping("/")
	public String home(@RequestParam(value = "page", defaultValue = "1") int page, Model model) {
		String userRole = "";
		int adminClass = 10;
		String userId = SecurityUtils.getCurrentUserId();
		if (userId != null && !userId.equals("Anonymous")) {
			userRole = allService.isuser(userId);
			if (userRole.equals("admin")) {
				adminClass = allService.getadminclass(userId);
			}
			model.addAttribute("userRole", userRole);
			model.addAttribute("adminClass", adminClass);
		}

		List<Product> products = productService.getProductList();
		Collections.reverse(products); // ← 정렬은 기존 그대로 유지

		int pageSize = 5;
		int totalCount = products.size();
		int totalPages = Math.max(1, (int) Math.ceil((double) totalCount / pageSize));

		// 페이지 클램핑(경계값 보정)
		int safePage = Math.max(1, Math.min(page, totalPages));
		int start = (safePage - 1) * pageSize;
		int end = Math.min(start + pageSize, totalCount);

		List<Product> paginatedProducts = (start >= end) ? Collections.emptyList() : products.subList(start, end);

		model.addAttribute("products", paginatedProducts);
		model.addAttribute("currentPage", safePage);
		model.addAttribute("totalPages", totalPages);

		int[] pagination = calculatePagination(safePage, totalPages);
		model.addAttribute("startPage", pagination[0]);
		model.addAttribute("endPage", pagination[1]);

		return "realMain";
	}

	@GetMapping("/Home/Main")
	public String mainPage(@RequestParam(value = "page", defaultValue = "1") int page, Model model) {
		String userRole = "";
		int adminClass = 5;
		String userId = SecurityUtils.getCurrentUserId();
		if (userId != null && !userId.equals("Anonymous")) {
			userRole = allService.isuser(userId);
			if (userRole.equals("admin")) {
				adminClass = allService.getadminclass(userId);
			}
			model.addAttribute("userRole", userRole);
			model.addAttribute("adminClass", adminClass);
		}

		List<Product> products = productService.getProductList();
		Collections.reverse(products); // ← 정렬은 기존 그대로 유지

		int pageSize = 5;
		int totalCount = products.size();
		int totalPages = Math.max(1, (int) Math.ceil((double) totalCount / pageSize));

		// 페이지 클램핑(경계값 보정)
		int safePage = Math.max(1, Math.min(page, totalPages));
		int start = (safePage - 1) * pageSize;
		int end = Math.min(start + pageSize, totalCount);

		List<Product> paginatedProducts = (start >= end) ? Collections.emptyList() : products.subList(start, end);

		model.addAttribute("products", paginatedProducts);
		model.addAttribute("currentPage", safePage);
		model.addAttribute("totalPages", totalPages);

		int[] pagination = calculatePagination(safePage, totalPages);
		model.addAttribute("startPage", pagination[0]);
		model.addAttribute("endPage", pagination[1]);

		return "realMain";
	}

	public static int[] calculatePagination(int currentPage, int totalPages) {
		if (currentPage <= 0) currentPage = 1;
		if (totalPages <= 0) totalPages = 1;
		int MAX_PAGES_TO_SHOW = 10;
		int startPage, endPage;

		if (totalPages <= MAX_PAGES_TO_SHOW) {
			startPage = 1;
			endPage = totalPages;
		} else {
			startPage = Math.max(1, currentPage - MAX_PAGES_TO_SHOW / 2);
			endPage = Math.min(totalPages, startPage + MAX_PAGES_TO_SHOW - 1);
			if (endPage - startPage + 1 < MAX_PAGES_TO_SHOW) {
				startPage = Math.max(1, endPage - MAX_PAGES_TO_SHOW + 1);
			}
		}

		return new int[] { startPage, endPage };
	}

	@GetMapping("/Home/login")
	public String Login(HttpServletRequest request, HttpServletResponse response) {
		// ❌ 진입 시 세션 무효화 제거 (세션은 로그아웃에서만 처리)
		return "AllLogin";
	}

	@PostMapping("/Home/logout")
	public String logout(@AuthenticationPrincipal OAuth2User principal, HttpServletRequest request, HttpServletResponse response) {
		// 스프링 시큐리티 로그아웃 처리
		Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
		if (authentication != null) {
			new SecurityContextLogoutHandler().logout(request, response, authentication);
			logger.info("Spring Security logout handler invoked");
		} else {
			logger.info("No authentication found for logout.");
		}

		// 세션 무효화
		HttpSession session = request.getSession(false);
		if (session != null) {
			logger.info("Session invalidated");
			session.invalidate();
		}

		// (선택) 애플리케이션 자체 쿠키 만료 예시 (CART_TOKEN 등 사용 중일 때)
		expireCookie(response, "CART_TOKEN");

		// 캐시 무효화 헤더 설정
		response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
		response.setHeader("Pragma", "no-cache");
		response.setDateHeader("Expires", 0);

		// ✅ JSESSIONID는 컨테이너가 관리 → 별도 수동 만료 불필요

		// 구글 로그아웃 리다이렉션
		if (principal != null) {
			try {
				String scheme = request.getScheme();
				String host = request.getServerName();
				int port = request.getServerPort();
				String redirectUrl = scheme + "://" + host + ((port == 80 || port == 443) ? "" : ":" + port) + "/Home/Main";
				String encodedUrl = URLEncoder.encode(redirectUrl, java.nio.charset.StandardCharsets.UTF_8.name());
				String logoutUrl = "https://accounts.google.com/Logout?continue=" + encodedUrl;
				logger.info("Redirecting to Google logout URL: {}", logoutUrl);
				return "redirect:" + logoutUrl;
			} catch (UnsupportedEncodingException e) {
				logger.error("Encoding not supported: ", e);
				return "redirect:/Home/Main";
			}
		}

		return "redirect:/Home/Main";
	}

	@GetMapping("/api/auth/check")
	public ResponseEntity<String> checkAuthentication(HttpServletRequest request) {
		Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
		if (authentication instanceof AnonymousAuthenticationToken) {
			return ResponseEntity.ok("User is not authenticated");
		} else if (authentication != null && authentication.isAuthenticated()) {
			return ResponseEntity.ok("Authenticated");
		}
		return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Not Authenticated");
	}

	// (선택) 자체 쿠키 만료 유틸
	private void expireCookie(HttpServletResponse response, String name) {
		Cookie cookie = new Cookie(name, "");
		cookie.setPath("/");
		cookie.setMaxAge(0);
		cookie.setHttpOnly(true);
		// cookie.setSecure(true); // HTTPS 환경이면 활성화
		response.addCookie(cookie);
		// SameSite 보강
		response.addHeader("Set-Cookie", name + "=; Max-Age=0; Path=/; HttpOnly; SameSite=Lax");
	}
}
