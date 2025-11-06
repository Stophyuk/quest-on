<template>
  <div class="min-h-screen pb-24 px-4 pt-6" style="padding-bottom: 90px;">
    <!-- 레벨업 모달 -->
    <LevelUpModal
      v-if="showLevelUpModal"
      :levelData="levelUpData"
      @close="showLevelUpModal = false"
    />

    <!-- 헤더 -->
    <header class="flex items-center justify-between mb-6">
      <h1 class="text-2xl font-pixel text-purple font-bold">Quest ON</h1>
      <router-link
        to="/profile"
        class="text-sm text-purple-600 hover:text-purple-700 font-medium"
      >
        통계 보기 →
      </router-link>
    </header>

    <!-- 플레이어 카드 -->
    <div class="mb-6">
      <PlayerCard />
    </div>

    <!-- 퀘스트 목록 -->
    <div class="card p-6">
      <div class="flex items-center justify-between mb-4">
        <h3 class="text-lg font-bold text-gray-900">오늘의 퀘스트</h3>
        <div class="flex items-center gap-2">
          <button
            v-if="hasGoalTree"
            @click="showQuestSuggester = true"
            class="text-xs px-3 py-1.5 bg-gradient-to-r from-emerald-500 to-green-600 text-white rounded-lg font-medium hover:shadow-md transition-all"
          >
            🤖 AI 추천
          </button>
          <span class="text-sm text-gray-500">
            {{ completedCount }} / {{ totalCount }} 완료
          </span>
        </div>
      </div>

      <!-- 빈 상태 -->
      <div v-if="quests.length === 0" class="text-center py-12">
        <div class="text-6xl mb-4">🎯</div>
        <h4 class="text-lg font-semibold text-neutral-800 mb-2">아직 퀘스트가 없어요</h4>
        <p class="text-neutral-600 text-sm">+ 버튼을 눌러 첫 퀘스트를 추가해보세요!</p>
      </div>

      <!-- 퀘스트 리스트 -->
      <div v-else class="space-y-3">
        <div
          v-for="quest in quests"
          :key="quest.id"
          class="bg-gray-50 rounded-lg p-4 border border-gray-100 hover:border-gray-200 transition-colors"
        >
          <div class="flex items-center gap-3">
            <!-- 체크박스 -->
            <button
              @click="toggleQuest(quest)"
              class="flex-shrink-0 w-6 h-6 rounded border-2 transition-all duration-200 flex items-center justify-center"
              :class="[
                quest.completed
                  ? 'bg-green-500 border-green-500 text-white'
                  : 'border-gray-300 hover:border-gray-400 bg-white'
              ]"
            >
              <svg v-if="quest.completed" class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/>
              </svg>
            </button>

            <!-- 내용 -->
            <div class="flex-1 min-w-0">
              <h4
                class="font-medium text-gray-900"
                :class="{ 'line-through text-gray-500': quest.completed }"
              >
                {{ quest.title }}
              </h4>
              <div class="flex items-center gap-2 mt-1">
                <span
                  class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium"
                  :class="getDifficultyClass(quest.difficulty)"
                >
                  {{ getDifficultyLabel(quest.difficulty) }}
                </span>
                <span class="text-xs text-gray-500">
                  {{ getDifficultyXP(quest.difficulty) }}XP
                </span>
              </div>
            </div>

            <!-- 삭제 버튼 -->
            <button
              @click="removeQuest(quest.id)"
              class="flex-shrink-0 p-2 text-gray-400 hover:text-red-500 transition-colors"
            >
              🗑️
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- 퀘스트 추가 모달 -->
    <QuestModal v-if="showQuestModal" @close="showQuestModal = false" />

    <!-- AI 퀘스트 추천 모달 -->
    <DailyQuestSuggester
      :show="showQuestSuggester"
      @complete="handleQuestSuggestComplete"
      @close="showQuestSuggester = false"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useQuestStore } from '@/stores/quest'
import PlayerCard from '@/components/quest/PlayerCard.vue'
import QuestModal from '@/components/quest/QuestModal.vue'
import LevelUpModal from '@/components/quest/LevelUpModal.vue'
import DailyQuestSuggester from '@/components/quest/DailyQuestSuggester.vue'

const questStore = useQuestStore()

// 모달 상태
const showQuestModal = ref(false)
const showLevelUpModal = ref(false)
const showQuestSuggester = ref(false)
const levelUpData = ref(null)

// 퀘스트 데이터
const quests = computed(() => questStore.quests)
const completedCount = computed(() => questStore.completedQuests.length)
const totalCount = computed(() => quests.value.length)

// 목표 트리 존재 여부
const hasGoalTree = computed(() => questStore.hasGoalTree)

// 난이도 라벨
function getDifficultyLabel(difficulty) {
  const labels = {
    easy: '쉬움',
    normal: '보통',
    hard: '어려움'
  }
  return labels[difficulty] || '보통'
}

// 난이도 클래스
function getDifficultyClass(difficulty) {
  const classes = {
    easy: 'bg-green-100 text-green-700',
    normal: 'bg-blue-100 text-blue-700',
    hard: 'bg-red-100 text-red-700'
  }
  return classes[difficulty] || 'bg-blue-100 text-blue-700'
}

// 난이도 경험치
function getDifficultyXP(difficulty) {
  return questStore.DIFFICULTY_XP[difficulty] || 10
}

// 퀘스트 완료 토글
function toggleQuest(quest) {
  if (quest.completed) {
    questStore.uncompleteQuest(quest.id)
  } else {
    const result = questStore.completeQuest(quest.id)

    // 레벨업 체크
    if (result.leveledUp) {
      levelUpData.value = result
      showLevelUpModal.value = true
    }
  }
}

// 퀘스트 삭제
function removeQuest(questId) {
  if (confirm('이 퀘스트를 삭제하시겠습니까?')) {
    questStore.removeQuest(questId)
  }
}

// AI 퀘스트 추천 완료 핸들러
function handleQuestSuggestComplete(quests) {
  console.log('AI가 추천한 퀘스트가 추가되었습니다:', quests)
}

// FloatingAddButton 이벤트 리스너
onMounted(() => {
  window.addEventListener('open-quest-modal', () => {
    showQuestModal.value = true
  })
})
</script>
