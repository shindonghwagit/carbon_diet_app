탄소 다이어트 앱 (carbon_diet_app)

1. 프로젝트 개요

일상생활(식사, 교통, 전기)에서 발생하는 탄소 배출량을 기록하고 관리하는 모바일 애플리케이션

2. 개발 동기 및 목적

기후 변화에 대한 생각이 유튜브를 보면서 되게 심각하다고 생각해서 개인의 탄소 배출량 관리가 중요하다는 것을 느끼게 되었다. 사용자들이 쉽게 자신의 탄소 배출량을 관리할 수 있는 도구를 제공하여, 환경 보호에 대한 인식을 높이고 실천을 독려하는 것을 목표로 한다.

3. 사용 기술
- Frontend: Flutter
  
- Backend: Spring Boot
  
- Database: PostgreSQL


4. . 주요 기능

4.1 사용자 인증
- 로그인 및 회원가입 기능
- 로그인 시 아이디 저장 (자동 완성) 기능
- 비밀번호 해싱을 통한 보안 강화
- 아이디/비밀번호 찾기 기능

4.2 탄소 배출량 기록 및 계산
- 식사: 식단 유형에 따른 탄소 배출량 계산
- 교통: 이동 수단 및 거리 기반 배출량 계산
- 전기: 전력 사용량 기반 배출량 계산

4.3 통계 및 시각화
- 주간 배출 패턴 그래프
- 달력 뷰를 통한 일별 배출량 확인 및 관리

4.4 환경 정보 매거진
- 네이버 뉴스 크롤링을 통한 실시간 환경 뉴스 제공
- 10분 단위 자동 뉴스 갱신 시스템
- 탄소 중립 실천 방법 및 환경 보호 팁 공유

4.5 개인 설정
- 사용자 프로필 커스텀 수정
- 일일 탄소 배출 목표량 설정
- 계정 보안 관리 (아이디 변경, 비밀번호 변경, 회원 탈퇴)
- 알림 설정 및 도움말 제공

5. 화면 구성

5.1 로그인 화면
- 기존 사용자 로그인 및 아이디 저장 체크 기능
- 회원가입 및 아이디/비밀번호 찾기 페이지 연결
- 회원가입 화면
- 신규 사용자 정보 입력 (ID, PW, 이름, 이메일 등)
- 비밀번호 암호화 처리 후 DB 저장

5.2 홈 화면
- 오늘의 탄소 배출량 요약 및 목표 달성률 확인
- 주요 기능(기록, 통계, 뉴스) 바로가기

5.3 통계 화면
- 달력 형식으로 일별 배출량 표시 
- 날짜 선택 시 해당일의 상세 배출 내역 확인 및 삭제
- 더블 클릭으로 새로운 기록 추가 가능

5.4 기록 추가 화면
- 직관적인 아이콘을 통한 전기/교통/식사 카테고리 선택
- 각 카테고리별 상세 정보 입력 및 배출량 자동 계산

5.5 매거진 화면
- 실시간 크롤링된 환경 뉴스 리스트 
- 타이머를 통한 자동 목록 새로고침
- 기사 클릭 시 원문 웹페이지로 이동

5.6 설정 화면
- 프로필 카드: 현재 아바타 및 닉네임 확인/수정
- 목표 관리: 슬라이더를 이용한 하루 탄소 한도 설정
- 계정 관리: 아이디 변경, 비밀번호 변경 
- 일반: 도움말 확인, 로그아웃, 회원 탈퇴



## 📁 디렉토리 구조

### Frontend (Flutter)
```
📦lib
 ┣ 📂screens
 ┃ ┣ 📂auth
 ┃ ┃ ┣ 📜find_account_screen.dart
 ┃ ┃ ┣ 📜login_screen.dart
 ┃ ┃ ┗ 📜signup_screen.dart
 ┃ ┣ 📂main
 ┃ ┃ ┣ 📜home_screen.dart
 ┃ ┃ ┣ 📜news_screen.dart
 ┃ ┃ ┣ 📜setting_screen.dart
 ┃ ┃ ┗ 📜stat_screen.dart
 ┃ ┣ 📜main_screen.dart
 ┃ ┗ 📜splash_screen.dart
 ┣ 📂widgets
 ┃ ┗ 📂inputs
 ┃ ┃ ┣ 📜elec_input.dart
 ┃ ┃ ┣ 📜food_input.dart
 ┃ ┃ ┣ 📜record_bottom_sheets.dart
 ┃ ┃ ┗ 📜trains_input.dart
 ┗ 📜main.dart
```

## Backend
```
📦src/main/java/com/example/carbon_backend
 ┣ 📂controller
 ┃ ┣ 📜MemberController.java 
 ┃ ┗ 📜NewsController.java
 ┣ 📂service
 ┃ ┣ 📜MemberService.java
 ┃ ┗ 📜NewsService.java 
 ┣ 📂repository
 ┃ ┗ 📜MemberRepository.java
 ┗ 📂domain
   ┗ 📜Member.java
 ```
