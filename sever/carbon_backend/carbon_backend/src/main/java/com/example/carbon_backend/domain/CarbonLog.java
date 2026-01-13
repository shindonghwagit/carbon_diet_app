package com.example.carbon_backend.domain;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Entity
@Getter
@NoArgsConstructor
public class CarbonLog {

    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String category;      // 카테고리 (전기, 교통, 식사)
    private String type;          // 세부 항목 (버스, 소고기 등)
    private double inputAmount;   // 입력값 (km, 인분, 원)
    private double carbonEmitted; // 탄소 배출량 (kg)

    private String username;

    private LocalDateTime createdAt;

    public CarbonLog(String category, String type, double inputAmount, double carbonEmitted, String username) {
        this.category = category;
        this.type = type;
        this.inputAmount = inputAmount;
        this.carbonEmitted = carbonEmitted;
        this.username = username;     // 이름표 붙이기
        this.createdAt = LocalDateTime.now();
    }

    public void setCreatedAt(LocalDateTime date) {
        this.createdAt = date;
    }

    public void setUsername(String newId) {
        this.username = username;
    }
}