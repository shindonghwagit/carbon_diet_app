package com.example.carbon_backend.controller;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.parser.Parser;
import org.jsoup.select.Elements;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;

@RestController
@RequestMapping("/api/news")
public class NewsController {

    // 썸네일이 없을 때 보여줄 예쁜 환경 이미지들 (랜덤 사용)
    private final String[] DEFAULT_IMAGES = {
            "https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=400&q=80", // 1. 맑은 숲
            "https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=400&q=80", // 2. 안개 낀 자연
            "https://images.unsplash.com/photo-1497436072909-60f360e1d4b0?w=400&q=80", // 3. 웅장한 산
            "https://images.unsplash.com/photo-1501854140884-074cf2b2b3f9?w=400&q=80", // 4. 푸른 바다
            "https://images.unsplash.com/photo-1466611653911-95081537e5b7?w=400&q=80", // 5. 풍력 발전기
            "https://images.unsplash.com/photo-1509391366360-2e959784a276?w=400&q=80", // 6. 태양광 패널
            "https://images.unsplash.com/photo-1532996122724-e3c354a0b15b?w=400&q=80", // 7. 분리수거/재활용
            "https://images.unsplash.com/photo-1589149098258-3e9102cd63d3?w=400&q=80", // 8. 북극곰 (빙하)
            "https://images.unsplash.com/photo-1611273426761-53c8577a3c97?w=400&q=80", // 9. 플라스틱 쓰레기 줄이기
            "https://images.unsplash.com/photo-1544979590-37e9b47cd705?w=400&q=80", // 10. 나무 심기 (새싹)
            "https://images.unsplash.com/photo-1418065460487-3e41a6c84dc5?w=400&q=80", // 11. 울창한 나무 숲
            "https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=400&q=80"  // 12. 들판과 노을
    };

    @GetMapping
    public List<Map<String, String>> getEcoNews() {
        List<Map<String, String>> newsList = new ArrayList<>();

        try {
            // 1. 구글 뉴스 RSS 주소 (검색어: 탄소중립, 환경보호)
            String query = URLEncoder.encode("탄소중립 환경보호", StandardCharsets.UTF_8);
            String url = "https://news.google.com/rss/search?q=" + query + "&hl=ko&gl=KR&ceid=KR:ko";

            // 2. RSS 데이터 가져오기 (XML 파싱)
            Document doc = Jsoup.connect(url)
                    .userAgent("Mozilla/5.0")
                    .parser(Parser.xmlParser())
                    .timeout(5000)
                    .get();

            // 3. 기사 목록 뽑기 (<item> 태그)
            Elements items = doc.select("item");
            Random random = new Random();

            int count = 0;
            for (Element item : items) {
                if (count >= 10) break; // 10개만

                Map<String, String> news = new HashMap<>();

                String title = item.select("title").text();
                String link = item.select("link").text();
                String pubDate = item.select("pubDate").text();

                // 구글 RSS는 출처가 제목 뒤에 "- 언론사명" 으로 붙어있음
                String source = "구글 뉴스";
                if (title.contains("-")) {
                    String[] parts = title.split("-");
                    source = parts[parts.length - 1].trim(); // 맨 뒤가 언론사
                }

                // 이미지: RSS는 썸네일을 안 줍니다. 그래서 우리가 준비한 예쁜 이미지를 랜덤으로 넣어줍니다.
                // (앱이 훨씬 깔끔해 보입니다)
                String image = DEFAULT_IMAGES[random.nextInt(DEFAULT_IMAGES.length)];

                news.put("title", title);
                news.put("link", link);
                news.put("image", image);
                news.put("source", source);
                news.put("desc", pubDate); // 날짜를 설명 대신 넣음

                newsList.add(news);
                count++;
            }

        } catch (Exception e) {
            e.printStackTrace();
            System.out.println("뉴스 가져오기 실패: " + e.getMessage());
        }

        return newsList;
    }
}