package com.example.demo.service;

import com.example.demo.dao.AdminDao;
import com.example.demo.dao.UserDao;
import com.example.demo.vo.Member;

import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional(readOnly = true)
public class AllService {
	private final UserDao userDao;
	private final AdminDao adminDao;

	AllService(UserDao userDao, AdminDao adminDao){
		this.userDao = userDao;
		this.adminDao = adminDao;
	}

	public String isuser(String userid) {
		String uid = safeTrim(userid);
		if (isBlank(uid) || "Anonymous".equals(uid)) {
			return "unknown";
		}
		int userCount = userDao.countByUserid(uid);
		boolean isAdminId = adminDao.checkid(uid);

		if (userCount > 0) {
			return "user";
		} else if (isAdminId) {
			return "admin";
		} else {
			return "unknown";
		}
	}

	public int getadminclass(String userid) {
		String uid = safeTrim(userid);
		if (isBlank(uid)) return defaultAdminClass(); // 기본값(정책에 맞게 조정)
		// AdminDao가 Integer를 반환할 수 있음을 가정하고 널 가드
		Integer cls = adminDao.getadminclass(uid);
		return cls == null ? defaultAdminClass() : cls;
	}

	@Transactional // DB 쓰기이므로 트랜잭션 필요
	public Member saveOrUpdateUser(String email, String name) {
		String em = safeTrim(email);
		String nm = safeTrim(name);
		if (isBlank(em)) {
			throw new IllegalArgumentException("email은 필수입니다.");
		}
		// OAuth 등에서 'email을 userid로 사용' 정책이라면 아래 주석 유지
		// userid == email
		Member member = userDao.findByUserid(em);
		if (member == null) {
			member = new Member();
			member.setUserid(em);
			member.setEmail(em);
			member.setName(nm);
			try {
				userDao.save(member); // insert
			} catch (DataIntegrityViolationException e) {
				// 경합으로 인한 UNIQUE 충돌 등 → 읽어와서 반환 (멱등성)
				Member existing = userDao.findByUserid(em);
				if (existing != null) return existing;
				throw e;
			}
		} else {
			// 필요한 필드만 업데이트(서비스 정책에 맞게)
			member.setName(nm);
			userDao.save(member); // update 또는 upsert 동작(DAO 구현에 따름)
		}
		return member;
	}

	// ====== small helpers ======
	private static String safeTrim(String s) { return s == null ? "" : s.trim(); }
	private static boolean isBlank(String s) { return s == null || s.trim().isEmpty(); }
	private static int defaultAdminClass() { return 10; } // 컨트롤러에서 쓰던 기본값과 맞추세요
}
