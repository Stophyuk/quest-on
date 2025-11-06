// supabase/functions/generate-vision-note/index.ts

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const ANTHROPIC_API_KEY = Deno.env.get("ANTHROPIC_API_KEY");

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
    const { name, values, goal, reasons } = await req.json();

    // 입력 검증
    if (!name || !values || !goal || !reasons) {
      throw new Error("필수 파라미터가 누락되었습니다");
    }

    // Claude API 호출
    const response = await fetch("https://api.anthropic.com/v1/messages", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "x-api-key": ANTHROPIC_API_KEY!,
        "anthropic-version": "2023-06-01",
      },
      body: JSON.stringify({
        model: "claude-3-5-sonnet-20241022",
        max_tokens: 1024,
        messages: [
          {
            role: "user",
            content: `당신은 전문 라이프 코치입니다. 다음 정보를 바탕으로 ${name}님을 위한 맞춤형 비전 노트를 작성해주세요.

**가치관**: ${values.join(", ")}
**목표**: ${goal}
**이유**: ${reasons.join(", ")}

다음 형식으로 작성해주세요:

1. ${name}님의 핵심 가치와 목표가 어떻게 연결되는지 설명 (2-3문장)
2. 목표를 달성했을 때의 긍정적인 변화 (2-3문장)
3. 실천을 위한 핵심 마인드셋 (2-3문장)

총 200-300자 이내로 간결하고 동기부여가 되도록 작성해주세요.`,
          },
        ],
      }),
    });

    if (!response.ok) {
      throw new Error(`Claude API 오류: ${response.statusText}`);
    }

    const data = await response.json();
    const visionNote = data.content[0].text;

    return new Response(
      JSON.stringify({ visionNote }),
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
