# 🔒 Quest ON - 보안 설정 가이드

> **⚠️ 긴급**: Supabase 키가 GitHub에 노출되었습니다. 즉시 조치가 필요합니다.

---

## 📋 현재 상태 요약

### ✅ 완료된 보안 조치
1. **코드 정리**: `lib/core/constants/env.dart`에서 하드코딩된 키 제거 완료
2. **Git 보안**: `.gitignore` 업데이트 완료
3. **문서화**: `SECURITY.md` 생성 완료
4. **템플릿**: `scripts/run_dev.bat.example` 생성 완료
5. **RLS 정책**: 모든 데이터베이스 테이블에 Row Level Security 활성화 확인 ✅

### ⚠️ 즉시 필요한 조치
1. **Supabase 키 재생성** (5분 소요)
2. **로컬 환경 설정** (2분 소요)
3. **앱 테스트** (3분 소요)

---

## 🚨 1단계: Supabase 키 재생성 (즉시)

### 왜 필요한가?
노출된 키로 악의적 사용자가:
- 데이터베이스 전체 접근 가능
- OpenAI API 무제한 호출 (비용 폭탄)
- 사용자 데이터 조작/삭제 가능

### 진행 방법

1. **Supabase 대시보드 접속**
   ```
   https://supabase.com/dashboard
   ```

2. **프로젝트 선택**
   - 프로젝트: `ufbajyakzsrumrnehthq`
   - Quest ON 프로젝트 클릭

3. **Settings → API 메뉴 이동**
   ```
   좌측 사이드바 → Settings → API
   ```

4. **Anon Key 재생성**
   - `Project API keys` 섹션에서
   - `anon/public` 키 찾기
   - 우측 `...` 메뉴 클릭
   - `Roll API Key` 또는 `Regenerate` 클릭
   - ⚠️ **새 키를 즉시 복사하세요** (다시 볼 수 없습니다)

5. **URL 확인**
   - 같은 페이지에서 `Project URL` 확인
   - 형식: `https://ufbajyakzsrumrnehthq.supabase.co`

---

## ⚙️ 2단계: 로컬 개발 환경 설정

### 방법 1: 자동 스크립트 사용 (권장)

1. **템플릿 복사**
   ```cmd
   cd C:\project\my-life-quest
   copy scripts\run_dev.bat.example scripts\run_dev.bat
   ```

2. **스크립트 편집**
   ```cmd
   notepad scripts\run_dev.bat
   ```

3. **실제 키 입력**
   ```batch
   flutter run ^
     --dart-define=SUPABASE_URL=https://ufbajyakzsrumrnehthq.supabase.co ^
     --dart-define=SUPABASE_ANON_KEY=<1단계에서_복사한_새로운_키> ^
     --dart-define=SENTRY_DSN= ^
     -d R3CW70E4TCM
   ```

4. **저장 후 실행**
   ```cmd
   scripts\run_dev.bat
   ```

### 방법 2: 직접 명령어 입력

매번 Flutter 실행 시:
```cmd
flutter run ^
  --dart-define=SUPABASE_URL=https://ufbajyakzsrumrnehthq.supabase.co ^
  --dart-define=SUPABASE_ANON_KEY=<새로운_키> ^
  -d R3CW70E4TCM
```

---

## ✅ 3단계: RLS 정책 검증 (이미 완료)

### 현재 RLS 상태 확인

다음 테이블들에 RLS가 활성화되어 있습니다:

| 테이블 | RLS 정책 | 상태 |
|--------|----------|------|
| `profiles` | SELECT, INSERT, UPDATE | ✅ 활성 |
| `quests` | SELECT, INSERT, UPDATE, DELETE | ✅ 활성 |
| `user_stats` | SELECT, INSERT, UPDATE | ✅ 활성 |
| `user_profiles` | SELECT, INSERT, UPDATE | ✅ 활성 |
| `vision_profiles` | SELECT, INSERT, UPDATE | ✅ 활성 |
| `vision_notes` | SELECT, INSERT | ✅ 활성 |
| `goal_trees` | SELECT, INSERT | ✅ 활성 |
| `weekly_reflections` | SELECT, INSERT, UPDATE | ✅ 활성 |
| `quest_history` | SELECT, INSERT | ✅ 활성 |
| `ai_generation_logs` | SELECT | ✅ 활성 |

**모든 정책이 `auth.uid() = user_id` 조건으로 사용자 격리 보장합니다.**

### 추가 검증 (선택)

Supabase SQL Editor에서 실행:
```sql
-- RLS 활성화 확인
SELECT schemaname, tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
AND rowsecurity = true;

-- 정책 목록 확인
SELECT schemaname, tablename, policyname, cmd, qual
FROM pg_policies
WHERE schemaname = 'public';
```

---

## 🧪 4단계: 테스트

### 1. 앱 실행
```cmd
scripts\run_dev.bat
```

### 2. 환경 변수 검증
앱 시작 시 다음 오류가 **나오면 안 됩니다**:
```
Missing required environment variables:
SUPABASE_URL is not set
SUPABASE_ANON_KEY is not set
```

### 3. 기능 테스트
- [ ] 로그인 성공
- [ ] 퀘스트 목록 조회
- [ ] 퀘스트 생성
- [ ] 퀘스트 완료 (경험치 획득)
- [ ] AI 퀘스트 추천 (OpenAI 연동)
- [ ] 프로필 편집

---

## 🔐 보안 체크리스트

### 즉시 조치
- [ ] Supabase Anon Key 재생성 완료
- [ ] 새 키로 로컬 `run_dev.bat` 생성
- [ ] 앱 정상 실행 확인
- [ ] **절대 `run_dev.bat`를 Git에 커밋하지 않기**

### 장기 보안
- [ ] GitHub Secret Scanning 활성화
- [ ] Supabase 사용량 모니터링 (API 폭탄 방지)
- [ ] Firebase Analytics 이벤트 검토
- [ ] Edge Functions 권한 검토

---

## 📞 문제 발생 시

### "Missing required environment variables" 오류
**원인**: 환경 변수가 전달되지 않음
**해결**:
```cmd
# 스크립트 경로 확인
dir scripts\run_dev.bat

# 존재하면
scripts\run_dev.bat

# 없으면 다시 생성
copy scripts\run_dev.bat.example scripts\run_dev.bat
notepad scripts\run_dev.bat
```

### "Invalid JWT" 또는 "Invalid API key" 오류
**원인**: 잘못된 키 또는 오래된 키 사용
**해결**: Supabase 대시보드에서 키 재확인 및 복사

### RLS 정책 오류
**원인**: 특정 테이블에 RLS 정책 누락
**해결**: `supabase/schema.sql` 실행하여 RLS 재적용

---

## 📚 참고 문서

- [SECURITY.md](./SECURITY.md) - 전체 보안 정책
- [scripts/README.md](./scripts/README.md) - 로컬 스크립트 가이드
- [Supabase RLS 문서](https://supabase.com/docs/guides/auth/row-level-security)

---

**마지막 업데이트**: 2025-11-11
**긴급도**: 🔴 HIGH - 즉시 조치 필요
