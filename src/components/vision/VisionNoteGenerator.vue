<template>
  <div v-if="show" class="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50 p-4">
    <div class="bg-white rounded-3xl shadow-2xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
      <!-- 로딩 상태 -->
      <div v-if="isGenerating" class="p-12 text-center">
        <div class="relative inline-block mb-6">
          <div class="w-24 h-24 border-8 border-blue-200 border-t-blue-600 rounded-full animate-spin"></div>
          <div class="absolute inset-0 flex items-center justify-center text-4xl">✨</div>
        </div>
        <h3 class="text-2xl font-bold text-gray-900 mb-3">AI가 비전 노트를 작성하고 있어요</h3>
        <p class="text-gray-600 mb-6">{{ loadingMessage }}</p>
        <div class="flex justify-center gap-2">
          <div class="w-3 h-3 bg-blue-500 rounded-full animate-bounce" style="animation-delay: 0s"></div>
          <div class="w-3 h-3 bg-blue-500 rounded-full animate-bounce" style="animation-delay: 0.2s"></div>
          <div class="w-3 h-3 bg-blue-500 rounded-full animate-bounce" style="animation-delay: 0.4s"></div>
        </div>
      </div>

      <!-- 에러 상태 -->
      <div v-else-if="error" class="p-12 text-center">
        <div class="text-6xl mb-4">😢</div>
        <h3 class="text-2xl font-bold text-gray-900 mb-3">비전 노트 생성 실패</h3>
        <p class="text-gray-600 mb-6">{{ error }}</p>
        <div class="flex gap-3 justify-center">
          <button
            @click="retryGeneration"
            class="px-6 py-3 bg-blue-500 text-white rounded-xl font-medium hover:bg-blue-600 transition-colors"
          >
            다시 시도
          </button>
          <button
            @click="skipVisionNote"
            class="px-6 py-3 bg-gray-200 text-gray-700 rounded-xl font-medium hover:bg-gray-300 transition-colors"
          >
            건너뛰기
          </button>
        </div>
      </div>

      <!-- 생성 완료 - 비전 노트 표시 -->
      <div v-else-if="generatedNote" class="overflow-y-auto max-h-[90vh]">
        <!-- 헤더 -->
        <div class="sticky top-0 bg-white border-b border-gray-200 px-6 py-4 rounded-t-3xl z-10">
          <h2 class="text-2xl font-bold text-gray-900">🌟 당신의 비전 노트</h2>
          <p class="text-sm text-gray-600 mt-1">AI가 작성한 당신만의 비전입니다</p>
        </div>

        <!-- 비전 노트 섹션별 내용 -->
        <div class="p-6 space-y-4">
          <!-- 1. 당신에 대한 이해 -->
          <div class="card bg-gradient-to-br from-blue-50 to-indigo-50 border-2 border-blue-200">
            <h3 class="text-lg font-bold text-blue-900 mb-3 flex items-center gap-2">
              <span>🔍</span> 당신에 대한 이해
            </h3>
            <div class="space-y-3">
              <div class="bg-white rounded-lg p-3">
                <p class="text-xs font-semibold text-blue-700 mb-1">현재 위치</p>
                <p class="text-sm text-gray-800 leading-relaxed">{{ generatedNote.understanding?.currentPosition }}</p>
              </div>
              <div class="bg-white rounded-lg p-3">
                <p class="text-xs font-semibold text-blue-700 mb-1">내면의 갈등</p>
                <p class="text-sm text-gray-800 leading-relaxed">{{ generatedNote.understanding?.innerConflict }}</p>
              </div>
            </div>
          </div>

          <!-- 2. 당신만의 성장 방정식 -->
          <div class="card bg-gradient-to-br from-purple-50 to-pink-50 border-2 border-purple-200">
            <h3 class="text-lg font-bold text-purple-900 mb-3 flex items-center gap-2">
              <span>💫</span> 당신만의 성장 방정식
            </h3>
            <div class="space-y-3">
              <div class="bg-white rounded-lg p-3">
                <p class="text-xs font-semibold text-purple-700 mb-1">가치관이 말하는 것</p>
                <p class="text-sm text-gray-800 leading-relaxed">{{ generatedNote.growthFormula?.valueAnalysis }}</p>
              </div>
              <div class="bg-white rounded-lg p-3">
                <p class="text-xs font-semibold text-purple-700 mb-1">5년 비전의 핵심</p>
                <p class="text-sm text-gray-800 leading-relaxed">{{ generatedNote.growthFormula?.visionCore }}</p>
              </div>
            </div>
          </div>

          <!-- 3. 1년 후의 변화 -->
          <div class="card bg-gradient-to-br from-green-50 to-emerald-50 border-2 border-green-200">
            <h3 class="text-lg font-bold text-green-900 mb-3 flex items-center gap-2">
              <span>🎯</span> 1년 후, 가장 의미 있는 변화
            </h3>
            <div class="space-y-3">
              <div class="bg-white rounded-lg p-3">
                <p class="text-sm text-gray-800 leading-relaxed mb-3">{{ generatedNote.oneYearChange?.overview }}</p>
              </div>

              <div class="bg-white rounded-lg p-3">
                <p class="text-xs font-semibold text-green-700 mb-2">핵심 마일스톤</p>
                <ul class="space-y-1">
                  <li v-for="(milestone, index) in generatedNote.oneYearChange?.milestones" :key="index" class="text-sm text-gray-800 flex items-start gap-2">
                    <span class="text-green-600 font-bold">✓</span>
                    <span>{{ milestone }}</span>
                  </li>
                </ul>
              </div>

              <div class="bg-white rounded-lg p-3">
                <p class="text-xs font-semibold text-orange-700 mb-2">예상되는 도전</p>
                <ul class="space-y-1">
                  <li v-for="(challenge, index) in generatedNote.oneYearChange?.challenges" :key="index" class="text-sm text-gray-800 flex items-start gap-2">
                    <span class="text-orange-600 font-bold">⚠</span>
                    <span>{{ challenge }}</span>
                  </li>
                </ul>
              </div>

              <div class="bg-white rounded-lg p-3">
                <p class="text-xs font-semibold text-blue-700 mb-2">돌파 전략</p>
                <ul class="space-y-1">
                  <li v-for="(strategy, index) in generatedNote.oneYearChange?.strategies" :key="index" class="text-sm text-gray-800 flex items-start gap-2">
                    <span class="text-blue-600 font-bold">→</span>
                    <span>{{ strategy }}</span>
                  </li>
                </ul>
              </div>
            </div>
          </div>

          <!-- 4. 실행 전략 -->
          <div class="card bg-gradient-to-br from-orange-50 to-yellow-50 border-2 border-orange-200">
            <h3 class="text-lg font-bold text-orange-900 mb-3 flex items-center gap-2">
              <span>⚡</span> 당신에게 맞는 실행 전략
            </h3>
            <div class="space-y-3">
              <div class="bg-white rounded-lg p-3">
                <p class="text-xs font-semibold text-orange-700 mb-1">시간 설계</p>
                <p class="text-sm text-gray-800 leading-relaxed">{{ generatedNote.actionStrategy?.timeDesign }}</p>
              </div>
              <div class="bg-white rounded-lg p-3">
                <p class="text-xs font-semibold text-orange-700 mb-1">학습 최적화</p>
                <p class="text-sm text-gray-800 leading-relaxed">{{ generatedNote.actionStrategy?.learningOptimization }}</p>
              </div>
              <div class="bg-white rounded-lg p-3">
                <p class="text-xs font-semibold text-orange-700 mb-1">동기 유지 시스템</p>
                <p class="text-sm text-gray-800 leading-relaxed">{{ generatedNote.actionStrategy?.motivationSystem }}</p>
              </div>
            </div>
          </div>

          <!-- 5. 코치의 통찰 -->
          <div class="card bg-gradient-to-br from-pink-50 to-rose-50 border-2 border-pink-200">
            <h3 class="text-lg font-bold text-pink-900 mb-3 flex items-center gap-2">
              <span>💬</span> 코치의 통찰
            </h3>
            <div class="bg-white rounded-lg p-4">
              <p class="text-sm text-gray-800 leading-relaxed italic">{{ generatedNote.coachingInsight?.message }}</p>
            </div>
          </div>
        </div>

        <!-- 하단 버튼 -->
        <div class="sticky bottom-0 bg-white border-t border-gray-200 px-6 py-4 rounded-b-3xl">
          <button
            @click="confirmNote"
            class="w-full px-6 py-3 bg-gradient-to-r from-green-500 to-emerald-600 text-white rounded-xl font-medium hover:shadow-lg transition-all"
          >
            확인하고 계속하기 ✓
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import { generateVisionNote } from '@/services/openai'
import { useQuestStore } from '@/stores/quest'

