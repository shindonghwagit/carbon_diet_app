package com.example.carbon_backend.controller;

import com.example.carbon_backend.service.NewsService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.List;
import java.util.Map;


@RestController
@RequiredArgsConstructor
public class NewsController {

    private final NewsService newsService;

    @GetMapping("/api/news")
    public List<Map<String, String>> getNews() {
        return newsService.getRandomNews();
    }
}