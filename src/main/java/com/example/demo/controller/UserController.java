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
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

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
		if (!model.containsAttribute("SignUpForm")) {
			model.addAttribute("SignUpForm", new SignUpForm());
		}
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
	public String signup(@ModelAttribute("SignUpForm") SignUpForm form,
						 RedirectAttributes ra) {

		Map<String, String> errors = new HashMap<>();

		// ▼ 트림
		String userid = safeTrim(form.getUserid());
		String pw     = safeTrim(form.getPw());
		String name   = safeTrim(form.getName());
		String email  = safeTrim(form.getEmail());
		String addr   = safeTrim(form.getAddress());

		// ▼ 수동 검증
		if (isBlank(userid)) errors.put("userid", "아이디를 입력해주세요.");
		else if (!userid.matches("^[A-Za-z0-9]{4,20}$"))
			errors.put("userid", "아이디는 영문/숫자 4~20자만 가능합니다.");

		if (isBlank(pw)) errors.put("pw", "비밀번호를 입력해주세요.");
		else if (!pw.matches("^(?=.*[A-Za-z])(?=.*\\d)\\S{8,64}$"))
			errors.put("pw", "비밀번호는 영문/숫자 포함 8~64자, 공백 불가입니다.");

		if (isBlank(name)) errors.put("name", "닉네임을 입력해주세요.");
		else if (!name.matches("^[가-힣A-Za-z0-9 _-]{2,20}$"))
			errors.put("name", "닉네임은 2~20자(한/영/숫자/_/-/스페이스)만 가능합니다.");

		if (isBlank(email)) errors.put("email", "이메일을 입력해주세요.");
		else if (!email.matches("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$"))
			errors.put("email", "올바른 이메일 형식이 아닙니다.");

		// ▼ 중복 체크
		if (!errors.containsKey("userid") && "user".equals(userService.isuser(userid))) {
			errors.put("userid", "이미 존재하는 아이디입니다.");
		}
		if (!errors.containsKey("email") && userService.getid3(email) != 0) {
			errors.put("email", "이미 사용 중인 이메일입니다.");
		}

		// 에러 있으면 flash로 되돌리기 (비번은 보안상 복원 X)
		if (!errors.isEmpty()) {
			SignUpForm echo = new SignUpForm();
			echo.setUserid(userid);
			echo.setName(name);
			echo.setEmail(email);
			echo.setAddress(addr);

			ra.addFlashAttribute("errors", errors);
			ra.addFlashAttribute("SignUpForm", echo);
			return "redirect:/user/Signup";
		}

		// 성공 처리
		Member newMember = new Member(userid, pw, name, email, addr);
		userService.signup(newMember);
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
	public String Signout(HttpSession session, int id) {
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
