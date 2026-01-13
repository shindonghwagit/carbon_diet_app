package com.example.carbon_backend.controller;

import com.example.carbon_backend.domain.CarbonLog;
import com.example.carbon_backend.service.CarbonService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@CrossOrigin("*")
@RestController
@RequiredArgsConstructor

public class CarbonController {

    private final CarbonService carbonService;

    // 전기
    @GetMapping("/api/elec")
    public String electric(@RequestParam String username, @RequestParam int money, @RequestParam(required = false) String date) {
        double carbon = carbonService.calculateElectricity(username, money, date);
        return String.format("전기요금 %d원, 탄소 %.2fkg 배출!", money, carbon);
    }

    // 교통
    @GetMapping("/api/trans")
    public String transport(@RequestParam String username, @RequestParam String type, @RequestParam double km, @RequestParam(required = false) String date) {
        double carbon = carbonService.calculateTransport(username, type, km, date);
        return String.format("%s %.1fkm 이동, 탄소 %.2fkg 배출!", type, km, carbon);
    }

    //  식사
    @GetMapping("/api/food")
    public String food(@RequestParam String username, @RequestParam String type, @RequestParam double amount, @RequestParam(required = false) String date) {
        double carbon = carbonService.calculateFood(username, type, amount, date);
        return String.format("%s %.1f인분 식사, 탄소 %.2fkg 배출!", type, amount, carbon);
    }

    //  전체 기록 조회:
    @GetMapping("/api/logs")
    public List<CarbonLog> getLogs(@RequestParam String username) {
        return carbonService.getLogsByUsername(username);
    }
}