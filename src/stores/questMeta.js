import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

// 카테고리 정의
export const CATEGORIES = [
  { id: 'health', label: '💪 건강', color: 'green' },
  { id: 'work', label: '💼 업무', color: 'blue' },
  { id: 'study', label: '📚 학습', color: 'purple' },
  { id: 'hobby', label: '🎨 취미', color: 'pink' },
  { id: 'relationship', label: '👥 관계', color: 'yellow' },
  { id: 'finance', label: '💰 재정', color: 'emerald' },
  { id: 'etc', label: '📌 기타', color: 'gray' }
]

// 우선순위 레이블 계산
export function getPriorityLabel(urgency, importance) {
  if (urgency === 'high' && importance === 'high') {
    return { label: '🔴 지금 당장', color: 'red', priority: 1 }
  } else if (urgency === 'low' && importance === 'high') {
    return { label: '🟡 계획 세우기', color: 'yellow', priority: 2 }
  } else if (urgency === 'high' && importance === 'low') {
    return { label: '🟠 위임 고려', color: 'orange', priority: 3 }
  } else {
    return { label: '🟢 여유있게', color: 'green', priority: 4 }
  }
}

export const useQuestMetaStore = defineStore('questMeta', () => {
  // 퀘스트별 메타 데이터 (questId를 key로 사용)
  const questMetas = ref({})

  // 필터 상태
  const filters = ref({
    category: null,
    tags: [],
    priority: null,
    dateRange: null,
    showCompleted: true
  })

  // 정렬 기준
  const sortBy = ref('default') // default | priority | deadline | category | createdAt

  // 퀘스트 메타 데이터 가져오기
  function getQuestMeta(questId) {
    return questMetas.value[questId] || getDefaultMeta()
  }

  // 기본 메타 데이터
  function getDefaultMeta() {
    return {
      // 반복 퀘스트 관련
      isRecurring: false,
      recurrenceType: 'daily', // daily | weekly | monthly | custom
      recurrenceDays: [], // [0,1,2,3,4,5,6] (0=일요일)
      recurrenceTime: '09:00',
      recurrenceEndType: 'never', // never | date | count
      recurrenceEndDate: null,
      recurrenceCount: null,
      parentQuestId: null, // 반복 퀘스트의 원본 템플릿 ID
      generatedAt: null, // 생성된 날짜

      // 알림 관련
      hasNotification: false,
      notificationTime: '09:00',
      notificationMinutesBefore: 0,

      // 분류 관련
      category: 'etc',
      tags: [],
      urgency: 'low', // high | low
      importance: 'low', // high | low

      // 일정 관련
      scheduledDate: null, // "2025-01-15"
      deadline: null, // "2025-01-20"
      estimatedMinutes: null,

      // 메모
      notes: ''
    }
  }

  // 퀘스트 메타 데이터 설정
  function setQuestMeta(questId, metaData) {
    if (!questMetas.value[questId]) {
      questMetas.value[questId] = getDefaultMeta()
    }
    questMetas.value[questId] = { ...questMetas.value[questId], ...metaData }
    saveToLocalStorage()
  }

  // 퀘스트 메타 데이터 업데이트 (부분 업데이트)
  function updateQuestMeta(questId, updates) {
    if (!questMetas.value[questId]) {
      questMetas.value[questId] = getDefaultMeta()
    }
    Object.assign(questMetas.value[questId], updates)
    saveToLocalStorage()
  }

  // 퀘스트 메타 데이터 삭제
  function deleteQuestMeta(questId) {
    delete questMetas.value[questId]
    saveToLocalStorage()
  }

  // 반복 퀘스트 템플릿 가져오기
  function getRecurringTemplates() {
    return Object.entries(questMetas.value)
      .filter(([id, meta]) => meta.isRecurring && !meta.parentQuestId)
      .map(([id, meta]) => ({ questId: id, ...meta }))
  }

  // 오늘 생성되어야 할 반복 퀘스트 확인
  function shouldGenerateToday(meta) {
    if (!meta.isRecurring || meta.parentQuestId) return false

    const today = new Date()
    const dayOfWeek = today.getDay()
    const todayString = today.toISOString().split('T')[0]

    // 요일 체크
    if (meta.recurrenceType === 'weekly' && !meta.recurrenceDays.includes(dayOfWeek)) {
      return false
    }

    if (meta.recurrenceType === 'daily' && meta.recurrenceDays.length > 0 && !meta.recurrenceDays.includes(dayOfWeek)) {
      return false
    }

    // 종료 조건 체크
    if (meta.recurrenceEndType === 'date' && meta.recurrenceEndDate) {
      if (new Date(meta.recurrenceEndDate) < today) return false
    }

    if (meta.recurrenceEndType === 'count' && meta.recurrenceCount) {
      // 생성된 개수 확인 필요 (questStore에서 처리)
    }

    return true
  }

  // 필터 설정
  function setFilter(filterName, value) {
    filters.value[filterName] = value
  }

  // 필터 초기화
  function resetFilters() {
    filters.value = {
      category: null,
      tags: [],
      priority: null,
      dateRange: null,
      showCompleted: true
    }
  }

  // 정렬 기준 변경
  function setSortBy(sort) {
    sortBy.value = sort
  }

  // 우선순위 계산
  function getQuestPriority(questId) {
    const meta = getQuestMeta(questId)
    return getPriorityLabel(meta.urgency, meta.importance)
  }

  // localStorage에 저장
  function saveToLocalStorage() {
    try {
      localStorage.setItem('quest-on-meta', JSON.stringify(questMetas.value))
    } catch (error) {
      console.error('Failed to save quest meta:', error)
    }
  }

  // localStorage에서 불러오기
  function loadFromLocalStorage() {
    try {
      const saved = localStorage.getItem('quest-on-meta')
      if (saved) {
        questMetas.value = JSON.parse(saved)
      }
    } catch (error) {
      console.error('Failed to load quest meta:', error)
    }
  }

  // 데이터 내보내기
  function exportMetaData() {
    return JSON.stringify(questMetas.value, null, 2)
  }

  // 데이터 가져오기
  function importMetaData(dataString) {
    try {
      const data = JSON.parse(dataString)
      questMetas.value = data
      saveToLocalStorage()
      return true
    } catch (error) {
      console.error('Failed to import meta data:', error)
      return false
    }
  }

  // 초기화 시 로드
  loadFromLocalStorage()

  return {
    // 상태
    questMetas,
    filters,
    sortBy,

    // 메서드
    getQuestMeta,
    setQuestMeta,
    updateQuestMeta,
    deleteQuestMeta,
    getRecurringTemplates,
    shouldGenerateToday,
    setFilter,
    resetFilters,
    setSortBy,
    getQuestPriority,
    exportMetaData,
    importMetaData,
    saveToLocalStorage,
    loadFromLocalStorage
  }
})
