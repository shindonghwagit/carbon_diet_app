package com.example.carbon_backend.controller;

import com.example.carbon_backend.domain.Member;
import com.example.carbon_backend.repository.MemberRepository;
import com.example.carbon_backend.service.MemberService;
import com.example.carbon_backend.service.PasswordEncoder;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@CrossOrigin("*")
@RestController
@RequiredArgsConstructor
public class MemberController {

    private final MemberService memberService;

    private final MemberRepository memberRepository;

    @PostMapping("/api/register")
    public String register(
            @RequestParam String id,
            @RequestParam String pw,
            @RequestParam String name,
            @RequestParam String email,
            @RequestParam String gender,
            @RequestParam String birthDate
    ) {
        return memberService.register(id, pw, name, email, gender, birthDate);
    }

    // 로그인
    @PostMapping("/api/login")
    public String login(@RequestParam String id, @RequestParam String pw) {
        return memberService.login(id, pw);
    }

    @DeleteMapping("/{username}")
    public ResponseEntity<String> deleteUser(@PathVariable String username) {

        memberService.deleteMember(username); // 👈 여기서 서비스 호출!

        return ResponseEntity.ok("회원 탈퇴가 완료되었습니다.");
    }

    @GetMapping("/api/member/find-id")
    public String findId(@RequestParam String name, @RequestParam String email) {
        return memberRepository.findByNameAndEmail(name, email)
                .map(member -> "찾으시는 아이디는 [" + member.getUsername() + "] 입니다.")
                .orElse("일치하는 회원 정보가 없습니다.");
    }

    //  2. 비밀번호 찾기
    @GetMapping("/api/member/find-pw")
    public String findPw(@RequestParam String username, @RequestParam String name) {
        return memberRepository.findByUsernameAndName(username, name)
                .map(member -> "회원님의 비밀번호는 [" + member.getPassword() + "] 입니다.")
                // 주의: 실제 서비스에선 비번을 바로 주면 안 되고, '임시 비번'으로 바꿔줘야 한다.
                .orElse("일치하는 회원 정보가 없습니다.");
    }

    // 비밀번호 변경
    @PutMapping("/api/member/update")
    public String updateMember(@RequestParam String id, @RequestParam String name) {
        // 1. 아이디로 유저 찾기
        Member member = memberRepository.findByUsername(id).orElse(null);
        if (member == null) return "FAIL:존재하지 않는 회원";

        // 2. 닉네임 변경 및 저장
        member.setName(name);
        memberRepository.save(member);

        return "SUCCESS:수정 완료";
    }

    @PutMapping("/api/member/password")
    public String updatePassword(@RequestParam String id, @RequestParam String currentPw, @RequestParam String newPw) {
        // 1. 회원 찾기
        Member member = memberRepository.findByUsername(id).orElse(null);
        if (member == null) return "FAIL:존재하지 않는 회원";

        // 2. 현재 비밀번호가 맞는지 확인 (암호화해서 비교)
        String encryptedCurrentPw = PasswordEncoder.encrypt(currentPw);
        if (!member.getPassword().equals(encryptedCurrentPw)) {
            return "FAIL:현재 비밀번호가 틀렸습니다.";
        }

        // 3. 새 비밀번호로 변경 (암호화 필수!)
        String encryptedNewPw = PasswordEncoder.encrypt(newPw);
        member.setPassword(encryptedNewPw);
        memberRepository.save(member);

        return "SUCCESS:비밀번호 변경 완료";
    }
}