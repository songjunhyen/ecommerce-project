package com.example.demo.service;

import java.util.HashMap;
import java.util.Map;

import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

@Service
public class KakaoAuthService {

    private static final String KAKAO_USER_INFO_URL = "https://kapi.kakao.com/v2/user/me";
    private final RestTemplate restTemplate;

    public KakaoAuthService(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    /** accessToken 으로 사용자 정보 조회 → 표준화된 Map 반환(id/email/name) */
    public Map<String, Object> verifyToken(String accessToken) {
        try {
            HttpHeaders headers = new HttpHeaders();
            headers.set("Authorization", "Bearer " + accessToken);
            HttpEntity<Void> entity = new HttpEntity<>(headers);

            ResponseEntity<Map> res = restTemplate.exchange(
                    KAKAO_USER_INFO_URL, HttpMethod.GET, entity, Map.class);

            Map<String, Object> body = res.getBody();
            if (body == null) throw new IllegalArgumentException("Empty Kakao response");

            // 안전 추출
            Object idObj = body.get("id");
            String id = (idObj != null) ? String.valueOf(idObj) : null;

            String email = null, name = null;
            Object accountObj = body.get("kakao_account");
            if (accountObj instanceof Map<?, ?> account) {
                Object emailObj = account.get("email");
                if (emailObj instanceof String) email = (String) emailObj;

                Object profileObj = account.get("profile");
                if (profileObj instanceof Map<?, ?> profile) {
                    Object nickObj = profile.get("nickname");
                    if (nickObj instanceof String) name = (String) nickObj;
                }
            }

            Map<String, Object> normalized = new HashMap<>();
            normalized.put("id", id);
            normalized.put("email", email); // 동의 안했을 수 있음(null)
            normalized.put("name", name != null ? name : ("kakao_user_" + id));
            return normalized;

        } catch (RestClientException e) {
            throw new IllegalArgumentException("Kakao token verification failed", e);
        }
    }

    public String getKakaoUserId(String accessToken) {
        return String.valueOf(verifyToken(accessToken).get("id"));
    }

    public String getKakaoEmail(String accessToken) {
        Object v = verifyToken(accessToken).get("email");
        return v != null ? v.toString() : null;
    }
}
