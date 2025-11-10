# Quest ON 리팩토링 계획

## 1. 앱 컨셉 변경

### 기존
- **이름**: Quest ON - 컨디션 기반 퀘스트 관리 앱
- **핵심**: 컨디션에 따른 목표 자동 조정
- **온보딩**: 간단한 프로필 설정

### 변경 후
- **이름**: Quest ON - 오늘의 나보다 나은 내일
- **핵심**: 비전/꿈/목표 설정 + AI 코칭 + 게이미피케이션
- **온보딩**: 상담가 스타일의 대화형 비전 설정

---

## 2. 핵심 플로우

```
1. 회원가입 (소셜 로그인)
   ↓
2. 대화형 비전 질문 (9개 질문)
   - 가치관
   - 현재 정체성
   - N년 후 정체성
   - 인생의 꿈
   - 현재 가장 큰 고민
   - N년 후 목표
   - 설정할 루틴
   - 선호 학습 방식
   - 동기부여 요소
   ↓
3. AI 비전 노트 생성 (30초)
   - OpenAI GPT-4o-mini 사용
   - 사용자 응답 분석
   - 맞춤형 비전 문서 생성
   ↓
4. 비전 확정 → 목표 트리 자동 생성
   - 장기 목표 (1-3년)
   - 중기 목표 (3-6개월)
   - 단기 목표 (1개월)
   - 주간 목표
   ↓
5. 일일 퀘스트 자동 추천
   - 목표 트리 기반
   - AI가 우선순위 제안
   - 사용자 맞춤 난이도
   ↓
6. 매일 퀘스트 완료 → 레벨업
   - 기존 게이미피케이션 유지
   - 경험치, 골드, 악세서리
   ↓
7. 주간/월간 회고 → AI 코칭
   - 달성률 분석
   - 개선점 제안
   - 동기부여 메시지
```

---

## 3. 데이터 모델 변경

### 3-1. 새로 추가할 모델

#### Vision (비전 노트)
```dart
class Vision {
  final String id;
  final String userId;
  final Map<String, String> answers;  // 9개 질문의 답변
  final String visionNote;            // AI 생성 비전 문서
  final DateTime createdAt;
  final DateTime? updatedAt;
}
```

#### GoalTree (목표 트리)
```dart
class GoalTree {
  final String id;
  final String userId;
  final String visionId;
  final List<Goal> longTermGoals;    // 1-3년 목표
  final List<Goal> midTermGoals;     // 3-6개월 목표
  final List<Goal> shortTermGoals;   // 1개월 목표
  final DateTime createdAt;
  final DateTime? updatedAt;
}

class Goal {
  final String id;
  final String title;
  final String description;
  final GoalTimeframe timeframe;
  final String? parentGoalId;        // 상위 목표 연결
  final bool isCompleted;
  final DateTime? completedAt;
}

enum GoalTimeframe {
  longTerm,   // 1-3년
  midTerm,    // 3-6개월
  shortTerm,  // 1개월
  weekly,     // 1주일
}
```

#### Reflection (회고)
```dart
class Reflection {
  final String id;
  final String userId;
  final ReflectionType type;          // weekly, monthly
  final DateTime startDate;
  final DateTime endDate;
  final int totalQuests;
  final int completedQuests;
  final double achievementRate;
  final String userThoughts;          // 사용자 회고 내용
  final String? aiCoachingMessage;    // AI 코칭 메시지
  final DateTime createdAt;
}

enum ReflectionType {
  weekly,
  monthly,
}
```

### 3-2. 수정할 모델

#### Quest
```dart
// 기존 유지하되 필드 추가
class Quest {
  // ... 기존 필드 유지
  final String? goalId;               // 목표 트리와 연결
  final bool isAiRecommended;         // AI 추천 퀘스트 여부
  final int aiPriority;               // AI 추천 우선순위 (1-10)
}
```

### 3-3. 제거할 모델/필드

