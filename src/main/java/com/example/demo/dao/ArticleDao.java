package com.example.demo.dao;

import com.example.demo.vo.Article;
import org.apache.ibatis.annotations.*;
import java.util.List;
import java.util.Optional;

@Mapper
public interface ArticleDao {

    // == CREATE ==
    @Insert("""
        INSERT INTO `article`
            (title, body, writer_id, reg_date, update_date, viewcount)
        VALUES
            (#{title}, #{body}, #{writerId}, NOW(), NOW(), 0)
        """)
    @Options(useGeneratedKeys = true, keyProperty = "id")
    void insert(Article article);

    // == READ (단건) ==
    @Select("""
        SELECT
            id,
            title,
            body,
            writer_id   AS writerId,
            reg_date    AS regDate,
            update_date AS updateDate,
            viewcount   AS viewCount
        FROM `article`
        WHERE id = #{id}
        """)
    Optional<Article> findById(Long id);

    // == READ (목록/검색/페이징) ==
    @Select("""
        SELECT
            id,
            title,
            body,
            writer_id   AS writerId,
            reg_date    AS regDate,
            update_date AS updateDate,
            viewcount   AS viewCount
        FROM `article`
        WHERE
            (#{q} IS NULL OR #{q} = '')
            OR title LIKE CONCAT('%', #{q}, '%')
            OR body  LIKE CONCAT('%', #{q}, '%')
        ORDER BY id DESC
        LIMIT #{limit} OFFSET #{offset}
        """)
    List<Article> list(@Param("offset") int offset,
                       @Param("limit") int limit,
                       @Param("q") String q);

    // == COUNT (검색 포함 총 개수) ==
    @Select("""
        SELECT COUNT(*)
        FROM `article`
        WHERE
            (#{q} IS NULL OR #{q} = '')
            OR title LIKE CONCAT('%', #{q}, '%')
            OR body  LIKE CONCAT('%', #{q}, '%')
        """)
    int count(@Param("q") String q);

    // == UPDATE ==
    @Update("""
        UPDATE `article`
        SET
            title = #{title},
            body  = #{body},
            update_date = NOW()
        WHERE id = #{id}
        """)
    int update(Article article);

    // == DELETE ==
    @Delete("DELETE FROM `article` WHERE id = #{id}")
    int delete(Long id);

    // == 조회수 증가 ==
    @Update("UPDATE `article` SET viewcount = viewcount + 1 WHERE id = #{id}")
    int increaseViewCount(Long id);
}
