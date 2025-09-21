package com.example.demo.dao;

import java.util.List;
import org.apache.ibatis.annotations.*;
import com.example.demo.vo.Member;

@Mapper
public interface UserDao {

	// ✅ regDate는 DB DEFAULT 사용 (컬럼/값에서 제외)
	@Insert("""
        INSERT INTO `user` (userid, userpw, `name`, email, `class`, address)
        VALUES (#{userid}, #{userpw}, #{name}, #{email}, #{memberClass}, #{address})
    """)
	void signup(Member member);

	@Update("""
        UPDATE `user`
        SET userpw = #{pw}, `name` = #{name}, email = #{email}, address = #{address}
        WHERE userid = #{userid}
    """)
	void modify(@Param("userid") String userid,
				@Param("pw") String pw,
				@Param("name") String name,
				@Param("email") String email,
				@Param("address") String address);

	@Delete("""
        DELETE FROM `user`
        WHERE id = #{id}
    """)
	void signout(@Param("id") int id);

	// ✅ memberClass ← `class` 매핑 보장
	@Select("SELECT id, regDate, userid, userpw, `name`, email, address, `class` FROM `user` WHERE userid = #{userid}")
	@Results(id="MemberMap", value={
			@Result(property="id",          column="id"),
			@Result(property="regDate",     column="regDate"),
			@Result(property="userid",      column="userid"),
			@Result(property="userpw",      column="userpw"),
			@Result(property="name",        column="name"),
			@Result(property="email",       column="email"),
			@Result(property="address",     column="address"),
			@Result(property="memberClass", column="class")
	})
	Member findByUserid(@Param("userid") String userid);

	@Select("SELECT COUNT(*) FROM `user` WHERE userid = #{userid}")
	int checkid(@Param("userid") String userid);

	// ⚠️ 평문 비교는 지양(PasswordEncoder로 검증 권장). 필요 시 임시 사용 가능
	@Select("""
        SELECT COUNT(*) FROM `user` WHERE userid = #{userid} AND userpw = #{pw}
    """)
	int checkpw(@Param("userid") String userid, @Param("pw") String pw);

	@Select("SELECT id FROM `user` WHERE userid = #{userid}")
	int getid(@Param("userid") String userid);

	@Select("SELECT COUNT(*) FROM `user` WHERE userid = #{userid}")
	int countByUserid(@Param("userid") String userid);

	@Select("SELECT id, regDate, userid, userpw, `name`, email, address, `class` FROM `user` WHERE email = #{email}")
	@ResultMap("MemberMap")
	Member findByUserEmail(@Param("email") String email);

	// ✅ UPSERT (MySQL 8.0.20+ 에서 VALUES() 대체: alias 사용)
	@Insert("""
        INSERT INTO `user` (userid, userpw, `name`, email, `class`, address)
        VALUES (#{userid}, #{userpw}, #{name}, #{email}, #{memberClass}, #{address})
        AS new
        ON DUPLICATE KEY UPDATE
            userpw = new.userpw,
            `name` = new.`name`,
            email  = new.email,
            address= new.address,
            `class`= new.`class`
    """)
	void save(Member member);

	@Select("""
        SELECT id, regDate, userid, userpw, `name`, email, address, `class`
        FROM `user`
        WHERE
            (#{name}  IS NULL OR `name`  LIKE CONCAT('%', #{name}, '%'))
        AND (#{email} IS NULL OR email  LIKE CONCAT('%', #{email}, '%'))
    """)
	@ResultMap("MemberMap")
	List<Member> searcUL(@Param("name") String name, @Param("email") String email);

	@Update("""
        UPDATE `user`
        SET userpw = #{newPassword}
        WHERE userid = #{userid}
    """)
	void resetPassword(@Param("userid") String userid,
					   @Param("newPassword") String newPassword);
}
