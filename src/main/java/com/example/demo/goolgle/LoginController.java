package com.example.demo.goolgle;

import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;            // ✅ Spring @Value
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import com.example.demo.service.AllService;
import com.example.demo.service.GoogleAuthService;
import com.example.demo.service.KakaoAuthService;
import com.example.demo.vo.Member;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;

import jakarta.servlet.http.HttpSession;

@RestController
@RequestMapping("/api/auth") // ✅ 권장: 명확한 prefix
public class LoginController {
	private static final Logger logger = LoggerFactory.getLogger(LoginController.class);

	@Value("${spring.security.oauth2.client.registration.google.client-id}")
	private String googleClientId;

	@Value("${spring.security.oauth2.client.registration.kakao.client-id}")
	private String kakaoClientId;

	private final HttpSession session;
	private final GoogleAuthService googleAuthService;
	private final KakaoAuthService kakaoAuthService;
	private final AllService allService;

	public LoginController(HttpSession session,
						   GoogleAuthService googleAuthService,
						   KakaoAuthService kakaoAuthService,
						   AllService allService) {
		this.session = session;
		this.googleAuthService = googleAuthService;
		this.kakaoAuthService = kakaoAuthService;
		this.allService = allService;
	}

	@PostMapping("/google")
	public ResponseEntity<?> handleGoogleLogin(@RequestBody Map<String, String> request) {
		String idTokenString = request.get("idToken");
		try {
			// ✅ audience(googleClientId) 검증 포함되어야 안전
			GoogleIdToken.Payload payload = googleAuthService.verifyToken(idTokenString);
			String email = payload.getEmail();
			String name  = (String) payload.get("name");

			Member user = allService.saveOrUpdateUser(email, name);

			// ✅ 세션엔 최소 식별자만 권장
			session.setAttribute("userId", user.getUserid());
			session.setAttribute("userRole", "user");

			return ResponseEntity.ok(Map.of("redirectUrl", "/Home/Main"));
		} catch (Exception e) {
			logger.error("Google token verification failed", e); // 토큰 값 자체는 로그에 찍지 않음
			return ResponseEntity.status(401).body(Map.of("error", "Invalid token"));
		}
	}

	@PostMapping("/kakao")
	public ResponseEntity<?> handleKakaoLogin(@RequestBody Map<String, String> request) {
		String accessToken = request.get("accessToken");
		try {
			Map<String, Object> info = kakaoAuthService.verifyToken(accessToken); // 내부에서 /v2/user/me 호출
			String email = (String) info.get("email");   // 동의 안 했을 수 있음 → 서비스에서 null 허용 처리
			String name  = (String) info.get("name");

			Member user = allService.saveOrUpdateUser(email, name);

			session.setAttribute("userId", user.getUserid());
			session.setAttribute("userRole", "user");

			return ResponseEntity.ok(Map.of("redirectUrl", "/Home/Main"));
		} catch (Exception e) {
			logger.error("Kakao token verification failed", e);
			return ResponseEntity.status(401).body(Map.of("error", "Invalid token"));
		}
	}

	@GetMapping("/google/login")
	public String googleLogin() {
		return "AllLogin"; // JSP 뷰 이름 반환 시에는 Controller가 보통 @Controller (not @RestController)
	}
}