- ❌ Condition 관련 모든 코드
- ❌ Quest의 conditionMultiplier 필드
- ❌ 컨디션 기반 목표 조정 로직

---

## 4. AI 통합 (OpenAI GPT-4o-mini)

### 4-1. 패키지 추가

```yaml
dependencies:
  dio: ^5.4.0                    # 이미 있음
  dart_openai: ^5.1.0            # 추가 필요
```

### 4-2. OpenAI Service 구조

```dart
class OpenAIService {
  final Dio _dio;
  final String _apiKey;

  // 1. 비전 노트 생성
  Future<String> generateVisionNote(Map<String, String> answers);

  // 2. 목표 트리 생성
  Future<GoalTree> generateGoalTree(String visionNote);

  // 3. 일일 퀘스트 추천
  Future<List<QuestSuggestion>> recommendDailyQuests({
    required GoalTree goalTree,
    required List<Quest> recentQuests,
    required int userLevel,
  });

  // 4. 회고 코칭 메시지 생성
  Future<String> generateCoachingMessage({
    required Reflection reflection,
    required String visionNote,
  });
}
```

### 4-3. API 호출 예시

#### 비전 노트 생성 프롬프트
```
당신은 전문 라이프 코치입니다. 사용자의 다음 답변을 바탕으로 맞춤형 비전 노트를 작성해주세요.

답변:
1. 가치관: {answer1}
2. 현재 정체성: {answer2}
3. 3년 후 정체성: {answer3}
4. 인생의 꿈: {answer4}
5. 현재 가장 큰 고민: {answer5}
6. 3년 후 목표: {answer6}
7. 설정할 루틴: {answer7}
8. 선호 학습 방식: {answer8}
9. 동기부여 요소: {answer9}

다음 형식으로 비전 노트를 작성해주세요:
1. 핵심 가치 (3가지)
2. 현재 상태 분석
3. 3년 후 비전
4. 실행 전략
5. 성장 포인트

한국어로 작성, 500-700자 분량
```

---

## 5. UI/UX 변경

### 5-1. 온보딩 화면 (신규)

**대화형 질문 UI**
```
┌─────────────────────────────┐
│  상담가 아바타 💬            │
│                             │
│  "안녕하세요! 함께 당신의    │
│   비전을 그려볼까요?"        │
│                             │
│  [1/9] 당신이 가장 중요하게  │
│  생각하는 가치는 무엇인가요?  │
│                             │
│  ┌───────────────────────┐  │
│  │                       │  │
│  │  자유로운 답변 입력...  │
│  │                       │  │
│  └───────────────────────┘  │
│                             │
│            [다음 →]          │
└─────────────────────────────┘
```

**AI 비전 노트 생성 중**
```
┌─────────────────────────────┐
│                             │
│      ✨ 비전 분석 중... ✨   │
│                             │
│     [████████░░░░] 75%      │
│                             │
│  당신만의 비전 노트를         │
│  작성하고 있습니다...         │
│                             │
│  예상 시간: 10초             │
└─────────────────────────────┘
```

**비전 노트 확인**
```
┌─────────────────────────────┐
│  📝 나의 비전 노트           │
│                             │
│  ━━━━━━━━━━━━━━━━━━━━━━━━  │
│                             │
│  💎 핵심 가치                │
│  • 자유                      │
│  • 성장                      │
│  • 기여                      │
│                             │
│  📊 현재 상태 분석           │
│  {AI 생성 내용}             │
│                             │
│  🎯 3년 후 비전              │
│  {AI 생성 내용}             │
│                             │
│  [수정하기] [확정하기]       │
└─────────────────────────────┘
```

### 5-2. 목표 트리 화면 (신규)

```
┌─────────────────────────────┐
│  🌳 나의 목표 트리           │
│                             │
│  장기 (1-3년)               │
│  ┌─────────────────────┐   │
│  │ 🎯 개발자로 성장하기 │   │
│  └─────────────────────┘   │
│           │                 │
│  중기 (3-6개월)             │
│  ┌─────────────────────┐   │
│  │ Flutter 마스터하기   │   │
│  └─────────────────────┘   │
│           │                 │
│  단기 (1개월)               │
│  ┌─────────────────────┐   │
│  │ 위젯 100개 만들기    │   │
│  └─────────────────────┘   │
│                             │
│  [목표 추가] [AI 재분석]     │
└─────────────────────────────┘
```

