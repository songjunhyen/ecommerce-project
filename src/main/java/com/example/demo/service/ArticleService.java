package com.example.demo.service;

import java.util.List;
import java.util.Objects;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.demo.dao.ArticleDao;
import com.example.demo.vo.Article;

@Service
@Transactional(readOnly = true)
public class ArticleService {

    private final ArticleDao articleDao;

    public ArticleService(ArticleDao articleDao) {
        this.articleDao = articleDao;
    }

    // ========= CREATE =========
    @Transactional
    public Long create(String writerId, String title, String body) {
        String t = safeTrim(title);
        String b = safeTrim(body);
        if (isBlank(writerId))      throw new IllegalArgumentException("writerId는 필수입니다.");
        if (isBlank(t))             throw new IllegalArgumentException("제목은 필수입니다.");
        if (t.length() > 200)       throw new IllegalArgumentException("제목은 200자를 초과할 수 없습니다.");
        if (isBlank(b))             throw new IllegalArgumentException("본문은 필수입니다.");
        if (b.length() > 20000)     throw new IllegalArgumentException("본문은 2만자를 초과할 수 없습니다.");

        Article article = new Article();
        article.setWriterId(writerId);
        article.setTitle(t);
        article.setBody(b);

        articleDao.insert(article);          // useGeneratedKeys로 id 채워짐
        return article.getId();
    }

    // ========= READ =========
    public Article getById(Long id) {
        if (id == null || id <= 0) throw new IllegalArgumentException("유효하지 않은 ID입니다.");
        return articleDao.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 게시글입니다."));
    }

    public PagedArticles list(int page, int pageSize, String q) {
        int ps = pageSize <= 0 ? 10 : Math.min(pageSize, 100);
        int p  = page <= 0 ? 1 : page;
        int offset = (p - 1) * ps;
        String query = normalizeQuery(q);

        List<Article> items = articleDao.list(offset, ps, query);
        int total = articleDao.count(query);
        int totalPages = (int) Math.ceil(total / (double) ps);

        return new PagedArticles(items, total, p, ps, Math.max(totalPages, 1));
    }

    // ========= UPDATE =========
    @Transactional
    public void update(Long id, String actorId, String title, String body) {
        if (id == null || id <= 0) throw new IllegalArgumentException("유효하지 않은 ID입니다.");
        Article current = getById(id);
        assertOwner(current.getWriterId(), actorId);

        String t = safeTrim(title);
        String b = safeTrim(body);
        if (isBlank(t))             throw new IllegalArgumentException("제목은 필수입니다.");
        if (t.length() > 200)       throw new IllegalArgumentException("제목은 200자를 초과할 수 없습니다.");
        if (isBlank(b))             throw new IllegalArgumentException("본문은 필수입니다.");
        if (b.length() > 20000)     throw new IllegalArgumentException("본문은 2만자를 초과할 수 없습니다.");

        Article toUpdate = new Article();
        toUpdate.setId(id);
        toUpdate.setTitle(t);
        toUpdate.setBody(b);

        int updated = articleDao.update(toUpdate);
        if (updated == 0) throw new IllegalStateException("수정에 실패했습니다.");
    }

    // ========= DELETE =========
    @Transactional
    public void delete(Long id, String actorId) {
        if (id == null || id <= 0) throw new IllegalArgumentException("유효하지 않은 ID입니다.");
        Article current = getById(id);
        assertOwner(current.getWriterId(), actorId);

        int deleted = articleDao.delete(id);
        if (deleted == 0) throw new IllegalStateException("삭제에 실패했습니다.");
    }

    // ========= VIEW COUNT =========
    @Transactional
    public void increaseViewCount(Long id) {
        if (id == null || id <= 0) throw new IllegalArgumentException("유효하지 않은 ID입니다.");
        articleDao.increaseViewCount(id);
    }

    // ========= Helpers =========
    private static void assertOwner(String ownerId, String actorId) {
        if (isBlank(actorId) || !Objects.equals(ownerId, actorId)) {
            throw new SecurityException("권한이 없습니다.");
        }
    }
    private static String safeTrim(String s) { return s == null ? "" : s.trim(); }
    private static boolean isBlank(String s) { return s == null || s.trim().isEmpty(); }
    private static String normalizeQuery(String q) {
        String t = safeTrim(q);
        return t.isEmpty() ? null : t;
    }

    // 간단 페이지 결과 DTO
    public static class PagedArticles {
        private final List<Article> items;
        private final int totalCount;
        private final int page;
        private final int pageSize;
        private final int totalPages;

        public PagedArticles(List<Article> items, int totalCount, int page, int pageSize, int totalPages) {
            this.items = items;
            this.totalCount = totalCount;
            this.page = page;
            this.pageSize = pageSize;
            this.totalPages = totalPages;
        }
        public List<Article> getItems() { return items; }
        public int getTotalCount() { return totalCount; }
        public int getPage() { return page; }
        public int getPageSize() { return pageSize; }
        public int getTotalPages() { return totalPages; }
    }
}
