package com.example.demo.controller;

import com.example.demo.service.SellerShipmentService;
import com.example.demo.util.SecurityUtils;
import com.example.demo.dao.PurchaseDao;
import com.example.demo.vo.MyOrderRow;
import com.example.demo.vo.SellerShipment;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Controller
@RequiredArgsConstructor
public class TrackingController {

    private final SellerShipmentService shipmentService;
    private final PurchaseDao purchaseDao;

    /** 비회원 배송조회 폼 */
    @GetMapping("/track")
    public String guestTrackForm() {
        return "jsp/track/guest-track-form"; // 주문번호/이메일/휴대폰 입력 폼
    }

    /** 비회원 배송조회 처리 (화면) */
    @PostMapping("/track")
    public String guestTrackResult(@RequestParam String orderNumber,
                                   @RequestParam String email,
                                   @RequestParam String phone,
                                   Model model) {
        // 1) 비회원 주문 존재+일치 검사
        var guest = purchaseDao.findGuestOrderForVerify(orderNumber, email, phone);
        if (guest == null) {
            model.addAttribute("error", "주문을 찾을 수 없거나 인증 정보가 일치하지 않습니다.");
            return "track/guest-track-form";
        }

        // 2) 스냅샷 조회 (없을 수도 있으니 필요하면 보정)
        List<SellerShipment> shipments = shipmentService.findByOrderNumber(orderNumber);
        if (shipments == null || shipments.isEmpty()) {
            // 주문에 참여한 판매자별 스냅샷이 아직 없다면,
            // 판매자별로는 못 채우지만, 최소 1회 주문번호 기준 보정 시도.
            // (실제 판매자별 스냅샷 생성은 각 판매자가 /seller/ship에서 조회할 때가 원칙)
            // 여기서는 결과가 비어있어도 UX 위해 빈 리스트라도 넘김.
        }

        model.addAttribute("orderNumber", orderNumber);
        model.addAttribute("shipments", shipments);
        return "track/guest-track-result";
    }

    @GetMapping("/mypage/orders")
    public String myOrders(Model model) {
        String userid = SecurityUtils.getCurrentUserId();
        if (userid == null || "Anonymous".equals(userid)) {
            return "redirect:/Home/login";
        }
        List<MyOrderRow> orders = purchaseDao.findMemberOrdersWithPrice(userid);
        model.addAttribute("orders", orders);
        return "track/orders"; // JSP 뷰
    }

    /** 회원 배송조회 (화면) - 본인 주문만 */
    @GetMapping("/my/orders/{orderNumber}/track")
    public String memberTrack(@PathVariable String orderNumber, Model model) {
        String userid = SecurityUtils.getCurrentUserId();
        if (userid == null || "Anonymous".equals(userid)) {
            return "redirect:/Home/login";
        }

        // 본인 주문인지 확인
        var pinfo = purchaseDao.getOrderInfoByPInfo(orderNumber);
        if (pinfo == null || !userid.equals(pinfo.getUserid())) {
            model.addAttribute("error", "본인 주문만 조회할 수 있습니다.");
            return "track/member-track-error";
        }

        List<SellerShipment> shipments = shipmentService.findByOrderNumber(orderNumber);
        model.addAttribute("orderNumber", orderNumber);
        model.addAttribute("shipments", shipments);
        return "track/member-track-result";
    }

    /** 비회원 JSON 조회 (필요 시) */
    @PostMapping("/api/track/guest")
    @ResponseBody
    public ResponseEntity<?> guestTrackApi(@RequestParam String orderNumber,
                                           @RequestParam String email,
                                           @RequestParam String phone) {
        var guest = purchaseDao.findGuestOrderForVerify(orderNumber, email, phone);
        if (guest == null) {
            return ResponseEntity.badRequest().body("not_found_or_mismatch");
        }
        return ResponseEntity.ok(shipmentService.findByOrderNumber(orderNumber));
    }

    /** 회원 JSON 조회 (필요 시) */
    @GetMapping("/api/track/member/{orderNumber}")
    @ResponseBody
    public ResponseEntity<?> memberTrackApi(@PathVariable String orderNumber) {
        String userid = SecurityUtils.getCurrentUserId();
        if (userid == null || "Anonymous".equals(userid)) {
            return ResponseEntity.status(401).body("unauthorized");
        }
        var pinfo = purchaseDao.getOrderInfoByPInfo(orderNumber);
        if (pinfo == null || !userid.equals(pinfo.getUserid())) {
            return ResponseEntity.status(403).body("forbidden");
        }
        return ResponseEntity.ok(shipmentService.findByOrderNumber(orderNumber));
    }
}
