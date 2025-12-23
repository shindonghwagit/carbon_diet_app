package com.example.carbon_backend.domain; // 👈 여기를 수정했습니다!

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Entity
@Data
@NoArgsConstructor
public class UsageResult {

    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private int inputMoney;
    private double calculatedUsage;
    private LocalDateTime createdAt;

    public UsageResult(int inputMoney, double calculatedUsage) {
        this.inputMoney = inputMoney;
        this.calculatedUsage = calculatedUsage;
        this.createdAt = LocalDateTime.now();
    }
}