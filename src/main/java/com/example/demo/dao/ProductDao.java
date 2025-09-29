package com.example.demo.dao;

import java.util.List;

import org.apache.ibatis.annotations.*;

import com.example.demo.vo.Product;

@Mapper
public interface ProductDao {

	// DB 기본값(regDate, viewcount) 쓰도록 제거
	@Insert("""
        INSERT INTO product
        (`writer`, `name`, price, `description`, imageUrl, `count`, category, maker, color, size, additionalOptions)
        VALUES
        (#{writer}, #{name}, #{price}, #{description}, #{imageUrl}, #{count}, #{category}, #{maker}, #{color}, #{size}, #{additionalOptions})
        """)
	int addProduct(Product product);

	@Select("SELECT COUNT(*) FROM product WHERE id = #{productId}")
	int existsById(@Param("productId") int productId);

	// 없는 컬럼 updateDate 제거 + 예약어 백틱 처리 + @Param 명시
	@Update("""
    UPDATE product SET
        `name` = #{p.name},
        price = #{p.price},
        `description` = #{p.description},
        imageUrl = #{p.imageUrl,jdbcType=VARCHAR},
        `count` = #{p.count},
        category = #{p.category},
        maker = #{p.maker},
        color = #{p.color},
        size = #{p.size},
        additionalOptions = #{p.additionalOptions}
    WHERE id = #{id}
    """)
	int modifyProduct(@Param("id") int productId, @Param("p") Product product);


	@Delete("DELETE FROM product WHERE id = #{productId}")
	int deleteProduct(@Param("productId") int productId);

	@Select("""
        SELECT id, writer, `name`, price, `description`, imageUrl, `count`,
               category, maker, color, size, additionalOptions, regDate, viewcount
        FROM product
        ORDER BY id DESC
        """)
	List<Product> getProductList();

	@Select("""
        SELECT id, writer, `name`, price, `description`, imageUrl, `count`,
               category, maker, color, size, additionalOptions, regDate, viewcount
        FROM product
        WHERE id = #{id}
        """)
	Product getProductDetail(@Param("id") int id);

	@Select("SELECT writer FROM product WHERE id = #{id}")
	String getWriterId(@Param("id") int id);

	@Update("UPDATE product SET viewcount = viewcount + 1 WHERE id = #{id}")
	int updateViewCount(@Param("id") int id);

	// 디버깅용: 지금 붙은 DB와 개수 확인
	@Select("SELECT DATABASE()")
	String currentSchema();

	@Select("SELECT COUNT(*) FROM product")
	int countAll();

	@Select("""
    SELECT id, writer, `name`, price, `description`, imageUrl, `count`,
           category, maker, color, size, additionalOptions, regDate, viewcount
    FROM product
    WHERE
        `name`        LIKE CONCAT('%', #{kw}, '%')
     OR `description` LIKE CONCAT('%', #{kw}, '%')
     OR category     LIKE CONCAT('%', #{kw}, '%')
     OR maker        LIKE CONCAT('%', #{kw}, '%')
     OR color        LIKE CONCAT('%', #{kw}, '%')
     OR size         LIKE CONCAT('%', #{kw}, '%')
    ORDER BY id DESC
    """)
	List<Product> getProductListSearch(@Param("kw") String keyword);

}
