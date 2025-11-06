<template>
  <div v-if="show" class="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50 p-4">
    <div class="bg-white rounded-3xl shadow-2xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
      <!-- 로딩 상태 -->
      <div v-if="isGenerating" class="p-12 text-center">
        <div class="relative inline-block mb-6">
          <div class="w-24 h-24 border-8 border-emerald-200 border-t-emerald-600 rounded-full animate-spin"></div>
          <div class="absolute inset-0 flex items-center justify-center text-4xl">🎮</div>
        </div>
        <h3 class="text-2xl font-bold text-gray-900 mb-3">AI가 오늘의 퀘스트를 추천하고 있어요</h3>
        <p class="text-gray-600 mb-6">{{ loadingMessage }}</p>
        <div class="flex justify-center gap-2">
          <div class="w-3 h-3 bg-emerald-500 rounded-full animate-bounce" style="animation-delay: 0s"></div>
          <div class="w-3 h-3 bg-emerald-500 rounded-full animate-bounce" style="animation-delay: 0.2s"></div>
          <div class="w-3 h-3 bg-emerald-500 rounded-full animate-bounce" style="animation-delay: 0.4s"></div>
        </div>
      </div>

      <!-- 에러 상태 -->
      <div v-else-if="error" class="p-12 text-center">
        <div class="text-6xl mb-4">😢</div>
        <h3 class="text-2xl font-bold text-gray-900 mb-3">퀘스트 추천 실패</h3>
        <p class="text-gray-600 mb-6">{{ error }}</p>
        <div class="flex gap-3 justify-center">
          <button
            @click="retryGeneration"
            class="px-6 py-3 bg-emerald-500 text-white rounded-xl font-medium hover:bg-emerald-600 transition-colors"
          >
            다시 시도
          </button>
          <button
            @click="close"
            class="px-6 py-3 bg-gray-200 text-gray-700 rounded-xl font-medium hover:bg-gray-300 transition-colors"
          >
            닫기
          </button>
        </div>
      </div>

      <!-- 생성 완료 - 퀘스트 목록 표시 -->
      <div v-else-if="suggestedQuests.length > 0" class="overflow-y-auto max-h-[90vh]">
        <!-- 헤더 -->
        <div class="sticky top-0 bg-white border-b border-gray-200 px-6 py-4 rounded-t-3xl z-10">
          <h2 class="text-2xl font-bold text-gray-900">🎮 오늘의 추천 퀘스트</h2>
          <p class="text-sm text-gray-600 mt-1">AI가 제안한 {{ suggestedQuests.length }}개의 퀘스트</p>
        </div>

        <!-- 현재 주차 목표 표시 -->
        <div v-if="currentWeekGoal" class="px-6 pt-4">
          <div class="bg-blue-50 rounded-lg p-4 border-2 border-blue-200">
            <div class="flex items-start gap-2">
              <span class="text-2xl">🎯</span>
              <div class="flex-1">
                <p class="text-xs font-semibold text-blue-600 mb-1">이번 주 목표</p>
                <p class="text-sm font-medium text-gray-900">{{ currentWeekGoal.title }}</p>
              </div>
            </div>
          </div>
        </div>

        <!-- 퀘스트 목록 -->
        <div class="p-6 space-y-3">
          <div
            v-for="(quest, index) in suggestedQuests"
            :key="index"
            class="border-2 rounded-xl p-4 transition-all"
            :class="selectedQuests.has(index) ? 'border-emerald-500 bg-emerald-50' : 'border-gray-200 hover:border-gray-300'"
          >
            <label class="flex items-start gap-3 cursor-pointer">
              <input
                type="checkbox"
                :checked="selectedQuests.has(index)"
                @change="toggleQuest(index)"
                class="mt-1 w-5 h-5 text-emerald-600 rounded"
              />
              <div class="flex-1">
                <div class="flex items-center gap-2 mb-2">
                  <h3 class="font-semibold text-gray-900">{{ quest.title }}</h3>
                  <span
                    class="text-xs px-2 py-1 rounded-full font-medium"
                    :class="getDifficultyClass(quest.difficulty)"
                  >
                    {{ getDifficultyLabel(quest.difficulty) }}
                  </span>
                  <span class="text-xs text-gray-500">
                    ⏱ {{ quest.estimatedTime }}분
                  </span>
                </div>
                <p class="text-sm text-gray-600 italic">{{ quest.reason }}</p>
              </div>
            </label>
          </div>
        </div>

        <!-- 하단 버튼 -->
        <div class="sticky bottom-0 bg-white border-t border-gray-200 px-6 py-4 flex gap-3 rounded-b-3xl">
          <button
            @click="close"
            class="px-6 py-3 bg-gray-200 text-gray-700 rounded-xl font-medium hover:bg-gray-300 transition-colors"
          >
            닫기
          </button>
          <button
            @click="addSelectedQuests"
            :disabled="selectedQuests.size === 0"
            class="flex-1 px-6 py-3 rounded-xl font-medium transition-all"
            :class="selectedQuests.size > 0 ? 'bg-gradient-to-r from-emerald-500 to-green-600 text-white hover:shadow-lg' : 'bg-gray-300 text-gray-500 cursor-not-allowed'"
          >
            {{ selectedQuests.size }}개 퀘스트 추가 ✓
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import { suggestDailyQuests } from '@/services/openai'
import { useQuestStore } from '@/stores/quest'

