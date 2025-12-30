package com.example.carbon_backend.domain;

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
    private String username;

    private int inputMoney;
    private double calculatedUsage;
    private LocalDateTime createdAt;

    public UsageResult(String username, int inputMoney, double calculatedUsage) {

    }

    public void deleteByUsername(String username) {
    }
}