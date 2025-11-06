// Edge Function: generate-goal-tree
// AI 1년 로드맵 (Goal Tree) 생성

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
    const { visionNote, yearGoals } = await req.json()

    if (!visionNote || !yearGoals) {
      return new Response(
        JSON.stringify({ error: 'visionNote and yearGoals are required' }),
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

    const prompt = `당신은 SMART 목표 설정과 프로젝트 관리 전문가입니다. OKR(Objectives and Key Results), 애자일 방법론, 습관 쌓기 이론을 활용하여 실행 가능한 로드맵을 설계합니다.

## 맥락 정보
**비전 노트 핵심**: ${JSON.stringify(visionNote.understanding?.currentPosition || '')}
**1년 목표들**:
${yearGoals.map((goal, i) => `${i + 1}. ${goal}`).join('\n')}

## 로드맵 설계 원칙
1. **SMART 기준 준수**: Specific(구체적), Measurable(측정가능), Achievable(달성가능), Relevant(관련성), Time-bound(기한명시)
2. **의존성 관리**: 선행 조건이 완료되어야 다음 단계 진행 가능한 구조
3. **점진적 난이도**: 쉬운 승리(Quick Wins) → 중간 도전 → 복합적 과제 순서
4. **검증 가능한 지표**: "~을 배운다" (X) → "~로 프로젝트 1개 완성" (O)
5. **버퍼 확보**: 예상치 못한 어려움을 위한 여유 시간 포함
6. **습관 강화**: 반복 가능한 루틴을 목표 안에 통합

다음 JSON 형식으로 로드맵을 작성하세요:

[
  {
    "id": "goal-1",
    "title": "1년 목표 제목 (간결하게)",
    "description": "이 목표를 달성하면 어떤 변화가 생기는지 (2-3문장)",
    "successCriteria": "목표 달성 여부를 판단할 명확한 기준 (예: '실사용자 100명 확보', 'TOEIC 800점 이상')",
    "quarters": [
      {
        "id": "q1",
        "title": "1분기 (1-4월): 핵심 테마",
        "objective": "이 분기의 핵심 목표 (OKR 방식)",
        "keyResults": [
          "측정 가능한 핵심 결과 1",
          "측정 가능한 핵심 결과 2"
        ],
        "months": [
          {
            "id": "month-1",
            "title": "1월",
            "focus": "이달의 집중 영역 (한 문장)",
            "deliverables": ["완성할 구체적 산출물 1", "완성할 구체적 산출물 2"],
            "metrics": "측정 지표 (예: '주 3회 실행', '프로젝트 1개 완성')",
            "dependencies": "선행 조건 또는 '없음'",
            "weeks": [
              {
                "id": "week-1",
                "title": "1주차",
                "goal": "이번 주 달성할 구체적 목표",
                "suggestedQuests": [
                  "DAY 1: 구체적 행동 (30분 이내 완료 가능)",
                  "DAY 2-3: 구체적 행동 (예: 'X 라이브러리 공식 문서 읽기')",
                  "DAY 4-7: 구체적 행동 (예: '간단한 TODO 앱 만들기')"
                ],
                "checkpoint": "주말에 스스로 확인할 질문",
                "riskMitigation": "예상되는 어려움과 대응 방법 (없으면 '없음')"
              },
              {
                "id": "week-2",
                "title": "2주차",
                "goal": "이번 주 달성할 구체적 목표",
                "suggestedQuests": [
                  "구체적 행동 1",
                  "구체적 행동 2",
                  "구체적 행동 3"
                ],
                "checkpoint": "주말 점검 질문",
                "riskMitigation": "예상 어려움 대응"
              },
              {
                "id": "week-3",
                "title": "3주차",
                "goal": "목표",
                "suggestedQuests": ["행동1", "행동2", "행동3"],
                "checkpoint": "점검 질문",
                "riskMitigation": "대응책"
              },
              {
                "id": "week-4",
                "title": "4주차",
                "goal": "목표",
                "suggestedQuests": ["행동1", "행동2", "행동3"],
                "checkpoint": "점검 질문",
                "riskMitigation": "대응책"
              }
            ]
          },
          {
            "id": "month-2",
            "title": "2월",
            "focus": "이달의 집중 영역",
            "deliverables": ["산출물 1", "산출물 2"],
            "metrics": "측정 지표",
            "dependencies": "1월 완료 필요",
            "weeks": [
              {"id": "week-5", "title": "5주차", "goal": "목표", "suggestedQuests": ["행동1", "행동2", "행동3"], "checkpoint": "질문", "riskMitigation": "대응"},
              {"id": "week-6", "title": "6주차", "goal": "목표", "suggestedQuests": ["행동1", "행동2", "행동3"], "checkpoint": "질문", "riskMitigation": "대응"},
              {"id": "week-7", "title": "7주차", "goal": "목표", "suggestedQuests": ["행동1", "행동2", "행동3"], "checkpoint": "질문", "riskMitigation": "대응"},
              {"id": "week-8", "title": "8주차", "goal": "목표", "suggestedQuests": ["행동1", "행동2", "행동3"], "checkpoint": "질문", "riskMitigation": "대응"}
            ]
          },
          {
            "id": "month-3",
            "title": "3월",
            "focus": "이달의 집중 영역",
            "deliverables": ["산출물 1", "산출물 2"],
            "metrics": "측정 지표",
            "dependencies": "2월 완료 필요",
            "weeks": [
              {"id": "week-9", "title": "9주차", "goal": "목표", "suggestedQuests": ["행동1", "행동2", "행동3"], "checkpoint": "질문", "riskMitigation": "대응"},
              {"id": "week-10", "title": "10주차", "goal": "목표", "suggestedQuests": ["행동1", "행동2", "행동3"], "checkpoint": "질문", "riskMitigation": "대응"},
              {"id": "week-11", "title": "11주차", "goal": "목표", "suggestedQuests": ["행동1", "행동2", "행동3"], "checkpoint": "질문", "riskMitigation": "대응"},
              {"id": "week-12", "title": "12주차", "goal": "목표", "suggestedQuests": ["행동1", "행동2", "행동3"], "checkpoint": "질문", "riskMitigation": "대응"}
            ]
          },
          {
            "id": "month-4",
            "title": "4월",
            "focus": "1분기 마무리 및 중간 점검",
            "deliverables": ["분기 프로젝트 완성", "회고 및 조정"],
            "metrics": "분기 목표 달성률",
            "dependencies": "1-3월 진행 상황"
          }
        ]
      },
      {
        "id": "q2",
        "title": "2분기 (5-8월): 핵심 테마",
        "objective": "분기 목표",
        "keyResults": ["핵심 결과 1", "핵심 결과 2"],
        "months": [
          {"id": "month-5", "title": "5월", "focus": "집중 영역", "deliverables": ["산출물"], "metrics": "지표", "dependencies": "1분기 완료"},
          {"id": "month-6", "title": "6월", "focus": "집중 영역", "deliverables": ["산출물"], "metrics": "지표", "dependencies": "5월"},
          {"id": "month-7", "title": "7월", "focus": "집중 영역", "deliverables": ["산출물"], "metrics": "지표", "dependencies": "6월"},
          {"id": "month-8", "title": "8월", "focus": "집중 영역", "deliverables": ["산출물"], "metrics": "지표", "dependencies": "7월"}
        ]
      },
      {
        "id": "q3",
        "title": "3분기 (9-12월): 핵심 테마",
        "objective": "분기 목표",
        "keyResults": ["핵심 결과 1", "핵심 결과 2"],
        "months": [
          {"id": "month-9", "title": "9월", "focus": "집중 영역", "deliverables": ["산출물"], "metrics": "지표", "dependencies": "2분기 완료"},
          {"id": "month-10", "title": "10월", "focus": "집중 영역", "deliverables": ["산출물"], "metrics": "지표", "dependencies": "9월"},
          {"id": "month-11", "title": "11월", "focus": "집중 영역", "deliverables": ["산출물"], "metrics": "지표", "dependencies": "10월"},
          {"id": "month-12", "title": "12월", "focus": "최종 마무리 및 1년 회고", "deliverables": ["최종 산출물", "1년 회고"], "metrics": "연간 목표 달성률", "dependencies": "9-11월"}
        ]
      }
    ]
  }
]

**중요 체크리스트**:
- [ ] 각 퀘스트가 30분~2시간 내 완료 가능한가?
- [ ] 성공 여부를 명확히 판단할 수 있는가?
- [ ] 이전 단계 없이도 시작 가능한가? (의존성 체크)
- [ ] 습관이 될 만한 반복 행동이 포함되어 있는가?
- [ ] 너무 완벽주의적이지 않고 실패해도 재시작 가능한가?`

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
            content: '당신은 SMART 목표 설정과 프로젝트 관리 전문가입니다. OKR, 애자일, 습관 쌓기 이론을 활용하여 실행 가능한 로드맵을 설계합니다.',
          },
          {
            role: 'user',
            content: prompt,
          },
        ],
        temperature: 0.75,
        max_tokens: 4000,
      }),
    })

    if (!openaiResponse.ok) {
      const errorData = await openaiResponse.json()
      throw new Error(`OpenAI API error: ${JSON.stringify(errorData)}`)
    }

    const openaiData = await openaiResponse.json()
    const goalTreeContent = openaiData.choices[0].message.content

    // JSON 파싱
    let goalTreeJSON
    try {
      goalTreeJSON = JSON.parse(goalTreeContent)
    } catch (e) {
      console.error('JSON parsing failed:', e)
      goalTreeJSON = []
    }

    // 4. 목표 트리 저장
    const { error: saveError } = await supabaseClient
      .from('goal_trees')
      .insert({
        user_id: user.id,
        tree_data: goalTreeJSON,
      })

    if (saveError) {
      console.error('Error saving goal tree:', saveError)
    }

    // 5. AI 사용량 로깅
    const tokensUsed = openaiData.usage?.total_tokens || 0
    const costUSD = tokensUsed * 0.000002

    await supabaseClient.from('ai_generation_logs').insert({
      user_id: user.id,
      generation_type: 'goal_tree',
      tokens_used: tokensUsed,
      cost_usd: costUSD,
    })

    return new Response(
      JSON.stringify({
        goalTree: goalTreeJSON,
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
