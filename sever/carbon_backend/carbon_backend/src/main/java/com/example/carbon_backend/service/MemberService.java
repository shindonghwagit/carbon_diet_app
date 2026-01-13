package com.example.carbon_backend.service;

import com.example.carbon_backend.domain.Member;
// import com.example.carbon_backend.domain.UsageResult;
import com.example.carbon_backend.repository.CarbonLogRepository;
import com.example.carbon_backend.repository.MemberRepository;
import com.example.carbon_backend.repository.UsageRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class MemberService {

    private final MemberRepository memberRepository;
    private final CarbonLogRepository carbonLogRepository;
    private final UsageRepository usageRepository;

    // 회원가입
    public String register(String username, String password, String name, String email, String gender, String birthDate) {
        if (memberRepository.findByUsername(username).isPresent()) {
            return "FAIL:이미 존재하는 아이디입니다.";
        }

        String encodedPassword = PasswordEncoder.encrypt(password); // 암호화

        Member member = new Member(username, encodedPassword, name, email, gender, birthDate);
        memberRepository.save(member);
        return "SUCCESS:회원가입 완료";
    }

    // 로그인 (그대로 둠)
    public String login(String username, String password) {
        Optional<Member> member = memberRepository.findByUsername(username);

        if (member.isPresent()) {
            String encodedInput = PasswordEncoder.encrypt(password);
            if (member.get().getPassword().equals(encodedInput)) {
                return "SUCCESS:" + member.get().getName();
            } else {
                return "FAIL:비밀번호가 틀렸습니다.";
            }
        }
        return "FAIL:존재하지 않는 아이디입니다.";
    }

    @Transactional
    public void deleteMember(String username) {
        carbonLogRepository.deleteAllByUsername(username);
        usageRepository.deleteByUsername(username);
        memberRepository.deleteById(username);
    }
}