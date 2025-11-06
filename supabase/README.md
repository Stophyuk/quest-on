# Quest ON - Supabase 설정 가이드

## 🚀 Supabase 프로젝트 설정

### 1단계: Supabase 프로젝트 생성

1. https://supabase.com 접속
2. "Start your project" 클릭
3. 새 프로젝트 생성:
   - **Organization**: 새로 만들거나 기존 선택
   - **Project Name**: `quest-on`
   - **Database Password**: 강력한 비밀번호 생성 (꼭 저장!)
   - **Region**: `Northeast Asia (Seoul)` 선택
   - **Pricing Plan**: Free (나중에 업그레이드 가능)

### 2단계: 데이터베이스 스키마 적용

1. Supabase Dashboard → SQL Editor 메뉴
2. `migrations/001_initial_schema.sql` 파일 내용 복사
3. SQL Editor에 붙여넣기
4. "Run" 버튼 클릭

또는 Supabase CLI 사용:

```bash
# Supabase CLI 설치
npm install -g supabase

# 로그인
supabase login

# 프로젝트 링크
supabase link --project-ref your-project-ref

# 마이그레이션 적용
supabase db push
```

### 3단계: 환경변수 설정

1. Supabase Dashboard → Settings → API
2. 다음 값들을 복사:
   - **Project URL**: `https://xxx.supabase.co`
   - **anon/public key**: `eyJhbG...`
   - **service_role key**: `eyJhbG...` (서버용, 노출 금지!)

3. 프로젝트 루트에 `.env.local` 파일 생성:

```env
# Supabase
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key

# OpenAI (Edge Function에서만 사용)
# Edge Function 환경변수로 별도 설정 필요
```

### 4단계: 인증 설정

1. Supabase Dashboard → Authentication → Providers
2. 활성화할 인증 방식:
   - ✅ **Email**: 기본 활성화됨
   - ✅ **Google**: (선택) OAuth 설정 필요
   - ✅ **Kakao**: (선택) 한국 사용자용

#### Google 로그인 설정 (선택)

1. https://console.cloud.google.com/ 접속
2. 프로젝트 생성 → API 및 서비스 → OAuth 2.0 클라이언트 ID
3. 승인된 리디렉션 URI:
   ```
   https://your-project.supabase.co/auth/v1/callback
   ```
4. 클라이언트 ID와 Secret을 Supabase에 입력

### 5단계: Storage 설정 (선택)

프로필 이미지 등을 저장하려면:

1. Supabase Dashboard → Storage → Create bucket
2. Bucket 이름: `avatars`
3. Public bucket 체크
4. RLS 정책 추가:
   - 사용자는 자신의 폴더에만 업로드 가능

---

## 📊 데이터베이스 스키마 구조

### 테이블 목록

| 테이블명 | 설명 | 주요 필드 |
|---------|------|----------|
| `user_profiles` | 사용자 프로필 | nickname, level, experience |
| `quests` | 퀘스트 목록 | title, difficulty, completed |
| `vision_profiles` | 비전 프로필 | values, year_goals |
| `vision_notes` | AI 비전 노트 | content (JSONB) |
| `goal_trees` | 1년 로드맵 | tree_data (JSONB) |
| `weekly_reflections` | 주간 회고 | reflection_data (JSONB) |
| `quest_history` | 완료 기록 | quest_title, xp_gained |
| `ai_generation_logs` | AI 사용량 | tokens_used, cost_usd |

### RPC 함수

| 함수명 | 설명 | 파라미터 |
|--------|------|----------|
| `gain_experience(xp_amount)` | 경험치 획득 및 자동 레벨업 | xp_amount: INTEGER |
| `get_weekly_stats()` | 주간 통계 조회 | 없음 |

---

## 🔐 보안 설정

### API 키 보호

⚠️ **절대로 service_role key를 클라이언트 코드에 노출하지 마세요!**

```javascript
// ❌ 잘못된 예 - service_role key 사용
const supabase = createClient(url, SERVICE_ROLE_KEY) // 위험!

// ✅ 올바른 예 - anon key 사용
const supabase = createClient(url, ANON_KEY) // RLS로 보호됨
```

### Row Level Security (RLS)

모든 테이블에 RLS가 활성화되어 있으므로:
- 사용자는 자신의 데이터만 접근 가능
- `auth.uid()`로 사용자 식별

---

## 🧪 테스트 데이터 삽입

SQL Editor에서 실행:

```sql
-- 테스트 퀘스트 추가 (본인 계정으로 로그인 후)
INSERT INTO quests (user_id, title, difficulty, is_recurring)
VALUES
  (auth.uid(), '물 8잔 마시기', 'easy', true),
  (auth.uid(), '30분 운동하기', 'normal', true),
  (auth.uid(), '1시간 독서하기', 'hard', false);

-- 경험치 획득 테스트
SELECT * FROM gain_experience(50);

-- 주간 통계 조회
SELECT * FROM get_weekly_stats();
```

---

## 📝 다음 단계

1. ✅ 데이터베이스 스키마 생성 완료
2. ⏭️ Edge Functions 배포 (`supabase/functions/`)
3. ⏭️ 프론트엔드 연동 (`npm install @supabase/supabase-js`)
4. ⏭️ 인증 UI 구현
5. ⏭️ 데이터 마이그레이션

---

## 🆘 문제 해결

### "relation does not exist" 에러

→ SQL 스키마가 제대로 실행되지 않았을 수 있습니다. SQL Editor에서 다시 실행하세요.

### "JWT expired" 에러

→ 세션이 만료되었습니다. `supabase.auth.refreshSession()` 호출 필요.

### RLS 정책 에러

→ `auth.uid()`가 null일 수 있습니다. 로그인 상태 확인.

---

## 📚 참고 자료

- [Supabase 공식 문서](https://supabase.com/docs)
- [Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)
- [Supabase CLI](https://supabase.com/docs/guides/cli)
