# Quest ON Flutter - 누락된 기능 분석

## 📊 현재 상태

### ✅ 이미 구현된 기능 (Flutter)
1. 회원가입/로그인 (Supabase Auth)
2. 데이터베이스 연동 (profiles, quests, user_stats)
3. 기본 인증 시스템
4. 에러 메시지 처리

### ❌ 누락된 주요 기능 (원본 Vue 앱에 존재)

---

## 1. 온보딩 시스템

### 원본 기능 (OnboardingModal.vue)
- **Step 1**: 환영 메시지 + 캐릭터 선택
  - 4가지 캐릭터 중 선택 (이모지)
  - 각 캐릭터마다 고유한 이모지와 이름
- **Step 2**: 닉네임 설정
  - 2-10자 제한
  - 한글/영어/숫자만 허용
- **Step 3**: 추가 설정 (확인 필요)

### 현재 Flutter 상태
- ❌ 온보딩 없음
- ❌ 로그인 후 바로 빈 화면

---

## 2. 홈 화면 (Home.vue)

### 원본 기능
1. **헤더**
   - "Quest ON" 로고 (픽셀 폰트)
   - "통계 보기 →" 버튼
2. **PlayerCard 컴포넌트**
   - 캐릭터 표시
   - 레벨/경험치 바
   - 닉네임
3. **퀘스트 목록**
   - 완료/미완료 카운트
   - AI 퀘스트 추천 버튼 (🤖)
   - 체크박스로 완료 토글
   - 난이도 배지 (쉬움/보통/어려움)
   - XP 표시
   - 삭제 버튼
4. **빈 상태 UI**
   - "아직 퀘스트가 없어요" 메시지
5. **모달들**
   - QuestModal (퀘스트 추가)
   - LevelUpModal (레벨업 축하)
   - DailyQuestSuggester (AI 추천)

### 현재 Flutter 상태
- ❌ 홈 화면 없음
- ❌ 로그인 후 라우팅 설정 안 됨

---

## 3. 플레이어 카드 (PlayerCard.vue)

### 원본 기능
- 캐릭터 이모지 크게 표시
- 닉네임
- 레벨 (Lv.X)
- 경험치 바 (현재/필요)
- 그라디언트 배경

### 현재 Flutter 상태
- ❌ PlayerCard 없음
- ✅ user_stats 테이블은 존재 (레벨/경험치 저장 가능)

---

## 4. 비전 시스템 (Vision.vue)

### 원본 기능
1. **VisionSurveyModal**
   - 4단계 설문 (가치관, 목표, 이유 등)
   - 단계별 진행 바
2. **VisionNoteGenerator**
   - AI 코칭 노트 생성
   - OpenAI API 사용
3. **비전 노트 표시**
   - 생성된 코칭 메시지 읽기
   - 재생성 기능

### 현재 Flutter 상태
- ✅ profiles 테이블 존재 (vision_note 컬럼)
- ✅ generate-vision-note Edge Function 작성됨
- ❌ UI 없음
- ❌ 설문 화면 없음
- ❌ 비전 노트 표시 화면 없음

---

## 5. 로드맵 시스템 (Roadmap.vue)

### 원본 기능
1. **GoalTreeGenerator**
   - 목표 트리 생성
   - AI 기반 마일스톤 생성
2. **로드맵 시각화**
   - 3-5개 마일스톤 표시
   - 각 마일스톤별 세부 목표
   - 진행률 표시

### 현재 Flutter 상태
- ✅ profiles 테이블 존재 (goal_tree 컬럼)
- ✅ generate-goal-tree Edge Function 작성됨
- ❌ UI 없음
- ❌ 로드맵 화면 없음

---

## 6. 퀘스트 추가 모달 (QuestModal.vue)

### 원본 기능
- 제목 입력
- 난이도 선택 (쉬움/보통/어려움)
- XP 자동 계산
- 카테고리 선택 (선택사항)

### 현재 Flutter 상태
- ✅ quests 테이블 존재
- ❌ 퀘스트 추가 UI 없음
- ❌ QuestModal 없음

---

## 7. 플로팅 추가 버튼 (FloatingAddButton.vue)

### 원본 기능
- 우하단 고정 플로팅 버튼
- 클릭 시 QuestModal 열기
- 그라디언트 배경
- 호버 애니메이션

