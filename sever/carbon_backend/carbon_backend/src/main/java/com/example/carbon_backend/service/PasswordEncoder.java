package com.example.carbon_backend.service;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class PasswordEncoder {

    // 비밀번호를 넣으면 -> 알 수 없는 문자열로 바꿔주는 함수
    public static String encrypt(String text) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            md.update(text.getBytes());
            return bytesToHex(md.digest());
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("암호화 알고리즘을 찾을 수 없습니다.", e);
        }
    }

    // (내부용) 바이트를 16진수 문자열로 변환
    private static String bytesToHex(byte[] bytes) {
        StringBuilder builder = new StringBuilder();
        for (byte b : bytes) {
            builder.append(String.format("%02x", b));
        }
        return builder.toString();
    }
}