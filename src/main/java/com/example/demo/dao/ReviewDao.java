package com.example.demo.dao;

import java.util.List;

import org.apache.ibatis.annotations.*;

import com.example.demo.vo.Review;

@Mapper
public interface ReviewDao {

	@Insert("""
        INSERT INTO review (writer, productid, reviewtext, star, regDate)
        VALUES (#{writer}, #{productid}, #{body}, #{star}, NOW())
    """)
	void AddReview(@Param("writer") String writer,
				   @Param("productid") int productid,
				   @Param("body") String body,
				   @Param("star") double star);

	@Select("""
        SELECT *
        FROM review
        WHERE productid = #{productid}
        ORDER BY regDate DESC
    """)
	List<Review> ReviewList(@Param("productid") int productid);

	@Update("""
        UPDATE review
        SET reviewtext = #{body}, regDate = NOW()
        WHERE writer = #{writer} AND productid = #{productid} AND id = #{reviewid}
    """)
	void ReviewModify(@Param("writer") String writer,
					  @Param("productid") int productid,
					  @Param("reviewid") int reviewid,
					  @Param("body") String body);

	@Delete("""
        DELETE FROM review
        WHERE writer = #{writer} AND productid = #{productid} AND id = #{reviewid}
    """)
	void ReviewDelete(@Param("writer") String writer,
					  @Param("productid") int productid,
					  @Param("reviewid") int reviewid);

	@Select("""
        SELECT AVG(star)
        FROM review
        WHERE productid = #{productid}
    """)
	Double GetAverStar(@Param("productid") int productid);

	@Select("""
        SELECT COUNT(*) > 0
        FROM review
        WHERE writer = #{writer}
    """)
	boolean iswriter(@Param("writer") String writer);
}
