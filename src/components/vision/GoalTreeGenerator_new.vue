<template>
  <div v-if="show" class="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50 p-4">
    <div class="bg-white rounded-3xl shadow-2xl max-w-4xl w-full max-h-[90vh] flex flex-col">
      <!-- 로딩 상태 -->
      <div v-if="isGenerating" class="p-12 text-center">
        <div class="relative inline-block mb-6">
          <div class="w-24 h-24 border-8 border-purple-200 border-t-purple-600 rounded-full animate-spin"></div>
          <div class="absolute inset-0 flex items-center justify-center text-4xl">🎯</div>
        </div>
        <h3 class="text-2xl font-bold text-gray-900 mb-3">목표 트리를 생성하고 있어요</h3>
        <p class="text-gray-600 mb-6">{{ loadingMessage }}</p>
        <div class="flex justify-center gap-2">
          <div class="w-3 h-3 bg-purple-500 rounded-full animate-bounce" style="animation-delay: 0s"></div>
          <div class="w-3 h-3 bg-purple-500 rounded-full animate-bounce" style="animation-delay: 0.2s"></div>
          <div class="w-3 h-3 bg-purple-500 rounded-full animate-bounce" style="animation-delay: 0.4s"></div>
        </div>
      </div>

      <!-- 에러 상태 -->
      <div v-else-if="error" class="p-12 text-center">
        <div class="text-6xl mb-4">😢</div>
        <h3 class="text-2xl font-bold text-gray-900 mb-3">목표 트리 생성 실패</h3>
        <p class="text-gray-600 mb-6">{{ error }}</p>
        <div class="flex gap-3 justify-center">
          <button
            @click="retryGeneration"
            class="px-6 py-3 bg-purple-500 text-white rounded-xl font-medium hover:bg-purple-600 transition-colors"
          >
            다시 시도
          </button>
          <button
            @click="skipGoalTree"
            class="px-6 py-3 bg-gray-200 text-gray-700 rounded-xl font-medium hover:bg-gray-300 transition-colors"
          >
            건너뛰기
          </button>
        </div>
      </div>

      <!-- 생성 완료 - 목표 트리 요약 표시 -->
      <template v-else-if="generatedTree && generatedTree.length > 0">
        <!-- 헤더 -->
        <div class="bg-white border-b border-gray-200 px-6 py-4 rounded-t-3xl flex-shrink-0">
          <h2 class="text-2xl font-bold text-gray-900">🎯 1년 로드맵 생성 완료!</h2>
          <p class="text-sm text-gray-600 mt-1">당신만의 성장 계획이 준비되었습니다</p>
        </div>

        <!-- 요약 내용 (스크롤 가능) -->
        <div class="flex-1 overflow-y-auto px-6 py-6">
          <div class="space-y-4">
            <!-- 첫 주차 목표 미리보기 -->
            <div v-if="firstWeekGoal" class="card bg-gradient-to-br from-green-50 to-emerald-50 border-2 border-green-200">
              <div class="flex items-start gap-3 mb-3">
                <span class="text-3xl">⭐</span>
                <div class="flex-1">
                  <p class="text-xs font-semibold text-green-700 mb-1">이번 주 시작 목표</p>
                  <h3 class="text-lg font-bold text-gray-900">{{ firstWeekGoal.title }}</h3>
                </div>
              </div>

              <div v-if="firstWeekGoal.suggestedQuests && firstWeekGoal.suggestedQuests.length > 0" class="bg-white rounded-lg p-3">
                <p class="text-xs font-semibold text-gray-600 mb-2">실행 항목:</p>
                <ul class="space-y-1">
                  <li
                    v-for="(quest, index) in firstWeekGoal.suggestedQuests"
                    :key="index"
                    class="text-sm text-gray-800 flex items-start gap-2"
                  >
                    <span class="text-green-600 font-bold">✓</span>
                    <span>{{ quest }}</span>
                  </li>
                </ul>
              </div>
            </div>

            <!-- 로드맵 요약 정보 -->
            <div class="card bg-gradient-to-br from-blue-50 to-indigo-50 border-2 border-blue-200">
              <div class="flex items-center gap-3 mb-3">
                <span class="text-3xl">🗺️</span>
                <h3 class="text-lg font-bold text-gray-900">전체 로드맵 구성</h3>
              </div>

              <div class="grid grid-cols-3 gap-3">
                <div class="bg-white rounded-lg p-3 text-center">
                  <p class="text-2xl font-bold text-blue-600">{{ totalQuarters }}</p>
                  <p class="text-xs text-gray-600 mt-1">분기</p>
                </div>
                <div class="bg-white rounded-lg p-3 text-center">
                  <p class="text-2xl font-bold text-purple-600">{{ totalMonths }}</p>
                  <p class="text-xs text-gray-600 mt-1">개월</p>
                </div>
                <div class="bg-white rounded-lg p-3 text-center">
                  <p class="text-2xl font-bold text-green-600">{{ totalWeeks }}</p>
                  <p class="text-xs text-gray-600 mt-1">주차</p>
                </div>
              </div>

              <div class="mt-3 bg-white rounded-lg p-3">
                <p class="text-sm text-gray-700 leading-relaxed">
                  <span class="font-semibold text-blue-700">💡 안내:</span>
                  전체 로드맵은 <span class="font-bold text-blue-600">🗺️ 로드맵</span> 메뉴에서 언제든지 확인할 수 있습니다.
                </p>
              </div>
            </div>

            <!-- 시작 격려 메시지 -->
            <div class="card bg-gradient-to-br from-purple-50 to-pink-50 border-2 border-purple-200">
              <div class="text-center">
                <p class="text-4xl mb-3">🚀</p>
                <h3 class="text-lg font-bold text-purple-900 mb-2">준비가 완료되었습니다!</h3>
                <p class="text-sm text-gray-700 leading-relaxed">
                  이제 매일 추천되는 퀘스트를 완료하며<br>
                  당신의 목표를 향해 나아가세요.
                </p>
              </div>
            </div>
          </div>
        </div>

        <!-- 하단 버튼 (고정) -->
        <div class="bg-white border-t border-gray-200 px-6 py-4 rounded-b-3xl flex-shrink-0">
          <button
            @click="confirmTree"
            class="w-full px-6 py-3 bg-gradient-to-r from-purple-500 to-indigo-600 text-white rounded-xl font-medium hover:shadow-lg transition-all text-lg"
          >
            Quest ON 시작하기! 🎮
          </button>
        </div>
      </template>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import { generateGoalTree } from '@/services/openai'
