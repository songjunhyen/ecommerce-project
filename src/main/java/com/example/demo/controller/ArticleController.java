package com.example.demo.controller;

import com.example.demo.util.SecurityUtils;
// import com.example.demo.service.ArticleService;
// import com.example.demo.vo.Article;

import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.time.LocalDateTime;
import java.util.List;

@Controller
public class ArticleController {

    // --- 서비스 연동 자리 ---
    // private final ArticleService articleService;
    // public ArticleController(ArticleService articleService) { this.articleService = articleService; }

    // ========= GET: 화면 라우트 유지 =========
    @GetMapping("/test/article/Main")
    public String mainPage() { return "article/main"; }

    @GetMapping("/article/add")
    public String addPage() { return "article/add"; }

    @GetMapping("/article/view")
    public String viewPage(@RequestParam Long id, Model model) {
        // Article article = articleService.findById(id)
        //     .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 글입니다."));
        // model.addAttribute("article", article);
        model.addAttribute("articleId", id);
        return "article/view";
    }

    @GetMapping("/article/modify")
    public String modifyPage(@RequestParam Long id, Model model) {
        // Article article = articleService.findById(id)
        //     .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 글입니다."));
        // model.addAttribute("article", article);
        model.addAttribute("articleId", id);
        return "article/modify";
    }

    @GetMapping("/article/delete")
    public String deletePage(@RequestParam Long id, Model model) {
        model.addAttribute("articleId", id);
        return "article/delete";
    }

    @GetMapping("/article/list")
    public String listPage(Model model,
                           @RequestParam(value = "page", defaultValue = "1") int page,
                           @RequestParam(value = "size", defaultValue = "10") int size,
                           @RequestParam(value = "q", required = false) String query) {
        // int total = articleService.count(query);
        // List<Article> items = articleService.list(page, size, query);

        model.addAttribute("currentPage", page);
        model.addAttribute("pageSize", size);
        model.addAttribute("query", query == null ? "" : query);
        // model.addAttribute("total", total);
        // model.addAttribute("articles", items);
        return "article/list";
    }

    // ========= POST: 처리 라우트 =========

    // 생성
    @PostMapping("/article/add/proc")
    public String addProc(@RequestParam String title,
                          @RequestParam String body,
                          HttpSession session,
                          RedirectAttributes ra) {
        String userId = SecurityUtils.getCurrentUserId();
        if (userId == null || "Anonymous".equals(userId)) {
            ra.addFlashAttribute("errorMessage", "로그인이 필요합니다.");
            return "redirect:/article/add";
        }

        title = safeTrim(title);
        body  = safeTrim(body);
        if (!validateTitleBody(title, body, ra)) return "redirect:/article/add";

        // Article article = new Article(null, userId, title, body, LocalDateTime.now(), LocalDateTime.now());
        // Long newId = articleService.create(article);
        Long newId = 1L; // 예시

        ra.addFlashAttribute("successMessage", "글이 등록되었습니다.");
        return "redirect:/article/view?id=" + newId;
    }

    // 수정
    @PostMapping("/article/modify/proc")
    public String modifyProc(@RequestParam Long id,
                             @RequestParam String title,
                             @RequestParam String body,
                             HttpSession session,
                             RedirectAttributes ra) {
        String userId = SecurityUtils.getCurrentUserId();
        if (userId == null || "Anonymous".equals(userId)) {
            ra.addFlashAttribute("errorMessage", "로그인이 필요합니다.");
            return "redirect:/article/modify?id=" + id;
        }

        title = safeTrim(title);
        body  = safeTrim(body);
        if (!validateTitleBody(title, body, ra)) return "redirect:/article/modify?id=" + id;

        // Article article = articleService.findById(id)
        //     .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 글입니다."));
        // if (!article.getWriterId().equals(userId)) {
        //     ra.addFlashAttribute("errorMessage", "수정 권한이 없습니다.");
        //     return "redirect:/article/view?id=" + id;
        // }
        // article.setTitle(title);
        // article.setBody(body);
        // article.setUpdatedAt(LocalDateTime.now());
        // articleService.update(id, article);

        ra.addFlashAttribute("successMessage", "글이 수정되었습니다.");
        return "redirect:/article/view?id=" + id;
    }

    // 삭제
    @PostMapping("/article/delete/proc")
    public String deleteProc(@RequestParam Long id,
                             HttpSession session,
                             RedirectAttributes ra) {
        String userId = SecurityUtils.getCurrentUserId();
        if (userId == null || "Anonymous".equals(userId)) {
            ra.addFlashAttribute("errorMessage", "로그인이 필요합니다.");
            return "redirect:/article/delete?id=" + id;
        }

        // Article article = articleService.findById(id)
        //     .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 글입니다."));
        // if (!article.getWriterId().equals(userId)) {
        //     ra.addFlashAttribute("errorMessage", "삭제 권한이 없습니다.");
        //     return "redirect:/article/view?id=" + id;
        // }
        // articleService.delete(id);

        ra.addFlashAttribute("successMessage", "글이 삭제되었습니다.");
        return "redirect:/article/list";
    }

    // ========= 내부 유틸 =========
    private String safeTrim(String s) { return s == null ? "" : s.trim(); }

    private boolean validateTitleBody(String title, String body, RedirectAttributes ra) {
        if (title.isEmpty() || body.isEmpty()) {
            ra.addFlashAttribute("errorMessage", "제목과 내용을 모두 입력하세요.");
            return false;
        }
        if (title.length() > 200) {
            ra.addFlashAttribute("errorMessage", "제목은 200자 이하여야 합니다.");
            return false;
        }
        if (body.length() > 20_000) {
            ra.addFlashAttribute("errorMessage", "본문은 20,000자 이하여야 합니다.");
            return false;
        }
        return true;
    }
}
