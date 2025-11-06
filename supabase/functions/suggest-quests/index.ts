// Edge Function: suggest-quests
// AI 기반 일일 퀘스트 추천

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // 1. 인증 확인
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      {
        global: {
          headers: { Authorization: req.headers.get('Authorization')! },
        },
      }
    )

    const {
      data: { user },
      error: userError,
    } = await supabaseClient.auth.getUser()

    if (userError || !user) {
      return new Response(
        JSON.stringify({ error: 'Unauthorized' }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 401,
        }
      )
    }

    // 2. 요청 데이터 파싱
    const { currentWeekGoal, condition } = await req.json()

    if (!currentWeekGoal) {
      return new Response(
        JSON.stringify({ error: 'currentWeekGoal is required' }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 400,
        }
      )
    }

    // 3. 최근 완료한 퀘스트 조회 (컨텍스트 제공)
    const { data: recentQuests } = await supabaseClient
      .from('quest_history')
      .select('quest_title, difficulty')
      .eq('user_id', user.id)
      .order('completed_at', { ascending: false })
      .limit(10)

    // 4. OpenAI API 호출
    const openaiApiKey = Deno.env.get('OPENAI_API_KEY')
    if (!openaiApiKey) {
      throw new Error('OPENAI_API_KEY not configured')
    }

    const conditionText = condition || '보통'
    const recentQuestsText = recentQuests
      ?.map(q => `- ${q.quest_title} (${q.difficulty})`)
      .join('\n') || '없음'

    const prompt = `당신은 행동과학과 습관 형성 전문가입니다. Tiny Habits, Atomic Habits, 행동 디자인 이론을 활용하여 지속 가능한 퀘스트를 추천합니다.

## 현재 상황
**이번 주 목표**: ${currentWeekGoal}
**오늘 컨디션**: ${conditionText}
**최근 7일 완료 기록**:
${recentQuestsText}

## 추천 전략
### 1. Tiny Habits 원칙 (BJ Fogg)
- B (Behavior) = M (Motivation) × A (Ability) × P (Prompt)
- 동기가 낮을 때는 난이도를 낮춰 능력(Ability)을 높임
- 작은 성공으로 동기 상승 → 점진적 확장

### 2. 습관 쌓기 (Habit Stacking)
- 기존 루틴에 새 행동 연결: "커피 마신 후 → 퀘스트 시작"
- 환경 설계: "책상 위에 노트북 열어두기"

### 3. 2분 규칙 (Atomic Habits)
- 컨디션 나쁠 때: 2분 내 완료 가능한 최소 버전
- 예: "30분 운동" → "운동복 입기" → 시작이 반!

### 4. 카테고리 균형
- **생산성**: 목표 직결 작업
- **학습**: 새로운 지식/기술
- **건강**: 신체/정신 관리
- **관계**: 네트워킹/소통
→ 하루 3-5개 중 최소 2개 카테고리 포함

### 5. 난이도 조절 (컨디션 기반)
**좋음 (에너지 80%+)**:
- Hard 1개 + Normal 2개 + Easy 1개
- 도전적이지만 완료 가능한 수준
- "오늘 안하면 아까운" 큰 작업

**보통 (에너지 50-80%)**:
- Normal 2개 + Easy 2개
- 안정적 진행 + 작은 성취감
- "꾸준함"에 집중

**나쁨 (에너지 50% 이하)**:
- Easy 3-4개 (2분 규칙 적용)
- "연속 기록 유지"가 목표
- 완벽주의 버리고 "최소한이라도"

### 6. 점진적 난이도 상승
- 같은 퀘스트 3회 연속 완료 → 다음 단계 제안
- 예: "10분 독서" (3회) → "20분 독서" 제안

## 출력 형식
{
  "quests": [
    {
      "title": "구체적 행동 (동사로 시작, 측정 가능)",
      "difficulty": "easy|normal|hard",
      "category": "생산성|학습|건강|관계",
      "estimatedTime": "예상 소요 시간 (분)",
      "reason": "이 퀘스트를 지금 추천하는 이유 (컨디션, 목표 연관성, 습관 형성 관점)",
      "tinyHabit": "2분 버전 대안 (컨디션 나쁠 때 사용)",
      "stackingTip": "기존 루틴과 연결하는 방법 (예: '아침 커피 마신 후')"
    }
  ],
  "todayFocus": "오늘 하루 집중할 한 가지 핵심 (1문장)",
  "motivationBoost": "컨디션에 맞는 응원 메시지 (2-3문장)"
}

## 퀘스트 작성 예시
❌ 나쁜 예: "열심히 공부하기" (추상적, 측정 불가)
✅ 좋은 예: "React Hooks 공식 문서 3페이지 읽고 메모 3줄 작성하기" (구체적, 측정 가능)

❌ 나쁜 예: "운동하기" (애매함)
✅ 좋은 예: "집 앞 공원 1바퀴 걷기 (15분)" (명확한 행동)

**핵심**: 오늘 완료 가능하고, 측정 가능하며, 주차 목표와 연결되고, 작은 성공을 쌓는 퀘스트를 추천하세요.`

    const openaiResponse = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${openaiApiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'gpt-3.5-turbo',
        messages: [
          {
            role: 'system',
            content: '당신은 행동과학과 습관 형성 전문가입니다. Tiny Habits, Atomic Habits 이론을 활용하여 지속 가능한 퀘스트를 추천합니다.',
          },
          {
            role: 'user',
            content: prompt,
          },
        ],
        temperature: 0.9,
        max_tokens: 1500,
      }),
    })

    if (!openaiResponse.ok) {
      const errorData = await openaiResponse.json()
      throw new Error(`OpenAI API error: ${JSON.stringify(errorData)}`)
    }

    const openaiData = await openaiResponse.json()
    const suggestionsContent = openaiData.choices[0].message.content

    // JSON 파싱
    let suggestionsJSON
    try {
      suggestionsJSON = JSON.parse(suggestionsContent)
    } catch (e) {
      console.error('JSON parsing failed:', e)
      suggestionsJSON = { quests: [] }
    }

    // 5. AI 사용량 로깅
    const tokensUsed = openaiData.usage?.total_tokens || 0
    const costUSD = tokensUsed * 0.000002

    await supabaseClient.from('ai_generation_logs').insert({
      user_id: user.id,
      generation_type: 'quest_suggestion',
      tokens_used: tokensUsed,
      cost_usd: costUSD,
    })

    return new Response(
      JSON.stringify({
        suggestions: suggestionsJSON.quests || [],
        tokensUsed,
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    )
  } catch (error) {
    console.error('Error:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500,
      }
    )
  }
})