### 5-3. 퀘스트 화면 (수정)

**AI 추천 퀘스트 섹션 추가**
```
┌─────────────────────────────┐
│  ✨ AI 추천 퀘스트           │
│  당신의 목표에 최적화된       │
│  오늘의 퀘스트입니다          │
│                             │
│  🔥 우선순위 높음            │
│  ┌─────────────────────┐   │
│  │ Flutter 위젯 3개     │   │
│  │ 만들기               │   │
│  │ 💎 50 EXP  🏅 우선   │   │
│  └─────────────────────┘   │
│                             │
│  [수락] [다른 추천 보기]     │
│                             │
│  📋 내 퀘스트               │
│  {기존 퀘스트 목록}          │
└─────────────────────────────┘
```

### 5-4. 회고 화면 (신규)

```
┌─────────────────────────────┐
│  📊 이번 주 회고             │
│                             │
│  달성률: 85% (17/20)        │
│  [████████████░░░░]         │
│                             │
│  💪 잘한 점                  │
│  • 매일 꾸준히 실천          │
│  • 어려운 퀘스트 도전         │
│                             │
│  🤔 개선할 점                │
│  ┌───────────────────────┐  │
│  │ 자유롭게 작성...       │  │
│  └───────────────────────┘  │
│                             │
│  [AI 코칭 받기]             │
│                             │
│  ━━━━━━━━━━━━━━━━━━━━━━━━  │
│                             │
│  🤖 AI 코치의 한마디         │
│  {AI 생성 코칭 메시지}       │
└─────────────────────────────┘
```

### 5-5. 제거할 화면

- ❌ 컨디션 설정 화면
- ❌ 컨디션 기반 목표 조정 UI
- ❌ 기존 온보딩 프로필 설정

---

## 6. 구현 단계

### Phase 1: 환경 설정 및 데이터 모델 (1-2일)
- [ ] OpenAI API 패키지 추가
- [ ] 환경 변수 설정 (.env)
- [ ] Vision, GoalTree, Reflection 모델 생성
- [ ] Drift 데이터베이스 스키마 업데이트
- [ ] Supabase 테이블 설계

### Phase 2: OpenAI 서비스 구현 (2-3일)
- [ ] OpenAIService 클래스 생성
- [ ] 비전 노트 생성 API
- [ ] 목표 트리 생성 API
- [ ] 퀘스트 추천 API
- [ ] 코칭 메시지 API
- [ ] 에러 핸들링 및 재시도 로직

### Phase 3: 대화형 온보딩 UI (2-3일)
- [ ] 9개 질문 화면 구현
- [ ] 애니메이션 효과 추가
- [ ] 진행률 표시
- [ ] AI 비전 노트 생성 로딩 화면
- [ ] 비전 노트 확인/수정 화면

### Phase 4: 목표 트리 시스템 (2-3일)
- [ ] 목표 트리 데이터 모델
- [ ] 목표 트리 시각화 UI
- [ ] 목표 추가/수정/삭제 기능
- [ ] 목표와 퀘스트 연결 로직

### Phase 5: AI 퀘스트 추천 (1-2일)
- [ ] 기존 퀘스트 화면 수정
- [ ] AI 추천 섹션 추가
- [ ] 추천 수락/거부 기능
- [ ] 추천 이유 표시

### Phase 6: 회고 및 코칭 (2-3일)
- [ ] 주간/월간 회고 화면
- [ ] 회고 작성 UI
- [ ] AI 코칭 메시지 생성
- [ ] 회고 히스토리 관리

