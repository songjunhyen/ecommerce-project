package com.example.demo.controller;

import java.io.File;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.time.Duration;
import java.time.LocalDate;
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
            memberClass = allService.getadminclass(userid);
        }
        model.addAttribute("memberClass", memberClass);

        return "product/productlist";
    }

    @GetMapping("/product/search")
    public String search(@RequestParam(value = "q", required = false) String q,
                         @RequestParam(value = "page", defaultValue = "1") int page,
                         Model model) {
        String keyword = (q == null) ? "" : q.trim();
        if (keyword.isEmpty()) return "redirect:/product/list";

        List<Product> products = productService.searchProducts(keyword);

        int pageSize = 10;
        int totalCount = products.size();
        int totalPages = Math.max(1, (int)Math.ceil((double)totalCount / pageSize));
        page = Math.max(1, Math.min(page, totalPages));

        int start = (page - 1) * pageSize;
        int end   = Math.min(start + pageSize, totalCount);
        List<Product> paginatedProducts = products.subList(start, end);

        model.addAttribute("products", paginatedProducts);
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", totalPages);

        int blockSize = 5;
        int startPage = ((page - 1) / blockSize) * blockSize + 1;
        int endPage   = Math.min(startPage + blockSize - 1, totalPages);
        model.addAttribute("startPage", startPage);
        model.addAttribute("endPage", endPage);

        String userid = SecurityUtils.getCurrentUserId();
        int memberClass = (userid != null && !"Anonymous".equals(userid)) ? allService.getadminclass(userid) : 0;
        model.addAttribute("memberClass", memberClass);

        model.addAttribute("totalCount", totalCount);
        model.addAttribute("q", keyword);

        return "product/productlist";
    }

    @PostMapping("/product/ADD")
    public String addProduct(HttpSession session, Model model, @RequestParam String name, @RequestParam int price,
                             @RequestParam String description, @RequestPart("imageFiles") MultipartFile[] imageFiles,
                             @RequestParam int count, @RequestParam String category, @RequestParam String maker,
                             @RequestParam String color, @RequestParam String size, @RequestParam String options) {

        String userid = SecurityUtils.getCurrentUserId();

        List<String> imageUrls = new ArrayList<>();

        if (imageFiles != null) {
            for (MultipartFile imageFile : imageFiles) {
                if (imageFile == null || imageFile.isEmpty()) continue;
                try {
                    String url = saveOneImageUnique(imageFile, 1024, 768); // 날짜폴더 + UUID + 확장자
                    imageUrls.add(url); // 웹 경로(/uploadimg/...)
                } catch (IOException e) {
                    e.printStackTrace();
                    model.addAttribute("errorMessage", "파일 업로드에 실패했습니다.");
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

    @GetMapping("/product/Modify")
    public String modify(Model model, @RequestParam int id) {
        Product product = productService.getProductDetail(id);  // ← 상세 로드
        model.addAttribute("productId", id);
        model.addAttribute("product", product);
        return "product/productmodify";
    }

    @PostMapping("/product/Modify")
    public String modifyProduct(
            Model model,
            @RequestParam Integer productId,
            @RequestParam(required=false) String name,
            @RequestParam(required=false) Integer price,
            @RequestParam(required=false) String description,
            @RequestParam(required=false) Integer count,
            @RequestParam(required=false) String category,
            @RequestParam(required=false) String maker,
            @RequestParam(required=false) String color,
            @RequestParam(required=false) String size,
            @RequestParam(required=false) String options,
            @RequestParam(value="existingImageUrls", required=false) String existingImageUrls,
            @RequestParam(value="removeImages", required=false) List<String> removeImages,
            @RequestParam(value="imageFiles", required=false) MultipartFile[] imageFiles // <- @RequestParam 로!
    ) {
        if (!productService.exists(productId)) {
            model.addAttribute("message", "제품 수정 중 오류가 발생하였습니다.");
            return "error";
        }

        // 1) 기존 엔티티 로드
        Product old = productService.getProductDetail(productId);

        // 2) 기존 URL 병합 준비
        List<String> finalUrls = new ArrayList<>();
        if (existingImageUrls != null && !existingImageUrls.isBlank()) {
            for (String s : existingImageUrls.split(",")) {
                String u = s.trim();
                if (!u.isEmpty()) finalUrls.add(u);
            }
        }

        // 3) 삭제 체크 + 실제 파일 삭제
        if (removeImages != null && !removeImages.isEmpty()) {
            finalUrls.removeIf(removeImages::contains);
            for (String imageUrl : removeImages) {
                try {
                    deletePhysicalByUrl(imageUrl);
                } catch (Exception ex) {
                    // 파일이 실제로 없더라도 URL만 제거되면 OK
                }
            }
        }

        // 4) 새 파일 저장 + URL 추가
        if (imageFiles != null && imageFiles.length > 0) {
            for (MultipartFile imageFile : imageFiles) {
                if (imageFile == null || imageFile.isEmpty()) continue;
                try {
                    String url = saveOneImageUnique(imageFile, 1920, 1080);
                    finalUrls.add(url);
                } catch (IOException e) {
                    e.printStackTrace();
                    model.addAttribute("errorMessage", "이미지 업로드 중 오류가 발생했습니다.");
                }
            }
        }

        // ✅ 항상 최종값을 그대로 사용(비어 있어도 저장)
        String newImageUrls = String.join(",", finalUrls);

        // 5) 빈 값은 기존값 유지
        String newName     = hasText(name)        ? name        : old.getName();
        Integer newPrice   = (price != null)      ? price       : old.getPrice();
        String newDesc     = hasText(description) ? description : old.getDescription();
        Integer newCount   = (count != null)      ? count       : old.getCount();
        String newCategory = hasText(category)    ? category    : old.getCategory();
        String newMaker    = hasText(maker)       ? maker       : old.getMaker();
        String newColor    = hasText(color)       ? color       : old.getColor();
        String newSize     = hasText(size)        ? size        : old.getSize();
        String newOptions  = hasText(options)     ? options     : old.getAdditionalOptions();

        Product merged = new Product(
                0, old.getWriter(), newName, newPrice, newDesc, newImageUrls,
                newCount, newCategory, newMaker, newColor, newSize, ""
        );
        merged.setAdditionalOptions(newOptions);

        productService.modifyProduct(productId, merged);

        // (선호) PRG 패턴
        return "forward:/product/Detail?id=" + productId;
    }


    private boolean hasText(String s){ return s != null && !s.trim().isEmpty(); }

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

    /* ======================= 인라인 헬퍼 ======================= */

    /** 업로드 베이스 경로 (개발용). 운영에선 외부 디렉터리로 교체 권장 */
    private String getUploadBaseDir() {
        return System.getProperty("user.dir") + "/src/main/resources/static/uploadimg/";
        // 운영 예시: return "C:/app/uploads/"; (그리고 WebMvcConfigurer로 /uploadimg/** 매핑)
    }

    /** 확장자 판별(파일명 우선, 없으면 contentType), 화이트리스트 적용 */
    private String resolveExtension(MultipartFile f) {
        String ext = "";
        String original = f.getOriginalFilename();
        if (original != null) {
            int dot = original.lastIndexOf('.');
            if (dot >= 0) ext = original.substring(dot).toLowerCase();
        }
        if (ext.isBlank()) {
            String ct = f.getContentType(); // image/jpeg, image/png...
            if (ct != null) {
                if (ct.equalsIgnoreCase("image/jpeg") || ct.equalsIgnoreCase("image/jpg")) ext = ".jpg";
                else if (ct.equalsIgnoreCase("image/png")) ext = ".png";
                else if (ct.equalsIgnoreCase("image/gif")) ext = ".gif";
                else if (ct.equalsIgnoreCase("image/webp")) ext = ".webp";
            }
        }
        if (!List.of(".jpg",".jpeg",".png",".gif",".webp").contains(ext)) ext = ".jpg";
        return ext.equals(".jpeg") ? ".jpg" : ext;
    }

    /** 날짜 폴더(/yyyy/MM/dd/) + UUID 확장자로 저장하고 웹 URL 반환 */
    private String saveOneImageUnique(MultipartFile file, int targetWidth, int targetHeight) throws IOException {
        LocalDate today = LocalDate.now();
        String dateRel = String.format("%04d/%02d/%02d/", today.getYear(), today.getMonthValue(), today.getDayOfMonth());

        String baseDir = getUploadBaseDir();
        File dir = new File(baseDir + dateRel);
        if (!dir.exists()) dir.mkdirs();

        String ext = resolveExtension(file);
        String unique; File dest;
        do {
            unique = UUID.randomUUID().toString().replace("-", "") + ext;
            dest = new File(dir, unique);
        } while (dest.exists());

        ImageUtils.resizeImage(file, dest.getAbsolutePath(), targetWidth, targetHeight);

        return "/uploadimg/" + dateRel + unique; // 웹 접근 경로
    }

    /** /uploadimg/상대경로 → 물리 파일 삭제 */
    private void deletePhysicalByUrl(String imageUrl) {
        if (imageUrl == null || !imageUrl.startsWith("/uploadimg/")) return;
        String rel = imageUrl.substring("/uploadimg/".length()); // yyyy/MM/dd/uuid.ext
        File f = new File(getUploadBaseDir(), rel.replace("/", File.separator));
        if (f.exists() && f.isFile()) {
            boolean deleted = f.delete();
            System.out.println("삭제: " + f.getAbsolutePath() + " -> " + deleted);
        }
    }
}