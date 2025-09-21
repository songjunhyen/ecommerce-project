package com.example.demo.service;

import java.util.List;

import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.demo.dao.AdminDao;
import com.example.demo.vo.Admin;

@Service
@Transactional(readOnly = true) // 기본 읽기 전용
public class AdminService {
	private final AdminDao adminDao;
	private final PasswordEncoder passwordEncoder;

	public AdminService(AdminDao adminDao, PasswordEncoder passwordEncoder) {
		this.adminDao = adminDao;
		this.passwordEncoder = passwordEncoder;
	}

	@Transactional // 쓰기
	public void signup(Admin newAdmin) {
		// 사전 중복 체크(아이디)
		if (newAdmin.getAdminId() == null || newAdmin.getAdminId().isBlank()) {
			throw new IllegalArgumentException("관리자 아이디는 필수입니다.");
		}
		boolean exists = adminDao.checkid(newAdmin.getAdminId());
		if (exists) {
			throw new IllegalStateException("이미 존재하는 관리자 아이디입니다.");
		}
		// (선택) 이메일 중복 체크 필요 시 getbyemail 사용
		if (newAdmin.getEmail() == null || newAdmin.getEmail().isBlank()) {
			throw new IllegalArgumentException("이메일은 필수입니다.");
		}
		if (adminDao.getbyemail(newAdmin.getEmail()) != null) {
			throw new IllegalStateException("이미 사용 중인 이메일입니다.");
		}

		if (newAdmin.getAdminPw() == null || newAdmin.getAdminPw().length() < 8) {
			throw new IllegalArgumentException("비밀번호는 8자 이상이어야 합니다.");
		}
		String encodedPassword = passwordEncoder.encode(newAdmin.getAdminPw());
		newAdmin.setAdminPw(encodedPassword);

		try {
			adminDao.signup(newAdmin);
		} catch (DataIntegrityViolationException e) {
			// UNIQUE 제약 등 DB 예외 방어
			throw new IllegalStateException("중복된 정보가 있습니다. 아이디/이메일을 확인하세요.", e);
		}
	}

	public boolean checking(String userid, String pw) {
		if (userid == null || userid.isBlank() || pw == null) return false;
		if (!adminDao.checkid(userid)) return false;

		String hashedPassword = adminDao.getHashedPassword(userid);
		if (hashedPassword == null || hashedPassword.isBlank()) return false;

		return passwordEncoder.matches(pw, hashedPassword);
	}

	public int getid(String userid) {
		// Dao가 Integer를 반환하도록 바꿨다면 널 가드
		Integer id = adminDao.getid(userid);
		return id == null ? 0 : id;
	}

	@Transactional // 쓰기
	public void modify(String newpw, String name, String email) {
		if (email == null || email.isBlank()) {
			throw new IllegalArgumentException("이메일은 필수입니다.");
		}
		if (newpw == null || newpw.length() < 8) {
			throw new IllegalArgumentException("비밀번호는 8자 이상이어야 합니다.");
		}
		String encodedPassword = passwordEncoder.encode(newpw);
		adminDao.modify(encodedPassword, name, email);
	}

	@Transactional // 쓰기
	public void signout(int id, String email) {
		if (id <= 0 || email == null || email.isBlank()) {
			throw new IllegalArgumentException("유효하지 않은 탈퇴 요청입니다.");
		}
		adminDao.signout(id, email);
	}

	public Admin getbyemail(String email) {
		if (email == null || email.isBlank()) return null;
		return adminDao.getbyemail(email);
	}

	public Admin getAdminClassByUserid(String userid) {
		if (userid == null || userid.isBlank()) return null;
		return adminDao.getAdminClassByUserid(userid);
	}

	public int getIdByEmail(String email) {
		Admin usr = adminDao.getbyemail(email);
		return (usr == null) ? 0 : usr.getId();
	}

	public List<Admin> searchAdmin(String adminclass, String name, String email) {
		// 그대로 위임 (Dao가 NULL을 조건부로 처리)
		return adminDao.searcAL(adminclass, name, email);
	}

	@Transactional // 쓰기
	public void resetPassword(String adminId, String newId, String newPassword) {
		if (adminId == null || adminId.isBlank()) {
			throw new IllegalArgumentException("기존 관리자 아이디는 필수입니다.");
		}
		if (newPassword == null || newPassword.length() < 8) {
			throw new IllegalArgumentException("비밀번호는 8자 이상이어야 합니다.");
		}
		// 아이디 변경이 포함되는 정책이므로, newId가 비어있지 않으면 중복 사전 체크
		if (newId != null && !newId.isBlank() && !adminId.equals(newId)) {
			boolean exists = adminDao.checkid(newId);
			if (exists) {
				throw new IllegalStateException("이미 존재하는 새 관리자 아이디입니다.");
			}
		}

		String encodedPassword = passwordEncoder.encode(newPassword);
		try {
			adminDao.resetPassword(adminId, newId, encodedPassword);
		} catch (DataIntegrityViolationException e) {
			// UNIQUE 충돌 등
			throw new IllegalStateException("아이디/이메일 중복으로 비밀번호 초기화에 실패했습니다.", e);
		}
	}
}