const props = defineProps({
  show: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['complete', 'close'])

const questStore = useQuestStore()

const isGenerating = ref(false)
const error = ref(null)
const suggestedQuests = ref([])
const selectedQuests = ref(new Set())
const loadingMessage = ref('주차 목표를 분석하고 있어요...')

const loadingMessages = [
  '주차 목표를 분석하고 있어요...',
  '오늘 실행 가능한 퀘스트를 찾고 있어요...',
  '맞춤형 퀘스트를 제안하고 있어요...',
  '거의 완료되었어요...'
]

let loadingInterval = null
let messageIndex = 0

// 현재 주차 목표
const currentWeekGoal = computed(() => questStore.currentWeekGoal)

// 완료한 퀘스트 목록
const completedQuests = computed(() => questStore.completedQuests)

// 사용 가능한 시간
const availableTime = computed(() => questStore.visionProfile?.availableTime || 2)

// show가 true로 변경되면 자동으로 생성 시작
watch(() => props.show, (newVal) => {
  if (newVal) {
    startGeneration()
  }
})

async function startGeneration() {
  isGenerating.value = true
  error.value = null
  suggestedQuests.value = []
  selectedQuests.value = new Set()
  messageIndex = 0
  loadingMessage.value = loadingMessages[0]

  // 로딩 메시지 순환
  loadingInterval = setInterval(() => {
    messageIndex = (messageIndex + 1) % loadingMessages.length
    loadingMessage.value = loadingMessages[messageIndex]
  }, 2000)

  try {
    // 현재 주차 목표가 없으면 에러
    if (!currentWeekGoal.value) {
      throw new Error('현재 주차 목표가 설정되지 않았습니다. 먼저 목표 트리를 생성해주세요.')
    }

    const quests = await suggestDailyQuests(
      currentWeekGoal.value,
      completedQuests.value,
      availableTime.value
    )

    if (!quests || quests.length === 0) {
      throw new Error('추천 퀘스트를 생성하지 못했습니다.')
    }

    suggestedQuests.value = quests

    // 모든 퀘스트를 기본으로 선택
    quests.forEach((_, index) => {
      selectedQuests.value.add(index)
    })
  } catch (err) {
    console.error('퀘스트 추천 실패:', err)
    error.value = err.message || '퀘스트를 추천하는 중 오류가 발생했습니다.'
  } finally {
    isGenerating.value = false
    if (loadingInterval) {
      clearInterval(loadingInterval)
      loadingInterval = null
    }
  }
}

function toggleQuest(index) {
  if (selectedQuests.value.has(index)) {
    selectedQuests.value.delete(index)
  } else {
    selectedQuests.value.add(index)
  }
  // Set을 새로 만들어서 반응성 트리거
  selectedQuests.value = new Set(selectedQuests.value)
}

function getDifficultyClass(difficulty) {
  switch (difficulty) {
    case 'easy':
      return 'bg-green-100 text-green-700'
    case 'hard':
      return 'bg-red-100 text-red-700'
    default:
      return 'bg-yellow-100 text-yellow-700'
  }
}

function getDifficultyLabel(difficulty) {
  switch (difficulty) {
    case 'easy':
      return '쉬움'
    case 'hard':
      return '어려움'
    default:
      return '보통'
  }
}

function retryGeneration() {
  startGeneration()
}

function regenerateQuests() {
  if (confirm('퀘스트를 다시 추천받으시겠습니까?')) {
    startGeneration()
  }
}

function addSelectedQuests() {
  const selected = Array.from(selectedQuests.value).map(index => suggestedQuests.value[index])

  // 선택된 퀘스트를 스토어에 추가
  selected.forEach(quest => {
    questStore.addQuest({
      title: quest.title,
      difficulty: quest.difficulty,
      isRecurring: false
    })
  })

  emit('complete', selected)
  close()
}

function close() {
  emit('close')
}
</script>

<style scoped>
@keyframes bounce {
  0%, 100% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-10px);
  }
}

.animate-bounce {
  animation: bounce 1s infinite;
}

/* 스크롤바 스타일링 */
div::-webkit-scrollbar {
  width: 8px;
}

div::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 10px;
}

div::-webkit-scrollbar-thumb {
  background: #888;
  border-radius: 10px;
}

div::-webkit-scrollbar-thumb:hover {
  background: #555;
}
</style>
