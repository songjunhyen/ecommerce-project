package com.example.demo.dao;

import java.util.List;

import org.apache.ibatis.annotations.*;

import com.example.demo.vo.Admin;

@Mapper
public interface AdminDao {

    @Insert("""
        INSERT INTO `admin` (regDate, adminId, adminPw, `name`, email, adminclass)
        VALUES (#{regDate}, #{adminId}, #{adminPw}, #{name}, #{email}, #{adminclass})
    """)
        // id가 AUTO_INCREMENT면 아래 옵션을 사용하세요 (vo에 id 필드 존재시)
        // @Options(useGeneratedKeys = true, keyProperty = "id")
    void signup(Admin newAdmin);

    @Update("""
        UPDATE `admin`
        SET `name` = #{name}, adminPw = #{newpw}
        WHERE email = #{email}
    """)
    void modify(@Param("newpw") String newpw,
                @Param("name") String name,
                @Param("email") String email);

    @Delete("""
        DELETE FROM `admin`
        WHERE id = #{id} AND email = #{email}
    """)
    void signout(@Param("id") int id,
                 @Param("email") String email);

    @Select("SELECT EXISTS(SELECT 1 FROM `admin` WHERE adminId = #{userid})")
    boolean checkid(String userid);

    @Select("SELECT adminPw FROM `admin` WHERE adminId = #{userid}")
    String getHashedPassword(String userid);

    @Select("SELECT id FROM `admin` WHERE adminId = #{adminId}")
    Integer getid(String adminId); // ❗ null 가능성 반영

    @Select("SELECT * FROM `admin` WHERE id = #{adminid} AND adminId = #{userid}")
    Admin getadmin(@Param("adminid") int adminid,
                   @Param("userid") String userid);

    @Select("SELECT * FROM `admin` WHERE email = #{email}")
    Admin getbyemail(String email);

    @Select("SELECT adminclass FROM `admin` WHERE adminId = #{userid}")
    Integer getadminclass(String userid); // ❗ null 가능성 반영(권장)

    @Select("SELECT * FROM `admin` WHERE adminId = #{username}") // 컬럼 표기 통일
    Admin findByUserid(String username);

    @Select("SELECT adminclass, `name` FROM `admin` WHERE adminId = #{userid}") // 컬럼 표기 통일
    Admin getAdminClassByUserid(String userid);

    @Select("""
            SELECT adminid, name, email, adminclass
            FROM `admin`
            WHERE
                (#{adminclass} IS NULL OR adminclass = #{adminclass})
                AND (#{name} IS NULL OR name LIKE CONCAT('%', #{name}, '%'))
                AND (#{email} IS NULL OR email LIKE CONCAT('%', #{email}, '%'))
    """)
    List<Admin> searcAL(@Param("adminclass") String adminclass,
                        @Param("name") String name,
                        @Param("email") String email);

    @Update("""
        UPDATE `admin`
        SET adminId = #{newId},
            adminPw = #{encodedPassword}
        WHERE adminId = #{adminId}
    """)
    void resetPassword(@Param("adminId") String adminId,
                       @Param("newId") String newId,
                       @Param("encodedPassword") String encodedPassword);
}
