# 🛒 E-commerce Project

Java Spring Boot 기반의 **간단한 E-commerce 웹 애플리케이션**입니다.  
사용자는 상품을 조회하고 장바구니에 담아 주문/결제까지 진행할 수 있습니다.  
관리자는 상품 관리와 주문 현황을 확인할 수 있습니다.

---

## 🚀 프로젝트 개요
- **개발 기간**: 2024.07 ~ 2024.08  
- **개발 인원**: 개인 프로젝트  
- **목표**: Spring Boot + MySQL 기반의 풀스택 웹 애플리케이션 개발 경험 축적 및 백엔드 역량 강화  

---

## 🛠️ 사용 기술 스택
- **Backend**: Java 17, Spring Boot 3.x, Spring Security, MyBatis  
- **Frontend**: JSP, HTML5, CSS3, JavaScript  
- **Database**: MySQL 8.x  
- **OAuth2**: Google 로그인 연동  
- **Build & Deploy**: Maven, Embedded Tomcat  
- **Version Control**: Git/GitHub  

---

## 📂 주요 기능
- 회원가입 / 로그인 / Spring Security 기반 인증·인가  
- 상품 목록 / 상세 조회  
- 장바구니 담기 / 수정 / 삭제  
- 주문 및 결제 (가상 결제 모듈 적용)  
- 리뷰 작성 / 조회  
- 관리자: 상품 등록/수정/삭제, 주문 내역 관리  

---

## 🗄️ DB 다이어그램
![DB Diagram](https://github.com/songjunhyen/ecommerce-project/issues/1#issue-3438355837)  

---

## 🎥 시연 영상
👉 [YouTube Demo Link](https://youtu.be/jiHBs8xHPFk)  
(상품 선택 → 장바구니 → 주문/결제 → 완료 흐름 시연)

---

## 📌 프로젝트 구조
```plaintext
src
 └─ main
    ├─ java/com/example/demo
    │   ├─ config           # Security / Web 설정
    │   ├─ controller       # Controller (상품, 장바구니, 결제 등)
    │   ├─ dao              # MyBatis DAO
    │   ├─ form             # 요청/응답 폼 객체
    │   ├─ google           # OAuth2 (Google API 연동)
    │   ├─ service          # 서비스 계층 (비즈니스 로직)
    │   ├─ util             # 유틸리티 클래스
    │   ├─ vo               # VO / DTO
    │   ├─ DataInitializer  # 초기 데이터 세팅
    │   ├─ ECommerceApplication # Spring Boot 메인
    │   └─ ServletInitializer   # 톰캣 배포 설정
    │
    ├─ resources
    │   ├─ META-INF
    │   ├─ static           # CSS, JS, 이미지 리소스
    │   ├─ templates        # JSP/Thymeleaf (선택 사용)
    │   ├─ application.yaml # 환경설정 (Git에 제외)
    │   └─ application-oauth.properties # OAuth2 설정 (Git에 제외)
    │
    └─ webapp
        ├─ static
        └─ WEB-INF/views/jsp
            └─ admin        # 관리자 JSP 화면



---


## 📈 배운 점 & 향후 개선

### ✅ 배운 점
- Spring Boot 기반 MVC 패턴과 레이어드 아키텍처 설계를 직접 구현하며 백엔드 구조에 대한 이해를 심화함  
- MyBatis를 활용해 SQL 매핑과 동적 쿼리 처리, 성능 최적화 방법을 경험함  
- Spring Security를 적용하여 사용자 인증/인가 흐름과 세션 관리에 대한 실무 감각을 익힘  
- OAuth2 클라이언트(Google) 연동을 통해 외부 서비스 인증 절차를 실제 프로젝트에 적용해봄  

### 🔧 향후 개선
- 프론트엔드를 React/Vue 등 SPA 프레임워크로 분리하여 사용자 경험(UX) 개선  
- 실제 PG사(결제 대행사) 모듈을 연동하여 실사용 가능한 결제 기능 구현  
- Docker 기반 배포 환경을 구성해 이식성과 운영 편의성 강화  

