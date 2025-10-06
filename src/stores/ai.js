// AI 기반 퀘스트 추천 및 분석 시스템
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export const useAIStore = defineStore('ai', () => {
  const isAnalyzing = ref(false)
  const lastAnalysis = ref(null)
  
  // 퀘스트 카테고리별 데이터베이스
  const questDatabase = ref({
    health: [
      {
        id: 'water_8',
        title: '물 8잔 마시기',
        description: '하루 권장 수분 섭취량 달성',
        difficulty: { '😊': 8, '😐': 6, '😞': 4 },
        tags: ['hydration', 'health', 'daily'],
        timeRequired: 10,
        benefits: ['수분 보충', '피부 개선', '집중력 향상']
      },
      {
        id: 'sleep_8h',
        title: '8시간 숙면',
        description: '충분한 휴식으로 컨디션 회복',
        difficulty: { '😊': 8, '😐': 7, '😞': 6 },
        tags: ['sleep', 'recovery', 'health'],
        timeRequired: 480,
        benefits: ['체력 회복', '면역력 강화', '기분 개선']
      },
      {
        id: 'meditation',
        title: '명상하기',
        description: '마음의 평온과 집중력 향상',
        difficulty: { '😊': 20, '😐': 15, '😞': 5 },
        tags: ['mindfulness', 'mental', 'calm'],
        timeRequired: 15,
        benefits: ['스트레스 해소', '집중력 향상', '감정 조절']
      },
      {
        id: 'vitamins',
        title: '비타민 섭취',
        description: '영양 보충제로 건강 관리',
        difficulty: { '😊': 1, '😐': 1, '😞': 1 },
        tags: ['nutrition', 'supplement', 'daily'],
        timeRequired: 2,
        benefits: ['영양 보충', '면역력 강화', '에너지 증진']
      }
    ],
    fitness: [
      {
        id: 'walk_30min',
        title: '30분 산책',
        description: '가벼운 유산소 운동으로 건강 증진',
        difficulty: { '😊': 30, '😐': 20, '😞': 10 },
        tags: ['cardio', 'outdoor', 'gentle'],
        timeRequired: 30,
        benefits: ['혈액순환', '기분 전환', '체력 증진']
      },
      {
        id: 'stretching',
        title: '스트레칭',
        description: '몸의 긴장을 풀고 유연성 향상',
        difficulty: { '😊': 15, '😐': 10, '😞': 5 },
        tags: ['flexibility', 'relaxation', 'mobility'],
        timeRequired: 15,
        benefits: ['근육 이완', '자세 개선', '부상 예방']
      },
      {
        id: 'pushups',
        title: '팔굽혀펴기',
        description: '상체 근력 강화 운동',
        difficulty: { '😊': 20, '😐': 15, '😞': 5 },
        tags: ['strength', 'upper-body', 'home'],
        timeRequired: 10,
        benefits: ['근력 증진', '체형 개선', '자신감 향상']
      },
      {
        id: 'stairs',
        title: '계단 오르기',
        description: '일상 속 간단한 운동',
        difficulty: { '😊': 5, '😐': 3, '😞': 2 },
        tags: ['cardio', 'daily', 'convenient'],
        timeRequired: 5,
        benefits: ['하체 강화', '심폐 기능', '칼로리 소모']
      }
    ],
    learning: [
      {
        id: 'reading',
        title: '독서하기',
        description: '책을 통한 지식과 교양 쌓기',
        difficulty: { '😊': 60, '😐': 30, '😞': 15 },
        tags: ['knowledge', 'brain', 'culture'],
        timeRequired: 45,
        benefits: ['지식 확장', '어휘력 증진', '상상력 개발']
      },
      {
        id: 'language',
        title: '외국어 공부',
        description: '새로운 언어 학습으로 역량 개발',
        difficulty: { '😊': 30, '😐': 20, '😞': 10 },
        tags: ['language', 'skill', 'communication'],
        timeRequired: 25,
        benefits: ['의사소통', '문화 이해', '뇌 활성화']
      },
      {
        id: 'podcast',
        title: '팟캐스트 듣기',
        description: '유익한 콘텐츠로 지식 습득',
        difficulty: { '😊': 30, '😐': 20, '😞': 10 },
        tags: ['audio', 'knowledge', 'convenient'],
        timeRequired: 25,
        benefits: ['정보 습득', '멀티태스킹', '시야 확장']
      },
      {
        id: 'skill_practice',
        title: '새로운 기술 연습',
        description: '업무나 취미 관련 기술 향상',
        difficulty: { '😊': 60, '😐': 40, '😞': 20 },
        tags: ['skill', 'practice', 'improvement'],
        timeRequired: 45,
        benefits: ['실력 향상', '자기계발', '경쟁력 강화']
      }
    ],
    work: [
      {
        id: 'planning',
        title: '하루 계획 세우기',
        description: '효율적인 시간 관리를 위한 계획 수립',
        difficulty: { '😊': 1, '😐': 1, '😞': 1 },
        tags: ['planning', 'productivity', 'organization'],
        timeRequired: 10,
        benefits: ['시간 관리', '목표 명확화', '스트레스 감소']
      },
      {
        id: 'email_clean',
        title: '이메일 정리',
        description: '받은편지함 정리로 업무 효율성 증대',
        difficulty: { '😊': 50, '😐': 30, '😞': 10 },
        tags: ['organization', 'digital', 'productivity'],
        timeRequired: 20,
        benefits: ['업무 효율', '스트레스 감소', '집중력 향상']
      },
      {
        id: 'skill_study',
        title: '업무 관련 학습',
        description: '전문성 향상을 위한 공부',
        difficulty: { '😊': 90, '😐': 60, '😞': 30 },
        tags: ['professional', 'development', 'career'],
        timeRequired: 60,
        benefits: ['전문성 향상', '승진 기회', '자신감 증진']
      }
    ],
    hobby: [
      {
        id: 'music',
        title: '음악 감상',
        description: '좋아하는 음악으로 감성 충전',
        difficulty: { '😊': 30, '😐': 20, '😞': 10 },
        tags: ['entertainment', 'emotion', 'relaxation'],
        timeRequired: 25,
        benefits: ['감정 조절', '스트레스 해소', '영감 얻기']
      },
      {
        id: 'drawing',
        title: '그림 그리기',
        description: '창의적 표현으로 마음 표현',
        difficulty: { '😊': 60, '😐': 30, '😞': 15 },
        tags: ['creative', 'art', 'expression'],
        timeRequired: 45,
        benefits: ['창의력 개발', '집중력 향상', '감정 표현']
      },
      {
        id: 'cooking',
        title: '요리하기',
        description: '건강한 음식 만들기',
        difficulty: { '😊': 60, '😐': 40, '😞': 20 },
        tags: ['cooking', 'nutrition', 'creative'],
        timeRequired: 45,
        benefits: ['영양 관리', '창의력', '성취감']
      }
    ]
  })

  // 사용자 패턴 분석
  function analyzeUserPatterns(questHistory, moodHistory) {
    isAnalyzing.value = true
    
    try {
      const analysis = {
        preferredCategories: analyzePreferredCategories(questHistory),
        optimalDifficulty: analyzeOptimalDifficulty(questHistory, moodHistory),
        timePreference: analyzeTimePreference(questHistory),
        moodPatterns: analyzeMoodPatterns(moodHistory),
        completionTrends: analyzeCompletionTrends(questHistory),
        recommendations: []
      }
      
      // AI 추천 생성
      analysis.recommendations = generateRecommendations(analysis)
      
      lastAnalysis.value = {
        ...analysis,
        timestamp: new Date().toISOString()
      }
      
      return analysis
    } finally {
      isAnalyzing.value = false
    }
  }

  // 선호 카테고리 분석
  function analyzePreferredCategories(questHistory) {
    const categoryStats = {}
    
    questHistory.forEach(quest => {
      const category = quest.category
      if (!categoryStats[category]) {
        categoryStats[category] = { completed: 0, total: 0, rate: 0 }
      }
      categoryStats[category].total++
      if (quest.completed) {
        categoryStats[category].completed++
      }
    })
    
    // 완료율 계산
    Object.keys(categoryStats).forEach(category => {
      const stats = categoryStats[category]
      stats.rate = stats.total > 0 ? (stats.completed / stats.total) * 100 : 0
    })
    
    return Object.entries(categoryStats)
      .sort(([,a], [,b]) => b.rate - a.rate)
      .map(([category, stats]) => ({ category, ...stats }))
  }

  // 최적 난이도 분석
  function analyzeOptimalDifficulty(questHistory, moodHistory) {
    const moodDifficultySuccess = {
      '😊': { success: 0, total: 0 },
      '😐': { success: 0, total: 0 },
      '😞': { success: 0, total: 0 }
    }
    
    // 기분별 성공률 분석
    questHistory.forEach(quest => {
      const mood = quest.mood || '😐'
      const difficulty = quest.targetValue || quest.difficulty[mood]
      
      if (moodDifficultySuccess[mood]) {
        moodDifficultySuccess[mood].total++
        if (quest.completed) {
          moodDifficultySuccess[mood].success++
        }
      }
    })
    
    return moodDifficultySuccess
  }

  // 시간 선호도 분석
  function analyzeTimePreference(questHistory) {
    const timeStats = {
      morning: 0,
      afternoon: 0,
      evening: 0
    }
    
    questHistory.forEach(quest => {
      if (quest.completedAt) {
        const hour = new Date(quest.completedAt).getHours()
        if (hour < 12) timeStats.morning++
        else if (hour < 18) timeStats.afternoon++
        else timeStats.evening++
      }
    })
    
    return timeStats
  }

  // 기분 패턴 분석
  function analyzeMoodPatterns(moodHistory) {
    const patterns = {
      averageCompletion: {
        '😊': 0,
        '😐': 0,
        '😞': 0
      },
      moodFrequency: {
        '😊': 0,
        '😐': 0,
        '😞': 0
      }
    }
    
    moodHistory.forEach(entry => {
      patterns.moodFrequency[entry.mood]++
      patterns.averageCompletion[entry.mood] += entry.completionRate
    })
    
    // 평균 계산
    Object.keys(patterns.averageCompletion).forEach(mood => {
      const frequency = patterns.moodFrequency[mood]
      if (frequency > 0) {
        patterns.averageCompletion[mood] /= frequency
      }
    })
    
    return patterns
  }

  // 완료 트렌드 분석
  function analyzeCompletionTrends(questHistory) {
    const recent7Days = questHistory.slice(-7)
    const totalCompletions = recent7Days.filter(q => q.completed).length
    const totalQuests = recent7Days.length
    
    return {
      recentCompletionRate: totalQuests > 0 ? (totalCompletions / totalQuests) * 100 : 0,
      streak: calculateCurrentStreak(questHistory),
      bestCategory: getBestPerformingCategory(questHistory)
    }
  }

  // 현재 연속 달성 계산
  function calculateCurrentStreak(questHistory) {
    let streak = 0
    for (let i = questHistory.length - 1; i >= 0; i--) {
      if (questHistory[i].completed) {
        streak++
      } else {
        break
      }
    }
    return streak
  }

  // 가장 성과가 좋은 카테고리
  function getBestPerformingCategory(questHistory) {
    const categoryStats = {}
    
    questHistory.forEach(quest => {
      const category = quest.category
      if (!categoryStats[category]) {
        categoryStats[category] = { completed: 0, total: 0 }
      }
      categoryStats[category].total++
      if (quest.completed) {
        categoryStats[category].completed++
      }
    })
    
    let bestCategory = null
    let bestRate = 0
    
    Object.entries(categoryStats).forEach(([category, stats]) => {
      const rate = stats.total > 0 ? (stats.completed / stats.total) * 100 : 0
      if (rate > bestRate) {
        bestRate = rate
        bestCategory = category
      }
    })
    
    return { category: bestCategory, rate: bestRate }
  }

  // AI 추천 생성
  function generateRecommendations(analysis) {
    const recommendations = []
    
    // 1. 성과가 좋은 카테고리에서 새로운 퀘스트 추천
    if (analysis.preferredCategories.length > 0) {
      const topCategory = analysis.preferredCategories[0].category
      const availableQuests = questDatabase.value[topCategory] || []
      
      recommendations.push({
        type: 'category-based',
        title: `${getCategoryLabel(topCategory)} 관련 추천`,
        reason: `${getCategoryLabel(topCategory)} 분야에서 좋은 성과를 보이고 있어요`,
        quests: availableQuests.slice(0, 2)
      })
    }
    
    // 2. 현재 기분에 맞는 난이도 추천
    recommendations.push({
      type: 'mood-based',
      title: '오늘 컨디션에 맞는 추천',
      reason: '현재 기분에 적절한 목표량으로 설정했어요',
      quests: getQuestsByMood(analysis.currentMood || '😊')
    })
    
    // 3. 시간 효율성 기반 추천
    recommendations.push({
      type: 'time-based',
      title: '짧은 시간 고효율 퀘스트',
      reason: '바쁜 일상 속에서도 달성 가능한 퀘스트예요',
      quests: getQuickQuests()
    })
    
    // 4. 도전적 추천 (연속 성공 시)
    if (analysis.completionTrends.streak >= 3) {
      recommendations.push({
        type: 'challenge',
        title: '도전 퀘스트',
        reason: `${analysis.completionTrends.streak}일 연속 달성 중! 더 도전적인 목표는 어떨까요?`,
        quests: getChallengeQuests()
      })
    }
    
    return recommendations
  }

  // 기분별 퀘스트 추천
  function getQuestsByMood(mood) {
    const allQuests = getAllQuests()
    
    if (mood === '😞') {
      // 힘든 날에는 쉽고 기분 전환되는 퀘스트
      return allQuests
        .filter(quest => quest.tags.includes('relaxation') || quest.tags.includes('gentle'))
        .slice(0, 3)
    } else if (mood === '😊') {
      // 컨디션 좋을 때는 생산적인 퀘스트
      return allQuests
        .filter(quest => quest.tags.includes('productive') || quest.tags.includes('skill'))
        .slice(0, 3)
    } else {
      // 보통일 때는 균형 잡힌 퀘스트
      return allQuests
        .filter(quest => quest.tags.includes('daily') || quest.tags.includes('health'))
        .slice(0, 3)
    }
  }

  // 빠른 퀘스트 추천
  function getQuickQuests() {
    return getAllQuests()
      .filter(quest => quest.timeRequired <= 15)
      .sort((a, b) => a.timeRequired - b.timeRequired)
      .slice(0, 3)
  }

  // 도전적 퀘스트 추천
  function getChallengeQuests() {
    return getAllQuests()
      .filter(quest => quest.difficulty['😊'] >= 30)
      .slice(0, 2)
  }

  // 모든 퀘스트 가져오기
  function getAllQuests() {
    return Object.values(questDatabase.value).flat()
  }

  // 카테고리 라벨 변환
  function getCategoryLabel(category) {
    const labels = {
      health: '건강',
      fitness: '운동',
      learning: '학습',
      work: '업무',
      hobby: '취미'
    }
    return labels[category] || category
  }

  // 퀘스트 검색
  function searchQuests(query, category = null) {
    let quests = getAllQuests()
    
    if (category && category !== 'all') {
      quests = questDatabase.value[category] || []
    }
    
    if (query.trim()) {
      const lowerQuery = query.toLowerCase()
      quests = quests.filter(quest => 
        quest.title.toLowerCase().includes(lowerQuery) ||
        quest.description.toLowerCase().includes(lowerQuery) ||
        quest.tags.some(tag => tag.toLowerCase().includes(lowerQuery))
      )
    }
    
    return quests
  }

  return {
    isAnalyzing,
    lastAnalysis,
    questDatabase,
    analyzeUserPatterns,
    generateRecommendations,
    searchQuests,
    getAllQuests,
    getCategoryLabel
  }
})