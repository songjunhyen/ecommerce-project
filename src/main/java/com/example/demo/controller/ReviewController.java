package com.example.demo.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import com.example.demo.service.ReviewService;
import com.example.demo.util.SecurityUtils;
import com.example.demo.vo.Review;

@Controller
public class ReviewController {
	private final ReviewService reviewService;

	ReviewController(ReviewService reviewService) {
		this.reviewService = reviewService;
	}

	@PostMapping("/Review/add")
	public String addReview(
			/* HttpSession session 제거 가능하지만 시그니처 유지 원칙에 따라 둡니다 */
			jakarta.servlet.http.HttpSession session,
			@RequestParam int productId,
			@RequestParam String body,
			@RequestParam double star
	) {
		String writer = SecurityUtils.getCurrentUserId();
		if (writer == null || "Anonymous".equals(writer)) {
			// 비로그인 사용자는 로그인 페이지 또는 상세 페이지로 돌려보냅니다.
			return "redirect:/product/detail?id=" + productId;
		}

		// 기본 검증
		if (productId <= 0) {
			return "redirect:/product/detail?id=" + productId;
		}

		String cleanBody = body == null ? "" : body.trim();
		if (cleanBody.isEmpty() || cleanBody.length() > 2000) {
			// 길이 제한은 필요에 맞게 조정 가능
			return "redirect:/product/detail?id=" + productId;
		}

		// 별점 0~5 범위 클램핑, 소수점 1자리로 제한
		double clamped = Math.max(0.0, Math.min(5.0, star));
		clamped = Math.round(clamped * 10.0) / 10.0;

		reviewService.AddReview(writer, productId, cleanBody, clamped);
		return "redirect:/product/detail?id=" + productId;
	}

	@GetMapping("/Review/list")
	@ResponseBody
	public List<Review> getReviewList(@RequestParam int productid) {
		if (productid <= 0) {
			// 빈 리스트 반환으로 방어
			return java.util.Collections.emptyList();
		}
		return reviewService.ReviewList(productid);
	}

	@PostMapping("/Review/modify")
	public String ReviewModify(
			/* HttpSession session 유지 */
			jakarta.servlet.http.HttpSession session,
			Model model,
			@RequestParam int productid,
			@RequestParam int reviewid,
			@RequestParam String body
	) {
		String writer = SecurityUtils.getCurrentUserId();
		if (writer == null || "Anonymous".equals(writer)) {
			model.addAttribute("message", "로그인이 필요합니다.");
			return "redirect:/product/detail?id=" + productid;
		}
		if (productid <= 0 || reviewid <= 0) {
			model.addAttribute("message", "잘못된 요청입니다.");
			return "redirect:/product/detail?id=" + productid;
		}

		String cleanBody = body == null ? "" : body.trim();
		if (cleanBody.isEmpty() || cleanBody.length() > 2000) {
			model.addAttribute("message", "리뷰 내용이 비어있거나 너무 깁니다.");
			return "redirect:/product/detail?id=" + productid;
		}

		// 현재는 서비스에 iswriter(writer)만 있어서 그대로 사용.
		// 가능하면 서비스에 isOwner(reviewid, writer) 추가 권장.
		if (!reviewService.iswriter(writer)) {
			model.addAttribute("message", "권한이 없습니다.");
			return "redirect:/product/detail?id=" + productid;
		}

		reviewService.ReviewModify(writer, productid, reviewid, cleanBody);
		return "redirect:/product/detail?id=" + productid;
	}

	@PostMapping("/Review/delete")
	public String ReviewDelete(
			/* HttpSession session 유지 */
			jakarta.servlet.http.HttpSession session,
			@RequestParam int productid,
			@RequestParam int reviewid
	) {
		String writer = SecurityUtils.getCurrentUserId();
		if (writer == null || "Anonymous".equals(writer)) {
			return "redirect:/product/detail?id=" + productid;
		}
		if (productid <= 0 || reviewid <= 0) {
			return "redirect:/product/detail?id=" + productid;
		}

		if (!reviewService.iswriter(writer)) {
			return "redirect:/product/detail?id=" + productid;
		}

		reviewService.ReviewDelete(writer, productid, reviewid);
		return "redirect:/product/detail?id=" + productid;
	}

	@GetMapping("/Review/getstar")
	@ResponseBody
	public ResponseEntity<Double> GetAverStar(@RequestParam int productid) {
		if (productid <= 0) {
			return ResponseEntity.ok(0.0);
		}
		double averageStar = reviewService.GetAverStar(productid);
		// 평균도 0~5 사이로 방어
		double safeAvg = Math.max(0.0, Math.min(5.0, averageStar));
		return ResponseEntity.ok(safeAvg);
	}
}
