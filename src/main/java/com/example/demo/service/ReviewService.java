package com.example.demo.service;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.demo.dao.ReviewDao;
import com.example.demo.vo.Review;

@Service
public class ReviewService {
	private final ReviewDao reviewDao;

	ReviewService(ReviewDao reviewDao){
		this.reviewDao = reviewDao;
	}

	@Transactional
	public void AddReview(String writer, int productid, String body, double star) {
		// 간단 유효성 보강 (원치 않으시면 제거하세요)
		if (body != null) body = body.trim();
		if (body == null || body.isEmpty()) body = "(내용 없음)";

		// 별점 범위 0.0 ~ 5.0로 클램핑
		star = Math.max(0.0, Math.min(5.0, star));

		reviewDao.AddReview(writer, productid, body, star);
	}

	public List<Review> ReviewList(int productid) {
		return reviewDao.ReviewList(productid);
	}

	@Transactional
	public void ReviewModify(String writer, int productid, int reviewid, String body) {
		if (body != null) body = body.trim();
		if (body == null || body.isEmpty()) body = "(내용 없음)";
		reviewDao.ReviewModify(writer, productid, reviewid, body);
	}

	@Transactional
	public void ReviewDelete(String writer, int productid, int reviewid) {
		reviewDao.ReviewDelete(writer, productid, reviewid);
	}

	public double GetAverStar(int productid) {
		Double star = reviewDao.GetAverStar(productid);
		if (star == null) {
			star = 0.0;
		}
		return star;
	}

	public boolean iswriter(String writer) {
		// 단순 위임이면 이렇게 축약 가능합니다
		return reviewDao.iswriter(writer);
	}
}
