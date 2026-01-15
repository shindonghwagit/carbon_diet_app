package com.example.carbon_backend.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ClassPathResource;

import jakarta.annotation.PostConstruct;
// import javax.annotation.PostConstruct;

import java.io.InputStream;
import java.io.IOException;

@Configuration
public class FCMConfig {

    @PostConstruct
    public void init() {
        try {
            // 이미 초기화되어 있으면 중복 실행 방지
            if (!FirebaseApp.getApps().isEmpty()) {
                return;
            }

            // 1. resources 폴더에서 키 파일 읽기
            InputStream serviceAccount = new ClassPathResource("serviceAccountKey.json").getInputStream();

            // 2. 옵션 설정
            FirebaseOptions options = FirebaseOptions.builder()
                    .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                    .build();

            // 3. 초기화
            FirebaseApp.initializeApp(options);
            System.out.println("Firebase Admin SDK 연동 성공!");

        } catch (IOException e) {
            e.printStackTrace();
            System.out.println(" Firebase 초기화 실패: " + e.getMessage());
        }
    }
}