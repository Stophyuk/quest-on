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
            content: "당신은 전문 라이프 코치입니다. 비전 노트를 바탕으로 구체적이고 실행 가능한 로드맵을 JSON 형식으로 작성합니다.",
          },
          {
            role: "user",
            content: `다음 비전 노트와 목표를 바탕으로 구체적인 실행 로드맵을 작성해주세요.

**비전 노트**:
${visionNote}

**목표**:
${goal}

다음 JSON 형식으로 3-5개의 마일스톤을 작성해주세요. 각 마일스톤은 시간 순서대로 배열되어야 합니다:

{
  "milestones": [
    {
      "title": "1단계 제목 (간결하게)",
      "description": "구체적인 실행 내용 (1-2문장)",
      "duration": "예상 기간 (예: 1-2주, 1개월)"
    },
    {
      "title": "2단계 제목",
      "description": "구체적인 실행 내용",
      "duration": "예상 기간"
    }
  ]
}

반드시 유효한 JSON 형식으로만 응답해주세요. 추가 설명은 포함하지 마세요.`,
          },
        ],
        temperature: 0.7,
        max_tokens: 1000,
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
