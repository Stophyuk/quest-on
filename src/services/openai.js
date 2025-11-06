import OpenAI from 'openai'

// OpenAI 클라이언트 초기화
const openai = new OpenAI({
  apiKey: import.meta.env.VITE_OPENAI_API_KEY,
  dangerouslyAllowBrowser: true // 브라우저에서 사용 (프로덕션에서는 백엔드 권장)
})

/**
 * 비전 설문 결과를 바탕으로 구조화된 비전 노트 생성
 * @param {Object} visionProfile - 설문 결과 객체
 * @returns {Promise<Object>} AI 생성 비전 노트 (JSON 구조)
 */
export async function generateVisionNote(visionProfile) {
  try {
    const prompt = `당신은 10년 이상의 경력을 가진 전문 라이프 코치입니다. 사용자의 응답을 깊이 분석하여 그들 스스로도 미처 깨닫지 못한 패턴과 가능성을 발견하고, 실질적인 통찰을 제공합니다.

=== 사용자 응답 분석 ===

**핵심 가치관**: ${visionProfile.values.join(', ')}
**현재 자기 인식**: ${visionProfile.currentIdentity}
**5년 후 이상적 모습**: ${visionProfile.futureIdentity}
**궁극적 인생 비전**: ${visionProfile.lifeDream}
**현재 주요 고민/장애물**: ${visionProfile.concerns}
**1년 목표 (우선순위순)**:
${visionProfile.yearGoals.map((goal, i) => `  ${i + 1}. ${goal}`).join('\n')}
**일상 패턴 및 에너지 흐름**: ${visionProfile.currentRoutine}
**현실적 투자 가능 시간**: 하루 ${visionProfile.availableTime}시간
**효과적인 학습 방식**: ${visionProfile.learningStyle}
**핵심 동기부여 요소**: ${visionProfile.motivation}

=== 작성 지침 ===

다음 JSON 구조로 비전 노트를 작성하세요. 각 항목은 단순 요약이 아닌 **심층 분석과 통찰**을 담아야 합니다:

{
  "understanding": {
    "currentPosition": "현재 정체성에서 드러나는 핵심 특성을 2-3가지 분석 (100-150자)",
    "innerConflict": "고민에서 발견되는 심층 패턴 분석. 왜 이런 고민이 생기는지, 이것이 성장에 어떤 의미인지 (100-150자)"
  },
  "growthFormula": {
    "valueAnalysis": "선택한 가치관들 간의 연결고리와 우선순위 분석 (100-150자)",
    "visionCore": "5년 후 모습과 인생의 꿈을 통합 분석. 표면적 목표 너머의 진짜 바람 (100-150자)"
  },
  "oneYearChange": {
    "overview": "1년 목표들의 상호 연관성과 시너지를 분석 (100-150자)",
    "milestones": ["마일스톤1", "마일스톤2", "마일스톤3"],
    "challenges": ["도전1", "도전2"],
    "strategies": ["전략1", "전략2", "전략3"]
  },
  "actionStrategy": {
    "timeDesign": "하루 ${visionProfile.availableTime}시간을 루틴과 에너지 흐름 고려하여 활용하는 구체적 방법 (80-120자)",
    "learningOptimization": "선호 학습 방식의 강점을 극대화하는 구체적 방법 (80-120자)",
    "motivationSystem": "동기부여 요소를 활용한 지속 가능한 습관 설계 (80-120자)"
  },
  "coachingInsight": {
    "message": "응답 전체에서 발견한 강점과 잠재력을 구체적으로 지적. 고민을 성장의 신호로 재프레이밍. 진심 어린 응원과 명확한 다음 단계 제시 (150-200자)"
  }
}

=== 작성 원칙 ===
- 반드시 위 JSON 구조만 반환하세요 (다른 텍스트 없이)
- 사용자가 쓴 문장을 그대로 반복하지 마세요
- 표면적 내용 너머의 패턴과 의미를 발견하세요
- 추상적 격려보다 구체적 통찰을 제공하세요
- 존댓말 사용, 따뜻하되 전문적인 톤 유지
- 각 문자열은 지정된 글자 수를 준수하세요`

    const response = await openai.chat.completions.create({
      model: 'gpt-4o-mini',
      messages: [
        {
          role: 'system',
          content: `당신은 심리학과 코칭 전문가입니다.
- 단순 요약이 아닌 패턴 분석과 통찰 제공
- 사용자의 문장을 그대로 반복하지 않고 재해석
- 구체적이고 실행 가능한 전략 제시
- 반드시 유효한 JSON만 반환 (추가 텍스트 없이)`
        },
        {
          role: 'user',
          content: prompt
        }
      ],
      temperature: 0.8,
      max_tokens: 2500,
      response_format: { type: "json_object" }
    })

    const content = response.choices[0].message.content
    const visionNote = JSON.parse(content)

    return visionNote
  } catch (error) {
    console.error('비전 노트 생성 실패:', error)
    throw new Error('AI 비전 노트를 생성하는 중 오류가 발생했습니다.')
  }
}

