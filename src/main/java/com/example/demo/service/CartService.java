package com.example.demo.service;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.demo.dao.CartDao;
import com.example.demo.vo.Cart;

@Service
@Transactional(readOnly = true)
public class CartService {
	private final CartDao cartDao;

	CartService(CartDao cartDao) {
		this.cartDao = cartDao;
	}

	public List<Cart> GetCartList(String userid) {
		return cartDao.GetCartList(userid);
	}

	@Transactional
	public void AddCartList(String userid, int productid, String name, String color, String size, int count, int price) {
		int safeCount = clampCount(count);
		cartDao.AddCartList(userid, productid, name, color, size, safeCount, price);
	}

	@Transactional
	public void ModifyCartList(int id, String userid, int productid, String productname, String a_color, String a_size,
							   String color, String size, int count, int price) {
		// a_* : 기존값, 나머지 : 수정된 값
		int safeCount = clampCount(count);

		boolean existed = checking(userid, productid, a_color, a_size);
		if (!existed) {
			// 기존 데이터가 없으면 새로 추가
			cartDao.insertCart(userid, productid, productname, color, size, safeCount, price);
			return;
		}

		// 기존 행의 id 일치 여부 확인 (DAO에서 없으면 0 반환하도록 정리되어 있음)
		int currentId = GetCartId(userid, productid, productname, a_color, a_size);
		if (id != currentId) {
			// 방어: 동일 행이 아닐 경우 기존 것을 지우고 새로 추가
			cartDao.DeleteCartList(id, userid, productid, a_color, a_size);
			cartDao.insertCart(userid, productid, productname, color, size, safeCount, price);
			return;
		}

		boolean colorChanged = (color != null && !color.equals(a_color));
		boolean sizeChanged  = (size  != null && !size.equals(a_size));

		if (colorChanged && sizeChanged) {
			// 둘 다 변경: 한 번에 갱신 (WHERE: id, userid, productid)
			cartDao.updateTwo(id, userid, productid, color, size);
		} else if (colorChanged) {
			// 색상만 변경 (WHERE: ... AND size = 기존값과 동일해야 함 → 컨트롤러에서 a_size 그대로 전달됨)
			cartDao.updateColor(id, userid, productid, color, a_size);
		} else if (sizeChanged) {
			// 사이즈만 변경 (WHERE: ... AND color = 기존값과 동일해야 함 → 컨트롤러에서 a_color 그대로 전달됨)
			cartDao.updateSize(id, userid, productid, a_color, size);
		} else {
			// 옵션 동일 → 수량만 수정
			cartDao.updateCount(userid, productid, color, size, safeCount);
		}
	}

	@Transactional
	public void DeleteCartList(int id, String userid, int productid, String color, String size) {
		cartDao.DeleteCartList(id, userid, productid, color, size);
	}

	public boolean checking(String userid, int productid, String color, String size) {
		int count = cartDao.checking(userid, productid, color, size);
		return count > 0;
	}

	public int GetCartId(String userid, int productid, String productname, String color, String size) {
		return cartDao.GetCartId(userid, productid, productname, color, size);
	}

	// ===== helpers =====
	private static int clampCount(int count) {
		if (count < 1) return 1;
		if (count > 99) return 99;
		return count;
	}
}
