package com.example.carbon_backend.domain;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Data
@NoArgsConstructor
public class Member {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true) // 아이디는 중복 안됨
    private String username;
    private String password;
    private String name; // 닉네임

    public Member(String username, String password, String name) {
        this.username = username;
        this.password = password;
        this.name = name;
    }
}