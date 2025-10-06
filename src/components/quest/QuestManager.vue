<template>
  <div class="space-y-4">
    <!-- 퀘스트 추가 버튼 -->
    <div class="flex justify-between items-center">
      <h2 class="text-xl font-bold text-neutral-800">퀘스트 관리</h2>
      <button
        @click="showAddModal = true"
        class="btn-primary px-4 py-2 rounded-lg flex items-center gap-2"
      >
        <span class="text-lg">➕</span>
        <span>새 퀘스트</span>
      </button>
    </div>

    <!-- 카테고리 필터 -->
    <div class="flex flex-wrap gap-2">
      <button
        v-for="category in categories"
        :key="category.value"
        @click="selectedCategory = category.value"
        class="px-3 py-1 rounded-full text-sm font-medium transition-colors"
        :class="selectedCategory === category.value 
          ? 'bg-primary-600 text-white' 
          : 'bg-neutral-200 text-neutral-700 hover:bg-neutral-300'"
      >
        {{ category.icon }} {{ category.label }}
      </button>
    </div>

    <!-- 퀘스트 목록 -->
    <div class="space-y-3">
      <QuestEditCard
        v-for="quest in filteredQuests"
        :key="quest.id"
        :quest="quest"
        @edit="editQuest"
        @delete="deleteQuest"
        @update="updateQuestProgress"
      />
      
      <div v-if="filteredQuests.length === 0" class="text-center py-8 text-neutral-500">
        <div class="text-4xl mb-2">📝</div>
        <p>{{ selectedCategory === 'all' ? '아직 퀘스트가 없어요' : '이 카테고리에 퀘스트가 없어요' }}</p>
        <p class="text-sm">새 퀘스트를 추가해보세요!</p>
      </div>
    </div>

    <!-- 퀘스트 추가/편집 모달 -->
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
import QuestEditCard from './QuestEditCard.vue'
import QuestModal from './QuestModal.vue'

const questStore = useQuestStore()
const showAddModal = ref(false)
const editingQuest = ref(null)
const selectedCategory = ref('all')

// 카테고리 정의
const categories = [
  { value: 'all', label: '전체', icon: '📋' },
  { value: 'health', label: '건강', icon: '💚' },
  { value: 'fitness', label: '운동', icon: '💪' },
  { value: 'learning', label: '학습', icon: '📚' },
  { value: 'work', label: '업무', icon: '💼' },
  { value: 'hobby', label: '취미', icon: '🎨' },
  { value: 'custom', label: '기타', icon: '⭐' }
]

// 필터링된 퀘스트
const filteredQuests = computed(() => {
  if (selectedCategory.value === 'all') {
    return questStore.quests
  }
  return questStore.quests.filter(quest => quest.category === selectedCategory.value)
})

// 퀘스트 편집
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