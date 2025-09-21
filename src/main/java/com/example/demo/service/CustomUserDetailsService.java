package com.example.demo.service;

import org.springframework.security.core.authority.AuthorityUtils;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import com.example.demo.dao.AdminDao;
import com.example.demo.dao.UserDao;
import com.example.demo.vo.Admin;
import com.example.demo.vo.Member;


@Service
public class CustomUserDetailsService implements UserDetailsService {
    private final UserDao userDao;
    private final AdminDao adminDao;

    public CustomUserDetailsService(UserDao userDao, AdminDao adminDao) {
        this.userDao = userDao;
        this.adminDao = adminDao;
    }

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        // 1) userid 로 우선 조회
        Member byId = userDao.findByUserid(username);
        if (byId != null) {
            return new org.springframework.security.core.userdetails.User(
                    byId.getUserid(),
                    byId.getUserpw(),
                    AuthorityUtils.createAuthorityList("ROLE_USER"));
        }

        // 2) email 로 조회 (OAuth 공통)
        Member byEmail = userDao.findByUserEmail(username);
        if (byEmail != null) {
            return new org.springframework.security.core.userdetails.User(
                    byEmail.getUserid(),
                    byEmail.getUserpw(),
                    AuthorityUtils.createAuthorityList("ROLE_USER"));
        }

        // 3) admin 조회
        Admin admin = adminDao.findByUserid(username);
        if (admin != null) {
            return new org.springframework.security.core.userdetails.User(
                    admin.getAdminId(),
                    admin.getAdminPw(),
                    AuthorityUtils.createAuthorityList("ROLE_ADMIN"));
        }

        throw new UsernameNotFoundException("User not found: " + username);
    }

    // 필요 시: 이메일로만 찾는 별도 엔드포인트
    public UserDetails loadUserByGoogle(String email) throws UsernameNotFoundException {
        Member member = userDao.findByUserEmail(email);
        if (member != null) {
            return new org.springframework.security.core.userdetails.User(
                    member.getUserid(),
                    member.getUserpw(),
                    AuthorityUtils.createAuthorityList("ROLE_USER"));
        }
        throw new UsernameNotFoundException("User not found by email: " + email);
    }
}