### 현재 Flutter 상태
- ❌ FloatingActionButton 없음

---

## 8. 하단 네비게이션 (BottomNavigation.vue)

### 원본 기능
- 5개 탭
  1. 홈 (🏠)
  2. 퀘스트 (⚔️)
  3. 비전 (✨)
  4. 로드맵 (🗺️)
  5. 프로필 (👤)
- 활성 탭 하이라이트
- 아이콘 + 라벨

### 현재 Flutter 상태
- ❌ BottomNavigationBar 없음
- ❌ 화면 간 라우팅 없음

---

## 9. 주간 회고 (WeeklyReflectionModal.vue)

### 원본 기능
- 주간 완료 퀘스트 요약
- 성취도 분석
- 다음 주 목표 설정

### 현재 Flutter 상태
- ❌ 주간 회고 기능 없음

---

## 10. AI 퀘스트 추천 (DailyQuestSuggester.vue)

### 원본 기능
- 목표 트리 기반 추천
- AI가 오늘의 퀘스트 제안
- 3-5개 추천 퀘스트
- 선택적으로 추가 가능

### 현재 Flutter 상태
- ❌ AI 추천 기능 없음

---

## 11. 레벨업 모달 (LevelUpModal.vue)

### 원본 기능
- 레벨업 축하 애니메이션
- 새 레벨 표시
- 보상 안내

### 현재 Flutter 상태
- ❌ LevelUpModal 없음
- ✅ user_stats 테이블은 존재

---

## 12. 프로필 화면 (Profile.vue)

### 원본 기능
- 통계 표시
  - 총 완료 퀘스트
  - 현재 레벨
  - 총 경험치
  - 연속 달성 일수
- 설정
  - 닉네임 변경
  - 캐릭터 변경
  - 로그아웃

### 현재 Flutter 상태
- ❌ 프로필 화면 없음

---

## 13. 퀘스트 화면 (Quests.vue)

### 원본 기능
- 전체 퀘스트 목록
- 필터링 (완료/미완료)
- 정렬 (날짜/난이도)
- 검색 기능

### 현재 Flutter 상태
- ❌ 퀘스트 전용 화면 없음

---

## 🎯 우선순위별 구현 계획

### Phase 5 (최우선): 핵심 UX
1. ✅ 온보딩 시스템
2. ✅ 홈 화면 + PlayerCard
3. ✅ 하단 네비게이션
4. ✅ 플로팅 추가 버튼
5. ✅ 퀘스트 추가 모달
6. ✅ 퀘스트 목록 표시 및 완료 토글

### Phase 6 (중요): 비전 시스템
7. ✅ 비전 설문 화면
8. ✅ 비전 노트 생성 (Edge Function 연동)
9. ✅ 비전 화면

### Phase 7 (중요): 로드맵 시스템
10. ✅ 로드맵 생성 (Edge Function 연동)
11. ✅ 로드맵 화면

### Phase 8 (추가 기능): 고급 기능
12. ✅ AI 퀘스트 추천
13. ✅ 레벨업 모달
14. ✅ 주간 회고
15. ✅ 프로필 화면

### Phase 9 (개선): UX 향상
16. ✅ 애니메이션 추가
17. ✅ 로딩 상태 표시
18. ✅ 에러 핸들링 강화

---

## 📝 중요 참고사항

### 디자인 시스템
- **폰트**:
  - 픽셀 폰트 (제목용)
  - Gmarket Sans (본문용)
- **색상**:
  - Primary: Purple (#8b5cf6)
  - Secondary: Blue (#3b82f6)
  - Success: Green (#10b981)
  - Neutral: Gray scale
- **그라디언트**: Purple → Blue

### 캐릭터 시스템
원본 Vue 앱에서 사용하는 캐릭터 이모지:
- 🐰 토끼
- 🐻 곰
- 🐱 고양이
- 🦊 여우

### API 연동
- Supabase Auth: ✅ 완료
- Supabase Database: ✅ 완료
- Edge Functions: ✅ 작성됨 (배포 필요)

---

**작성일**: 2025-11-06
**상태**: Flutter 마이그레이션 Phase 1-4 완료, Phase 5+ 대기 중
