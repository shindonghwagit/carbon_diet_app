package com.example.carbon_backend.repository;

import com.example.carbon_backend.domain.Member;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface MemberRepository extends JpaRepository<Member, Long> {
    // 아이디로 회원 찾기 기능 추가
    Optional<Member> findByUsername(String username);

    Optional<Member> findByNameAndEmail(String name, String email);

    Optional<Member> findByUsernameAndName(String username, String name);

    void deleteById(String username);
}