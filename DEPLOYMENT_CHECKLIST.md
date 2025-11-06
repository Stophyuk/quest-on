# Quest ON - 배포 체크리스트

## ✅ 완료된 작업 (Phase 1-5)

### 📊 Phase 1: Supabase 백엔드 구축

- ✅ `supabase/migrations/001_initial_schema.sql` - 데이터베이스 스키마
  - 8개 테이블: user_profiles, quests, vision_profiles, vision_notes, goal_trees, weekly_reflections, quest_history, ai_generation_logs
  - RLS 정책 (Row Level Security) 적용
  - 자동 레벨업 트리거 및 RPC 함수
- ✅ `supabase/README.md` - Supabase 설정 가이드

### 🔐 Phase 2: OpenAI API 보안 (Edge Functions)

- ✅ `supabase/functions/generate-vision-note/index.ts` - AI 비전 노트 생성
- ✅ `supabase/functions/generate-goal-tree/index.ts` - 1년 로드맵 생성
- ✅ `supabase/functions/suggest-quests/index.ts` - 일일 퀘스트 추천
- ✅ `supabase/functions/README.md` - Edge Functions 배포 가이드

### 🌐 Phase 3: 프론트엔드 Supabase 연동

- ✅ `src/lib/supabase.js` - Supabase 클라이언트 설정
- ✅ `src/services/auth.js` - 인증 API
- ✅ `src/services/profile.js` - 프로필 API
- ✅ `src/services/questsApi.js` - 퀘스트 API
- ✅ `src/services/visionApi.js` - Vision API
- ✅ `src/stores/auth.js` - 인증 상태 관리
- ✅ `MIGRATION_GUIDE.md` - 데이터 마이그레이션 가이드

### 🔑 Phase 4: 인증 시스템

- ✅ `src/views/Login.vue` - 로그인 페이지
- ✅ `src/views/Signup.vue` - 회원가입 페이지
- ✅ `src/views/AuthCallback.vue` - OAuth 콜백 페이지
- ✅ `src/router/index.js` - 라우터 설정 (로그인/회원가입 추가)
- ✅ `src/App.vue` - 인증 리스너 초기화

### 📜 Phase 5: 법률 문서 및 에러 추적

- ✅ `public/privacy-policy.md` - 개인정보처리방침
- ✅ `public/terms-of-service.md` - 이용약관
- ✅ `src/views/Privacy.vue` - 개인정보처리방침 페이지
- ✅ `src/views/Terms.vue` - 이용약관 페이지
- ✅ `src/lib/sentry.js` - Sentry 에러 추적 설정
- ✅ `src/main.js` - Sentry 초기화
- ✅ `SENTRY_SETUP.md` - Sentry 설정 가이드

---

## 🚀 배포 전 필수 작업

### 1. Supabase 설정

```bash
# 1. Supabase 프로젝트 생성
# https://supabase.com

# 2. 데이터베이스 스키마 적용
# Dashboard → SQL Editor에서 supabase/migrations/001_initial_schema.sql 실행

# 3. Edge Functions 배포
supabase login
supabase link --project-ref your-project-ref
supabase secrets set OPENAI_API_KEY=sk-your-key
supabase functions deploy

# 4. 환경변수 복사
# Dashboard → Settings → API에서 URL과 anon key 복사
```

### 2. 환경변수 설정

`.env.production` 파일 생성:

```env
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbG...
VITE_SENTRY_DSN=https://abc123@o123456.ingest.sentry.io/7891234
```

### 3. Sentry 설정 (선택사항)

```bash
# 1. Sentry 프로젝트 생성
# https://sentry.io

# 2. DSN 복사하여 .env에 추가

# 3. 프로덕션 빌드
npm run build
```

### 4. Vercel 배포

```bash
# 1. Vercel CLI 설치
npm install -g vercel

# 2. 로그인
vercel login

# 3. 배포
vercel --prod

# 4. 환경변수 설정
# Vercel Dashboard → Settings → Environment Variables에서 추가
# - VITE_SUPABASE_URL
# - VITE_SUPABASE_ANON_KEY
# - VITE_SENTRY_DSN
```

---

## 📋 배포 후 확인사항

### 기능 테스트

