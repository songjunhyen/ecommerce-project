package com.example.demo.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import com.example.demo.form.SignUpForm;
import com.example.demo.service.UserService;
import com.example.demo.util.SecurityUtils;
import com.example.demo.vo.Member;

import jakarta.servlet.http.HttpSession;

@Controller
public class UserController {
	private final UserService userService;

	public UserController(UserService userService) {
		this.userService = userService;
	}

	@GetMapping("/test/user/Main")
	public String mainPage() {
		return "user/main";
	}

	@GetMapping("/user/Signup")
	public String signUP(Model model) {
		model.addAttribute("SignUpForm", new SignUpForm());
		return "user/signup";
	}

	@GetMapping("/user/Search")
	public String Search() {
		return "user/usersearch";
	}

	@GetMapping("/user/Modify")
	public String Modify() {
		// 접근 가드(로그인 필요)
		String current = SecurityUtils.getCurrentUserId();
		if (current == null || "Anonymous".equals(current)) {
			return "redirect:/Home/login";
		}
		return "user/modify";
	}

	@GetMapping("/user/Check")
	public String check(Model model) {
		String userid = SecurityUtils.getCurrentUserId();
		if (userid == null || "Anonymous".equals(userid)) {
			return "redirect:/Home/login";
		}
		Member me = userService.findByUserid(userid); // 서비스에 맞게 구현
		model.addAttribute("member", me);
		return "user/check";
	}

	@PostMapping("/user/Checking")
	public String checking(@RequestParam String pw, Model model) {
		String userid = SecurityUtils.getCurrentUserId();
		if (userid == null || "Anonymous".equals(userid)) {
			model.addAttribute("result", "false");
			return "user/modify";
		}
		boolean result = userService.checkon(userid, pw == null ? "" : pw);
		model.addAttribute("result", result ? "true" : "false");
		return "user/modify";
	}

	@PostMapping("/user/signup")
	public String signup(Model model, SignUpForm signupform) {
		// 기본 검증
		String userid = safeTrim(signupform.getUserid());
		String pw = safeTrim(signupform.getPw());
		String name = safeTrim(signupform.getName());
		String email = safeTrim(signupform.getEmail());
		String address = safeTrim(signupform.getAddress());

		if (isBlank(userid) || isBlank(pw) || isBlank(name) || isBlank(email)) {
			model.addAttribute("errorMessage", "필수 항목이 누락되었습니다.");
			return "redirect:/user/Signup";
		}
		if (!email.matches("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$")) {
			model.addAttribute("errorMessage", "올바른 이메일 형식이 아닙니다.");
			return "redirect:/user/Signup";
		}
		if (pw.length() < 8 || pw.length() > 64) {
			model.addAttribute("errorMessage", "비밀번호는 8~64자여야 합니다.");
			return "redirect:/user/Signup";
		}

		// 존재 여부(아이디/이메일) 체크
		String isclass = userService.isuser(userid);
		if ("user".equals(isclass)) {
			model.addAttribute("errorMessage", "이미 존재하는 사용자입니다.");
			return "redirect:/user/Signup";
		}
		if (userService.getid3(email) != 0) {
			model.addAttribute("errorMessage", "이미 사용 중인 이메일입니다.");
			return "redirect:/user/Signup";
		}

		Member newMember = new Member(userid, pw, name, email, address);
		userService.signup(newMember); // 서비스에서 해시 처리 가정
		return "redirect:/Home/Main";
	}

	@PostMapping("/user/modify")
	public String modify(HttpSession session,
						 @RequestParam String pw,
						 @RequestParam String name,
						 @RequestParam String email,
						 @RequestParam String address) {
		String userid = SecurityUtils.getCurrentUserId();
		if (userid == null || "Anonymous".equals(userid)) {
			return "redirect:/Home/login";
		}

		String spw = safeTrim(pw);
		String sname = safeTrim(name);
		String semail = safeTrim(email);
		String saddr = safeTrim(address);

		if (!isBlank(spw) && (spw.length() < 8 || spw.length() > 64)) {
			return "redirect:/user/Modify";
		}
		if (!isBlank(semail) && !semail.matches("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$")) {
			return "redirect:/user/Modify";
		}

		userService.modify(userid, spw, sname, semail, saddr);
		return "redirect:/Home/Main";
	}

	@GetMapping("/user/Signout") // jsp쪽에서 비번 체크하도록
	public String Sigbout(HttpSession session, int id) {
		// 로그인 사용자와 요청 id 일치 확인(권한 가드)
		String current = SecurityUtils.getCurrentUserId();
		if (current == null || "Anonymous".equals(current)) {
			return "redirect:/Home/login";
		}
		int myId = userService.getid2(current);
		if (myId != id) {
			// 내 계정이 아니면 거부
			return "redirect:/Home/Main";
		}

		userService.signout(id);

		// 세션 정리
		session.removeAttribute("id");
		session.removeAttribute("islogined");
		session.invalidate();
		return "redirect:/Home/Main";
	}

	@RequestMapping("/user/checkId.do")
	@ResponseBody
	public Map<Object, Object> checkId(@RequestParam String userid) {
		Map<Object, Object> map = new HashMap<>();
		String idTrim = safeTrim(userid);
		if (isBlank(idTrim)) {
			map.put("cnt", 1); // 빈 값은 사용 불가로 처리
			return map;
		}
		int id = userService.getid2(idTrim);
		map.put("cnt", id == 0 ? 0 : 1);
		return map;
	}

	@RequestMapping("/user/checkEmail.do")
	@ResponseBody
	public Map<Object, Object> checkEmail(@RequestParam String email) {
		Map<Object, Object> map = new HashMap<>();
		String em = safeTrim(email);
		if (isBlank(em) || !em.matches("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$")) {
			map.put("cnt", 1); // 형식 불량/빈 값은 사용 불가로 처리
			return map;
		}
		int id = userService.getid3(em);
		map.put("cnt", id == 0 ? 0 : 1);
		return map;
	}

	@RequestMapping(value = "/user/Searching", method = RequestMethod.POST)
	@ResponseBody
	public List<Member> searchUsers(@RequestParam(required = false) String name,
									@RequestParam(required = false) String email) {
		String sname = trimToNull(name);
		String semail = trimToNull(email);
		// (권장) 관리자만 접근하도록 서비스/시큐리티에서 추가 가드
		return userService.searchUser(sname, semail);
	}

	@PostMapping("/user/resetPassword")
	public String resetPassword(@RequestParam String userid, Model model) {
		String target = safeTrim(userid);
		if (isBlank(target)) {
			model.addAttribute("message", "유효하지 않은 사용자입니다.");
			return "user/usersearch";
		}
		// 새 비밀번호 생성(표시/로깅 금지, 서비스에서 해시/통지 처리)
		String newPassword = UUID.randomUUID().toString().replace("-", "");
		userService.resetPassword(target, newPassword);
		model.addAttribute("message", "비밀번호가 초기화되었습니다.");
		return "user/usersearch";
	}

	// ====== 작은 유틸 ======
	private static String safeTrim(String s) { return s == null ? "" : s.trim(); }
	private static boolean isBlank(String s) { return s == null || s.trim().isEmpty(); }
	private static String trimToNull(String s) {
		if (s == null) return null;
		String t = s.trim();
		return t.isEmpty() ? null : t;
	}
}
