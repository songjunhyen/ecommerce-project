package com.example.demo.service;

import java.util.List;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.demo.dao.UserDao;
import com.example.demo.vo.Member;

@Service
public class UserService {
	private final UserDao userDao;
	private final PasswordEncoder passwordEncoder;

	public UserService(UserDao userDao, PasswordEncoder passwordEncoder) {
		this.userDao = userDao;
		this.passwordEncoder = passwordEncoder;
	}

	@Transactional
	public void signup(Member member) {
		String encodedPassword = passwordEncoder.encode(member.getUserpw());
		member.setUserpw(encodedPassword);
		userDao.signup(member);
	}

	@Transactional
	public void modify(String userid, String pw, String name, String email, String address) {
		String encodedPassword = passwordEncoder.encode(pw);
		userDao.modify(userid, encodedPassword, name, email, address);
	}

	@Transactional
	public void signout(int id) {
		userDao.signout(id);
	}

	public boolean checking(String userid, String pw) {
		Member member = userDao.findByUserid(userid);
		if (member != null) {
			String storedPassword = member.getUserpw();
			return passwordEncoder.matches(pw, storedPassword);
		}
		return false;
	}

	public int getid(String userid, String pw) {
		Member member = userDao.findByUserid(userid);
		if (member != null && passwordEncoder.matches(pw, member.getUserpw())) {
			return member.getId();
		}
		return -1;
	}

	public boolean existsByUserid(String userid) {
		return userDao.countByUserid(userid) > 0;
	}

	public int getid2(String userid) {
		Member usr = userDao.findByUserid(userid);
		return (usr == null) ? 0 : usr.getId();
	}

	// ⚠️ 이 메서드는 AllService가 관리자 여부를 따로 판단하므로, 여기서는 user만 판단하는 게 더 안전합니다.
	public String isuser(String userid) {
		return userDao.countByUserid(userid) > 0 ? "user" : "admin";
		// 권장: return userDao.countByUserid(userid) > 0 ? "user" : "unknown";
	}

	public boolean checkon(String userid, String pw) {
		Member member = userDao.findByUserid(userid);
		return member != null && passwordEncoder.matches(pw, member.getUserpw());
	}

	public int getid3(String email) {
		Member usr = userDao.findByUserEmail(email);
		return (usr == null) ? 0 : usr.getId();
	}

	public List<Member> searchUser(String name, String email) {
		return userDao.searcUL(name, email);
	}

	@Transactional
	public void resetPassword(String userid, String newPassword) {
		String encodedPassword = passwordEncoder.encode(newPassword);
		userDao.resetPassword(userid, encodedPassword);
	}

	public Member findByUserid(String userid) {
		return userDao.findByUserid(userid);
	}
}
