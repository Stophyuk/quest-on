// supabase/functions/generate-goal-tree/index.ts

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const OPENAI_API_KEY = Deno.env.get("OPENAI_API_KEY");

serve(async (req) => {
  // CORS 헤더
  const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers":
      "authorization, x-client-info, apikey, content-type",
  };

  // Preflight 요청 처리
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { visionNote, goal } = await req.json();

    // 입력 검증
    if (!visionNote || !goal) {
      throw new Error("필수 파라미터가 누락되었습니다");
    }

    // OpenAI API 호출
    const response = await fetch("https://api.openai.com/v1/chat/completions", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${OPENAI_API_KEY}`,
      },
      body: JSON.stringify({
        model: "gpt-4o-mini",
        messages: [
          {
            role: "system",
            content: `당신은 행동 심리학과 목표 달성 전문가인 전문 라이프 코치입니다.

다음 원칙을 바탕으로 실행 로드맵을 작성합니다:
- 작은 성공 경험 축적 (Small Wins Strategy)
- 점진적 난이도 증가 (Progressive Overload)
- 구체적이고 측정 가능한 목표 (SMART Goals)
- 장애물 예측 및 대처 방안 준비
- 지속 가능한 습관 형성 중심`,
          },
          {
            role: "user",
            content: `다음 비전 노트와 목표를 바탕으로 실행 로드맵을 작성해주세요.

**비전 노트**:
${visionNote}

**최종 목표**:
${goal}

**로드맵 작성 가이드**:

4-6개의 마일스톤을 작성하되, 다음 구조를 따라주세요:

1. **초기 단계** (1-2개): 쉽고 빠른 성공 경험
   - 목표를 향한 첫 걸음
   - 동기 부여와 자신감 형성에 집중
   - 기간: 1-2주 정도

2. **중기 단계** (2-3개): 핵심 습관 및 시스템 구축
   - 지속 가능한 루틴 만들기
   - 구체적인 기술이나 지식 습득
   - 기간: 3-6주 정도

3. **심화 단계** (1-2개): 목표 달성을 위한 최종 도약
   - 더 높은 수준의 도전
   - 최종 목표에 근접
   - 기간: 4-8주 정도

**JSON 형식**:
{
  "milestones": [
    {
      "title": "마일스톤 제목 (명확하고 동기부여되는 표현, 15자 이내)",
      "description": "구체적인 실행 내용. 무엇을(What), 어떻게(How), 왜(Why) 포함. (60-80자)",
      "duration": "예상 소요 기간 (예: 1-2주, 3-4주, 1-2개월)",
      "successCriteria": "성공 여부를 판단할 수 있는 구체적인 기준 (30-50자)",
      "potentialObstacles": "예상되는 어려움과 대처 방안 (50-70자)",
      "keyActions": [
        "실천할 수 있는 구체적인 액션 1 (20-30자)",
        "실천할 수 있는 구체적인 액션 2 (20-30자)",
        "실천할 수 있는 구체적인 액션 3 (20-30자)"
      ]
    }
  ]
}

**중요 사항**:
- 각 마일스톤은 이전 단계의 성과를 바탕으로 점진적으로 발전
- 모든 필드를 빠짐없이 작성
- 반드시 유효한 JSON 형식으로만 응답
- 추가 설명이나 마크다운 포맷 사용 금지`,
          },
        ],
        temperature: 0.7,
        max_tokens: 2500,
        response_format: { type: "json_object" },
      }),
    });

    if (!response.ok) {
      const errorData = await response.json();
      throw new Error(`OpenAI API 오류: ${errorData.error?.message || response.statusText}`);
    }

    const data = await response.json();
    let goalTreeText = data.choices[0].message.content;

    let goalTree;
    try {
      goalTree = JSON.parse(goalTreeText);
    } catch (parseError) {
      console.error("JSON 파싱 오류:", goalTreeText);
      throw new Error("AI 응답을 JSON으로 파싱할 수 없습니다");
    }

    return new Response(
      JSON.stringify({ goalTree }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 200,
      }
    );
  } catch (error) {
    console.error("Error:", error);
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 400,
      }
    );
  }
});