### Phase 7: 컨디션 제거 및 정리 (1일)
- [ ] Condition 관련 코드 제거
- [ ] Quest 모델 정리
- [ ] 불필요한 화면 제거
- [ ] 코드 정리 및 리팩토링

### Phase 8: 테스트 및 최적화 (2-3일)
- [ ] 전체 플로우 테스트
- [ ] OpenAI API 비용 최적화
- [ ] 오프라인 모드 처리
- [ ] 에러 케이스 처리
- [ ] 성능 최적화

---

## 7. OpenAI API 비용 예측

### GPT-4o-mini 가격
- Input: $0.150 / 1M tokens
- Output: $0.600 / 1M tokens

### 예상 토큰 사용량
1. **비전 노트 생성**: ~1,500 tokens (input) + ~800 tokens (output) = 2,300 tokens
   - 비용: $0.00069/회
2. **목표 트리 생성**: ~1,000 tokens (input) + ~500 tokens (output) = 1,500 tokens
   - 비용: $0.00045/회
3. **일일 퀘스트 추천**: ~800 tokens (input) + ~300 tokens (output) = 1,100 tokens
   - 비용: $0.00030/회
4. **코칭 메시지**: ~600 tokens (input) + ~400 tokens (output) = 1,000 tokens
   - 비용: $0.00030/회

### 월간 예상 비용 (사용자당)
- 비전 노트: 1회 = $0.00069
- 목표 트리: 2회 = $0.00090
- 일일 퀘스트: 30회 = $0.00900
- 코칭: 5회 = $0.00150
- **총 월간**: ~$0.012 (약 16원)

### 1,000명 사용자 기준
- 월간 비용: ~$12 (약 16,000원)
- 연간 비용: ~$144 (약 192,000원)

---

## 8. 환경 변수 설정

`.env` 파일 생성:
```env
# OpenAI
OPENAI_API_KEY=sk-...

# Supabase (기존)
SUPABASE_URL=https://...
SUPABASE_ANON_KEY=...

# Firebase (기존)
FIREBASE_API_KEY=...
```

---

## 9. 주요 기술 스택

### 기존 유지
- Flutter 3.38.0
- Riverpod (상태관리)
- Supabase (백엔드)
- Drift (로컬 DB)
- Firebase Analytics
- Google Mobile Ads
- In-App Purchase

### 신규 추가
- **dart_openai**: OpenAI API 통합
- **flutter_dotenv**: 환경 변수 관리

---

## 10. 마이그레이션 전략

### 기존 사용자 데이터 처리
1. 기존 퀘스트 데이터는 유지
2. 컨디션 데이터는 삭제
3. 업데이트 시 온보딩 다시 진행 (비전 설정)
4. 기존 레벨/경험치/골드 유지

### 앱 버전 관리
- 현재: v1.0.0
- 리팩토링 후: v2.0.0 (Major version up)

---

## 11. 리스크 관리

### 주요 리스크
1. **OpenAI API 비용 증가**: 사용량 모니터링 및 제한 설정
2. **API 응답 시간**: 로딩 상태 UI로 사용자 경험 개선
3. **API 장애**: 오프라인 모드 및 재시도 로직
4. **사용자 혼란**: 명확한 가이드 및 튜토리얼

### 대응 방안
- OpenAI API 사용량 알림 설정
- 캐싱 전략으로 중복 호출 방지
- 오프라인에서도 기본 기능 동작
- 업데이트 노트에 변경사항 명확히 안내

---

## 12. 체크리스트

### 시작 전
- [ ] OpenAI API 키 발급
- [ ] 개발 환경 백업
- [ ] 새 브랜치 생성 (feature/v2-refactoring)

### 구현 중
- [ ] 각 Phase별 테스트 완료
- [ ] 코드 리뷰
- [ ] 문서화

### 완료 후
- [ ] 전체 통합 테스트
- [ ] 베타 테스터 피드백
- [ ] Play Store 업데이트 준비

---

**작성일**: 2025-11-10
**목표 완료일**: 2025-11-24 (2주)
**담당**: Claude + 사용자
