# Quest ON - 발견된 문제 및 수정사항

## 🔴 현재 상태: 로그인 불가

### 로그에서 발견된 오류
```
AuthException: Email address "test94@test.com" is invalid, statusCode: 400
AuthException: Invalid login credentials, statusCode: 400 (반복)
```

---

## 📋 전체 이슈 리스트

### 1. ✅ 수정 완료: UI 오버플로우
- **위치**: `signup_screen.dart:215`
- **문제**: 약관 텍스트가 좁은 화면에서 넘침
- **수정**: `Expanded` 위젯 추가, 폰트 크기 14px
- **상태**: ✅ 완료

### 2. ✅ 수정 완료: 에러 메시지 개선
- **위치**: `auth_remote_datasource.dart`
- **문제**: "Exception: 잘못된 요청입니다." 같은 불친절한 메시지
- **수정**:
  - 메시지 기반 상세 에러 분류
  - "Exception:" 접두사 제거
  - 한글 사용자 친화적 메시지
- **상태**: ✅ 완료

### 3. ❌ 설정 필요: Supabase 이메일 인증
- **문제**: 회원가입 후 이메일 확인을 해야 로그인 가능
- **원인**: Supabase 프로젝트에서 "Confirm email" 활성화됨
- **수정 방법** (사용자 액션 필요):
  1. https://supabase.com/dashboard 접속
  2. Authentication → Settings
  3. Email Auth → **Confirm email 비활성화**
- **상태**: ⏳ 사용자 설정 대기

### 4. ❌ 설정 필요: 데이터베이스 테이블
- **문제**: 테이블이 생성되지 않아 데이터 저장 불가
- **필요 테이블**: `profiles`, `quests`, `user_stats`
- **수정 방법** (사용자 액션 필요):
  1. Supabase 대시보드 → SQL Editor
  2. `supabase/schema.sql` 파일 내용 실행
- **상태**: ⏳ 사용자 설정 대기

### 5. ❌ 배포 필요: Edge Functions
- **문제**: AI 코칭 및 로드맵 생성 불가
- **필요 Functions**: `generate-vision-note`, `generate-goal-tree`
- **수정 방법** (사용자 액션 필요):
  ```bash
  supabase functions deploy generate-vision-note
  supabase functions deploy generate-goal-tree
  ```
- **상태**: ⏳ 사용자 배포 대기 (선택사항)

### 6. ⚠️ 잠재적 문제: Supabase 프로젝트 소유권
- **문제**: 현재 코드에 하드코딩된 Supabase URL이 사용자의 프로젝트가 아닐 수 있음
- **확인 필요**:
  - URL: `https://ufbajyakzsrumrnehthq.supabase.co`
  - 이것이 본인의 프로젝트인지 확인
- **수정 방법**: 본인 프로젝트의 URL/Key로 `lib/core/constants/env.dart` 수정

---

## 🔧 자동 수정 가능한 부분 (코드 개선)

### 추가 개선 사항

#### 1. 이메일 인증 필요 시 안내 메시지 추가
현재 상태에서는 "Invalid login credentials" 메시지만 표시되는데, 이메일 인증이 필요한 경우를 더 명확하게 안내해야 합니다.

**개선 필요**:
- 회원가입 성공 후 이메일 인증 안내
- 로그인 실패 시 이메일 확인 유도

#### 2. 데이터베이스 연결 상태 체크
앱 시작 시 필수 테이블 존재 여부 확인

#### 3. 온보딩 플로우 개선
- 첫 실행 시 설정 가이드 표시
- Supabase 연결 상태 표시

---

## 🎯 우선순위별 수정 계획

### P0 (최우선): 로그인 활성화
1. **Supabase 이메일 인증 비활성화** (사용자 설정)
2. **데이터베이스 스키마 생성** (사용자 SQL 실행)

→ 이 2가지만 완료하면 **회원가입/로그인/퀘스트 시스템 작동**

### P1 (중요): 전체 플로우 활성화
3. **Edge Functions 배포** (사용자 CLI 명령)

→ 이것까지 완료하면 **비전 시스템 (AI 코칭, 로드맵) 작동**

### P2 (개선): 사용자 경험 향상
4. 이메일 인증 안내 메시지 추가 (코드 수정)
5. 데이터베이스 연결 체크 (코드 수정)
6. 온보딩 플로우 (코드 수정)

---

## 📝 사용자 액션 체크리스트

### [ ] 1단계: Supabase 프로젝트 확인
- [ ] https://supabase.com/dashboard 접속
- [ ] Project Ref: `ufbajyakzsrumrnehthq` 검색
- [ ] 본인의 프로젝트가 맞는지 확인
- [ ] 아니라면 본인 프로젝트의 URL/Key 확인

### [ ] 2단계: 이메일 인증 비활성화
- [ ] Supabase 대시보드 → Authentication → Settings
- [ ] Email Auth → Confirm email **비활성화**
- [ ] Save 클릭

### [ ] 3단계: 데이터베이스 스키마 생성
- [ ] Supabase 대시보드 → SQL Editor
- [ ] New Query 클릭
- [ ] `supabase/schema.sql` 파일 내용 복사
- [ ] 붙여넣기 후 Run 클릭
- [ ] 성공 메시지 확인

### [ ] 4단계: 앱 테스트
- [ ] Chrome 새로고침 (F5)
- [ ] 회원가입 시도 (예: `user@example.com` / `password123`)
- [ ] 로그인 시도
- [ ] 퀘스트 추가 테스트

### [ ] 5단계 (선택): Edge Functions 배포
- [ ] Supabase CLI 설치
- [ ] `supabase login`
- [ ] `supabase link --project-ref ufbajyakzsrumrnehthq`
- [ ] Anthropic API Key 설정
- [ ] `supabase functions deploy generate-vision-note`
- [ ] `supabase functions deploy generate-goal-tree`

---

## 🚨 중요 알림

**현재 앱이 작동하지 않는 이유:**
1. Supabase 이메일 인증이 활성화되어 있어서 회원가입 후 이메일 확인이 필요함
2. 데이터베이스 테이블이 생성되지 않아서 데이터를 저장할 수 없음

**빠른 해결 방법:**
→ 위 체크리스트의 **2단계, 3단계**만 완료하면 앱이 정상 작동합니다!

---

**작성일**: 2025-11-06
**다음 단계**: 사용자 Supabase 설정 후 재테스트