const props = defineProps({
  show: {
    type: Boolean,
    default: false
  },
  visionProfile: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['complete', 'skip', 'close'])

const questStore = useQuestStore()

const isGenerating = ref(false)
const error = ref(null)
const generatedNote = ref(null)
const loadingMessage = ref('당신의 응답을 분석하고 있어요...')

const loadingMessages = [
  '당신의 응답을 분석하고 있어요...',
  '가치관과 목표를 정리하고 있어요...',
  '맞춤형 비전을 작성하고 있어요...',
  '거의 완료되었어요...'
]

let loadingInterval = null
let messageIndex = 0

// 비전 프로필이 변경되면 자동으로 생성 시작
watch(() => props.show, (newVal) => {
  if (newVal && props.visionProfile) {
    startGeneration()
  }
})

async function startGeneration() {
  isGenerating.value = true
  error.value = null
  generatedNote.value = null
  messageIndex = 0
  loadingMessage.value = loadingMessages[0]

  // 로딩 메시지 순환
  loadingInterval = setInterval(() => {
    messageIndex = (messageIndex + 1) % loadingMessages.length
    loadingMessage.value = loadingMessages[messageIndex]
  }, 3000)

  try {
    const note = await generateVisionNote(props.visionProfile)
    generatedNote.value = note

    // Store에 JSON 객체로 저장
    questStore.setVisionNote(note)
  } catch (err) {
    console.error('비전 노트 생성 실패:', err)
    error.value = err.message || '비전 노트를 생성하는 중 오류가 발생했습니다.'
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

function regenerateNote() {
  if (confirm('비전 노트를 다시 생성하시겠습니까?')) {
    startGeneration()
  }
}

function skipVisionNote() {
  if (confirm('비전 노트 없이 계속 진행하시겠습니까? 나중에 다시 생성할 수 있습니다.')) {
    emit('skip')
  }
}

function confirmNote() {
  emit('complete', generatedNote.value)
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
