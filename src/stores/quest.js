import { defineStore } from 'pinia'
import { ref, computed, watch } from 'vue'
import { storageManager } from './storage.js'

export const useQuestStore = defineStore('quest', () => {
  // ==================== 상태 ====================
  const level = ref(0)
  const experience = ref(0)
  const totalCompleted = ref(0)
  const quests = ref([])
  const isLoaded = ref(false)

  // ==================== 난이도별 경험치 ====================
  const DIFFICULTY_XP = {
    easy: 10,
    normal: 20,
    hard: 30
  }

  // ==================== 경험치 공식 (최적화) ====================
  const experienceToNextLevel = computed(() => {
    const lv = level.value
    if (lv === 0) return 30
    if (lv <= 4) return 50 + (lv * 50)  // 60, 100, 150, 200
    return 200 + ((lv - 4) * 100)  // 300, 400, 500, 600...
  })

  const progressPercentage = computed(() => {
    const nextLevel = experienceToNextLevel.value
    if (nextLevel === 0) return 0
    return Math.min((experience.value / nextLevel) * 100, 100)
  })

  // ==================== 캐릭터 진화 ====================
  const characterStage = computed(() => {
    const lv = level.value
    if (lv >= 8) return 'adult'
    if (lv >= 4) return 'teen'
    return 'baby'
  })

  const characterSizeClass = computed(() => {
    const stage = characterStage.value
    if (stage === 'adult') return 'text-9xl'
    if (stage === 'teen') return 'text-8xl'
    return 'text-6xl'
  })

  const characterEffect = computed(() => {
    const stage = characterStage.value
    if (stage === 'adult') return '✨'
    if (stage === 'teen') return '😊'
    return ''
  })

  // ==================== 퀘스트 관련 계산 ====================
  const todayQuests = computed(() => {
    return quests.value.filter(q => !q.completed)
  })

  const completedQuests = computed(() => {
    return quests.value.filter(q => q.completed)
  })

  const recurringQuests = computed(() => {
    return quests.value.filter(q => q.isRecurring)
  })

  const oneTimeQuests = computed(() => {
    return quests.value.filter(q => !q.isRecurring && !q.completed)
  })

  const completionRate = computed(() => {
    const total = quests.value.length
    if (total === 0) return 0
    return (completedQuests.value.length / total) * 100
  })

  // ==================== 퀘스트 추가 ====================
  function addQuest(questData) {
    try {
      if (!questData?.title?.trim()) {
        throw new Error('퀘스트 제목이 필요합니다')
      }

      const newQuest = {
        id: Date.now(),
        title: questData.title.trim(),
        difficulty: questData.difficulty || 'normal',
        completed: false,
        isRecurring: questData.isRecurring || false, // 매일 반복 여부
        streak: 0, // 연속 달성 일수
        lastCompletedDate: null, // 마지막 완료 날짜
        createdAt: new Date().toISOString(),
        completedAt: null
      }

      quests.value.push(newQuest)
      saveData()
      return newQuest
    } catch (error) {
      console.error('Failed to add quest:', error)
      return null
    }
  }

  // ==================== 퀘스트 완료 ====================
  function completeQuest(questId) {
    const quest = quests.value.find(q => q.id === questId)
    if (quest && !quest.completed) {
      const today = new Date().toISOString().split('T')[0]
      quest.completed = true
      quest.completedAt = new Date().toISOString()
      totalCompleted.value++

      // 반복 퀘스트인 경우 연속 달성 처리
      if (quest.isRecurring) {
        const lastDate = quest.lastCompletedDate
        if (lastDate) {
          const yesterday = new Date()
          yesterday.setDate(yesterday.getDate() - 1)
          const yesterdayStr = yesterday.toISOString().split('T')[0]

          // 어제 완료했다면 연속 유지
          if (lastDate === yesterdayStr) {
            quest.streak = (quest.streak || 0) + 1
          } else if (lastDate !== today) {
            // 하루 이상 건너뛰었다면 리셋
            quest.streak = 1
          }
        } else {
          // 첫 완료
          quest.streak = 1
        }
        quest.lastCompletedDate = today
      }

      const xp = DIFFICULTY_XP[quest.difficulty] || 10
      const result = gainExperience(xp)
      saveData() // 즉시 저장
      return result
    }
    return { leveledUp: false }
  }

  // ==================== 퀘스트 완료 취소 ====================
  function uncompleteQuest(questId) {
    const quest = quests.value.find(q => q.id === questId)
    if (quest && quest.completed) {
      quest.completed = false
      quest.completedAt = null
      totalCompleted.value = Math.max(0, totalCompleted.value - 1)
      saveData()
    }
  }

  // ==================== 퀘스트 삭제 ====================
  function removeQuest(questId) {
    const index = quests.value.findIndex(q => q.id === questId)
    if (index > -1) {
      quests.value.splice(index, 1)
      saveData()
      return true
    }
    return false
  }

  // ==================== 경험치 획득 & 레벨업 ====================
  function gainExperience(amount) {
    const previousLevel = level.value
    experience.value += amount

    let maxIterations = 100
    let iterationCount = 0

    while (experience.value >= experienceToNextLevel.value &&
           experienceToNextLevel.value > 0 &&
           iterationCount < maxIterations) {
      experience.value -= experienceToNextLevel.value
      level.value++
      iterationCount++
    }

    if (iterationCount >= maxIterations) {
      console.error('gainExperience: 무한루프 방지 작동')
    }

    if (level.value > previousLevel) {
      return {
        leveledUp: true,
        newLevel: level.value,
        levelsGained: level.value - previousLevel
      }
    }

    return { leveledUp: false }
  }

  // ==================== 데이터 저장 ====================
  function saveData() {
    if (!storageManager.checkStorageBeforeSave()) {
      console.error('저장 공간 부족')
      return false
    }

    const dataToSave = {
      version: '1.0.0',
      user: {
        level: level.value,
        experience: experience.value,
        totalCompleted: totalCompleted.value
      },
      quests: quests.value
    }

    storageManager.saveQuestData(dataToSave)
    return true
  }

  // ==================== 데이터 불러오기 ====================
  function loadData() {
    const savedData = storageManager.loadQuestData()

    if (savedData) {
      // 버전 확인 (향후 마이그레이션 대비)
      if (savedData.version === '1.0.0' && savedData.user) {
        level.value = savedData.user.level || 0
        experience.value = savedData.user.experience || 0
        totalCompleted.value = savedData.user.totalCompleted || 0
      } else {
        // 구버전 데이터 마이그레이션
        level.value = savedData.level || 0
        experience.value = savedData.experience || 0
        totalCompleted.value = savedData.totalCompleted || 0
      }

      if (savedData.quests && savedData.quests.length > 0) {
        quests.value = savedData.quests
      }
    }

    isLoaded.value = true
  }

  // ==================== 데이터 내보내기/가져오기 ====================
  function exportData() {
    return storageManager.exportAllData()
  }

  function importData(dataString) {
    const success = storageManager.importAllData(dataString)
    if (success) {
      loadData()
    }
    return success
  }

  function getStorageInfo() {
    return storageManager.getStorageInfo()
  }

  // ==================== 주간 통계 ====================
  function getWeeklyStats() {
    const now = new Date()
    const weekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000)

    const weeklyCompleted = quests.value.filter(q => {
      if (!q.completed || !q.completedAt) return false
      const completedDate = new Date(q.completedAt)
      return completedDate >= weekAgo && completedDate <= now
    })

    return {
      totalCompleted: weeklyCompleted.length,
      byDifficulty: {
        easy: weeklyCompleted.filter(q => q.difficulty === 'easy').length,
        normal: weeklyCompleted.filter(q => q.difficulty === 'normal').length,
        hard: weeklyCompleted.filter(q => q.difficulty === 'hard').length
      },
      totalXP: weeklyCompleted.reduce((sum, q) => sum + (DIFFICULTY_XP[q.difficulty] || 0), 0)
    }
  }

  // ==================== 반복 퀘스트 자정 리셋 ====================
  function resetDailyQuests() {
    const today = new Date().toISOString().split('T')[0]
    let hasChanges = false

    quests.value.forEach(quest => {
      if (quest.isRecurring && quest.completed) {
        const completedDate = quest.completedAt ? quest.completedAt.split('T')[0] : null
        // 오늘이 아닌 날짜에 완료된 반복 퀘스트는 리셋
        if (completedDate && completedDate !== today) {
          quest.completed = false
          quest.completedAt = null
          hasChanges = true
        }
      }
    })

    if (hasChanges) {
      saveData()
    }
  }

  // ==================== 마지막 리셋 날짜 확인 및 리셋 실행 ====================
  const lastResetDate = ref(null)

  function checkAndResetDaily() {
    const today = new Date().toISOString().split('T')[0]
    const savedResetDate = localStorage.getItem('lastResetDate')

    if (savedResetDate !== today) {
      resetDailyQuests()
      lastResetDate.value = today
      localStorage.setItem('lastResetDate', today)
    }
  }

  // ==================== 반응형 데이터 감시 및 자동 저장 ====================
  watch([level, experience, totalCompleted, quests],
    () => {
      if (isLoaded.value) {
        saveData()
      }
    },
    { deep: true }
  )

  // ==================== 앱 시작 시 데이터 로드 및 일일 리셋 체크 ====================
  loadData()
  checkAndResetDaily()

  // ==================== 10분마다 일일 리셋 체크 ====================
  setInterval(checkAndResetDaily, 10 * 60 * 1000)

  // ==================== Export ====================
  return {
    // 상태
    level,
    experience,
    totalCompleted,
    quests,
    isLoaded,

    // 계산된 값
    experienceToNextLevel,
    progressPercentage,
    todayQuests,
    completedQuests,
    recurringQuests,
    oneTimeQuests,
    completionRate,
    characterStage,
    characterSizeClass,
    characterEffect,

    // 함수
    addQuest,
    completeQuest,
    uncompleteQuest,
    removeQuest,
    gainExperience,
    saveData,
    loadData,
    exportData,
    importData,
    getStorageInfo,
    getWeeklyStats,

    // 상수
    DIFFICULTY_XP
  }
})
