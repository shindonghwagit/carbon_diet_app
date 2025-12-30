package com.example.carbon_backend.repository;

import com.example.carbon_backend.domain.UsageResult;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UsageRepository extends JpaRepository<UsageResult, Long> {

    void deleteByUsername(String username);
}