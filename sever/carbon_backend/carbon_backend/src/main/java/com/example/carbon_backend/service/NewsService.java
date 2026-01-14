package com.example.carbon_backend.service;

import org.jsoup.Jsoup;
import org.springframework.http.*;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.beans.factory.annotation.Value;

import java.util.*;

@Service
public class NewsService {

    @Value("${oauth.client-id}")
    private String clientId;

    @Value("${oauth.client-secret}")
    private String clientSecret;

    private final List<String> ecoImages = Arrays.asList(
            "https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=500&q=80",
            "https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=500&q=80",
            "https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=500&q=80",
            "https://images.unsplash.com/photo-1501854140884-074bf6b243e7?w=500&q=80",
            "https://images.unsplash.com/photo-1518173946687-a4c8892bbd9f?w=500&q=80",
            "https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=500&q=80",
            "https://images.unsplash.com/photo-1500829243541-74b677fecc30?w=500&q=80",
            "https://images.unsplash.com/photo-1466611653911-95081537e5b7?w=500&q=80",
            "https://images.unsplash.com/photo-1596394516093-501ba68a0ba6?w=500&q=80",
            "https://images.unsplash.com/photo-1511497584788-876760111969?w=500&q=80"
    );

    private List<Map<String, String>> cachedNews = new ArrayList<>();

    @Scheduled(fixedRate = 3600000)
    public void fetchNewsFromNaver() {
        System.out.println("뉴스 갱신 시작...");
        String query = "탄소중립"; // 검색어
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
            Random random = new Random(); // 랜덤 객체 생성

            for (Map<String, Object> item : items) {
                Map<String, String> news = new HashMap<>();

                String title = Jsoup.parse((String) item.get("title")).text();
                String desc = "";
                if (item.get("description") != null) {
                    desc = Jsoup.parse((String) item.get("description")).text();
                }

                news.put("title", title);
                news.put("link", (String) item.get("link"));
                news.put("date", (String) item.get("pubDate"));

                String randomImg = ecoImages.get(random.nextInt(ecoImages.size()));
                news.put("image", randomImg);      // 프론트엔드에서 보여줄 이미지
                news.put("source", "네이버 뉴스");   // 출처 표기

                newNewsList.add(news);
            }
            this.cachedNews = newNewsList;
            System.out.println("뉴스 갱신 완료! 총 " + cachedNews.size() + "개");

        } catch (Exception e) {
            System.out.println("뉴스 가져오기 실패: " + e.getMessage());
        }
    }

    public List<Map<String, String>> getRandomNews() {
        if (cachedNews.isEmpty()) {
            fetchNewsFromNaver();
        }

        List<Map<String, String>> shuffled = new ArrayList<>(cachedNews);
        Collections.shuffle(shuffled);

        return shuffled.subList(0, Math.min(5, shuffled.size()));
    }
}