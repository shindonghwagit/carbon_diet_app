package com.example.carbon_backend.service;

import com.example.carbon_backend.domain.Member;
import com.example.carbon_backend.repository.MemberRepository;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import lombok.RequiredArgsConstructor;

import java.util.List;

@Service
@RequiredArgsConstructor
public class NotificationScheduler {

    private final MemberRepository memberRepository;

    // 매일 밤 9시 0분 0초에 실행되는 설정
    @Scheduled(fixedRate = 30000)
    public void sendNightlyNotification() {
        System.out.println("밤 8시가 되었습니다. 알림 전송을 시작합니다!");

        // 1. DB에서 모든 회원 가져오기
        List<Member> members = memberRepository.findAll();

        for (Member member : members) {
            String token = member.getFcmToken();

            // 토큰이 있는 사람에게만 보냄
            if (token != null && !token.isEmpty()) {
                sendToMember(token, member.getName());
            }
        }
    }

    private void sendToMember(String token, String name) {
        try {
            Notification notification = Notification.builder()
                    .setTitle("탄소 다이어트")
                    .setBody(name + "님! 오늘 하루 탄소 줄이기 성공하셨나요?")
                    .build();

            Message message = Message.builder()
                    .setToken(token)
                    .setNotification(notification)
                    .putData("click_action", "FLUTTER_NOTIFICATION_CLICK")
                    .build();

            FirebaseMessaging.getInstance().send(message);
            System.out.println("알림 전송 성공: " + name);

        } catch (Exception e) {
            System.out.println("전송 실패 (" + name + "): " + e.getMessage());
        }
    }
}