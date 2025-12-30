package com.example.carbon_backend.repository; // 패키지명 확인

import com.example.carbon_backend.domain.CarbonLog;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface CarbonLogRepository extends JpaRepository<CarbonLog, Long> {
    // 👇 이 줄이 없으면 안 됩니다! (이름으로 찾기 기능)
    List<CarbonLog> findByUsername(String username);

    void deleteByUsername(String username);
}