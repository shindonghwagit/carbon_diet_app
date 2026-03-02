# 🌿 탄소 다이어트 앱

> 일상생활(식사, 교통, 전기)에서 발생하는 탄소 배출량을 기록하고 관리하는 모바일 앱입니다.
>
> 핵심 기능 : `탄소 배출량 계산`, `주간 통계 시각화`, `환경 뉴스`

---

## ⏲️ 개발 기간

- 2025.05 ~ 2025.06

---

## 🙂 시작 가이드

### Backend 실행
```bash
# PostgreSQL 실행 후 application.properties에 DB 정보 설정
cd backend
./gradlew bootRun
```

### Frontend 실행
```bash
cd frontend
flutter pub get
flutter run
```

> Android 에뮬레이터 사용 시 백엔드 주소는 `http://10.0.2.2:8080`

---

## 🛠️ 사용 기술

| 구분 | 기술 |
|------|------|
| Frontend | Flutter (Dart) |
| Backend | Spring Boot (Java) |
| Database | PostgreSQL |
| ORM | Spring Data JPA |

### 주요 패키지

**Flutter**
- `http` — REST API 통신
- `table_calendar` — 달력 UI
- `shared_preferences` — 로그인 세션 로컬 저장
- `lottie` — 애니메이션
- `google_fonts`, `url_launcher`, `intl`

---

## 🎥 화면 구성

| 스플래시 / 로그인 | 홈 (탄소 입력) |
|:---:|:---:|
| | |

| 통계 화면 | 환경 뉴스 |
|:---:|:---:|
| | |

---

## 📁 디렉토리 구조

```
📦carbon_diet_app
 ┣ 📂backend
 ┃ ┗ 📂src/main/java/com/example/carbon_backend
 ┃   ┣ 📂controller
 ┃   ┃ ┣ 📜CarbonController.java
 ┃   ┃ ┗ 📜MemberController.java
 ┃   ┣ 📂domain
 ┃   ┃ ┣ 📜CarbonLog.java
 ┃   ┃ ┣ 📜Member.java
 ┃   ┃ ┗ 📜UsageResult.java
 ┃   ┣ 📂repository
 ┃   ┃ ┣ 📜CarbonLogRepository.java
 ┃   ┃ ┣ 📜MemberRepository.java
 ┃   ┃ ┗ 📜UsageRepository.java
 ┃   ┗ 📂service
 ┃     ┣ 📜CarbonService.java
 ┃     ┣ 📜MemberService.java
 ┃     ┗ 📜PasswordEncoder.java
 ┗ 📂frontend
   ┗ 📂lib
     ┗ 📜main.dart
```

---

## 🚩 커밋 컨벤션

| 커밋 유형 | 의미 |
|---------|------|
| `feat` | 기능 추가 |
| `fix` | 버그 수정 |
| `style` | 코드 포맷팅, UI 수정 |
| `refactor` | 코드 리팩토링 |
| `chore` | 패키지 설정, .gitignore 등 |
| `docs` | README 등 문서 수정 |
| `init` | 프로젝트 초기 설정 |

---

## ✔️ 주요 기능

### `탄소 배출량 기록`

- **전기**, **교통(버스/지하철/자가용 등)**, **식사(육류/채식 등)** 3가지 카테고리로 탄소 배출량을 계산하고 저장합니다.
- 회원별로 데이터가 분리되어 개인 기록만 조회할 수 있습니다.

### `주간 통계 시각화`

- 주간 탄소 배출 패턴을 **그래프**로 시각화하여 한눈에 확인할 수 있습니다.
- 달력 기반 날짜 선택으로 특정 일자의 기록을 조회할 수 있습니다.

| 주간 통계 그래프 |
|:---:|
| |

### `회원 인증`

- 아이디/비밀번호 기반 **회원가입 및 로그인** 기능을 제공합니다.
- 로그인 상태는 `SharedPreferences`로 유지됩니다.

### `환경 뉴스 & 매거진`

- 환경 관련 뉴스와 정보를 제공합니다.
- 외부 링크 연동으로 상세 기사로 이동할 수 있습니다.

---

## 🔌 API 명세

| Method | Endpoint | 설명 |
|--------|----------|------|
| `POST` | `/api/register` | 회원가입 |
| `POST` | `/api/login` | 로그인 |
| `GET` | `/api/elec` | 전기 사용량 탄소 계산 및 저장 |
| `GET` | `/api/trans` | 교통 탄소 계산 및 저장 |
| `GET` | `/api/food` | 식사 탄소 계산 및 저장 |
| `GET` | `/api/logs` | 사용자별 기록 전체 조회 |
| `DELETE` | `/api/reset` | 전체 데이터 초기화 |
