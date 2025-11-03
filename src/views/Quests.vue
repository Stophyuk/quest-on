<template>
  <div class="min-h-screen bg-gradient-to-b from-purple-50 to-white pb-24">
    <!-- 헤더 -->
    <div class="bg-white shadow-sm sticky top-0 z-10">
      <div class="max-w-md mx-auto px-4 py-4">
        <h1 class="text-2xl font-bold text-neutral-800">퀘스트 관리</h1>
      </div>
    </div>

    <div class="max-w-md mx-auto px-4 py-6 space-y-6">
      <!-- 데일리 루틴 섹션 -->
      <section v-if="recurringQuests.length > 0">
        <div class="flex items-center justify-between mb-3">
          <div class="flex items-center gap-2">
            <h2 class="text-lg font-bold text-neutral-800">🔄 데일리 루틴</h2>
            <span class="text-sm text-neutral-500">
              ({{ completedRecurringCount }}/{{ recurringQuests.length }})
            </span>
          </div>
        </div>

        <div class="space-y-3">
          <div
            v-for="quest in recurringQuests"
            :key="quest.id"
            class="bg-white rounded-xl p-4 shadow-sm border-2 transition-all"
            :class="quest.completed ? 'border-green-200 bg-green-50' : 'border-neutral-200'"
          >
            <div class="flex items-start gap-3">
              <!-- 체크박스 -->
              <button
                @click="toggleQuest(quest)"
                class="flex-shrink-0 w-6 h-6 rounded-full border-2 transition-all mt-0.5"
                :class="quest.completed
                  ? 'bg-green-500 border-green-500'
                  : 'border-neutral-300 hover:border-green-500'"
              >
                <span v-if="quest.completed" class="text-white text-sm">✓</span>
              </button>

              <!-- 퀘스트 정보 -->
              <div class="flex-1 min-w-0">
                <div class="flex items-center gap-2 mb-1">
                  <h3
                    class="font-medium"
                    :class="quest.completed ? 'text-green-700 line-through' : 'text-neutral-800'"
                  >
                    {{ quest.title }}
                  </h3>
                </div>

                <div class="flex items-center gap-2 text-xs text-neutral-500">
                  <span>{{ getDifficultyEmoji(quest.difficulty) }} {{ getDifficultyLabel(quest.difficulty) }}</span>
                  <span>·</span>
                  <span>{{ getQuestXP(quest.difficulty) }}XP</span>
                  <span v-if="quest.streak && quest.streak > 0">
                    ·
                    <span class="text-orange-600 font-medium">🔥 {{ quest.streak }}일 연속</span>
                  </span>
                </div>
              </div>

              <!-- 삭제 버튼 -->
              <button
                @click="deleteQuest(quest.id)"
                class="flex-shrink-0 text-neutral-400 hover:text-red-500 transition-colors"
              >
                ✖
              </button>
            </div>
          </div>
        </div>
      </section>

      <!-- 진행 중인 퀘스트 섹션 -->
      <section v-if="oneTimeQuests.length > 0">
        <div class="flex items-center justify-between mb-3">
          <h2 class="text-lg font-bold text-neutral-800">📋 진행 중인 퀘스트</h2>
          <span class="text-sm text-neutral-500">({{ oneTimeQuests.length }})</span>
        </div>

        <div class="space-y-3">
          <div
            v-for="quest in oneTimeQuests"
            :key="quest.id"
            class="bg-white rounded-xl p-4 shadow-sm border-2 border-neutral-200 hover:border-purple-200 transition-all"
          >
            <div class="flex items-start gap-3">
              <!-- 체크박스 -->
              <button
                @click="toggleQuest(quest)"
                class="flex-shrink-0 w-6 h-6 rounded-full border-2 border-neutral-300 hover:border-purple-500 transition-all mt-0.5"
              >
              </button>

              <!-- 퀘스트 정보 -->
              <div class="flex-1 min-w-0">
                <h3 class="font-medium text-neutral-800 mb-1">
                  {{ quest.title }}
                </h3>

                <div class="flex items-center gap-2 text-xs text-neutral-500">
                  <span>{{ getDifficultyEmoji(quest.difficulty) }} {{ getDifficultyLabel(quest.difficulty) }}</span>
                  <span>·</span>
                  <span>{{ getQuestXP(quest.difficulty) }}XP</span>
                </div>
              </div>

              <!-- 삭제 버튼 -->
              <button
                @click="deleteQuest(quest.id)"
                class="flex-shrink-0 text-neutral-400 hover:text-red-500 transition-colors"
              >
                ✖
              </button>
            </div>
          </div>
        </div>
      </section>

      <!-- 완료된 퀘스트 섹션 -->
      <section v-if="completedOneTimeQuests.length > 0">
        <button
          @click="showCompleted = !showCompleted"
          class="w-full flex items-center justify-between mb-3 py-2"
        >
          <div class="flex items-center gap-2">
            <h2 class="text-lg font-bold text-neutral-800">✅ 완료된 퀘스트</h2>
            <span class="text-sm text-neutral-500">({{ completedOneTimeQuests.length }})</span>
          </div>
          <span class="text-neutral-400">{{ showCompleted ? '▼' : '▶' }}</span>
        </button>

        <div v-if="showCompleted" class="space-y-3">
          <div
            v-for="quest in completedOneTimeQuests"
            :key="quest.id"
            class="bg-green-50 rounded-xl p-4 border-2 border-green-200"
          >
            <div class="flex items-start gap-3">
              <!-- 체크박스 -->
              <div class="flex-shrink-0 w-6 h-6 rounded-full bg-green-500 border-2 border-green-500 flex items-center justify-center mt-0.5">
                <span class="text-white text-sm">✓</span>
              </div>

              <!-- 퀘스트 정보 -->
              <div class="flex-1 min-w-0">
                <h3 class="font-medium text-green-700 line-through mb-1">
                  {{ quest.title }}
                </h3>

                <div class="flex items-center gap-2 text-xs text-green-600">
                  <span>{{ getDifficultyEmoji(quest.difficulty) }} {{ getDifficultyLabel(quest.difficulty) }}</span>
                  <span>·</span>
                  <span>{{ getQuestXP(quest.difficulty) }}XP</span>
                </div>
              </div>

              <!-- 삭제 버튼 -->
              <button
                @click="deleteQuest(quest.id)"
                class="flex-shrink-0 text-green-400 hover:text-red-500 transition-colors"
              >
                ✖
              </button>
            </div>
          </div>
        </div>
      </section>

      <!-- 빈 상태 -->
      <div
        v-if="recurringQuests.length === 0 && oneTimeQuests.length === 0 && completedOneTimeQuests.length === 0"
        class="text-center py-12"
      >
        <div class="text-6xl mb-4">📝</div>
        <p class="text-neutral-600 font-medium mb-2">아직 퀘스트가 없어요</p>
        <p class="text-sm text-neutral-500">오른쪽 하단 + 버튼으로<br>새 퀘스트를 추가해보세요!</p>
      </div>
    </div>

    <!-- FloatingAddButton -->
    <FloatingAddButton />

    <!-- QuestModal -->
    <QuestModal v-if="showModal" @close="showModal = false" />
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useQuestStore } from '@/stores/quest'
import FloatingAddButton from '@/components/common/FloatingAddButton.vue'
import QuestModal from '@/components/quest/QuestModal.vue'

