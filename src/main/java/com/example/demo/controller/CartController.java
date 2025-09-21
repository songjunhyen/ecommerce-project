package com.example.demo.controller;

import java.util.ArrayList;
import java.util.List;
import java.io.IOException;
import java.security.NoSuchAlgorithmException;
import java.util.UUID;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.view.RedirectView;

import com.example.demo.service.CartService;
import com.example.demo.util.SecurityUtils;
import com.example.demo.util.SessionFileUtil;
import com.example.demo.vo.Cart;
import com.example.demo.vo.CartItem;

import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@Controller
public class CartController {
	private CartService cartservice;

	CartController(CartService cartservice) {
		this.cartservice = cartservice;
	}

	@PostMapping("/Cart/add")
	public String addCartItem(HttpSession session, Model model, @RequestParam int productid, @RequestParam String name,
							  @RequestParam String color, @RequestParam String size, @RequestParam int count, @RequestParam int price) {
		String userid = SecurityUtils.getCurrentUserId();
		count = Math.max(1, Math.min(99, count));

		boolean ishave = cartservice.checking(userid, productid, color, size);
		if (!ishave) {
			cartservice.AddCartList(userid, productid, name, color, size, count, price);
		} else {
			int id = cartservice.GetCartId(userid, productid, name, color, size);
			cartservice.ModifyCartList(id, userid, productid, name, color, size, color, size, count, price);
		}
		return "redirect:/Cart/List";
	}

	@GetMapping("/Cart/List")
	public String GetCartList(HttpSession session, Model model) {
		String userid = SecurityUtils.getCurrentUserId();
		List<Cart> carts = cartservice.GetCartList(userid);
		model.addAttribute("userid", userid);
		model.addAttribute("carts", carts);
		return "cart/cartmain";
	}

	@PostMapping("/Cart/Modify")
	public String ModifyCartList(HttpSession session, @RequestParam int id, @RequestParam String productname,
								 @RequestParam int productid, @RequestParam String a_color, @RequestParam String a_size,
								 @RequestParam String color, @RequestParam String size, @RequestParam int count, @RequestParam int price) {
		String userid = SecurityUtils.getCurrentUserId();
		count = Math.max(1, Math.min(99, count));
		cartservice.ModifyCartList(id, userid, productid, productname, a_color, a_size, color, size, count, price);
		return "redirect:/Cart/List";
	}

	@PostMapping("/Cart/Delete")
	public String DeleteCartList(HttpSession session, @RequestParam int id, @RequestParam int productid,
								 @RequestParam String color, @RequestParam String size) {
		String userid = SecurityUtils.getCurrentUserId();
		cartservice.DeleteCartList(id, userid, productid, color, size);
		return "redirect:/Cart/List";
	}

	private String getOrCreateCartToken(HttpServletRequest request, HttpServletResponse response) {
		if (request.getCookies() != null) {
			for (Cookie c : request.getCookies()) {
				if ("CART_TOKEN".equals(c.getName())) {
					String v = c.getValue();
					if (v != null && !v.isBlank()) {   // ← 값 가드
						return v;
					}
				}
			}
		}
		String token = UUID.randomUUID().toString();
		Cookie cookie = new Cookie("CART_TOKEN", token);
		cookie.setPath("/");
		cookie.setMaxAge(60 * 60 * 24); // 1일 (원하시면 30일로 늘려도 됩니다)
		cookie.setHttpOnly(true);
		// cookie.setSecure(true); // HTTPS 환경에서 활성화
		response.addCookie(cookie);
		// SameSite 보강(서블릿 쿠키 속성에 없으므로 헤더로 추가)
		response.addHeader("Set-Cookie",
				"CART_TOKEN=" + token + "; Max-Age=" + 60 * 60 * 24 + "; Path=/; HttpOnly; SameSite=Lax");
		return token;
	}

