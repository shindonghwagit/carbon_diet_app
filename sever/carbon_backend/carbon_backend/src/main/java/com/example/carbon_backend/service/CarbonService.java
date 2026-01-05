package com.example.carbon_backend.service;

import com.example.carbon_backend.domain.CarbonLog;
import com.example.carbon_backend.domain.UsageResult;
import com.example.carbon_backend.repository.CarbonLogRepository;
import com.example.carbon_backend.repository.UsageRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;

@Service
@RequiredArgsConstructor
public class CarbonService {
    private final CarbonLogRepository carbonLogRepository;

    private final UsageRepository usageRepository;

    // 1. 전기
    public double calculateElectricity(String username, int billAmount, String date) {
        double usageKwh = billAmount / 200.0;
        double carbon = usageKwh * 0.47;
        saveLog(username, "전기", "전기요금", billAmount, carbon, date); // date 넘기기

        UsageResult result = new UsageResult(username, billAmount, usageKwh);
        usageRepository.save(result);

        return carbon;
    }

    // 2.  교통
    public double calculateTransport(String username, String type, double km, String date) {
        double factor = 0.0;
        if (type.equals("버스")) factor = 0.05;
        else if (type.equals("지하철")) factor = 0.03;
        else if (type.equals("택시")) factor = 0.18;
        else if (type.equals("자차")) factor = 0.21;

        double carbon = km * factor;

        // 날짜(date)까지 같이 저장!
        saveLog(username, "교통", type, km, carbon, date);
        return carbon;
    }

    // 3.  식사 (전체 코드)
    public double calculateFood(String username, String type, double servings, String date) {
        double factor = 0;
        if (type.equals("소고기")) factor = 27.0;
        else if (type.equals("돼지고기")) factor = 6.9;
        else if (type.equals("닭고기")) factor = 6.9;
        else factor = 2.0;

        // 1인분(0.2kg) 환산 계산
        double carbon = servings * 0.2 * factor;

        // 날짜(date)까지 같이 저장!
        saveLog(username, "식사", type, servings, carbon, date);
        return carbon;
    }


    //  저장 함수 (이미 고치신 부분)
    private void saveLog(String username, String category, String type, double input, double carbon) {
        double rounded = Math.round(carbon * 100) / 100.0;
        CarbonLog log = new CarbonLog(category, type, input, rounded, username);
        carbonLogRepository.save(log);
    }

    //  조회 함수
    public List<CarbonLog> getLogsByUsername(String username) {
        return carbonLogRepository.findByUsername(username);
    }

    //  데이터 전체 삭제
    public void deleteAllLogs() {
        carbonLogRepository.deleteAll();
    }


    private void saveLog(String username, String category, String type, double input, double carbon, String date) {
        double rounded = Math.round(carbon * 100) / 100.0;

        // 1. 기본 정보로 장부 만들기
        CarbonLog log = new CarbonLog(category, type, input, rounded, username);

        // 2. 날짜 지정
        if (date != null && !date.isEmpty() && !date.equals("null")) {
            try {
                java.time.LocalDate localDate = java.time.LocalDate.parse(date);
                log.setCreatedAt(localDate.atStartOfDay());
            } catch (Exception e) {
                System.out.println("날짜 변환 실패: " + e.getMessage());
            }
        }

        carbonLogRepository.save(log);
    }
}