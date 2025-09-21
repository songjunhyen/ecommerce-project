package com.example.demo.dao;

import java.util.List;

import org.apache.ibatis.annotations.*;

import com.example.demo.vo.Cart;

@Mapper
public interface CartDao {

	@Select("""
        SELECT
            id,
            userid,
            productid,
            productname,
            color,
            size,
            count,
            price,
            (price * count) AS priceall
        FROM cart
        WHERE userid = #{userid}
        ORDER BY id DESC
    """)
	List<Cart> GetCartList(String userid);

	@Insert("""
        INSERT INTO cart (userid, productid, productname, color, size, count, price)
        VALUES (#{userid}, #{productid}, #{name}, #{color}, #{size}, #{count}, #{price})
    """)
	void AddCartList(@Param("userid") String userid,
					 @Param("productid") int productid,
					 @Param("name") String name,
					 @Param("color") String color,
					 @Param("size") String size,
					 @Param("count") int count,
					 @Param("price") int price);

	@Insert("""
        INSERT INTO cart (userid, productid, productname, color, size, count, price)
        VALUES (#{userid}, #{productid}, #{productname}, #{color}, #{size}, #{count}, #{price})
    """)
	void insertCart(@Param("userid") String userid,
					@Param("productid") int productid,
					@Param("productname") String productname,
					@Param("color") String color,
					@Param("size") String size,
					@Param("count") int count,
					@Param("price") int price);

	@Update("""
        UPDATE cart
        SET count = #{count}
        WHERE userid = #{userid}
          AND productid = #{productid}
          AND color = #{color}
          AND size = #{size}
    """)
	void updateCount(@Param("userid") String userid,
					 @Param("productid") int productid,
					 @Param("color") String color,
					 @Param("size") String size,
					 @Param("count") int count);

	@Delete("""
        DELETE FROM cart
        WHERE id = #{id}
          AND userid = #{userid}
          AND productid = #{productid}
          AND color = #{color}
          AND size = #{size}
    """)
	void DeleteCartList(@Param("id") int id,
						@Param("userid") String userid,
						@Param("productid") int productid,
						@Param("color") String color,
						@Param("size") String size);

	@Select("""
        SELECT COUNT(*)
        FROM cart
        WHERE userid = #{userid}
          AND productid = #{productid}
          AND color = #{color}
          AND size = #{size}
    """)
	int checking(@Param("userid") String userid,
				 @Param("productid") int productid,
				 @Param("color") String color,
				 @Param("size") String size);

	@Select("""
        SELECT IFNULL(MAX(id), 0) AS id
        FROM cart
        WHERE userid = #{userid}
          AND productid = #{productid}
          AND productname = #{productname}
          AND color = #{color}
          AND size = #{size}
    """)
	int GetCartId(@Param("userid") String userid,
				  @Param("productid") int productid,
				  @Param("productname") String productname,
				  @Param("color") String color,
				  @Param("size") String size);

	@Update("""
        UPDATE cart
        SET color = #{color}
        WHERE id = #{id}
          AND userid = #{userid}
          AND productid = #{productid}
          AND size = #{size}
    """)
	void updateColor(@Param("id") int id,
					 @Param("userid") String userid,
					 @Param("productid") int productid,
					 @Param("color") String color,
					 @Param("size") String size);

	@Update("""
        UPDATE cart
        SET size = #{size}
        WHERE id = #{id}
          AND userid = #{userid}
          AND productid = #{productid}
          AND color = #{color}
    """)
	void updateSize(@Param("id") int id,
					@Param("userid") String userid,
					@Param("productid") int productid,
					@Param("color") String color,
					@Param("size") String size);

	@Update("""
        UPDATE cart
        SET size = #{size},
            color = #{color}
        WHERE id = #{id}
          AND userid = #{userid}
          AND productid = #{productid}
    """)
	void updateTwo(@Param("id") int id,
				   @Param("userid") String userid,
				   @Param("productid") int productid,
				   @Param("color") String color,
				   @Param("size") String size);
}
