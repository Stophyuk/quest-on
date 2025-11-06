# Sentry 에러 추적 설정 가이드

## 📊 Sentry란?

Sentry는 실시간 에러 추적 및 모니터링 플랫폼입니다. 프로덕션 환경에서 발생하는 에러를 자동으로 수집하고 분석하여 빠르게 대응할 수 있습니다.

---

## 🚀 Sentry 프로젝트 생성

### 1단계: Sentry 계정 생성

1. https://sentry.io 접속
2. "Start Free Trial" 클릭
3. 이메일 또는 GitHub 계정으로 가입

### 2단계: 프로젝트 생성

1. "Create Project" 클릭
2. **Platform**: Vue 선택
3. **Project Name**: `quest-on`
4. **Alert Frequency**: "On every new issue" (권장)
5. "Create Project" 클릭

### 3단계: DSN 복사

프로젝트 생성 후 표시되는 DSN을 복사합니다.

```
https://abc123@o123456.ingest.sentry.io/7891234
```

---

## ⚙️ Quest ON에 Sentry 연동

### 1단계: 환경변수 설정

프로젝트 루트에 `.env` 파일 생성 (또는 `.env.local`):

```env
# Supabase
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key

# Sentry
VITE_SENTRY_DSN=https://abc123@o123456.ingest.sentry.io/7891234
```

### 2단계: 빌드 및 테스트

```bash
# 개발 서버 재시작
npm run dev

# 빌드
npm run build
```

### 3단계: 에러 테스트

개발자 도구 콘솔에서 테스트:

```javascript
throw new Error('Sentry 테스트 에러')
```

Sentry Dashboard → Issues에서 에러 확인

---

## 📋 Sentry 기능

### 1. 자동 에러 캡처

모든 JavaScript 에러가 자동으로 Sentry에 전송됩니다:

```javascript
// 자동 캡처됨
function buggyFunction() {
  const obj = null
  obj.property // TypeError: Cannot read property 'property' of null
}
```

### 2. 커스텀 에러 로깅

```javascript
import { logError } from '@/lib/sentry'

try {
  await riskyOperation()
} catch (error) {
  logError(error, {
    context: 'Quest 생성 중 에러',
    questTitle: quest.title,
  })
}
```

### 3. 사용자 정보 추적

로그인 후 자동으로 사용자 정보가 Sentry에 전송됩니다:

```javascript
// src/stores/auth.js에서 자동 처리
import { setSentryUser } from '@/lib/sentry'

async function signIn(email, password) {
  const { user } = await authApi.signInWithEmail(email, password)
  setSentryUser(user) // Sentry에 사용자 정보 전송
}
```

### 4. 성능 모니터링

```javascript
import { startTransaction } from '@/lib/sentry'

async function loadQuests() {
  const transaction = startTransaction('Load Quests')

  try {
    const quests = await questsApi.getQuests()
    // ...
  } catch (error) {
    transaction.setStatus('internal_error')
    throw error
  } finally {
    transaction.finish()
  }
}
```

### 5. 메시지 로깅

```javascript
import { logMessage } from '@/lib/sentry'

// 경고 메시지
logMessage('사용자가 비정상적인 경로로 접근', 'warning')

// 정보 메시지
logMessage('마이그레이션 완료', 'info')
```

---

## 🔧 Sentry 설정 커스터마이징

### src/lib/sentry.js 수정

```javascript
Sentry.init({
  app,
  dsn: sentryDsn,
  environment,

  // 샘플링 비율 조정 (비용 절감)
  tracesSampleRate: 0.2, // 20%만 성능 추적

  // Session Replay 비활성화 (비용 절감)
  replaysSessionSampleRate: 0,
  replaysOnErrorSampleRate: 0,

  // 추가 에러 무시
  ignoreErrors: [
    'ChunkLoadError', // Vite 빌드 관련
    'cancelled', // 사용자가 취소한 요청
  ],
})
```

---

## 📊 Sentry Dashboard 사용법

### 1. Issues (에러 목록)

- **New**: 처음 발생한 에러
- **Unresolved**: 미해결 에러
- **Resolved**: 해결된 에러
- **Ignored**: 무시된 에러

### 2. 에러 상세 정보

각 에러 클릭 시 확인 가능:

- **Stack Trace**: 에러 발생 위치
- **Breadcrumbs**: 에러 발생 전 사용자 행동
- **Tags**: 브라우저, OS, 환경 정보
- **User**: 에러를 경험한 사용자 정보

### 3. Alerts (알림 설정)

Settings → Alerts에서 설정:

- 이메일 알림
- Slack 통합
- Discord 통합

---

## 💰 Sentry 요금제

| 플랜 | 가격 | 에러 수 | Session Replay |
|------|------|---------|----------------|
| **Developer** | 무료 | 5,000 events/월 | 50 replays/월 |
| **Team** | $26/월 | 50,000 events/월 | 500 replays/월 |
| **Business** | $80/월 | 150,000 events/월 | 5,000 replays/월 |

### 비용 최적화 팁

1. **샘플링 비율 낮추기**: `tracesSampleRate: 0.1`
2. **Session Replay 끄기**: 비용이 많이 듦
3. **에러 필터링**: `ignoreErrors`로 불필요한 에러 제외
4. **Release 태깅**: 버전별로 에러 추적

---

## 🎯 프로덕션 체크리스트

- [ ] Sentry DSN 환경변수 설정
- [ ] 프로덕션 빌드에서 소스맵 업로드 설정
- [ ] 알림 채널 설정 (이메일, Slack 등)
- [ ] 에러 필터링 규칙 설정
- [ ] 샘플링 비율 조정 (비용 최적화)
- [ ] Sentry Dashboard에서 에러 확인 가능한지 테스트

---

## 📚 참고 자료

- [Sentry Vue 공식 문서](https://docs.sentry.io/platforms/javascript/guides/vue/)
- [Sentry 가격 정책](https://sentry.io/pricing/)
- [Sentry Best Practices](https://docs.sentry.io/platforms/javascript/best-practices/)

---

## 🆘 문제 해결

### "Sentry DSN not configured" 경고

→ `.env` 파일에 `VITE_SENTRY_DSN` 추가

### 에러가 Sentry에 전송되지 않음

1. DSN이 올바른지 확인
2. 네트워크 탭에서 `sentry.io`로 요청이 가는지 확인
3. `ignoreErrors`에 해당 에러가 포함되어 있는지 확인

### 소스맵이 표시되지 않음

```bash
# Vite 빌드 시 소스맵 생성
npm run build -- --sourcemap
```

---

**문의**: support@quest-on.com
