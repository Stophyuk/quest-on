# Quest ON - 전체 설정 체크리스트

현재 상태: 로그인 실패 (Invalid login credentials)

## 🔍 문제 원인 분석

로그에서 발견된 오류:
```
AuthException: Email address "test94@test.com" is invalid, statusCode: 400
AuthException: Invalid login credentials, statusCode: 400
```

**주요 원인:**
1. ❌ Supabase 이메일 인증 설정 (Email confirmation required)
2. ❌ 데이터베이스 테이블 미생성
3. ❌ Edge Functions 미배포

---

## ✅ 필수 설정 단계

### 1단계: Supabase 프로젝트 확인

현재 연결된 Supabase 프로젝트:
- **URL**: `https://ufbajyakzsrumrnehthq.supabase.co`
- **Project Ref**: `ufbajyakzsrumrnehthq`

#### 확인 방법:
1. https://supabase.com/dashboard 접속
2. 위 Project Ref로 검색
3. 본인의 프로젝트가 맞는지 확인

---

### 2단계: 이메일 인증 비활성화 (개발용)

**중요**: 개발/테스트 중에는 이메일 인증을 비활성화해야 합니다!

#### 설정 방법:
1. Supabase 대시보드 → **Authentication** → **Settings**
2. **Email Auth** 섹션 찾기
3. **Confirm email** 옵션을 **비활성화** (Disabled)
4. **Save** 클릭

**현재 문제**: 이메일 인증이 활성화되어 있어서 회원가입 후 이메일 확인을 해야 로그인 가능

---

### 3단계: 데이터베이스 스키마 생성

#### 실행 방법:
1. Supabase 대시보드 → **SQL Editor**
2. **New Query** 클릭
3. `supabase/schema.sql` 파일 내용 전체 복사
4. 붙여넣기 후 **Run** 클릭

#### 생성될 테이블:
- ✅ `profiles` (비전 시스템)
- ✅ `quests` (퀘스트 관리)
- ✅ `user_stats` (레벨/경험치)

#### 확인 방법:
```sql
-- SQL Editor에서 실행
SELECT tablename FROM pg_tables WHERE schemaname = 'public';
```

결과에 `profiles`, `quests`, `user_stats`가 보여야 함

---

### 4단계: RLS (Row Level Security) 정책 확인

데이터베이스 테이블 생성 시 RLS 정책도 자동으로 생성됩니다.

#### 확인 방법:
1. Supabase 대시보드 → **Authentication** → **Policies**
2. 각 테이블(`profiles`, `quests`, `user_stats`)에 다음 정책이 있어야 함:
   - ✅ Users can view own data
   - ✅ Users can insert own data
   - ✅ Users can update own data

---

### 5단계: Edge Functions 배포 (선택)

**비전 시스템**(AI 코칭, 로드맵)을 사용하려면 Edge Functions 배포가 필요합니다.

#### 필요한 것:
- Supabase CLI 설치
- Anthropic API Key

#### 배포 명령어:
```bash
# 1. Supabase CLI 로그인
supabase login

# 2. 프로젝트 연결
supabase link --project-ref ufbajyakzsrumrnehthq

# 3. Anthropic API Key 설정
supabase secrets set ANTHROPIC_API_KEY=your_key_here

# 4. Edge Functions 배포
supabase functions deploy generate-vision-note
supabase functions deploy generate-goal-tree
```

**주의**: Edge Functions 없이도 회원가입/로그인/퀘스트 시스템은 작동합니다!

---

## 🧪 테스트 플로우

### 플로우 1: 인증 테스트 (최우선)

1. **회원가입**
   - 이메일: `user@example.com` (유효한 이메일 형식)
   - 비밀번호: `password123` (최소 6자)
   - ✅ "회원가입이 완료되었습니다!" 메시지
   - ⚠️ 이메일 인증이 활성화된 경우: 메일함 확인 필요

2. **로그인**
   - 방금 가입한 이메일/비밀번호 입력
   - ✅ "로그인되었습니다!" 메시지
   - ✅ 홈 화면으로 자동 이동

### 플로우 2: 비전 시스템 (Edge Functions 필요)

3. **비전 설문**
   - ✅ "비전 설문 시작하기" 버튼 클릭
   - ✅ 4단계 설문 완료

4. **AI 코칭**
   - ✅ 자동으로 코칭 노트 생성
   - ⚠️ Edge Function 미배포 시 오류 발생

5. **로드맵**
   - ✅ 3-5개 마일스톤 표시
   - ⚠️ Edge Function 미배포 시 오류 발생

### 플로우 3: 퀘스트 시스템

6. **퀘스트 추가**
   - ✅ + 버튼 클릭
   - ✅ 카테고리, 난이도, 목표 설정
   - ✅ "퀘스트가 추가되었습니다!"

7. **컨디션 조정**
   - ✅ 상단 컨디션 선택
   - ✅ 모든 퀘스트 목표 자동 조정

8. **퀘스트 진행**
   - ✅ 퀘스트 카드 탭
   - ✅ 진행률 증가
   - ✅ 완료 시 경험치 획득

---

## 🐛 예상 오류 및 해결

### 오류 1: "Email address is invalid"
**원인**: 이메일 형식 오류 또는 이메일 인증 설정
**해결**:
- 유효한 이메일 사용 (예: user@example.com)
- Supabase에서 이메일 인증 비활성화

### 오류 2: "Invalid login credentials"
**원인**:
1. 이메일 인증을 완료하지 않음
2. 잘못된 비밀번호
3. 계정이 존재하지 않음

**해결**:
1. Supabase에서 이메일 인증 비활성화
2. 회원가입 후 이메일 확인 (인증 활성화된 경우)
3. 올바른 이메일/비밀번호 입력

### 오류 3: "AI 코칭 생성 중 오류"
**원인**: Edge Functions 미배포
**해결**:
- Edge Functions 배포 (위 5단계 참고)
- 또는 일단 비전 시스템 건너뛰기

### 오류 4: "퀘스트가 저장되지 않음"
**원인**: 데이터베이스 테이블 미생성
**해결**: `supabase/schema.sql` 실행 (위 3단계)

---

## 📊 현재 상태 요약

| 항목 | 상태 | 조치 필요 |
|------|------|----------|
| Supabase 연결 | ✅ 정상 | - |
| 이메일 인증 설정 | ❌ 활성화됨 | **비활성화 필요** |
| 데이터베이스 스키마 | ❓ 미확인 | **생성 필요** |
| RLS 정책 | ❓ 미확인 | schema.sql 실행 시 자동 생성 |
| Edge Functions | ❌ 미배포 | 선택 사항 |

---

## 🚀 빠른 시작 (최소 설정)

**로그인/퀘스트 시스템만 테스트하려면:**

1. ✅ Supabase 이메일 인증 **비활성화**
2. ✅ `supabase/schema.sql` **실행**
3. ✅ 앱 새로고침 (Chrome에서 F5)
4. ✅ 회원가입 → 로그인 → 퀘스트 추가

**비전 시스템까지 사용하려면:**
- 위 1-2 단계 + Edge Functions 배포 (5단계)

---

**작성일**: 2025-11-06
**상태**: 설정 대기 중
