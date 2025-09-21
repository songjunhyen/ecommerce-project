package com.example.demo.service;

import java.io.IOException;
import java.math.BigDecimal;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.http.*;
import java.net.http.HttpRequest;
import java.time.Duration;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.http.HttpHeaders;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;

import com.example.demo.dao.PaymentDao;
import com.example.demo.vo.PaymentInfo;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

@Service
public class PaymentService {
    private final PaymentDao paymentDao;
    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper;

    @Value("${iamport.api.key}")
    private String apiKey;

    @Value("${iamport.api.secret}")
    private String apiSecret;

    public PaymentService(RestTemplate restTemplate, ObjectMapper objectMapper, PaymentDao paymentDao) {
        this.paymentDao = paymentDao;
        this.restTemplate = restTemplate;
        this.objectMapper = objectMapper;
    }

    public String getAccessToken() {
        String url = "https://api.iamport.kr/users/getToken";
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        String body = String.format("{\"imp_key\":\"%s\", \"imp_secret\":\"%s\"}", apiKey, apiSecret);
        HttpEntity<String> request = new HttpEntity<>(body, headers);

        ResponseEntity<String> response = restTemplate.exchange(url, HttpMethod.POST, request, String.class);
        try {
            JsonNode root = objectMapper.readTree(response.getBody());
            String token = root.path("response").path("access_token").asText(null);
            if (token == null || token.isBlank()) {
                throw new IllegalStateException("토큰 발급 실패");
            }
            return token;
        } catch (Exception e) {
            throw new RuntimeException("Failed to get access token", e);
        }
    }

    public JsonNode getPaymentInfo(String impUid, String accessToken) {
        // 권장 엔드포인트: /payments/{imp_uid}
        String url = "https://api.iamport.kr/payments/" + impUid;

        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(accessToken); // Bearer 토큰

        HttpEntity<Void> request = new HttpEntity<>(headers);
        ResponseEntity<String> response = restTemplate.exchange(url, HttpMethod.GET, request, String.class);

        try {
            JsonNode root = objectMapper.readTree(response.getBody());
            return root.path("response");
        } catch (Exception e) {
            throw new RuntimeException("Failed to get payment info", e);
        }
    }

    public PaymentInfo getPaymentInfoByImpUid(String impUid) {
        if (impUid == null || impUid.isBlank()) return null;
        return paymentDao.getPaymentInfoByImpUid(impUid);
    }

    public boolean verifyPayment(String impUid, String merchantUid, BigDecimal price) {
        if (impUid == null || impUid.isBlank() || merchantUid == null || merchantUid.isBlank() || price == null) {
            return false;
        }
        String token = getAccessToken();
        JsonNode payment = getPaymentInfo(impUid, token);

        if (payment.isMissingNode() || payment.isNull()) return false;

        // Iamport는 amount/paid_amount 둘 다 케이스 존재 → 우선 amount, 없으면 paid_amount
        BigDecimal paid = null;
        if (payment.hasNonNull("amount")) {
            paid = new BigDecimal(payment.get("amount").asText("0"));
        } else if (payment.hasNonNull("paid_amount")) {
            paid = new BigDecimal(payment.get("paid_amount").asText("0"));
        }
        return paid != null && paid.compareTo(price) == 0;
    }

    @Transactional
    public void completePayment(String merchantUid, PaymentInfo paymentInfo) {
        paymentDao.completePayment(merchantUid, paymentInfo);
    }

    @Transactional
    public void removePayAuth(String impUid) {
        if (impUid == null || impUid.isBlank()) return;
        paymentDao.removePayAuth(impUid);
    }

    @Transactional
    public void setImpUid(String impUid, String merchantUid) {
        if (impUid == null || impUid.isBlank() || merchantUid == null || merchantUid.isBlank()) return;
        paymentDao.setImpUid(impUid, merchantUid);
    }

    public PaymentInfo getPaymentDATA(String ordernumber) {
        if (ordernumber == null || ordernumber.isBlank()) return null;
        return paymentDao.getPaymentDATA(ordernumber);
    }

    public HttpResponse<String> approvePayment(String paymentId)
            throws URISyntaxException, IOException, InterruptedException {

        // TODO: 설정값으로 이동(application.yml)
        String paymentUrl = "https://dev.apis.naver.com/naverpay-partner/naverpay/payments/v2.2/apply/payment";
        String naverClientId = "발급된 client id";
        String naverClientSecret = "발급된 client secret";
        String naverPayChainId = "발급된 chain id";
        String naverPayIdempotencyKey = "API 멱등성 키";

        HttpClient client = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(5))
                .build();

        HttpRequest request = HttpRequest.newBuilder()
                .uri(new URI(paymentUrl))
                .timeout(Duration.ofSeconds(10))
                .header("X-Naver-Client-Id", naverClientId)
                .header("X-Naver-Client-Secret", naverClientSecret)
                .header("X-NaverPay-Chain-Id", naverPayChainId)
                .header("X-NaverPay-Idempotency-Key", naverPayIdempotencyKey)
                .header("Content-Type", "application/x-www-form-urlencoded")
                .POST(HttpRequest.BodyPublishers.ofString("paymentId=" + paymentId))
                .build();

        return client.send(request, HttpResponse.BodyHandlers.ofString());
    }

    public boolean verifyPaymentNaver(String impUid, String ordernumber, BigDecimal price) {
        PaymentInfo byImp = getPaymentInfoByImpUid(impUid);
        PaymentInfo byOrder = getPaymentDATA(ordernumber);
        if (byImp == null || byOrder == null || price == null) return false;

        BigDecimal p1 = byImp.getPrice();
        BigDecimal p2 = byOrder.getPrice();
        return p1 != null && p2 != null
                && p1.compareTo(price) == 0
                && p2.compareTo(price) == 0
                && p1.compareTo(p2) == 0;
    }
}