/**
 * 비전 노트와 연간 목표를 바탕으로 목표 트리 생성
 * @param {string} visionNote - AI 생성 비전 노트
 * @param {Array<string>} yearGoals - 1년 목표 배열
 * @returns {Promise<Array>} 구조화된 목표 트리
 */
export async function generateGoalTree(visionNote, yearGoals) {
  try {
    const prompt = `당신은 목표 설정 전문가입니다. 사용자의 비전과 연간 목표를 실행 가능한 계층적 목표 트리로 변환해주세요.

**비전 노트**:
${visionNote}

**1년 목표**:
${yearGoals.map((goal, i) => `${i + 1}. ${goal}`).join('\n')}

다음 JSON 형식으로 목표 트리를 생성해주세요:

\`\`\`json
[
  {
    "id": "goal-1",
    "title": "목표 제목",
    "type": "yearly",
    "description": "목표 설명",
    "quarters": [
      {
        "id": "q1-1",
        "title": "1분기 목표",
        "type": "quarterly",
        "months": [
          {
            "id": "m1-1",
            "title": "1월 목표",
            "type": "monthly",
            "weeks": [
              {
                "id": "w1-1",
                "title": "1주차 목표",
                "type": "weekly",
                "suggestedQuests": [
                  "구체적 실행 항목 1",
                  "구체적 실행 항목 2"
                ]
              }
            ]
          }
        ]
      }
    ]
  }
]
\`\`\`

**요구사항**:
1. 각 연간 목표를 4개 분기로 나눔
2. 각 분기를 3개월로 세분화
3. 첫 달의 첫 주만 구체적으로 작성 (나머지는 생략)
4. 첫 주의 실행 항목(suggestedQuests)은 3-5개 제안
5. 모든 목표는 측정 가능하고 실현 가능해야 함

**JSON만 반환하세요** (설명 없이)`

    const response = await openai.chat.completions.create({
      model: 'gpt-4o-mini',
      messages: [
        {
          role: 'system',
          content: '당신은 목표를 계층적으로 구조화하는 전문가입니다. 항상 유효한 JSON만 반환합니다.'
        },
        {
          role: 'user',
          content: prompt
        }
      ],
      temperature: 0.5,
      max_tokens: 3000,
      response_format: { type: 'json_object' }
    })

    const result = JSON.parse(response.choices[0].message.content)
    return result.goals || result // 구조에 따라 유연하게 처리
  } catch (error) {
    console.error('목표 트리 생성 실패:', error)
    throw new Error('목표 트리를 생성하는 중 오류가 발생했습니다.')
  }
}

/**
 * 주간 목표를 기반으로 일일 퀘스트 제안
 * @param {Object} weeklyGoal - 주간 목표 객체
 * @param {Array} completedQuests - 이미 완료한 퀘스트 목록
 * @param {number} availableTime - 사용자가 하루에 사용할 수 있는 시간
 * @returns {Promise<Array>} 제안된 일일 퀘스트 배열
 */