const questStore = useQuestStore()
const showModal = ref(false)
const showCompleted = ref(false)

// 반복 퀘스트
const recurringQuests = computed(() => questStore.recurringQuests)

// 완료된 반복 퀘스트 개수
const completedRecurringCount = computed(() => {
  return recurringQuests.value.filter(q => q.completed).length
})

// 일반 퀘스트 (미완료)
const oneTimeQuests = computed(() => questStore.oneTimeQuests)

// 완료된 일반 퀘스트
const completedOneTimeQuests = computed(() => {
  return questStore.quests.filter(q => !q.isRecurring && q.completed)
})

// 난이도 이모지
function getDifficultyEmoji(difficulty) {
  const emojis = {
    easy: '😊',
    normal: '😐',
    hard: '😞'
  }
  return emojis[difficulty] || '😐'
}

// 난이도 라벨
function getDifficultyLabel(difficulty) {
  const labels = {
    easy: '쉬움',
    normal: '보통',
    hard: '어려움'
  }
  return labels[difficulty] || '보통'
}

// 퀘스트 XP
function getQuestXP(difficulty) {
  return questStore.DIFFICULTY_XP[difficulty] || 10
}

// 퀘스트 토글
function toggleQuest(quest) {
  if (quest.completed) {
    questStore.uncompleteQuest(quest.id)
  } else {
    questStore.completeQuest(quest.id)
  }
}

// 퀘스트 삭제
function deleteQuest(questId) {
  if (confirm('정말 이 퀘스트를 삭제하시겠습니까?')) {
    questStore.removeQuest(questId)
  }
}

// 퀘스트 모달 열기 이벤트 리스너
onMounted(() => {
  window.addEventListener('open-quest-modal', () => {
    showModal.value = true
  })
})
</script>
