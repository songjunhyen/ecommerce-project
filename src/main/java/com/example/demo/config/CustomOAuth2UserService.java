package com.example.demo.config;

import org.springframework.security.oauth2.client.userinfo.DefaultOAuth2UserService;
import org.springframework.security.oauth2.client.userinfo.OAuth2UserRequest;
import org.springframework.security.oauth2.client.userinfo.OAuth2UserService;
import org.springframework.security.oauth2.core.OAuth2AuthenticationException;
import org.springframework.security.oauth2.core.user.DefaultOAuth2User;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Service;
import org.springframework.security.core.authority.SimpleGrantedAuthority;

import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

import com.example.demo.service.AllService;

import java.util.Collections;
import java.util.Map;

@Service
public class CustomOAuth2UserService implements OAuth2UserService<OAuth2UserRequest, OAuth2User> {

	private final AllService allService;
	private final OAuth2UserService<OAuth2UserRequest, OAuth2User> delegate = new DefaultOAuth2UserService();

	public CustomOAuth2UserService(AllService allService) { this.allService = allService; }

	@Override
	public OAuth2User loadUser(OAuth2UserRequest userRequest) throws OAuth2AuthenticationException {
		// 1) 표준 방식으로 사용자 정보 조회 (이전처럼 직접 REST 호출 X)
		OAuth2User loaded = delegate.loadUser(userRequest);
		Map<String, Object> attrs = loaded.getAttributes();
		String registrationId = userRequest.getClientRegistration().getRegistrationId();

		// 2) 기존 키 호환 유지
		// - Google: 이미 "sub"와 "email"을 제공
		// - Kakao: nickname을 "sub"에, email은 동의 시 kakao_account.email에서
		if ("kakao".equals(registrationId)) {
			// kakao_account/profile 안전 추출
			Object kakaoAccountObj = attrs.get("kakao_account");
			if (kakaoAccountObj instanceof Map<?, ?> kakaoAccount) {
				// email 보강
				Object emailObj = kakaoAccount.get("email");
				if (emailObj instanceof String email) {
					attrs.put("email", email);
				}
				// profile.nickname → sub 보강(기존 호환)
				Object profileObj = kakaoAccount.get("profile");
				if (profileObj instanceof Map<?, ?> profile) {
					Object nickObj = profile.get("nickname");
					if (nickObj instanceof String nickname) {
						attrs.put("sub", nickname); // ✅ 기존 코드와 동일 키 사용
					}
				}
			}
			// 그래도 sub이 비어 있으면 id를 문자열로 대체 (식별자 보장)
			if (!attrs.containsKey("sub") || attrs.get("sub") == null) {
				Object id = attrs.get("id"); // kakao의 고유 id
				if (id != null) attrs.put("sub", String.valueOf(id));
			}
		}
		// Google의 경우 별도 변경 없음 (이미 "sub","email" 포함)

		// 3) 기존 세션 키/값 유지
		String email = safeStr(attrs.get("email"));
		String nameForDisplay = safeStr(attrs.get("sub")); // ✅ 기존과 동일하게 sub를 이름 용도로 사용
		ServletRequestAttributes sra = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
		if (sra != null) {
			HttpServletRequest request = sra.getRequest();
			HttpSession session = request.getSession();
			session.setAttribute("customuser", email);  // ✅ 기존 세션 키 유지
			session.setAttribute("userRole", "user");   // ✅ 기존 세션 키 유지
		}

		// 4) DB 동기화 (기존 시그니처 유지)
		allService.saveOrUpdateUser(email, nameForDisplay);

		// 5) 반환 시 nameAttributeKey를 "sub"로 유지 (기존과 동일)
		return new DefaultOAuth2User(
				Collections.singleton(new SimpleGrantedAuthority("ROLE_USER")),
				attrs,
				"sub" // ✅ 기존과 동일
		);
	}

	private static String safeStr(Object o) {
		return (o == null) ? null : String.valueOf(o);
	}
}
