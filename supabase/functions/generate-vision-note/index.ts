// supabase/functions/generate-vision-note/index.ts

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
    const { name, values, goal, reasons } = await req.json();

    // 입력 검증
    if (!name || !values || !goal || !reasons) {
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
            content: `당신은 심리학과 행동 변화 전문가인 전문 라이프 코치입니다.

다음 원칙을 바탕으로 비전 노트를 작성합니다:
- 성장 마인드셋 (Growth Mindset) 강조
- SMART 목표 프레임워크 활용
- 자기 효능감 (Self-Efficacy) 향상
- 내재적 동기 (Intrinsic Motivation) 유발
- 구체적인 실행 전략 제시`,
          },
          {
            role: "user",
            content: `${name}님을 위한 맞춤형 비전 노트를 작성해주세요.

**${name}님 프로필**:
• 핵심 가치: ${values.join(", ")}
• 달성하고 싶은 목표: ${goal}
• 목표를 이루고자 하는 이유: ${reasons.join(", ")}

**작성 가이드**:

1. **가치-목표 연결 분석** (80-100자)
   - ${name}님의 가치관(${values.join(", ")})이 목표와 어떻게 연결되는지 분석
   - 이 목표가 ${name}님의 삶에서 어떤 의미를 갖는지 설명

2. **비전 구체화** (100-120자)
   - 목표 달성 후 ${name}님의 모습을 생생하게 묘사
   - 긍정적 변화가 일상에 어떻게 나타날지 구체적으로 표현
   - 내재적 보상 (자존감, 성취감, 만족감) 강조

3. **실천 마인드셋** (80-100자)
   - 성장 과정에서 겪을 어려움을 자연스러운 것으로 프레이밍
   - 작은 진전도 의미 있다는 점 강조
   - 자기 자비 (Self-Compassion)의 중요성 언급

4. **핵심 실행 원칙** (60-80자)
   - ${name}님이 매일 실천할 수 있는 구체적인 행동 원칙 1-2가지
   - 습관 형성을 위한 실용적인 팁

**톤앤매너**:
- 따뜻하고 격려하는 어조 유지
- 구체적이고 실천 가능한 표현 사용
- "~해야 한다" 대신 "~할 수 있습니다" 같은 자율성 존중 표현 사용
- ${name}님이 이미 변화를 시작한 사람처럼 느낄 수 있도록 작성

총 320-400자 내외로 작성해주세요.`,
          },
        ],
        temperature: 0.7,
        max_tokens: 800,
      }),
    });

    if (!response.ok) {
      const errorData = await response.json();
      throw new Error(`OpenAI API 오류: ${errorData.error?.message || response.statusText}`);
    }

    const data = await response.json();
    const visionNote = data.choices[0].message.content;

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
