package com.example.demo.controller;

import com.example.demo.service.SellerShipmentService;
import com.example.demo.util.SecurityUtils;
import com.example.demo.vo.SellerShipment;
import com.example.demo.vo.SellerShipmentSearchRequest;
import com.example.demo.vo.SellerShipmentUpdateRequest;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

/**
 * 판매자 전용 출고/배송 관리 컨트롤러
 * Base URL: /seller/ship
 *
 * 뷰:
 *  - 목록:   jsp/admin/shipments.jsp
 *  - 상세:   jsp/admin/shipment-detail.jsp
 *
 * JSON:
 *  - 목록:   GET  /seller/ship/list.json
 *  - 집계:   POST /seller/ship/consolidate
 *  - 상세:   GET  /seller/ship/{orderNumber}.json
 *  - 수정:   POST /seller/ship/update
 *  - 상태변경: POST /seller/ship/{orderNumber}/status
 *  - 단건재집계: POST /seller/ship/{orderNumber}/recalc
 */
@Controller
@RequestMapping("/seller/ship")
public class SellerShipmentController {

    private final SellerShipmentService service;

    public SellerShipmentController(SellerShipmentService service) {
        this.service = service;
    }

    /** 로그인 판매자 ID */
    private String currentSellerId() {
        String uid = SecurityUtils.getCurrentUserId();
        if (uid == null || "Anonymous".equals(uid)) return null;
        return uid;
    }

    /** 목록 페이지 (JSP 렌더)
     *  - refresh=true 이면 먼저 스냅샷 집계(consolidate) 실행 후 목록 조회
     */
    @GetMapping
    public String listPage(@RequestParam(required = false) String status,
                           @RequestParam(required = false) String q,
                           @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
                           @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to,
                           @RequestParam(defaultValue = "0") int page,
                           @RequestParam(defaultValue = "20") int size,
                           @RequestParam(defaultValue = "false") boolean refresh,
                           Model model) {

        String sellerId = currentSellerId();
        if (sellerId == null) return "redirect:/Home/login";

        var req = SellerShipmentSearchRequest.builder()
                .sellerId(sellerId).status(status).q(q).from(from).to(to)
                .page(page).size(size).build();

        if (refresh) {
            service.consolidateSnapshots(req);
        }

        List<SellerShipment> rows = service.list(req);
        model.addAttribute("rows", rows);
        model.addAttribute("status", status);
        model.addAttribute("q", q);
        model.addAttribute("from", from);
        model.addAttribute("to", to);
        model.addAttribute("page", page);
        model.addAttribute("size", size);
        return "admin/shipments";
    }

    /** 목록 API (JSON) - refresh=true 지원 */
    @GetMapping("/list.json")
    @ResponseBody
    public ResponseEntity<?> listApi(@RequestParam(required = false) String status,
                                     @RequestParam(required = false) String q,
                                     @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
                                     @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to,
                                     @RequestParam(defaultValue = "0") int page,
                                     @RequestParam(defaultValue = "20") int size,
                                     @RequestParam(defaultValue = "false") boolean refresh) {

        String sellerId = currentSellerId();
        if (sellerId == null) return ResponseEntity.status(401).body("unauthorized");

        var req = SellerShipmentSearchRequest.builder()
                .sellerId(sellerId).status(status).q(q).from(from).to(to)
                .page(page).size(size).build();

        if (refresh) {
            service.consolidateSnapshots(req);
        }
        return ResponseEntity.ok(service.list(req));
    }

    /** 조회 버튼 전용(스냅샷 집계) – JSON 응답 */
    @PostMapping("/consolidate")
    @ResponseBody
    public ResponseEntity<?> consolidate(@RequestParam(required = false) String status,
                                         @RequestParam(required = false) String q,
                                         @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
                                         @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to) {

        String sellerId = currentSellerId();
        if (sellerId == null) return ResponseEntity.status(401).body("unauthorized");

        var req = SellerShipmentSearchRequest.builder()
                .sellerId(sellerId).status(status).q(q).from(from).to(to)
                .page(0).size(1000).build();

        int affected = service.consolidateSnapshots(req);
        return ResponseEntity.ok(affected);
    }

    /** 단건 상세 페이지 (JSP) */
    @GetMapping("/{orderNumber}")
    public String detailPage(@PathVariable String orderNumber, Model model) {
        String sellerId = currentSellerId();
        if (sellerId == null) return "redirect:/Home/login";

        SellerShipment one = service.getOne(orderNumber, sellerId);
        model.addAttribute("row", one);
        return "admin/shipment-detail";
    }

    /** 단건 상세 API (JSON) */
    @GetMapping("/{orderNumber}.json")
    @ResponseBody
    public ResponseEntity<?> detailApi(@PathVariable String orderNumber) {
        String sellerId = currentSellerId();
        if (sellerId == null) return ResponseEntity.status(401).body("unauthorized");
        return ResponseEntity.ok(service.getOne(orderNumber, sellerId));
    }

    /** 운송장/상태 업데이트 (JSON)
     * body 예:
     * {
     *   "orderNumber": "1234-aaaa...",
     *   "trackingNo": "1234567890",
     *   "carrier": "CJ",
     *   "status": "배송중"
     * }
     */
    @PostMapping("/update")
    @ResponseBody
    public ResponseEntity<?> update(@RequestBody SellerShipmentUpdateRequest req) {
        String sellerId = currentSellerId();
        if (sellerId == null) return ResponseEntity.status(401).body("unauthorized");

        // 보안: sellerId는 현재 로그인 값으로 강제
        req.setSellerId(sellerId);
        service.updateTrackingAndStatus(req);
        return ResponseEntity.ok("ok");
    }

    /** 상태만 변경 (JSON) */
    @PostMapping("/{orderNumber}/status")
    @ResponseBody
    public ResponseEntity<?> updateStatus(@PathVariable String orderNumber,
                                          @RequestParam String status) {
        String sellerId = currentSellerId();
        if (sellerId == null) return ResponseEntity.status(401).body("unauthorized");

        service.updateStatus(orderNumber, sellerId, status);
        return ResponseEntity.ok("ok");
    }

    /** 특정 주문만 재집계 후 반환 (JSON) — 상세 화면의 "새로고침" */
    @PostMapping("/{orderNumber}/recalc")
    @ResponseBody
    public ResponseEntity<?> recalcOne(@PathVariable String orderNumber) {
        String sellerId = currentSellerId();
        if (sellerId == null) return ResponseEntity.status(401).body("unauthorized");

        return ResponseEntity.ok(service.consolidateOneOrder(orderNumber, sellerId));
    }
}