export async function suggestDailyQuests(weeklyGoal, completedQuests = [], availableTime = 2) {
  try {
    const completedTitles = completedQuests.map(q => q.title).join(', ')

    const prompt = `당신은 일일 퀘스트를 제안하는 AI 코치입니다.

**이번 주 목표**: ${weeklyGoal.title}

**이미 완료한 퀘스트**: ${completedTitles || '없음'}

**사용 가능한 시간**: 하루 ${availableTime}시간

오늘 수행할 퀘스트 3-5개를 제안해주세요. 다음 JSON 형식으로 반환하세요:

\`\`\`json
{
  "quests": [
    {
      "title": "퀘스트 제목 (구체적이고 실행 가능하게)",
      "difficulty": "easy|normal|hard",
      "estimatedTime": "예상 소요 시간 (분)",
      "reason": "이 퀘스트를 추천하는 이유 (1문장)"
    }
  ]
}
\`\`\`

**요구사항**:
1. 총 예상 소요 시간이 ${availableTime}시간을 넘지 않도록
2. 이미 완료한 퀘스트는 제외
3. easy: 30분 이하, normal: 30-60분, hard: 60분 이상
4. 주간 목표와 직접적으로 연결된 퀘스트만 제안
5. 구체적이고 측정 가능한 퀘스트

**JSON만 반환하세요**`

    const response = await openai.chat.completions.create({
      model: 'gpt-4o-mini',
      messages: [
        {
          role: 'system',
          content: '당신은 실행 가능한 일일 퀘스트를 제안하는 전문가입니다.'
        },
        {
          role: 'user',
          content: prompt
        }
      ],
      temperature: 0.6,
      max_tokens: 1000,
      response_format: { type: 'json_object' }
    })

    const result = JSON.parse(response.choices[0].message.content)
    return result.quests || []
  } catch (error) {
    console.error('일일 퀘스트 제안 실패:', error)
    throw new Error('일일 퀘스트를 제안하는 중 오류가 발생했습니다.')
  }
}

/**
 * 주간 회고와 통계를 바탕으로 AI 코칭 메시지 생성
 * @param {Object} weeklyStats - 주간 통계 데이터
 * @param {Object} reflection - 사용자 회고 내용
 * @returns {Promise<string>} AI 코칭 메시지
 */
export async function generateCoaching(weeklyStats, reflection) {
  try {
    const prompt = `당신은 공감 능력이 뛰어난 라이프 코치입니다. 사용자의 주간 활동을 분석하고 따뜻한 코칭을 제공해주세요.

**이번 주 통계**:
- 완료한 퀘스트: ${weeklyStats.totalCompleted}개
- 난이도별: Easy ${weeklyStats.easy}개, Normal ${weeklyStats.normal}개, Hard ${weeklyStats.hard}개
- 획득 경험치: ${weeklyStats.totalXP} XP
- 완료율: ${weeklyStats.completionRate}%

**사용자 회고**:
- 성취한 것: ${reflection.achievements}
- 어려웠던 점: ${reflection.challenges}
- 깨달은 점: ${reflection.insights}

다음 구조로 코칭 메시지를 작성해주세요:

## 🎉 이번 주 성과
[구체적인 숫자와 함께 성과를 칭찬]

## 💪 성장 포인트
[어려웠던 점을 공감하고, 그 속에서 발견한 성장 요소]

## 📈 다음 주 전략
[통계와 회고를 바탕으로 구체적인 개선 방안 2-3가지 제안]

## 💭 코치의 한마디
[따뜻하고 동기부여되는 마무리 메시지]

**중요**:
- 구체적인 수치를 활용
- 비판보다는 격려와 제안
- 실행 가능한 조언
- 300-500자 분량`

    const response = await openai.chat.completions.create({
      model: 'gpt-4o-mini',
      messages: [
        {
          role: 'system',
          content: '당신은 따뜻하고 통찰력 있는 라이프 코치입니다. 사용자의 노력을 인정하고 건설적인 피드백을 제공합니다.'
        },
        {
          role: 'user',
          content: prompt
        }
      ],
      temperature: 0.7,
      max_tokens: 1200
    })

    return response.choices[0].message.content
  } catch (error) {
    console.error('AI 코칭 생성 실패:', error)
    throw new Error('AI 코칭 메시지를 생성하는 중 오류가 발생했습니다.')
  }
}

/**
 * API 연결 테스트
 * @returns {Promise<boolean>} 연결 성공 여부
 */
export async function testConnection() {
  try {
    const response = await openai.chat.completions.create({
      model: 'gpt-4o-mini',
      messages: [{ role: 'user', content: 'Hello' }],
      max_tokens: 10
    })
    return true
  } catch (error) {
    console.error('OpenAI API 연결 실패:', error)
    return false
  }
}
