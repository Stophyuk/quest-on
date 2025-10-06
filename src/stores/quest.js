import { defineStore } from 'pinia'
import { ref, computed, watch } from 'vue'
import { storageManager } from './storage.js'

export const useQuestStore = defineStore('quest', () => {
  const currentCondition = ref('😊')
  const level = ref(0)
  const experience = ref(0)
  const streakCount = ref(0)
  const totalCompleted = ref(0)
  const isLoaded = ref(false)
  const points = ref(0) // 포인트 시스템
  const accessories = ref([]) // 보유 악세사리
  const equippedAccessory = ref(null) // 장착한 악세사리
  
  const quests = ref([
    {
      id: 1,
      title: '물 마시기',
      description: '하루 8잔의 물을 마시자',
      difficulty: { '😊': 8, '😐': 6, '😞': 4 },
      category: 'health',
      completed: false,
      progress: 0
    },
    {
      id: 2,
      title: '운동하기',
      description: '몸을 움직여보자',
      difficulty: { '😊': 30, '😐': 20, '😞': 10 },
      category: 'fitness',
      completed: false,
      progress: 0
    },
    {
      id: 3,
      title: '독서하기',
      description: '책을 읽어서 지식을 쌓자',
      difficulty: { '😊': 60, '😐': 30, '😞': 15 },
      category: 'learning',
      completed: false,
      progress: 0
    }
  ])

  const conditions = [
    {
      emoji: '😊',
      label: '좋음',
      description: '컨디션이 최고! 높은 목표에 도전해보세요',
      difficultyMultiplier: 1.0,
      examples: '물 8잔, 30분 운동, 60분 독서'
    },
    {
      emoji: '😐',
      label: '보통',
      description: '평범한 하루. 적당한 목표로 꾸준히',
      difficultyMultiplier: 0.75,
      examples: '물 6잔, 20분 운동, 30분 독서'
    },
    {
      emoji: '😞',
      label: '힘듦',
      description: '오늘은 힘든 날. 작은 목표부터 차근차근',
      difficultyMultiplier: 0.5,
      examples: '물 4잔, 10분 운동, 15분 독서'
    }
  ]

  // 경험치 밸런스: 초반 빠른 성장
  const experienceToNextLevel = computed(() => {
    const lv = level.value
    if (lv === 0) return 0
    if (lv === 1) return 50   // 퀘스트 5개
    if (lv === 2) return 100  // 퀘스트 10개
    if (lv === 3) return 150  // 퀘스트 15개 + 첫 진화!
    if (lv === 4) return 200  // 퀘스트 20개
    if (lv === 5) return 300  // 퀘스트 30개
    if (lv === 6) return 500  // 퀘스트 50개
    if (lv === 7) return 800  // 퀘스트 80개 + 두 번째 진화!
    return 1000 // 레벨 8+
  })

  const progressPercentage = computed(() => {
    const nextLevel = experienceToNextLevel.value
    if (nextLevel === 0) return 0
    return (experience.value / nextLevel) * 100
  })

  // 캐릭터 진화 단계
  const characterStage = computed(() => {
    const lv = level.value
    if (lv >= 8) return 'adult'      // 어른 (크고 당당함)
    if (lv >= 4) return 'teen'       // 청소년 (중간 크기)
    return 'baby'                     // 아기 (작고 귀여움)
  })

  // 캐릭터 크기 클래스
  const characterSizeClass = computed(() => {
    const stage = characterStage.value
    if (stage === 'adult') return 'text-9xl'
    if (stage === 'teen') return 'text-8xl'
    return 'text-6xl'
  })

  // 캐릭터 표정/이펙트
  const characterEffect = computed(() => {
    const stage = characterStage.value
    if (stage === 'adult') return '✨'
    if (stage === 'teen') return '😊'
    return ''
  })
  
  const todayQuests = computed(() => {
    return quests.value.map(quest => ({
      ...quest,
      targetValue: quest.difficulty[currentCondition.value]
    }))
  })

  const completedQuests = computed(() => 
    todayQuests.value.filter(quest => quest.completed)
  )

  const completionRate = computed(() => {
    if (todayQuests.value.length === 0) return 0
    return (completedQuests.value.length / todayQuests.value.length) * 100
  })

  function setCondition(condition) {
    const oldCondition = currentCondition.value
    currentCondition.value = condition

    // 컨디션 변경 시 진행 중인 퀘스트들의 목표값 자동 조정
    adjustQuestTargetsForCondition(oldCondition, condition)
  }

  function adjustQuestTargetsForCondition(oldCondition, newCondition) {
    quests.value.forEach(quest => {
      if (!quest.completed && quest.progress > 0) {
        const oldTarget = quest.difficulty[oldCondition] || 1
        const newTarget = quest.difficulty[newCondition] || 1

        // 진행도를 비율로 유지 (예: 50% 진행 상태 유지)
        const progressRatio = quest.progress / oldTarget
        const newProgress = Math.round(progressRatio * newTarget)

        quest.progress = Math.min(newProgress, newTarget)

        // 새 목표값으로 완료 상태 재확인
        quest.completed = quest.progress >= newTarget
      }
    })
  }

  function updateQuestProgress(questId, progress) {
    const quest = quests.value.find(q => q.id === questId)
    if (quest) {
      // 안전한 숫자 변환
      const safeProgress = Math.max(0, Number(progress) || 0)
      quest.progress = safeProgress
      
      const target = quest.difficulty[currentCondition.value] || 1
      const wasCompleted = quest.completed
      quest.completed = safeProgress >= target
      
      // 새로 완료된 경우에만 경험치 지급 (10 XP)
      if (quest.completed && !wasCompleted) {
        gainExperience(10)
        totalCompleted.value++
      }
    }
  }

  function completeQuest(questId) {
    const quest = quests.value.find(q => q.id === questId)
    if (quest && !quest.completed) {
      quest.completed = true
      quest.progress = quest.difficulty[currentCondition.value]
      totalCompleted.value++
      return gainExperience(10)
    }
    return { leveledUp: false }
  }

  function gainExperience(amount) {
    const previousLevel = level.value
    experience.value += amount

    // 무한루프 방지: 최대 100회 반복 제한
    let maxIterations = 100
    let iterationCount = 0

    while (experience.value >= experienceToNextLevel.value &&
           experienceToNextLevel.value > 0 &&
           iterationCount < maxIterations) {
      experience.value -= experienceToNextLevel.value
      level.value++
      points.value += 100
      iterationCount++
    }

    // 비정상적인 반복 감지 시 로그
    if (iterationCount >= maxIterations) {
      console.error('gainExperience: 무한루프 방지 작동', {
        level: level.value,
        experience: experience.value,
        experienceToNextLevel: experienceToNextLevel.value
      })
    }

    // 레벨업 발생시 이벤트 반환
    if (level.value > previousLevel) {
      return {
        leveledUp: true,
        newLevel: level.value,
        pointsEarned: 100 * (level.value - previousLevel)
      }
    }

    return { leveledUp: false }
  }

  function resetDailyQuests() {
    quests.value.forEach(quest => {
      quest.completed = false
      quest.progress = 0
    })
  }

  function getEncouragementMessage() {
    const rate = completionRate.value
    const messages = {
      '😊': {
        high: '와! 정말 대단해요! 🎉',
        medium: '좋은 페이스네요! 💪',
        low: '괜찮아요, 천천히 해봐요! 😊'
      },
      '😐': {
        high: '생각보다 잘하고 있어요! 👏',
        medium: '꾸준히 하고 있네요! 👍',
        low: '오늘은 이정도면 충분해요! 😌'
      },
      '😞': {
        high: '힘든 중에도 정말 잘했어요! 🌟',
        medium: '작은 성취도 큰 의미가 있어요! 💝',
        low: '괜찮아요. 내일은 더 나을 거예요! 🤗'
      }
    }
    
    const level = rate >= 80 ? 'high' : rate >= 40 ? 'medium' : 'low'
    return messages[currentCondition.value][level]
  }

  // 악세사리 구매 함수
  function buyAccessory(accessory) {
    if (points.value >= accessory.price) {
      points.value -= accessory.price
      accessories.value.push(accessory.id)
      saveData()
      return true
    }
    return false
  }

  // 악세사리 장착 함수
  function equipAccessory(accessoryId) {
    if (accessories.value.includes(accessoryId)) {
      equippedAccessory.value = accessoryId
      saveData()
      return true
    }
    return false
  }

  // 데이터 저장 함수
  function saveData() {
    // 저장 전 용량 체크
    if (!storageManager.checkStorageBeforeSave()) {
      console.error('저장 공간 부족: 데이터를 저장할 수 없습니다.')
      // 사용자에게 알림 (추후 UI로 개선)
      alert('⚠️ 저장 공간이 부족합니다. 오래된 퀘스트를 삭제해주세요.')
      return false
    }

    const dataToSave = {
      currentCondition: currentCondition.value,
      level: level.value,
      experience: experience.value,
      streakCount: streakCount.value,
      totalCompleted: totalCompleted.value,
      quests: quests.value,
      completionRate: completionRate.value,
      points: points.value,
      accessories: accessories.value,
      equippedAccessory: equippedAccessory.value
    }

    storageManager.saveQuestData(dataToSave)

    // 기분 히스토리도 저장
    storageManager.saveMoodHistory({
      mood: currentCondition.value,
      completionRate: completionRate.value,
      questsCompleted: completedQuests.value.length
    })

    return true
  }

  // 데이터 불러오기 함수
  function loadData() {
    const savedData = storageManager.loadQuestData()

    if (savedData) {
      currentCondition.value = savedData.currentCondition || '😊'
      level.value = savedData.level || 1
      experience.value = savedData.experience || 0
      streakCount.value = savedData.streakCount || 0
      totalCompleted.value = savedData.totalCompleted || 0
      points.value = savedData.points || 0
      accessories.value = savedData.accessories || []
      equippedAccessory.value = savedData.equippedAccessory || null

      if (savedData.quests && savedData.quests.length > 0) {
        quests.value = savedData.quests
      }
    }

    isLoaded.value = true
  }

  // 퀘스트 추가 함수
  function addQuest(questData) {
    try {
      // 입력 검증
      if (!questData?.title?.trim()) {
        throw new Error('퀘스트 제목이 필요합니다')
      }
      
      const newQuest = {
        id: Date.now(),
        title: questData.title.trim(),
        description: questData.description?.trim() || '',
        difficulty: questData.difficulty || { '😊': 1, '😐': 1, '😞': 1 },
        category: questData.category || 'custom',
        completed: false,
        progress: 0,
        createdAt: new Date().toISOString()
      }
      
      quests.value.push(newQuest)
      saveData()
      return newQuest
    } catch (error) {
      console.error('Failed to add quest:', error)
      return null
    }
  }

  // 퀘스트 삭제 함수
  function removeQuest(questId) {
    const index = quests.value.findIndex(q => q.id === questId)
    if (index > -1) {
      quests.value.splice(index, 1)
      saveData()
      return true
    }
    return false
  }

  // 퀘스트 수정 함수
  function updateQuest(questId, updates) {
    const quest = quests.value.find(q => q.id === questId)
    if (quest) {
      Object.assign(quest, updates)
      saveData()
      return true
    }
    return false
  }

  // 데이터 내보내기
  function exportData() {
    return storageManager.exportAllData()
  }

  // 데이터 가져오기
  function importData(dataString) {
    const success = storageManager.importAllData(dataString)
    if (success) {
      loadData()
    }
    return success
  }

  // 스토리지 정보 가져오기
  function getStorageInfo() {
    return storageManager.getStorageInfo()
  }

  // 연속 달성 계산 (연속으로 80% 이상 달성한 날 수)
  function updateStreakCount() {
    const history = storageManager.loadMoodHistory()
    if (!history || history.length === 0) {
      streakCount.value = 0
      return
    }

    let streak = 0
    const today = new Date().toDateString()

    // 최근 기록부터 역순으로 확인
    for (let i = history.length - 1; i >= 0; i--) {
      const entry = history[i]
      const entryDate = new Date(entry.date).toDateString()

      // 오늘 기록이면서 80% 이상 달성
      if (i === history.length - 1 && entryDate === today) {
        if (entry.completionRate >= 80) {
          streak++
        } else {
          break // 오늘 80% 미만이면 중단
        }
      }
      // 과거 기록
      else if (entry.completionRate >= 80) {
        // 연속된 날짜인지 확인
        if (i < history.length - 1) {
          const prevEntry = history[i + 1]
          const prevDate = new Date(prevEntry.date)
          const currentDate = new Date(entry.date)
          const dayDiff = Math.floor((prevDate - currentDate) / (1000 * 60 * 60 * 24))

          // 하루 차이가 나야 연속
          if (dayDiff === 1) {
            streak++
          } else {
            break
          }
        }
      } else {
        break
      }
    }

    streakCount.value = streak
    saveData()
  }

  // 반응형 데이터 감시 및 자동 저장
  watch([currentCondition, level, experience, totalCompleted, quests, points, accessories, equippedAccessory],
    () => {
      if (isLoaded.value) {
        saveData()
      }
    },
    { deep: true }
  )

  // 완료율 변경 감지 및 연속 달성 업데이트
  watch(completionRate, (newRate) => {
    if (isLoaded.value && newRate >= 80) {
      // 80% 이상 달성 시 연속 달성 업데이트
      setTimeout(() => {
        updateStreakCount()
      }, 500)
    }
  })

  // 앱 시작 시 데이터 로드
  loadData()

  return {
    // 상태
    currentCondition,
    level,
    experience,
    streakCount,
    totalCompleted,
    quests,
    conditions,
    isLoaded,
    points,
    accessories,
    equippedAccessory,

    // 계산된 값
    experienceToNextLevel,
    progressPercentage,
    todayQuests,
    completedQuests,
    completionRate,
    characterStage,
    characterSizeClass,
    characterEffect,

    // 기본 함수들
    setCondition,
    updateQuestProgress,
    completeQuest,
    gainExperience,
    resetDailyQuests,
    getEncouragementMessage,

    // 새로운 CRUD 함수들
    addQuest,
    removeQuest,
    updateQuest,

    // 캐릭터 & 상점 함수들
    buyAccessory,
    equipAccessory,

    // 데이터 관리 함수들
    saveData,
    loadData,
    exportData,
    importData,
    getStorageInfo,
    updateStreakCount
  }
})