	@PostMapping("/Temporarily/Cart/add")
	public String addCartTemp(HttpSession session, HttpServletRequest request, HttpServletResponse response,
							  Model model, @RequestParam int productid, @RequestParam String name, @RequestParam String color,
							  @RequestParam String size, @RequestParam int count, @RequestParam int price) {

		String token = getOrCreateCartToken(request, response);

		List<CartItem> cartItems = (List<CartItem>) session.getAttribute("cartItems");
		if (cartItems == null) {
			try {
				cartItems = SessionFileUtil.loadSession(token);
			} catch (IOException | NoSuchAlgorithmException e) {
				cartItems = new ArrayList<>();
			}
			session.setAttribute("cartItems", cartItems);
		}

		count = Math.max(1, Math.min(99, count));
		boolean updated = false;
		for (CartItem item : cartItems) {
			if (item.getProductid() == productid && item.getName().equals(name) && item.getColor().equals(color)
					&& item.getSize().equals(size)) {
				item.setCount(Math.max(1, Math.min(99, item.getCount() + count)));
				updated = true;
				break;
			}
		}
		if (!updated) {
			cartItems.add(new CartItem(productid, name, color, size, count, price));
		}

		try {
			SessionFileUtil.saveSession(token, cartItems);
		} catch (Exception ignored) {
		}

		model.addAttribute("carts", cartItems);
		return "redirect:/temp/Cart";
	}


	@GetMapping("/temp/Cart")
	public String TempCartList(HttpSession session, HttpServletRequest request, HttpServletResponse response,
							   Model model) {
		String token = getOrCreateCartToken(request, response);

		List<CartItem> cartItems = (List<CartItem>) session.getAttribute("cartItems");
		if (cartItems == null) {
			try {
				cartItems = SessionFileUtil.loadSession(token);
			} catch (IOException | NoSuchAlgorithmException e) {
				cartItems = new ArrayList<>();
			}
			session.setAttribute("cartItems", cartItems);
		}

		model.addAttribute("carts", cartItems);
		return "cart/tempcart";
	}

	@PostMapping("/Temporarily/Cart/Modify")
	public RedirectView modifyCartItem(@RequestParam int productid, @RequestParam String color,
									   @RequestParam String size, @RequestParam int count, @RequestParam int price,
									   HttpSession session, HttpServletRequest request, HttpServletResponse response) {

		String token = getOrCreateCartToken(request, response);

		List<CartItem> cartItems = (List<CartItem>) session.getAttribute("cartItems");
		if (cartItems == null) {
			try {
				cartItems = SessionFileUtil.loadSession(token);
			} catch (IOException | NoSuchAlgorithmException e) {
				cartItems = new ArrayList<>();
			}
			session.setAttribute("cartItems", cartItems);
		}

		count = Math.max(1, Math.min(99, count));
		boolean updated = false;
		for (CartItem item : cartItems) {
			if (item.getProductid() == productid && item.getColor().equals(color) && item.getSize().equals(size)) {
				item.setCount(count);
				updated = true;
				break;
			}
		}
		if (!updated) {
			cartItems.add(new CartItem(productid, "Product Name", color, size, count, price));
		}

		try {
			SessionFileUtil.saveSession(token, cartItems);
		} catch (IOException ignored) {
		}

		return new RedirectView("/temp/Cart");
	}

	@PostMapping("/Temporarily/Cart/Delete")
	public RedirectView deleteCartItem(@RequestParam int productid, @RequestParam String color,
									   @RequestParam String size, HttpSession session, HttpServletRequest request, HttpServletResponse response) {

		String token = getOrCreateCartToken(request, response);

		List<CartItem> cartItems = (List<CartItem>) session.getAttribute("cartItems");
		if (cartItems == null) {
			try {
				cartItems = SessionFileUtil.loadSession(token);
			} catch (IOException | NoSuchAlgorithmException e) {
				cartItems = new ArrayList<>();
			}
			session.setAttribute("cartItems", cartItems);
		}

		cartItems.removeIf(item -> item.getProductid() == productid && item.getColor().equals(color)
				&& item.getSize().equals(size));

		try {
			SessionFileUtil.saveSession(token, cartItems);
		} catch (IOException ignored) {
		}

		return new RedirectView("/temp/Cart");
	}
}
