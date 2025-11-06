// Edge Function: generate-vision-note
// AI 비전 노트 생성 (OpenAI API 프록시)

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // CORS preflight 처리
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
    const { visionProfile } = await req.json()

    if (!visionProfile) {
      return new Response(
        JSON.stringify({ error: 'visionProfile is required' }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 400,
        }
      )
    }

    // 3. OpenAI API 호출
    const openaiApiKey = Deno.env.get('OPENAI_API_KEY')
    if (!openaiApiKey) {
      throw new Error('OPENAI_API_KEY not configured')
    }

    const prompt = `당신은 심리학 기반의 전문 라이프 코치입니다. 자기결정이론(Self-Determination Theory), 성장 마인드셋, 인지행동치료(CBT) 원리를 활용하여 사용자의 성장을 돕습니다.

## 사용자 프로필
**핵심 가치관**: ${visionProfile.values?.join(', ')}
**현재 자아 인식**: ${visionProfile.currentIdentity}
**이상적 미래상**: ${visionProfile.futureIdentity}
**인생의 궁극적 목표**: ${visionProfile.lifeDream}
**현재 겪는 어려움**: ${visionProfile.concerns}
**1년 구체적 목표**: ${visionProfile.yearGoals?.join(' / ')}
**하루 루틴 패턴**: ${visionProfile.currentRoutine}
**일일 가용 시간**: ${visionProfile.availableTime}시간
**선호 학습 방식**: ${visionProfile.learningStyle}
**동기 부여 요소**: ${visionProfile.motivation}

## 코칭 가이드라인
1. **인지 왜곡 패턴 파악**: 흑백논리, 파국화, 과잉일반화 등을 발견하고 리프레이밍
2. **내재적 동기 강화**: 외부 보상보다 자율성, 유능감, 관계성에 초점
3. **구체적 행동 설계**: 추상적 조언 대신 "내일 아침 첫 30분에 할 행동" 수준의 구체성
4. **심리적 안전감**: 실패를 학습 기회로 재해석, 완벽주의 경계
5. **점진적 성장**: 작은 승리(Small Wins) 누적으로 자기효능감 향상

다음 JSON 형식으로 깊이 있는 비전 노트를 작성하세요:

{
  "understanding": {
    "currentPosition": "현재 위치를 객관적으로 분석. 강점과 성장 기회를 균형있게 제시 (3-4문장)",
    "innerConflict": "고민 이면의 근본 욕구와 두려움을 파악. 인지 왜곡이 있다면 리프레이밍 제시 (3-4문장)",
    "reflectionQuestions": ["스스로에게 던질 핵심 질문 1", "핵심 질문 2", "핵심 질문 3"]
  },
  "growthFormula": {
    "valueAnalysis": "가치관들 사이의 연결고리와 우선순위를 분석. 가치관이 목표 달성에 어떤 에너지를 제공하는지 설명 (3-4문장)",
    "visionCore": "5년 후 이상적 자아의 핵심 정체성을 명확히 규정. '무엇을 하는 사람'보다 '어떤 가치를 실현하는 사람'에 초점 (3-4문장)",
    "identityBridge": "현재 자아에서 미래 자아로 가는 구체적 변화 3단계를 단계별로 제시 (각 단계 1-2문장)"
  },
  "oneYearChange": {
    "overview": "1년 후 가장 의미있는 변화를 구체적 장면으로 묘사. '어떤 상황에서 어떤 행동을 하고 있을지' (3-4문장)",
    "milestones": [
      "3개월: 측정 가능한 구체적 마일스톤",
      "6개월: 측정 가능한 구체적 마일스톤",
      "12개월: 측정 가능한 구체적 마일스톤"
    ],
    "challenges": [
      "예상 장애물 1과 그것이 왜 나타나는지 심리적 배경",
      "예상 장애물 2와 그것이 왜 나타나는지 심리적 배경"
    ],
    "strategies": [
      "장애물 1 돌파 전략: 구체적 행동 + 마인드셋",
      "장애물 2 돌파 전략: 구체적 행동 + 마인드셋",
      "일상 회복력 강화: 좌절 후 재시작 루틴"
    ]
  },
  "actionStrategy": {
    "timeDesign": "현재 루틴의 비효율 구간을 파악하고 가용 시간을 전략적으로 배치. 에너지 리듬을 고려한 시간 블록 설계 (4-5문장)",
    "learningOptimization": "학습 스타일에 맞는 구체적 학습법 + 뇌과학 기반 효율 팁. 단순 암기가 아닌 깊은 이해와 적용 중심 (4-5문장)",
    "motivationSystem": "동기 부여 방식에 맞춘 개인화된 보상 체계 + 슬럼프 극복 루틴. 외재적 동기를 내재적 동기로 전환하는 방법 (4-5문장)",
    "firstStep": "내일부터 시작할 수 있는 가장 작고 구체적인 행동 1가지. '언제, 어디서, 무엇을, 어떻게' 명확히 제시"
  },
  "coachingInsight": {
    "message": "개인화된 응원 메시지. 사용자의 언어와 상황에 공감하면서도 성장을 독려. 완벽주의를 경계하고 '과정의 가치'를 강조 (5-6문장)",
    "mindsetShift": "지금 당장 관점을 바꿔야 할 핵심 1가지. 예: '완벽한 계획'에서 '빠른 실행과 조정'으로",
    "weeklyCheck": "매주 스스로 점검할 질문 (자기 성찰 유도)"
  }
}

**중요**: 추상적이거나 일반적인 조언을 피하고, 사용자의 구체적 상황에 맞춘 실행 가능한 인사이트를 제공하세요.`

    const openaiResponse = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${openaiApiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'gpt-3.5-turbo', // 비용 절감을 위해 GPT-3.5 사용
        messages: [
          {
            role: 'system',
            content: '당신은 심리학 기반 전문 라이프 코치입니다. 사용자의 구체적 상황에 맞춘 깊이 있고 실행 가능한 인사이트를 제공합니다.',
          },
          {
            role: 'user',
            content: prompt,
          },
        ],
        temperature: 0.8,
        max_tokens: 3000,
      }),
    })

    if (!openaiResponse.ok) {
      const errorData = await openaiResponse.json()
      throw new Error(`OpenAI API error: ${JSON.stringify(errorData)}`)
    }

    const openaiData = await openaiResponse.json()
    const visionNoteContent = openaiData.choices[0].message.content

    // JSON 파싱
    let visionNoteJSON
    try {
      visionNoteJSON = JSON.parse(visionNoteContent)
    } catch (e) {
      // JSON 파싱 실패 시 텍스트 그대로 반환
      visionNoteJSON = { rawContent: visionNoteContent }
    }

    // 4. 비전 노트 저장
    const { error: saveError } = await supabaseClient
      .from('vision_notes')
      .insert({
        user_id: user.id,
        content: visionNoteJSON,
      })

    if (saveError) {
      console.error('Error saving vision note:', saveError)
      // 저장 실패해도 결과는 반환
    }

    // 5. AI 사용량 로깅
    const tokensUsed = openaiData.usage?.total_tokens || 0
    const costUSD = tokensUsed * 0.000002 // GPT-3.5-turbo: $0.002 / 1K tokens

    await supabaseClient.from('ai_generation_logs').insert({
      user_id: user.id,
      generation_type: 'vision_note',
      tokens_used: tokensUsed,
      cost_usd: costUSD,
    })

    return new Response(
      JSON.stringify({
        visionNote: visionNoteJSON,
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