import { useQuestStore } from '@/stores/quest'

const props = defineProps({
  show: {
    type: Boolean,
    default: false
  },
  visionNote: {
    type: String,
    required: true
  },
  yearGoals: {
    type: Array,
    required: true
  }
})

const emit = defineEmits(['complete', 'skip', 'close'])

const questStore = useQuestStore()

const isGenerating = ref(false)
const error = ref(null)
const generatedTree = ref([])
const loadingMessage = ref('비전 노트를 분석하고 있어요...')

const loadingMessages = [
  '비전 노트를 분석하고 있어요...',
  '연간 목표를 세분화하고 있어요...',
  '실행 가능한 단계로 나누고 있어요...',
  '거의 완료되었어요...'
]

let loadingInterval = null
let messageIndex = 0

// 첫 주차 목표 (온보딩 미리보기용)
const firstWeekGoal = computed(() => {
  if (generatedTree.value.length > 0 &&
      generatedTree.value[0].quarters?.[0]?.months?.[0]?.weeks?.[0]) {
    return generatedTree.value[0].quarters[0].months[0].weeks[0]
  }
  return null
})

// 전체 로드맵 통계
const totalQuarters = computed(() => {
  return generatedTree.value.reduce((sum, year) => sum + (year.quarters?.length || 0), 0)
})

const totalMonths = computed(() => {
  return generatedTree.value.reduce((sum, year) => {
    return sum + (year.quarters?.reduce((qSum, quarter) => qSum + (quarter.months?.length || 0), 0) || 0)
  }, 0)
})

const totalWeeks = computed(() => {
  return generatedTree.value.reduce((sum, year) => {
    return sum + (year.quarters?.reduce((qSum, quarter) => {
      return qSum + (quarter.months?.reduce((mSum, month) => mSum + (month.weeks?.length || 0), 0) || 0)
    }, 0) || 0)
  }, 0)
})

// show가 true로 변경되면 자동으로 생성 시작
watch(() => props.show, (newVal) => {
  if (newVal && props.visionNote && props.yearGoals.length > 0) {
    startGeneration()
  }
})

async function startGeneration() {
  isGenerating.value = true
  error.value = null
  generatedTree.value = []
  messageIndex = 0
  loadingMessage.value = loadingMessages[0]

  // 로딩 메시지 순환
  loadingInterval = setInterval(() => {
    messageIndex = (messageIndex + 1) % loadingMessages.length
    loadingMessage.value = loadingMessages[messageIndex]
  }, 3000)

  try {
    const tree = await generateGoalTree(props.visionNote, props.yearGoals)

    // 응답이 배열이면 그대로, 객체면 goals 속성 추출
    if (Array.isArray(tree)) {
      generatedTree.value = tree
    } else if (tree.goals && Array.isArray(tree.goals)) {
      generatedTree.value = tree.goals
    } else {
      throw new Error('목표 트리 형식이 올바르지 않습니다.')
    }

    // Store에 저장
    questStore.setGoalTree(generatedTree.value)

    // 첫 주차 목표를 현재 주차 목표로 설정
    if (generatedTree.value.length > 0 &&
        generatedTree.value[0].quarters?.[0]?.months?.[0]?.weeks?.[0]) {
      const firstWeekGoal = generatedTree.value[0].quarters[0].months[0].weeks[0]
      questStore.setCurrentWeekGoal(firstWeekGoal)
    }
  } catch (err) {
    console.error('목표 트리 생성 실패:', err)
    error.value = err.message || '목표 트리를 생성하는 중 오류가 발생했습니다.'
  } finally {
    isGenerating.value = false
    if (loadingInterval) {
      clearInterval(loadingInterval)
      loadingInterval = null
    }
  }
}

function retryGeneration() {
  startGeneration()
}

function skipGoalTree() {
  if (confirm('목표 트리 없이 계속 진행하시겠습니까? 나중에 다시 생성할 수 있습니다.')) {
    emit('skip')
  }
}

function confirmTree() {
  emit('complete', generatedTree.value)
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
