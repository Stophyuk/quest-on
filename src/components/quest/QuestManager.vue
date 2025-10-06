<template>
  <div class="space-y-4">
    <!-- 필터 토글 버튼 -->
    <div class="flex justify-between items-center">
      <button
        @click="showFilters = !showFilters"
        class="px-4 py-2 bg-white rounded-lg shadow-sm flex items-center gap-2 text-sm font-medium"
      >
        <span>🔍</span>
        <span>필터 {{ showFilters ? '숨기기' : '보기' }}</span>
      </button>
      <div class="text-sm text-gray-600">
        총 {{ filteredAndSortedQuests.length }}개 퀘스트
      </div>
    </div>

    <!-- 필터 컴포넌트 -->
    <QuestFilters
      v-if="showFilters"
      :selected-category="filters.category"
      :selected-priority="filters.priority"
      :selected-sort="sortBy"
      :show-completed="filters.showCompleted"
      @update:category="filters.category = $event"
      @update:priority="filters.priority = $event"
      @update:sort="sortBy = $event"
      @update:showCompleted="filters.showCompleted = $event"
      @reset="resetFilters"
    />

    <!-- 퀘스트 목록 -->
    <div class="space-y-3">
      <QuestEditCard
        v-for="quest in filteredAndSortedQuests"
        :key="quest.id"
        :quest="quest"
        @detail="openDetailModal"
        @edit="editQuest"
        @delete="deleteQuest"
        @update="updateQuestProgress"
      />

      <div v-if="filteredAndSortedQuests.length === 0" class="text-center py-8 text-neutral-500">
        <div class="text-4xl mb-2">📝</div>
        <p>{{ hasActiveFilters ? '필터 조건에 맞는 퀘스트가 없어요' : '아직 퀘스트가 없어요' }}</p>
        <p class="text-sm">{{ hasActiveFilters ? '다른 필터를 시도해보세요!' : 'FAB 버튼으로 새 퀘스트를 추가해보세요!' }}</p>
      </div>
    </div>

    <!-- 퀘스트 상세 편집 모달 -->
    <QuestDetailModal
      v-if="showDetailModal"
      :quest="detailQuest"
      :quest-meta="detailQuestMeta"
      @save="saveDetailQuest"
      @close="closeDetailModal"
    />

    <!-- 퀘스트 빠른 편집 모달 (기존) -->
    <QuestModal
      v-if="showAddModal || editingQuest"
      :quest="editingQuest"
      @save="saveQuest"
      @close="closeModal"
    />
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useQuestStore } from '../../stores/quest'
import { useQuestMetaStore, getPriorityLabel } from '../../stores/questMeta'
import QuestEditCard from './QuestEditCard.vue'
import QuestModal from './QuestModal.vue'
import QuestDetailModal from './QuestDetailModal.vue'
import QuestFilters from './QuestFilters.vue'

const questStore = useQuestStore()
const questMetaStore = useQuestMetaStore()
const showAddModal = ref(false)
const editingQuest = ref(null)
const showFilters = ref(false)
const showDetailModal = ref(false)
const detailQuest = ref(null)
const detailQuestMeta = ref(null)

// 필터 상태
const filters = ref({
  category: null,
  priority: null,
  showCompleted: true
})

// 정렬 기준
const sortBy = ref('default')

// 필터 적용 여부
const hasActiveFilters = computed(() => {
  return filters.value.category !== null ||
         filters.value.priority !== null ||
         !filters.value.showCompleted ||
         sortBy.value !== 'default'
})

