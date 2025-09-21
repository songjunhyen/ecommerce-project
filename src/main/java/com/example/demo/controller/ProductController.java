package com.example.demo.controller;

import java.io.File;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.time.Duration;
import java.time.LocalDateTime;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.multipart.MultipartFile;

import com.example.demo.service.AllService;
import com.example.demo.service.ProductService;
import com.example.demo.util.ImageUtils;
import com.example.demo.util.SecurityUtils;
import com.example.demo.vo.Product;

import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@Controller
public class ProductController {

	private final ProductService productService;
	private final AllService allService;

	public ProductController(ProductService productService, AllService allService) {
		this.productService = productService;
		this.allService =  allService;
	}
	
	@GetMapping("/test/product/Main")
	public String mainPage() {
		return "product/main"; // "product/main.jsp"를 반환하도록 설정
	}

	@GetMapping("/product/add")
	public String write() {
		return "product/productadd"; // "product/productadd.jsp"를 반환하도록 설정
	}

    @GetMapping("/product/list")
    public String list(@RequestParam(value = "page", defaultValue = "1") int page, Model model) {
        List<Product> products = productService.getProductList();

        Collections.reverse(products);

        int pageSize = 10;
        int totalCount = products.size();
        int totalPages = (int) Math.ceil((double) totalCount / pageSize);
        int start = (page - 1) * pageSize;
        int end = Math.min(start + pageSize, totalCount);

        List<Product> paginatedProducts = products.subList(start, end);

        model.addAttribute("products", paginatedProducts);
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", totalPages);

        // ★ 로그인 유저의 memberClass 모델에 주입
        String userid = SecurityUtils.getCurrentUserId();
        int memberClass = 0; // 기본 일반회원
        if (userid != null && !"Anonymous".equals(userid)) {
            // 프로젝트에 맞춰 구현:
            // 1) AllService에 관리자 등급 조회 메서드가 있으면 사용
            //    (관리자면 1 반환하도록 통일)
            memberClass = allService.getadminclass(userid);
            // 만약 allService가 아닌 별도 MemberService가 있으면
            // memberClass = memberService.findByUserid(userid).getMemberClass();
        }
        model.addAttribute("memberClass", memberClass);

        return "product/productlist";
    }


	@GetMapping("/product/modify")
	public String modify(Model model, @RequestParam int id) {
		model.addAttribute("productId", id);
		return "product/productmodify"; // "product/productadd.jsp"를 반환하도록 설정
	}

    @PostMapping("/product/ADD")
    public String addProduct(HttpSession session, Model model, @RequestParam String name, @RequestParam int price,
                             @RequestParam String description, @RequestPart("imageFiles") MultipartFile[] imageFiles,
                             @RequestParam int count, @RequestParam String category, @RequestParam String maker,
                             @RequestParam String color, @RequestParam String size, @RequestParam String options) {

        String userid = SecurityUtils.getCurrentUserId();

        List<String> imageUrls = new ArrayList<>();
        String uploadDir = System.getProperty("user.dir") + "/src/main/resources/static/uploadimg/";

        // 디렉토리 존재 여부 확인 및 생성
        File uploadDirFile = new File(uploadDir);
        if (!uploadDirFile.exists()) {
            uploadDirFile.mkdirs();
        }

        for (MultipartFile imageFile : imageFiles) {
            if (imageFile != null && !imageFile.isEmpty()) {
                String originalFileName = imageFile.getOriginalFilename();
                if (originalFileName != null && !originalFileName.isEmpty()) {
                    try {
                        originalFileName = new String(originalFileName.getBytes("ISO-8859-1"), "UTF-8");
                    } catch (UnsupportedEncodingException e) {
                        e.printStackTrace();
                        model.addAttribute("errorMessage", "파일 이름 인코딩 처리에 실패했습니다.");
                    }

                    String fileExtension = "";
                    if (originalFileName.contains(".")) {
                        fileExtension = originalFileName.substring(originalFileName.lastIndexOf("."));
                    }

                    String uniqueFileName = UUID.randomUUID().toString() + fileExtension;
                    String filePath = uploadDir + uniqueFileName;

                    try {
                        // 리사이징 적용
                        ImageUtils.resizeImage(imageFile, filePath, 1024, 768); // 원하는 크기로 조정

                        System.out.println("File uploaded to: " + filePath);  // 디버깅용
                        imageUrls.add("/uploadimg/" + uniqueFileName); // 웹에서 접근할 수 있는 경로
                    } catch (IOException e) {
                        e.printStackTrace();
                        model.addAttribute("errorMessage", "파일 업로드에 실패했습니다.");
                    }
                }
            }
        }

        String combinedImageUrls = String.join(",", imageUrls);
        Product product = new Product(0, userid, name, price, description, combinedImageUrls, count, category, maker, color,
                size, "");
        product.setAdditionalOptions(options);

        productService.addProduct(product);
        model.addAttribute("product", product);
        return "redirect:/Home/Main";
    }
    
