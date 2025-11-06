# Quest ON - Flutter 앱 테스트 가이드

지금까지 완료된 기능을 테스트하기 위한 가이드입니다.

## 📋 완료된 기능
- ✅ Phase 1: 기본 인프라 (Supabase, Riverpod, GoRouter, 테마)
- ✅ Phase 2: 인증 시스템 (로그인/회원가입)
- ✅ Phase 3: 비전 시스템 (설문, AI 코칭, 로드맵)
- ✅ Phase 4: 퀘스트 시스템 (CRUD, 컨디션 조정, 경험치/레벨)

---

## 🚀 1. Supabase 설정

### 1-1. 데이터베이스 스키마 생성

1. Supabase 대시보드 접속: https://supabase.com/dashboard
2. 프로젝트 선택
3. 왼쪽 메뉴 → **SQL Editor** 클릭
4. **New Query** 클릭
5. `supabase/schema.sql` 파일 내용 전체 복사하여 붙여넣기
6. **Run** 버튼 클릭

**생성되는 테이블:**
- `profiles` (비전 시스템 데이터)
- `quests` (퀘스트 데이터)
- `user_stats` (레벨/경험치 데이터)

### 1-2. Edge Functions 배포

**필요한 것:**
- Supabase CLI 설치: https://supabase.com/docs/guides/cli
- Anthropic API Key: https://console.anthropic.com/

**배포 명령어:**

```bash
# Supabase CLI 로그인
supabase login

# 프로젝트 연결
supabase link --project-ref YOUR_PROJECT_REF

# Anthropic API Key 설정 (Supabase Secrets)
supabase secrets set ANTHROPIC_API_KEY=your_anthropic_api_key_here

# Edge Functions 배포
supabase functions deploy generate-vision-note
supabase functions deploy generate-goal-tree
```

**PROJECT_REF 찾는 방법:**
- Supabase 대시보드 → Settings → General → Reference ID

---

## 🔑 2. Flutter 앱 환경변수 설정

### 2-1. Supabase 정보 확인

Supabase 대시보드 → Settings → API

- **Project URL**: `https://xxxxxx.supabase.co`
- **Anon (public) key**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`

### 2-2. `lib/core/constants/env.dart` 업데이트

현재 코드에 이미 하드코딩되어 있지만, 프로덕션에서는 환경변수로 관리해야 합니다.

```dart
class Env {
  static const String supabaseUrl = 'YOUR_PROJECT_URL';
  static const String supabaseAnonKey = 'YOUR_ANON_KEY';
}
```

---

## 📱 3. Flutter 앱 실행

### 3-1. 의존성 설치

```bash
cd C:\Users\정지혁\my-life-quest
flutter pub get
```

### 3-2. 앱 실행 (디버그 모드)

**Android 에뮬레이터:**

```bash
# 에뮬레이터가 실행 중인지 확인
flutter devices

