// 개인화 및 감정 분석 시스템
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { storageManager } from './storage.js'

export const usePersonalizationStore = defineStore('personalization', () => {
  const userProfile = ref({
    preferences: {
      difficultyCurve: 'adaptive', // adaptive, gentle, challenging
      motivationStyle: 'encouraging', // encouraging, challenging, neutral
      timePreference: 'flexible', // morning, afternoon, evening, flexible
      categories: [], // 선호 카테고리들
    },
    patterns: {
      moodCycles: [],
      productivityPeaks: [],
      successTriggers: [],
      failurePatterns: []
    },
    insights: {
      personalizedMessages: [],
      adaptiveGoals: {},
      optimalSchedule: null
    }
  })

  const emotionAnalysis = ref({
    currentState: {
      energy: 0, // -1 to 1
      motivation: 0, // -1 to 1
      stress: 0, // -1 to 1
      confidence: 0 // -1 to 1
    },
    trends: [],
    predictions: []
  })

  // 감정 상태 분석
  function analyzeEmotionalState(moodHistory, questHistory) {
    const recent = moodHistory.slice(-7) // 최근 7일
    
    if (recent.length === 0) return
    
    // 에너지 레벨 분석
    const energyLevels = recent.map(entry => {
      const moodToEnergy = { '😊': 0.8, '😐': 0.3, '😞': -0.5 }
      return moodToEnergy[entry.mood] || 0
    })
    
    // 동기부여 레벨 분석 (완료율 기반)
    const motivationLevels = recent.map(entry => {
      return (entry.completionRate / 100) * 2 - 1 // -1 to 1 scale
    })
    
    // 스트레스 레벨 분석 (목표 대비 실제 달성)
    const stressLevels = recent.map(entry => {
      const gap = Math.abs(entry.completionRate - 80) // 80%를 이상적 목표로 설정
      return Math.min(gap / 80, 1) * (entry.completionRate < 50 ? 1 : -1)
    })
    
    // 자신감 레벨 분석 (연속 성공 패턴)
    const confidenceLevels = calculateConfidenceTrend(recent)
    
    emotionAnalysis.value.currentState = {
      energy: average(energyLevels),
      motivation: average(motivationLevels),
      stress: average(stressLevels),
      confidence: average(confidenceLevels)
    }
    
    // 트렌드 업데이트
    updateEmotionalTrends()
  }

  // 자신감 트렌드 계산
  function calculateConfidenceTrend(recentData) {
    return recentData.map((entry, index) => {
      // 최근일수록 가중치를 더 높게
      const weight = (index + 1) / recentData.length
      const baseConfidence = entry.completionRate / 100
      
      // 연속 성공 보너스
      let streakBonus = 0
      for (let i = index; i >= 0; i--) {
        if (recentData[i].completionRate >= 70) {
          streakBonus += 0.1
        } else {
          break
        }
      }
      
      return Math.min((baseConfidence + streakBonus) * weight * 2 - 1, 1)
    })
  }

  // 감정 트렌드 업데이트
  function updateEmotionalTrends() {
    const currentTime = new Date()
    emotionAnalysis.value.trends.push({
      timestamp: currentTime.toISOString(),
      state: { ...emotionAnalysis.value.currentState }
    })
    
    // 최근 30일만 유지
    emotionAnalysis.value.trends = emotionAnalysis.value.trends.slice(-30)
  }

  // 개인화된 목표 조정
  function adaptiveGoalAdjustment(baseGoal, userState) {
    const { energy, motivation, stress, confidence } = emotionAnalysis.value.currentState
    
    let multiplier = 1.0
    
    // 에너지 레벨에 따른 조정
    if (energy > 0.5) {
      multiplier *= 1.2 // 에너지 높으면 목표 상향
    } else if (energy < -0.3) {
      multiplier *= 0.7 // 에너지 낮으면 목표 하향
    }
    
    // 스트레스 레벨에 따른 조정
    if (stress > 0.5) {
      multiplier *= 0.8 // 스트레스 높으면 목표 완화
    }
    
    // 자신감에 따른 조정
    if (confidence > 0.6) {
      multiplier *= 1.1 // 자신감 높으면 약간 도전적으로
    } else if (confidence < -0.3) {
      multiplier *= 0.9 // 자신감 낮으면 안전하게
    }
    
    // 동기부여에 따른 조정
    if (motivation < -0.5) {
      multiplier *= 0.6 // 동기부여 매우 낮으면 크게 완화
    }
    
    return Math.max(Math.round(baseGoal * multiplier), 1)
  }

  // 개인화된 격려 메시지 생성
  function generatePersonalizedMessage(context = 'general') {
    const { energy, motivation, stress, confidence } = emotionAnalysis.value.currentState
    const motivationStyle = userProfile.value.preferences.motivationStyle
    
    let messages = []
    
    // 현재 상태에 따른 메시지 선택
    if (energy < -0.3 && stress > 0.3) {
      // 피곤하고 스트레스 받는 상태
      messages = [
        "오늘은 좀 힘든 하루네요. 작은 것부터 천천히 시작해봐요 🤗",
        "무리하지 마세요. 당신만의 속도로 가는 것이 중요해요 💙",
        "완벽하지 않아도 괜찮아요. 작은 진전도 큰 의미가 있어요 🌱"
      ]
    } else if (confidence < -0.3) {
      // 자신감 부족 상태
      messages = [
        "어제의 실패는 오늘의 성공을 위한 경험이에요 💪",
        "작은 성취부터 시작해보세요. 자신감은 조금씩 쌓여갑니다 ✨",
        "당신은 이미 시작했다는 것만으로도 대단해요 🌟"
      ]
    } else if (energy > 0.5 && motivation > 0.3) {
      // 좋은 컨디션
      if (motivationStyle === 'challenging') {
        messages = [
          "컨디션이 좋네요! 더 도전적인 목표는 어떨까요? 🚀",
          "이 기세로 한 단계 더 나아가볼까요? 🔥",
          "오늘은 평소보다 더 큰 성취를 이룰 수 있을 것 같아요! ⭐"
        ]
      } else {
        messages = [
          "오늘 컨디션이 정말 좋아 보여요! 🌞",
          "이런 날에는 무엇이든 할 수 있을 것 같아요! ✨",
          "좋은 에너지가 느껴져요. 오늘도 화이팅! 💪"
        ]
      }
    } else {
      // 보통 상태
      messages = [
        "꾸준함이 가장 큰 힘이에요. 오늘도 한 걸음씩! 👣",
        "평범한 하루도 의미 있는 하루예요 🌿",
        "작은 습관들이 모여 큰 변화를 만들어요 🌱"
      ]
    }
    
    return messages[Math.floor(Math.random() * messages.length)]
  }

  // 최적 시간대 예측
  function predictOptimalTime(questHistory) {
    const timeSlots = {
      morning: { success: 0, total: 0 },
      afternoon: { success: 0, total: 0 },
      evening: { success: 0, total: 0 }
    }
    
    questHistory.forEach(quest => {
      if (quest.completedAt) {
        const hour = new Date(quest.completedAt).getHours()
        let timeSlot
        
        if (hour < 12) timeSlot = 'morning'
        else if (hour < 18) timeSlot = 'afternoon'
        else timeSlot = 'evening'
        
        timeSlots[timeSlot].total++
        if (quest.completed) {
          timeSlots[timeSlot].success++
        }
      }
    })
    
    // 성공률 계산 및 최적 시간대 찾기
    let bestTime = 'morning'
    let bestRate = 0
    
    Object.entries(timeSlots).forEach(([time, stats]) => {
      const rate = stats.total > 0 ? stats.success / stats.total : 0
      if (rate > bestRate && stats.total >= 3) { // 최소 3회 이상 데이터
        bestRate = rate
        bestTime = time
      }
    })
    
    return {
      optimalTime: bestTime,
      confidence: bestRate,
      timeSlots
    }
  }

  // 실패 패턴 분석
  function analyzeFailurePatterns(questHistory) {
    const failures = questHistory.filter(quest => !quest.completed)
    
    const patterns = {
      categories: {},
      timeOfDay: {},
      mood: {},
      difficulty: {}
    }
    
    failures.forEach(quest => {
      // 카테고리별 실패 분석
      patterns.categories[quest.category] = (patterns.categories[quest.category] || 0) + 1
      
      // 시간대별 실패 분석
      if (quest.attemptedAt) {
        const hour = new Date(quest.attemptedAt).getHours()
        const timeSlot = hour < 12 ? 'morning' : hour < 18 ? 'afternoon' : 'evening'
        patterns.timeOfDay[timeSlot] = (patterns.timeOfDay[timeSlot] || 0) + 1
      }
      
      // 기분별 실패 분석
      if (quest.mood) {
        patterns.mood[quest.mood] = (patterns.mood[quest.mood] || 0) + 1
      }
      
      // 난이도별 실패 분석
      const difficulty = quest.targetValue || 1
      const difficultyLevel = difficulty <= 5 ? 'easy' : difficulty <= 15 ? 'medium' : 'hard'
      patterns.difficulty[difficultyLevel] = (patterns.difficulty[difficultyLevel] || 0) + 1
    })
    
    return patterns
  }

  // 성공 트리거 분석
  function analyzeSuccessTriggers(questHistory) {
    const successes = questHistory.filter(quest => quest.completed)
    
    const triggers = {
      consecutiveDays: 0,
      preferredCategories: [],
      optimalDifficulty: null,
      bestMood: null
    }
    
    // 연속 성공 패턴
    let currentStreak = 0
    let maxStreak = 0
    
    questHistory.slice().reverse().forEach(quest => {
      if (quest.completed) {
        currentStreak++
        maxStreak = Math.max(maxStreak, currentStreak)
      } else {
        currentStreak = 0
      }
    })
    
    triggers.consecutiveDays = maxStreak
    
    // 선호 카테고리 (성공률 높은 순)
    const categoryStats = {}
    successes.forEach(quest => {
      categoryStats[quest.category] = (categoryStats[quest.category] || 0) + 1
    })
    
    triggers.preferredCategories = Object.entries(categoryStats)
      .sort(([,a], [,b]) => b - a)
      .slice(0, 3)
      .map(([category]) => category)
    
    return triggers
  }

  // 동적 난이도 조정
  function getDynamicDifficulty(baseQuest, userHistory) {
    const recentPerformance = calculateRecentPerformance(userHistory)
    const categoryPerformance = calculateCategoryPerformance(baseQuest.category, userHistory)
    
    let adjustmentFactor = 1.0
    
    // 전반적 성과에 따른 조정
    if (recentPerformance > 0.8) {
      adjustmentFactor *= 1.2 // 성과 좋으면 난이도 상승
    } else if (recentPerformance < 0.4) {
      adjustmentFactor *= 0.8 // 성과 안 좋으면 난이도 하락
    }
    
    // 카테고리별 성과에 따른 조정
    if (categoryPerformance > 0.7) {
      adjustmentFactor *= 1.1
    } else if (categoryPerformance < 0.3) {
      adjustmentFactor *= 0.9
    }
    
    // 감정 상태에 따른 추가 조정
    const emotionalAdjustment = adaptiveGoalAdjustment(1, emotionAnalysis.value.currentState)
    adjustmentFactor *= emotionalAdjustment
    
    return {
      '😊': Math.max(Math.round(baseQuest.difficulty['😊'] * adjustmentFactor), 1),
      '😐': Math.max(Math.round(baseQuest.difficulty['😐'] * adjustmentFactor), 1),
      '😞': Math.max(Math.round(baseQuest.difficulty['😞'] * adjustmentFactor), 1)
    }
  }

  // 최근 성과 계산
  function calculateRecentPerformance(history, days = 7) {
    const recent = history.slice(-days)
    if (recent.length === 0) return 0.5
    
    const completed = recent.filter(quest => quest.completed).length
    return completed / recent.length
  }

  // 카테고리별 성과 계산
  function calculateCategoryPerformance(category, history) {
    const categoryQuests = history.filter(quest => quest.category === category)
    if (categoryQuests.length === 0) return 0.5
    
    const completed = categoryQuests.filter(quest => quest.completed).length
    return completed / categoryQuests.length
  }

  // 유틸리티 함수들
  function average(numbers) {
    if (numbers.length === 0) return 0
    return numbers.reduce((sum, num) => sum + num, 0) / numbers.length
  }

  // 데이터 저장
  function savePersonalizationData() {
    const data = {
      userProfile: userProfile.value,
      emotionAnalysis: emotionAnalysis.value
    }
    storageManager.saveUserProfile(data)
  }

  // 데이터 로드
  function loadPersonalizationData() {
    const data = storageManager.loadUserProfile()
    if (data) {
      userProfile.value = data.userProfile || userProfile.value
      emotionAnalysis.value = data.emotionAnalysis || emotionAnalysis.value
    }
  }

  return {
    userProfile,
    emotionAnalysis,
    analyzeEmotionalState,
    adaptiveGoalAdjustment,
    generatePersonalizedMessage,
    predictOptimalTime,
    analyzeFailurePatterns,
    analyzeSuccessTriggers,
    getDynamicDifficulty,
    savePersonalizationData,
    loadPersonalizationData
  }
})