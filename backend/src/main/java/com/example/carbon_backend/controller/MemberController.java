package com.example.carbon_backend.controller;

import com.example.carbon_backend.service.MemberService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@CrossOrigin("*")
@RestController
@RequiredArgsConstructor
public class MemberController {

    private final MemberService memberService;

    // 회원가입: /api/register?id=user&pw=1234&name=홍길동
    @PostMapping("/api/register")
    public String register(@RequestParam String id, @RequestParam String pw, @RequestParam String name) {
        return memberService.register(id, pw, name);
    }

    // 로그인: /api/login?id=user&pw=1234
    @PostMapping("/api/login")
    public String login(@RequestParam String id, @RequestParam String pw) {
        return memberService.login(id, pw);
    }
}