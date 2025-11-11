# Quest ON 🎮

> **AI가 설계하는 나만의 성장 여정**
> "오늘 컨디션이 최악이어도, 당신은 성장할 수 있습니다"

[![Flutter](https://img.shields.io/badge/Flutter-3.38.0-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Analytics-FFCA28?logo=firebase)](https://firebase.google.com)
[![OpenAI](https://img.shields.io/badge/OpenAI-GPT--3.5-412991?logo=openai)](https://openai.com)
[![License](https://img.shields.io/badge/License-Proprietary-red)](LICENSE)

---

## 🌟 What is Quest ON?

**Quest ON**은 행동과학(Tiny Habits, Atomic Habits)과 AI를 결합한 차세대 목표 달성 앱입니다.

### 핵심 차별점
- 🤖 **AI 행동과학 코치**: OpenAI 기반 개인화 퀘스트 자동 생성
- 📊 **적응형 목표 시스템**: 컨디션에 따라 난이도 자동 조정
- 🎮 **게이미피케이션**: 경험치, 레벨업, 업적으로 지속 동기 부여
- 🎯 **비전 기반 온보딩**: 6가지 질문으로 인생 로드맵 자동 설계

---

## 🚀 Key Features

### ✅ 이미 구현된 기능

#### 1. AI 퀘스트 추천
- OpenAI GPT-3.5 Turbo 연동
- Tiny Habits/Atomic Habits 이론 기반 프롬프트
- 실시간 캐싱으로 API 비용 90% 절감
- 컨디션별 맞춤 퀘스트 (쉬움/보통/어려움/매우 어려움)

```dart
// 예시: 컨디션 최악 → "2분 규칙" 적용
오늘 컨디션: 최악 😫
AI 추천: "책상 위에 노트북 펴놓기" (Easy, 10 EXP)
→ 2분 완료 → 연속 기록 유지 ✅
```

#### 2. 경험치 & 레벨 시스템
- 난이도별 차등 보상 (10/20/30/50 EXP)
- 레벨 1→100 성장 시스템
- 퀘스트 히스토리 대시보드

#### 3. 비전/목표 온보딩
- 6단계 질문 기반 비전 수립
- AI 자동 목표 로드맵 생성
- 주차별 실행 계획 제시

#### 4. 프로필 & 커스터마이징
- 닉네임 + 캐릭터(12종) 선택
- 업적 시스템 (Coming Soon)

#### 5. 수익화 인프라
- Google AdMob 광고 연동 (배너/전면/리워드)
- In-App Purchase (Plus/Pro 구독)
- Firebase Analytics 이벤트 로깅

---

## 🛠 Tech Stack

### Frontend
- **Framework**: Flutter 3.38.0 (Dart 3.6.1)
- **State Management**: Riverpod
- **UI**: Material Design 3

### Backend
- **Database**: Supabase (PostgreSQL)
- **Edge Functions**: Deno (TypeScript)
- **AI**: OpenAI GPT-3.5 Turbo API

### Infrastructure
- **Analytics**: Firebase Analytics (GA4)
- **Ads**: Google AdMob
- **Payments**: Google Play Billing
- **Auth**: Supabase Auth (Google OAuth)

### Architecture
```
lib/
├── core/              # 상수, 테마, 유틸
├── data/              # 데이터 소스, 레포지토리 구현
│   ├── datasources/   # Remote/Local 데이터 소스
│   ├── models/        # JSON 직렬화 모델
│   ├── repositories/  # 레포지토리 구현체
│   └── services/      # AI, 광고, 분석 서비스
├── domain/            # 비즈니스 로직 (Clean Architecture)
│   ├── entities/      # 엔티티 (Quest, UserStats 등)
│   └── repositories/  # 레포지토리 인터페이스
└── presentation/      # UI 레이어
    ├── providers/     # Riverpod 상태 관리
    ├── screens/       # 화면 컴포넌트
    └── widgets/       # 재사용 위젯
```

---

## 🎯 Quick Start

### Prerequisites
- Flutter SDK 3.38.0+
- Dart SDK 3.6.1+
- Android Studio / Xcode
- Supabase Account
- OpenAI API Key

### Installation

```bash
# 1. 저장소 클론
git clone https://github.com/yourusername/quest-on.git
cd quest-on

# 2. 의존성 설치
flutter pub get

# 3. 환경변수 설정 (.env 파일 생성)
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
OPENAI_API_KEY=your_openai_api_key

# 4. Android 실행
flutter run -d <device_id>
```

### Supabase 설정

```bash
# Edge Function 배포
cd supabase/functions
supabase functions deploy suggest-quests

# 데이터베이스 마이그레이션
supabase db push
```

---

## 📊 Business Model

### Freemium 구독 모델

| Plan | Price | Features |
|------|-------|----------|
| **Free** | $0 | 기본 퀘스트, AI 추천 3회/일, 광고 표시 |
| **Plus** | $4.99/월 | 광고 제거, AI 무제한, 고급 리포트 |
| **Pro** | $9.99/월 | Plus + GPT-4 코칭, 팀 협업 |

### 수익 예측 (1년차)
- **목표 DAU**: 50,000
- **구독 전환율**: 5% (Plus 3%, Pro 2%)
- **예상 MRR**: $24,925
- **연 매출**: $299,100

---

## 🏆 Competitive Advantage

| 기능 | Habitica | Todoist | Notion | **Quest ON** |
|------|----------|---------|--------|--------------|
| AI 퀘스트 추천 | ❌ | ❌ | ❌ | ✅ |
| 컨디션 적응형 | ❌ | ❌ | ❌ | ✅ |
| 행동과학 이론 | ❌ | ❌ | ❌ | ✅ (Tiny/Atomic Habits) |
| 게이미피케이션 | ✅ | ❌ | ❌ | ✅ |
| 러닝 커브 | 높음 | 낮음 | 매우 높음 | **매우 낮음** (3분 온보딩) |

---

## 📈 Roadmap

### Phase 1: MVP (완료 ✅)
- [x] AI 퀘스트 추천 시스템
- [x] 경험치 & 레벨 시스템
- [x] 비전 기반 온보딩
- [x] 광고 & 구독 연동
- [x] Firebase Analytics

### Phase 2: Growth (Q1 2026)
- [ ] iOS 버전 출시
- [ ] 친구 초대 바이럴 루프
- [ ] 업적 시스템 완성
- [ ] 위젯 (홈 화면 퀘스트 표시)
- [ ] 다크 모드

### Phase 3: Scale (Q2-Q4 2026)
- [ ] GPT-4 AI 코칭
- [ ] 팀 협업 기능 (B2B)
- [ ] 커뮤니티 퀘스트
- [ ] 다국어 지원 (영어/일본어)
- [ ] 음성 인터페이스

---

## 🤝 Contributing

현재 비공개 프로젝트이지만, 피드백은 환영합니다.

**문의:**
- Email: stophyuk94@gmail.com
- Issues: GitHub Issues 탭

---

## 📄 License

Proprietary - All Rights Reserved

Copyright (c) 2025 Quest ON Team

---

## 🌟 Why Quest ON?

> **"습관을 바꾸면 인생이 바뀝니다.
> 하지만 대부분은 시작조차 못합니다.
> Quest ON이 그 첫 걸음을 불가능에서 불가피로 만듭니다."**

### 문제
- 92%의 신년 목표가 1월에 포기됨
- 컨디션 나쁜 날 = 목표 포기 = 자괴감 = 악순환

### 솔루션
- AI가 컨디션별 최적 퀘스트 자동 생성
- "2분 규칙"으로 연속 기록 유지
- 66일 후 → 습관 완성 ✨

**Join us in revolutionizing personal growth!** 🚀

---

Made with ❤️ by Quest ON Team
