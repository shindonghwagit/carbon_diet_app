package com.example.carbon_backend.service;

import org.jsoup.Jsoup;
import org.springframework.http.*;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
public class NewsService {

    @Value("${oauth.client-id}")
    private String clientId;

    @Value("${oauth.client-secret}")
    private String clientSecret;


    private List<Map<String, String>> cachedNews = new ArrayList<>(); // 뉴스를 저장해둘 공간

    // 1시간마다 자동으로 실행됨 (3600000ms = 1시간)
    @Scheduled(fixedRate = 3600000)
    public void fetchNewsFromNaver() {
        System.out.println("뉴스 갱신 시작...");
        String query = "탄소중립"; // 검색어 (환경, 제로웨이스트 등으로 변경 가능)
        String apiUrl = "https://openapi.naver.com/v1/search/news.json?query=" + query + "&display=50&sort=sim";

        RestTemplate restTemplate = new RestTemplate();
        HttpHeaders headers = new HttpHeaders();
        headers.set("X-Naver-Client-Id", clientId);
        headers.set("X-Naver-Client-Secret", clientSecret);

        HttpEntity<String> entity = new HttpEntity<>(headers);

        try {
            ResponseEntity<Map> response = restTemplate.exchange(apiUrl, HttpMethod.GET, entity, Map.class);
            List<Map<String, Object>> items = (List<Map<String, Object>>) response.getBody().get("items");

            List<Map<String, String>> newNewsList = new ArrayList<>();
            for (Map<String, Object> item : items) {
                Map<String, String> news = new HashMap<>();
                String title = Jsoup.parse((String) item.get("title")).text();
                String desc = Jsoup.parse((String) item.get("description")).text();

                news.put("title", title);
                news.put("link", (String) item.get("link"));
                news.put("date", (String) item.get("pubDate"));
                newNewsList.add(news);
            }
            this.cachedNews = newNewsList; // 저장소 업데이트
            System.out.println("뉴스 갱신 완료! 총 " + cachedNews.size() + "개");

        } catch (Exception e) {
            System.out.println("뉴스 가져오기 실패: " + e.getMessage());
        }
    }

    // 앱에 보낼 때는 랜덤으로 5개만 뽑아서 줌
    public List<Map<String, String>> getRandomNews() {
        if (cachedNews.isEmpty()) {
            fetchNewsFromNaver();
        }

        List<Map<String, String>> shuffled = new ArrayList<>(cachedNews);
        Collections.shuffle(shuffled);

        // 5개만 잘라서 리턴
        return shuffled.subList(0, Math.min(5, shuffled.size()));
    }
}