- [ ] 회원가입 / 로그인 정상 작동
- [ ] 퀘스트 추가 / 완료 정상 작동
- [ ] 레벨업 시스템 정상 작동
- [ ] AI 비전 노트 생성 테스트
- [ ] AI 퀘스트 추천 테스트
- [ ] Google OAuth 로그인 테스트 (설정한 경우)
- [ ] 프로필 페이지 정상 표시
- [ ] 약관 페이지 정상 표시

### 데이터 확인

- [ ] Supabase Dashboard에서 데이터 저장 확인
- [ ] RLS 정책 정상 작동 (다른 사용자 데이터 접근 불가)
- [ ] Edge Functions 로그 확인

### 에러 추적

- [ ] Sentry Dashboard에서 에러 수신 확인
- [ ] 테스트 에러 발생시켜서 Sentry 연동 확인

---

## 🔧 추가 최적화 (선택사항)

### 성능 최적화

```bash
# 1. Vite 빌드 최적화
npm run build

# 2. 번들 크기 분석
npm run build -- --mode analyze

# 3. Lighthouse 점수 확인
# Chrome DevTools → Lighthouse
```

### SEO 설정

`index.html` 수정:

```html
<head>
  <title>Quest ON - 컨디션 기반 퀘스트 관리</title>
  <meta name="description" content="매일의 컨디션에 맞춰 목표를 달성하는 똑똑한 퀘스트 관리 앱" />
  <meta property="og:title" content="Quest ON" />
  <meta property="og:description" content="컨디션 기반 퀘스트 관리" />
  <meta property="og:image" content="/og-image.png" />
</head>
```

### PWA 설정 (오프라인 지원)

```bash
npm install -D vite-plugin-pwa
```

`vite.config.js` 수정:

```javascript
import { VitePWA } from 'vite-plugin-pwa'

export default {
  plugins: [
    VitePWA({
      registerType: 'autoUpdate',
      manifest: {
        name: 'Quest ON',
        short_name: 'Quest ON',
        description: '컨디션 기반 퀘스트 관리',
        theme_color: '#9333ea',
      },
    }),
  ],
}
```

---

## 💰 예상 비용 (월 100명 기준)

### Supabase
- **Free Tier**: 500MB 데이터베이스, 1GB 파일 저장소
- **예상 사용량**: 데이터베이스 ~50MB, Edge Functions 무료
- **비용**: **$0/월** (Free Tier 충분)

### OpenAI API
- **비전 노트**: $0.003 x 100 = $3
- **로드맵**: $0.005 x 100 = $5
- **퀘스트 추천**: $0.001 x 100 x 30일 = $30
- **합계**: **$38/월**

### Vercel
- **Free Tier**: 100GB 대역폭/월
- **비용**: **$0/월** (Free Tier 충분)

### Sentry
- **Developer Plan**: 5,000 events/월
- **비용**: **$0/월** (Free Tier 충분)

### **총 예상 비용: $38/월**

---

## 📊 모니터링

### Supabase Dashboard
- Database → Tables: 데이터 확인
- Edge Functions → Logs: Edge Function 에러 확인
- Auth → Users: 회원 수 확인

### Sentry Dashboard
- Issues: 에러 목록
- Performance: 성능 모니터링
- Releases: 버전별 에러 추적

### Vercel Dashboard
- Analytics: 방문자 통계
- Logs: 서버 로그
- Deployment: 배포 상태

---

## 🆘 문제 해결

### Supabase 연결 실패
→ 환경변수 확인: `VITE_SUPABASE_URL`, `VITE_SUPABASE_ANON_KEY`

### Edge Functions 에러
→ Supabase Dashboard → Edge Functions → Logs 확인

### OpenAI API 에러
→ Edge Functions 환경변수 `OPENAI_API_KEY` 확인

### Sentry 에러 미수신
→ `.env`에 `VITE_SENTRY_DSN` 확인

---

## 📚 참고 문서

- `supabase/README.md` - Supabase 설정 가이드
- `supabase/functions/README.md` - Edge Functions 배포 가이드
- `MIGRATION_GUIDE.md` - 데이터 마이그레이션 가이드
- `SENTRY_SETUP.md` - Sentry 설정 가이드

---

**배포 완료 후 팀에 공유**: support@quest-on.com
