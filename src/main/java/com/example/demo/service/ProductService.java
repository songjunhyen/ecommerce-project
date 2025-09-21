package com.example.demo.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.example.demo.dao.ProductDao;
import com.example.demo.util.Util;
import com.example.demo.vo.Product;

@Service
public class ProductService {
	private final ProductDao productDao;

	public ProductService(ProductDao productDao) {
		this.productDao = productDao;
	}

	public void addProduct(Product product) {
		productDao.addProduct(product);
	}

	public boolean exists(int productId) {
		return productDao.existsById(productId) > 0;
	}

	public void modifyProduct(int productId, Product product) {
		productDao.modifyProduct(productId, product);
	}

	public void deleteProduct(int productId) {
		productDao.deleteProduct(productId);
	}

	public List<Product> getProductList() {
		return productDao.getProductList();
	}

	public Product getProductDetail(int id) {
		return productDao.getProductDetail(id);
	}

	public String getWriterId(int id) {
		return productDao.getWriterId(id);
	}

	public void updateViewCount(int id) {
		productDao.updateViewCount(id);
	}
}
