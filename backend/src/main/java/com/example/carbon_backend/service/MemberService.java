package com.example.carbon_backend.service;

import com.example.carbon_backend.domain.Member;
import com.example.carbon_backend.repository.MemberRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class MemberService {
    private final MemberRepository memberRepository;

    // 회원가입 (암호화해서 저장!)
    public String register(String username, String password, String name) {
        if (memberRepository.findByUsername(username).isPresent()) {
            return "FAIL:이미 존재하는 아이디입니다.";
        }

        //  비밀번호 암호화
        String encodedPassword = PasswordEncoder.encrypt(password);

        // 암호화된 비밀번호로 멤버 생성
        Member member = new Member(username, encodedPassword, name);
        memberRepository.save(member);
        return "SUCCESS:회원가입 완료";
    }

    // 로그인 (암호화된 것끼리 비교!)
    public String login(String username, String password) {
        Optional<Member> member = memberRepository.findByUsername(username);

        if (member.isPresent()) {
            //  사용자가 입력한 비밀번호도 똑같이 암호화해서 비교
            String encodedInput = PasswordEncoder.encrypt(password);

            // DB에 있는 암호화된 비밀번호 vs 방금 입력한 암호화된 비밀번호
            if (member.get().getPassword().equals(encodedInput)) {
                return "SUCCESS:" + member.get().getName();
            } else {
                return "FAIL:비밀번호가 틀렸습니다.";
            }
        }
        return "FAIL:존재하지 않는 아이디입니다.";
    }
}