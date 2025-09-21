package com.example.demo.controller;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.example.demo.service.AdminService;
import com.example.demo.util.SecurityUtils;
import com.example.demo.vo.Admin;

import jakarta.servlet.http.HttpSession;

@Controller
public class AdminController {

	@Autowired
	private AdminService adminService;

	@GetMapping("/admin/Dashboard")
	public String Board(Model model) {	//대쉬보드 이장
		String userid = SecurityUtils.getCurrentUserId();
		Admin foundadmin = adminService.getAdminClassByUserid(userid); //내부에는 adminClass랑 name만 들어있음
		model.addAttribute("admin", foundadmin);
		return "admin/dashboard";
	}

	// ---------------- 폐이지 이동 ------------------
	@GetMapping("/admin/Signup")
	public String signUP() {
		return "admin/signup";
	}
	
	@GetMapping("/admin/SignupReport")
	public String signUPre() {
		return "admin/signupReport";
	}

	@GetMapping("/admin/Modify")
	public String Modify() {
		return "admin/modify";
	}

	@GetMapping("/admin/ModifyAdmin")
	public String ModifyAdmin() {
		return "admin/adminModify";
	}

	@GetMapping("/admin/Search")
	public String Search() {
		return "admin/search";
	}

	// ---------------------------------------------------

	@PostMapping("/admin/signup")
	public String signup(@RequestParam String name, @RequestParam String email, @RequestParam int adminclass, RedirectAttributes redirectAttributes) {

		if (name == null || name.trim().isEmpty() ||
				email == null || email.trim().isEmpty()) {
			redirectAttributes.addFlashAttribute("error", "필수 항목이 비어있습니다.");
			return "redirect:/admin/Signup";
		}

		// 2) 특수문자 포함 여부 체크 (한글,영문,숫자만 허용)
		if (!name.matches("^[a-zA-Z0-9가-힣]+$")) {
			redirectAttributes.addFlashAttribute("error", "이름에 특수문자를 포함할 수 없습니다.");
			return "redirect:/admin/Signup";
		}

		// 이메일 형식 체크
		if (!email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$")) {
			redirectAttributes.addFlashAttribute("error", "이메일 형식이 올바르지 않습니다.");
			return "redirect:/admin/Signup";
		}

		LocalDateTime currentTime = LocalDateTime.now();
		DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMddHHmmssSSS");
		String formattedDateTime = currentTime.format(formatter);
		String adminid = "admin" + formattedDateTime;

		UUID uuid = UUID.randomUUID();
		String adminpw = uuid.toString().replace("-", "");

		Admin newAdmin = new Admin(adminid, adminpw, name, email);
		adminService.signup(newAdmin);
		redirectAttributes.addFlashAttribute("admin", newAdmin);
		return "redirect:/admin/SignupReport";
	}

	@GetMapping("/admin/Signout") // jsp쪽에서 비번 체크하도록
	public String Sigbout(HttpSession session, @RequestParam String email) {
		int adminid = (int) session.getAttribute("id");
		adminService.signout(adminid, email);

		return "redirect:/Home/Main";
	}

	@GetMapping("/admin/logout")
	public String logout(HttpSession session) {
		// 세션에서 userid 제거
		session.removeAttribute("id");
		// 세션 무효화
		session.invalidate();

		return "redirect:/Home/Main";
	}
		
	@RequestMapping("/admin/checkEmail_do")
	@ResponseBody
	public Map<Object, Object> checkEmail(@RequestParam String email) {
		int id = adminService.getIdByEmail(email);
        //getMemberId는 id로 멤버의 dto를 꺼내오는 메소드
        
		Map<Object, Object> map = new HashMap<>();

		// 아이디가 존재하지 않으면
		if(id == 0) {
			map.put("cnt", 0);
		// 아이디가 존재하면
		}else {
			map.put("cnt", 1);
		}
		
		return map;
	}
	
	@RequestMapping(value = "/admin/Searching", method = RequestMethod.POST)
	@ResponseBody
	public List<Admin> searchAdmins(@RequestParam(required = false) String adminclass,
			@RequestParam(required = false) String name, @RequestParam(required = false) String email) {
		// 빈값 처리
		if (adminclass == null || adminclass.isEmpty()) {
			adminclass = null; // adminclass가 빈 문자열일 경우 null로 처리
		}
		if (name == null || name.isEmpty()) {
			name = null; // name이 빈 문자열일 경우 null로 처리
		}
		if (email == null || email.isEmpty()) {
			email = null; // email이 빈 문자열일 경우 null로 처리
		}

		List<Admin> admins = adminService.searchAdmin(adminclass, name, email);
		return admins;
	}
	
	 @PostMapping("/admin/resetAD")
	    public String resetPassword(@RequestParam String adminid, Model model) {
	        // 초기화
		 	LocalDateTime currentTime = LocalDateTime.now();
			DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMddHHmmssSSS");
			String formattedDateTime = currentTime.format(formatter);
			String newId = "admin" + formattedDateTime;
	        String newPassword = UUID.randomUUID().toString().replace("-", "");
	        
	        adminService.resetPassword(adminid, newId, newPassword);
	        model.addAttribute("message", "비밀번호가 초기화되었습니다.");
	        return "admin/modify";
	    }
}