# 앱 실행
flutter run
```

**Chrome (웹 테스트):**

```bash
flutter run -d chrome
```

---

## ✅ 4. 테스트 시나리오

### 시나리오 1: 회원가입 → 비전 설문 → 퀘스트 생성

#### Step 1: 회원가입
1. 앱 실행 시 로그인 화면 표시
2. 하단 "계정이 없으신가요? 회원가입" 클릭
3. 이메일, 비밀번호 입력 후 회원가입
4. 자동으로 로그인되어 홈 화면으로 이동

#### Step 2: 비전 설문
1. 홈 화면에서 "비전 설문 시작하기" 버튼 클릭
2. **1단계**: 이름 입력 (예: "홍길동")
3. **2단계**: 가치관 선택 (최대 3개, 예: 성장, 건강, 관계)
4. **3단계**: 목표 입력 (예: "6개월 안에 건강한 생활습관 만들기")
5. **4단계**: 이유 선택 (최대 3개, 예: 자기계발, 건강 개선)
6. **완료** 버튼 클릭

#### Step 3: AI 코칭 확인
1. 자동으로 AI 코칭 생성 화면으로 이동
2. 로딩 후 맞춤형 코칭 노트 표시
3. "로드맵 생성하기" 버튼 클릭

#### Step 4: 로드맵 확인
1. 자동으로 로드맵 생성 화면으로 이동
2. 로딩 후 3-5개의 마일스톤 표시
3. "시작하기" 버튼 클릭 → 퀘스트 목록 화면으로 이동

#### Step 5: 퀘스트 추가
1. 우측 하단 + 버튼 클릭
2. **퀘스트 제목** 입력 (예: "아침 조깅하기")
3. **설명** 입력 (선택, 예: "30분 이상 조깅하기")
4. **카테고리** 선택 (예: 건강 💪)
5. **난이도** 선택 (예: 보통)
6. **목표 횟수** 입력 (예: 5회)
7. **기본 컨디션** 선택 (예: 보통)
8. 예상 경험치 확인 (예: +100 EXP)
9. "퀘스트 추가" 버튼 클릭

#### Step 6: 컨디션 조정 테스트
1. 상단 "오늘의 컨디션" 에서 다른 컨디션 선택 (예: 좋음 → 나쁨)
2. 모든 퀘스트의 목표가 자동으로 조정됨 확인
3. 스낵바로 "컨디션이 '나쁨'로 변경되었습니다" 메시지 표시

#### Step 7: 퀘스트 진행
1. 퀘스트 카드를 **탭**하여 진행 (+1)
2. 진행률 바가 증가하는 것 확인
3. 목표 달성 시:
   - 스낵바: "🎉 '아침 조깅하기' 완료! +100 EXP"
   - 퀘스트가 완료 상태로 변경
   - 자동으로 경험치 획득 (레벨업 가능)

### 시나리오 2: 로그아웃 → 로그인

1. 우측 상단 로그아웃 아이콘 클릭
2. 로그인 화면으로 이동
3. 이메일, 비밀번호 입력 후 로그인
4. 이전 데이터 유지되는지 확인 (퀘스트, 경험치 등)

---

## 🐛 5. 예상되는 문제 및 해결

### 문제 1: "Supabase URL이 유효하지 않습니다"
**원인**: `lib/core/constants/env.dart`의 URL/Key가 잘못됨
**해결**: Supabase 대시보드에서 정확한 값 복사

### 문제 2: "Edge Function 호출 실패"
**원인**: Edge Functions가 배포되지 않음
**해결**:
```bash
supabase functions deploy generate-vision-note
supabase functions deploy generate-goal-tree
```

### 문제 3: "AI 코칭 생성 중 오류"
**원인**: Anthropic API Key 미설정
**해결**:
```bash
supabase secrets set ANTHROPIC_API_KEY=your_key_here
```

### 문제 4: "퀘스트가 저장되지 않음"
**원인**: 테이블이 생성되지 않았거나 RLS 정책 문제
**해결**: `supabase/schema.sql` 재실행

### 문제 5: Flutter 빌드 에러
**해결**:
```bash
flutter clean
flutter pub get
flutter run
```

---

## 📊 6. 확인할 주요 기능

### Phase 2: 인증 시스템
- [x] 회원가입 (이메일 형식 검증)
- [x] 로그인 (비밀번호 일치 검증)
- [x] 로그아웃
- [x] 자동 로그인 유지

### Phase 3: 비전 시스템
- [x] 4단계 설문 (이름, 가치관, 목표, 이유)
- [x] 가치관/이유 최대 3개 선택 제한
- [x] 기타 직접 입력 (10자/20자 제한)
- [x] AI 코칭 노트 생성
- [x] 로드맵 생성 (3-5개 마일스톤)

### Phase 4: 퀘스트 시스템
- [x] 퀘스트 추가 (카테고리, 난이도, 목표 횟수)
- [x] 예상 경험치 계산 표시
- [x] 컨디션별 목표 자동 조정
- [x] 퀘스트 진행 (+1)
- [x] 퀘스트 완료 시 경험치 획득
- [x] 오늘 완료 통계 표시

---

## 🔄 7. 다음 단계

테스트 후 발견된 버그나 개선사항을 정리하고,
다음 단계인 **Phase 5: 오프라인 동기화**를 진행합니다.

---

**작성일**: 2025-11-06
**테스트 버전**: Phase 1-4 완료
