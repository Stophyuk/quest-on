# Quest ON - Edge Functions 배포 가이드

## 📦 Edge Functions 목록

| 함수명 | 경로 | 설명 | API 엔드포인트 |
|--------|------|------|----------------|
| `generate-vision-note` | `/functions/generate-vision-note` | AI 비전 노트 생성 | `POST /functions/v1/generate-vision-note` |
| `generate-goal-tree` | `/functions/generate-goal-tree` | 1년 로드맵 생성 | `POST /functions/v1/generate-goal-tree` |
| `suggest-quests` | `/functions/suggest-quests` | 일일 퀘스트 추천 | `POST /functions/v1/suggest-quests` |

---

## 🚀 배포 방법

### 1단계: Supabase CLI 설치 및 로그인

```bash
# Supabase CLI 설치 (이미 설치했다면 생략)
npm install -g supabase

# Supabase 로그인
supabase login

# 프로젝트 링크
supabase link --project-ref your-project-ref
```

**Project Ref 찾기**:
- Supabase Dashboard → Settings → General
- Project Reference ID 복사 (예: `abcdefghijklmno`)

### 2단계: OpenAI API 키 환경변수 설정

⚠️ **중요**: Edge Function에서 사용할 OpenAI API 키를 Supabase에 등록해야 합니다.

```bash
# OpenAI API 키 설정
supabase secrets set OPENAI_API_KEY=sk-your-openai-api-key-here

# 설정 확인
supabase secrets list
```

또는 Supabase Dashboard에서 직접 설정:
1. Dashboard → Settings → Edge Functions
2. "Add new secret" 클릭
3. Name: `OPENAI_API_KEY`
4. Value: OpenAI API 키 입력

### 3단계: Edge Functions 배포

```bash
# 모든 함수 한 번에 배포
supabase functions deploy

# 또는 개별 배포
supabase functions deploy generate-vision-note
supabase functions deploy generate-goal-tree
supabase functions deploy suggest-quests
```

배포 완료 후 엔드포인트 확인:
```
https://your-project.supabase.co/functions/v1/generate-vision-note
https://your-project.supabase.co/functions/v1/generate-goal-tree
https://your-project.supabase.co/functions/v1/suggest-quests
```

---

## 🧪 Edge Functions 테스트

### 로컬 개발 환경에서 테스트

```bash
# Edge Functions 로컬 실행
supabase functions serve

# 다른 터미널에서 테스트
curl -i --location --request POST 'http://localhost:54321/functions/v1/suggest-quests' \
  --header 'Authorization: Bearer YOUR_ANON_KEY' \
  --header 'Content-Type: application/json' \
  --data '{"currentWeekGoal":"운동 습관 만들기","condition":"좋음"}'
```

### 배포된 함수 테스트

#### 1. generate-vision-note 테스트

```bash
curl -i --location --request POST \
  'https://your-project.supabase.co/functions/v1/generate-vision-note' \
  --header 'Authorization: Bearer YOUR_ANON_KEY' \
  --header 'Content-Type: application/json' \
  --data '{
    "visionProfile": {
      "values": ["건강", "성장"],
      "currentIdentity": "개발자",
      "futureIdentity": "시니어 개발자",
      "lifeDream": "의미 있는 서비스 만들기",
      "concerns": "시간 관리",
      "yearGoals": ["운동 습관", "사이드 프로젝트 완성"],
      "currentRoutine": "출퇴근 후 코딩",
      "availableTime": 3,
      "learningStyle": "실습 위주",
      "motivation": "성취감"
    }
  }'
```

#### 2. generate-goal-tree 테스트

```bash
curl -i --location --request POST \
  'https://your-project.supabase.co/functions/v1/generate-goal-tree' \
  --header 'Authorization: Bearer YOUR_ANON_KEY' \
  --header 'Content-Type: application/json' \
  --data '{
    "visionNote": {
      "understanding": {
        "currentPosition": "개발자로서 성장 중"
      }
    },
    "yearGoals": ["운동 습관 만들기", "사이드 프로젝트 완성"]
  }'
```

#### 3. suggest-quests 테스트

```bash
curl -i --location --request POST \
  'https://your-project.supabase.co/functions/v1/suggest-quests' \
  --header 'Authorization: Bearer YOUR_ANON_KEY' \
  --header 'Content-Type: application/json' \
  --data '{
    "currentWeekGoal": "운동 습관 만들기",
    "condition": "좋음"
  }'
```

---

## 🔐 인증 처리

모든 Edge Functions는 Supabase 인증이 필요합니다.

### 프론트엔드에서 호출 예시

```javascript
import { supabase } from '@/lib/supabase'

async function generateVisionNote(visionProfile) {
  const { data: { session } } = await supabase.auth.getSession()

  const response = await fetch(
    `${import.meta.env.VITE_SUPABASE_URL}/functions/v1/generate-vision-note`,
    {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${session.access_token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ visionProfile }),
    }
  )

  return await response.json()
}
```

---

## 📊 모니터링

### 로그 확인

```bash
# 실시간 로그 보기
supabase functions logs generate-vision-note --tail

# 최근 로그 보기
supabase functions logs suggest-quests --limit 50
```

### Dashboard에서 확인

1. Supabase Dashboard → Edge Functions
2. 각 함수 클릭 → "Logs" 탭
3. 요청 수, 오류율, 응답 시간 확인

---

## 💰 비용 계산

### OpenAI API 비용 (GPT-3.5-turbo)

| 함수 | 평균 토큰 | 비용/요청 | 월 100명 사용 시 |
|------|----------|----------|------------------|
| `generate-vision-note` | ~1,500 | $0.003 | $30 |
| `generate-goal-tree` | ~2,500 | $0.005 | $50 |
| `suggest-quests` | ~500 | $0.001 | $10 |

**월간 예상 비용** (100명, 각 1회 사용): **$90**

### Supabase Edge Functions 비용

- **Free Tier**: 500K invocations/월
- **Pro Tier**: 2M invocations/월 포함
- 추가: $2 per 1M invocations

---

## 🛠️ 문제 해결

### "Function not found" 오류

```bash
# 함수 목록 확인
supabase functions list

# 재배포
supabase functions deploy function-name
```

### "Unauthorized" 오류

→ `Authorization` 헤더가 올바른지 확인
→ 세션이 만료되지 않았는지 확인

### "OPENAI_API_KEY not configured" 오류

```bash
# Secret 재설정
supabase secrets set OPENAI_API_KEY=your-key

# 함수 재배포 (환경변수 적용)
supabase functions deploy
```

### CORS 오류

→ Edge Function 코드에 `corsHeaders`가 포함되어 있는지 확인
→ OPTIONS 메서드 처리가 되어 있는지 확인

---

## 📚 참고 자료

- [Supabase Edge Functions 문서](https://supabase.com/docs/guides/functions)
- [Deno 런타임 문서](https://deno.land/manual)
- [OpenAI API 문서](https://platform.openai.com/docs)

---

## 🔄 업데이트 흐름

```bash
# 1. 코드 수정
vim supabase/functions/suggest-quests/index.ts

# 2. 로컬 테스트
supabase functions serve
# (다른 터미널에서) curl로 테스트

# 3. 배포
supabase functions deploy suggest-quests

# 4. 로그 확인
supabase functions logs suggest-quests --tail
```