// 필터링 및 정렬된 퀘스트
const filteredAndSortedQuests = computed(() => {
  let quests = [...questStore.quests]

  // 완료된 퀘스트 필터링
  if (!filters.value.showCompleted) {
    quests = quests.filter(q => !q.isCompleted)
  }

  // 카테고리 필터링
  if (filters.value.category) {
    quests = quests.filter(q => {
      const meta = questMetaStore.getQuestMeta(q.id)
      return meta.category === filters.value.category
    })
  }

  // 우선순위 필터링
  if (filters.value.priority) {
    quests = quests.filter(q => {
      const meta = questMetaStore.getQuestMeta(q.id)
      const priority = getPriorityLabel(meta.urgency, meta.importance)
      return priority.priority === filters.value.priority
    })
  }

  // 정렬
  if (sortBy.value === 'priority') {
    quests.sort((a, b) => {
      const metaA = questMetaStore.getQuestMeta(a.id)
      const metaB = questMetaStore.getQuestMeta(b.id)
      const priorityA = getPriorityLabel(metaA.urgency, metaA.importance).priority
      const priorityB = getPriorityLabel(metaB.urgency, metaB.importance).priority
      return priorityA - priorityB
    })
  } else if (sortBy.value === 'deadline') {
    quests.sort((a, b) => {
      const metaA = questMetaStore.getQuestMeta(a.id)
      const metaB = questMetaStore.getQuestMeta(b.id)
      if (!metaA.deadline && !metaB.deadline) return 0
      if (!metaA.deadline) return 1
      if (!metaB.deadline) return -1
      return new Date(metaA.deadline) - new Date(metaB.deadline)
    })
  } else if (sortBy.value === 'category') {
    quests.sort((a, b) => {
      const metaA = questMetaStore.getQuestMeta(a.id)
      const metaB = questMetaStore.getQuestMeta(b.id)
      return (metaA.category || '').localeCompare(metaB.category || '')
    })
  } else if (sortBy.value === 'createdAt') {
    quests.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt))
  }

  return quests
})

// 필터 초기화
function resetFilters() {
  filters.value = {
    category: null,
    priority: null,
    showCompleted: true
  }
  sortBy.value = 'default'
}

// 퀘스트 상세 편집 열기
function openDetailModal(quest) {
  detailQuest.value = { ...quest }
  detailQuestMeta.value = questMetaStore.getQuestMeta(quest.id)
  showDetailModal.value = true
}

// 상세 편집 모달 닫기
function closeDetailModal() {
  showDetailModal.value = false
  detailQuest.value = null
  detailQuestMeta.value = null
}

// 상세 편집 저장
function saveDetailQuest(data) {
  try {
    // 퀘스트 기본 정보 업데이트
    const success = questStore.updateQuest(detailQuest.value.id, {
      title: data.title
    })

    if (success) {
      // questMeta 정보 업데이트
      questMetaStore.updateQuestMeta(detailQuest.value.id, data.meta)
      closeDetailModal()
    } else {
      alert('퀘스트 저장에 실패했습니다.')
    }
  } catch (error) {
    console.error('Error saving quest detail:', error)
    alert('퀘스트 저장 중 오류가 발생했습니다.')
  }
}

// 퀘스트 빠른 편집
function editQuest(quest) {
  editingQuest.value = { ...quest }
}

// 퀘스트 삭제
function deleteQuest(questId) {
  if (confirm('정말 이 퀘스트를 삭제하시겠습니까?')) {
    questStore.removeQuest(questId)
  }
}

// 퀘스트 저장
function saveQuest(questData) {
  try {
    let success = false
    
    if (editingQuest.value) {
      // 편집 모드
      success = questStore.updateQuest(editingQuest.value.id, questData)
    } else {
      // 추가 모드
      const newQuest = questStore.addQuest(questData)
      success = !!newQuest
    }
    
    if (success) {
      closeModal()
    } else {
      alert('퀘스트 저장에 실패했습니다. 다시 시도해주세요.')
    }
  } catch (error) {
    console.error('Error saving quest:', error)
    alert('퀘스트 저장 중 오류가 발생했습니다.')
  }
}

// 모달 닫기
function closeModal() {
  showAddModal.value = false
  editingQuest.value = null
}

// 퀘스트 진행도 업데이트
function updateQuestProgress(questId, progress) {
  questStore.updateQuestProgress(questId, progress)
}
</script>