    @PostMapping("/product/Detail")
    public String ProductDetail(HttpSession session, HttpServletRequest request, HttpServletResponse response, Model model, @RequestParam int id) {
        boolean result = productService.exists(id);
        if (!result) {
            model.addAttribute("message", "제품 추가 중 오류가 발생하였습니다.");
            return "error";
        }

        String writerid = productService.getWriterId(id);
        String userid = SecurityUtils.getCurrentUserId();
        Product product = productService.getProductDetail(id);

        if (writerid.equals(userid)) {
            model.addAttribute("product", product);
            model.addAttribute("userid", userid);
            return "product/productdetail";
        } 

        handleViewCountCookie(request, response, id);
        
		String userRole = "";
		int adminClass = 5;
		if (userid != null && !userid.equals("Anonymous")) {
			userRole = allService.isuser(userid);
			if (userRole.equals("admin")) {
				adminClass = allService.getadminclass(userid);
			}
			model.addAttribute("userRole", userRole);
			model.addAttribute("adminClass", adminClass);
		}
		
        model.addAttribute("product", product);
        return "product/productdetail";
    }

    private void handleViewCountCookie(HttpServletRequest request, HttpServletResponse response, int productId) {
        final String cookieName = "viewedProduct_" + productId;
        final long nowSec = java.time.Instant.now().getEpochSecond();
        final long oneDaySec = 86400L;

        boolean shouldUpdateViewCount = true;

        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if (cookieName.equals(cookie.getName())) {
                    String v = cookie.getValue();
                    try {
                        long lastSec = Long.parseLong(v); // epoch seconds
                        if ((nowSec - lastSec) <= oneDaySec) {
                            shouldUpdateViewCount = false;
                        }
                    } catch (NumberFormatException ignored) {
                        // 값 이상하면 새로 갱신
                    }
                    // 유효시간/값 갱신
                    updateCookie(response, cookieName, Long.toString(nowSec), (int) oneDaySec);
                    break;
                }
            }
        }

        if (shouldUpdateViewCount) {
            updateCookie(response, cookieName, Long.toString(nowSec), (int) oneDaySec);
            productService.updateViewCount(productId);
        }
    }

    private void updateCookie(HttpServletResponse response, String name, String value, int maxAge) {
        Cookie cookie = new Cookie(name, value);
        cookie.setMaxAge(maxAge);
        cookie.setPath("/");           // 경로 명시
        cookie.setHttpOnly(true);      // JS 접근 차단
        // cookie.setSecure(true);     // HTTPS 환경이면 활성화
        response.addCookie(cookie);

        // SameSite 보강 (서블릿 Cookie에 속성이 없으므로 헤더로 추가)
        response.addHeader("Set-Cookie",
                name + "=" + value
                        + "; Max-Age=" + maxAge
                        + "; Path=/; HttpOnly; SameSite=Lax");
        // HTTPS면 "; Secure" 도 같이 추가하세요.
    }

	@PostMapping("/product/Modify")
	public String modifyProduct(HttpSession session, Model model, @RequestParam int productId,
			@RequestParam String name, @RequestParam int price, @RequestParam String description,
			@RequestParam int count, @RequestParam String category, @RequestParam String maker,
			@RequestParam String color, @RequestParam String size, @RequestParam List<String> options) {

		boolean result = productService.exists(productId);

		if (!result) {
			model.addAttribute("message", "제품 수정 중 오류가 발생하였습니다.");
			return "error";
		} else {
			String userid = SecurityUtils.getCurrentUserId();
			Product product = new Product(0, userid, name, price, description, "", count, category, maker, color, size, "");
			productService.modifyProduct(productId, product);
			model.addAttribute("product", product);
			return "redirect:/product/detail?id=" + productId;
		}
	}

	@PostMapping("/product/Delete")
	public String deleteProduct(Model model, @RequestParam int id) {
		boolean result = productService.exists(id);
		if (!result) {
			model.addAttribute("message", "제품 삭제 중 오류가 발생하였습니다.");
			return "error";
		} else {
			productService.deleteProduct(id);
			model.addAttribute("productId", id);
			return "redirect:/product/list";
		}
	}
}


