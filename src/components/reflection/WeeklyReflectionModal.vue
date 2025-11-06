<template>
  <div v-if="show" class="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50 p-4">
    <div class="bg-white rounded-3xl shadow-2xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
      <!-- 회고 작성 단계 -->
      <div v-if="!isGenerating && !aiCoaching" class="overflow-y-auto max-h-[90vh]">
        <!-- 헤더 -->
        <div class="sticky top-0 bg-white border-b border-gray-200 px-6 py-4 rounded-t-3xl z-10">
          <h2 class="text-2xl font-bold text-gray-900">📝 주간 회고</h2>
          <p class="text-sm text-gray-600 mt-1">이번 주를 돌아보며 회고를 작성해보세요</p>
        </div>

        <!-- 주간 통계 -->
        <div class="px-6 pt-4">
          <div class="bg-blue-50 rounded-lg p-4 border-2 border-blue-200">
            <h3 class="font-semibold text-blue-900 mb-3">📊 이번 주 성과</h3>
            <div class="grid grid-cols-2 gap-3">
              <div class="bg-white rounded-lg p-3">
                <p class="text-xs text-gray-600">완료한 퀘스트</p>
                <p class="text-2xl font-bold text-blue-600">{{ weeklyStats.totalCompleted }}개</p>
              </div>
              <div class="bg-white rounded-lg p-3">
                <p class="text-xs text-gray-600">획득 경험치</p>
                <p class="text-2xl font-bold text-purple-600">{{ weeklyStats.totalXP }} XP</p>
              </div>
              <div class="bg-white rounded-lg p-3">
                <p class="text-xs text-gray-600">완료율</p>
                <p class="text-2xl font-bold text-green-600">{{ weeklyStats.completionRate }}%</p>
              </div>
              <div class="bg-white rounded-lg p-3">
                <p class="text-xs text-gray-600">난이도 분포</p>
                <p class="text-sm font-medium text-gray-800">
                  😊{{ weeklyStats.easy }} 😐{{ weeklyStats.normal }} 😞{{ weeklyStats.hard }}
                </p>
              </div>
            </div>
          </div>
        </div>

        <!-- 회고 질문 -->
        <div class="p-6 space-y-5">
          <!-- 질문 1: 성취한 것 -->
          <div>
            <label class="block text-sm font-semibold text-gray-900 mb-2">
              🎉 이번 주 가장 뿌듯했던 성취는 무엇인가요?
            </label>
            <textarea
              v-model="reflection.achievements"
              placeholder="예: 꾸준히 운동을 지속했고, 프로젝트 마감을 맞췄어요"
              class="w-full px-4 py-3 border-2 border-gray-300 rounded-lg focus:outline-none focus:border-blue-500 resize-none"
              rows="3"
              maxlength="300"
            ></textarea>
            <p class="text-xs text-gray-500 text-right mt-1">{{ reflection.achievements.length }}/300</p>
          </div>

          <!-- 질문 2: 어려웠던 점 -->
          <div>
            <label class="block text-sm font-semibold text-gray-900 mb-2">
              😓 어려웠거나 아쉬웠던 점은 무엇인가요?
            </label>
            <textarea
              v-model="reflection.challenges"
              placeholder="예: 시간 관리가 잘 안 돼서 몇 개 퀘스트를 미루게 됐어요"
              class="w-full px-4 py-3 border-2 border-gray-300 rounded-lg focus:outline-none focus:border-blue-500 resize-none"
              rows="3"
              maxlength="300"
            ></textarea>
            <p class="text-xs text-gray-500 text-right mt-1">{{ reflection.challenges.length }}/300</p>
          </div>

          <!-- 질문 3: 깨달은 점 -->
          <div>
            <label class="block text-sm font-semibold text-gray-900 mb-2">
              💡 이번 주를 통해 깨달은 점이 있나요?
            </label>
            <textarea
              v-model="reflection.insights"
              placeholder="예: 아침에 운동하면 하루가 더 활기차다는 걸 알았어요"
              class="w-full px-4 py-3 border-2 border-gray-300 rounded-lg focus:outline-none focus:border-blue-500 resize-none"
              rows="3"
              maxlength="300"
            ></textarea>
            <p class="text-xs text-gray-500 text-right mt-1">{{ reflection.insights.length }}/300</p>
          </div>
        </div>

        <!-- 하단 버튼 -->
        <div class="sticky bottom-0 bg-white border-t border-gray-200 px-6 py-4 flex gap-3 rounded-b-3xl">
          <button
            @click="close"
            class="px-6 py-3 bg-gray-100 text-gray-700 rounded-xl font-medium hover:bg-gray-200 transition-colors"
          >
            취소
          </button>
          <button
            @click="submitReflection"
            :disabled="!canSubmit"
            class="flex-1 px-6 py-3 rounded-xl font-medium transition-all"
            :class="canSubmit ? 'bg-gradient-to-r from-blue-500 to-indigo-600 text-white hover:shadow-lg' : 'bg-gray-300 text-gray-500 cursor-not-allowed'"
          >
            AI 코칭 받기 🤖
          </button>
        </div>
      </div>

      <!-- AI 코칭 생성 중 -->
      <div v-else-if="isGenerating" class="p-12 text-center">
        <div class="relative inline-block mb-6">
          <div class="w-24 h-24 border-8 border-indigo-200 border-t-indigo-600 rounded-full animate-spin"></div>
          <div class="absolute inset-0 flex items-center justify-center text-4xl">🤖</div>
        </div>
        <h3 class="text-2xl font-bold text-gray-900 mb-3">AI 코치가 분석하고 있어요</h3>
        <p class="text-gray-600 mb-6">{{ loadingMessage }}</p>
        <div class="flex justify-center gap-2">
          <div class="w-3 h-3 bg-indigo-500 rounded-full animate-bounce" style="animation-delay: 0s"></div>
          <div class="w-3 h-3 bg-indigo-500 rounded-full animate-bounce" style="animation-delay: 0.2s"></div>
          <div class="w-3 h-3 bg-indigo-500 rounded-full animate-bounce" style="animation-delay: 0.4s"></div>
        </div>
      </div>

      <!-- AI 코칭 결과 -->
      <div v-else-if="aiCoaching" class="overflow-y-auto max-h-[90vh]">
        <!-- 헤더 -->
        <div class="sticky top-0 bg-white border-b border-gray-200 px-6 py-4 rounded-t-3xl z-10">
          <h2 class="text-2xl font-bold text-gray-900">🤖 AI 코치의 피드백</h2>
          <p class="text-sm text-gray-600 mt-1">당신의 성장을 응원합니다</p>
        </div>

        <!-- 코칭 내용 -->
        <div class="p-6">
          <div class="prose prose-sm max-w-none">
            <div class="whitespace-pre-wrap text-gray-800" v-html="formattedCoaching"></div>
          </div>
        </div>

        <!-- 하단 버튼 -->
        <div class="sticky bottom-0 bg-white border-t border-gray-200 px-6 py-4">
          <button
            @click="confirmCoaching"
            class="w-full px-6 py-3 bg-gradient-to-r from-indigo-500 to-purple-600 text-white rounded-xl font-medium hover:shadow-lg transition-all"
          >
            완료 ✓
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { generateCoaching } from '@/services/openai'
import { useQuestStore } from '@/stores/quest'

const props = defineProps({
  show: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['complete', 'close'])

const questStore = useQuestStore()

const reflection = ref({
  achievements: '',
  challenges: '',
  insights: ''
})

const isGenerating = ref(false)
const aiCoaching = ref('')
const loadingMessage = ref('회고 내용을 분석하고 있어요...')

const loadingMessages = [
  '회고 내용을 분석하고 있어요...',
  '주간 통계를 검토하고 있어요...',
  '맞춤형 코칭을 작성하고 있어요...',
  '거의 완료되었어요...'
]

let loadingInterval = null
let messageIndex = 0

// 주간 통계
const weeklyStats = computed(() => questStore.getWeeklyStats())

// 제출 가능 여부
const canSubmit = computed(() => {
  return reflection.value.achievements.trim().length > 0 ||
         reflection.value.challenges.trim().length > 0 ||
         reflection.value.insights.trim().length > 0
})

// 마크다운 스타일 간단 적용
const formattedCoaching = computed(() => {
  if (!aiCoaching.value) return ''

  return aiCoaching.value
    .replace(/^# (.*$)/gm, '<h1 class="text-2xl font-bold mt-6 mb-3 text-gray-900">$1</h1>')
    .replace(/^## (.*$)/gm, '<h2 class="text-xl font-bold mt-5 mb-2 text-gray-800">$1</h2>')
    .replace(/^### (.*$)/gm, '<h3 class="text-lg font-semibold mt-4 mb-2 text-gray-700">$1</h3>')
    .replace(/\*\*(.*?)\*\*/g, '<strong class="font-bold text-gray-900">$1</strong>')
    .replace(/\*(.*?)\*/g, '<em class="italic">$1</em>')
    .replace(/\n\n/g, '</p><p class="my-3">')
    .replace(/^(.+)$/gm, '<p class="my-2 leading-relaxed">$&</p>')
})

async function submitReflection() {
  isGenerating.value = true
  messageIndex = 0
  loadingMessage.value = loadingMessages[0]

  // 로딩 메시지 순환
  loadingInterval = setInterval(() => {
    messageIndex = (messageIndex + 1) % loadingMessages.length
    loadingMessage.value = loadingMessages[messageIndex]
  }, 2500)

  try {
    const coaching = await generateCoaching(weeklyStats.value, reflection.value)
    aiCoaching.value = coaching

    // 회고 저장
    questStore.addWeeklyReflection({
      ...reflection.value,
      stats: weeklyStats.value,
      aiCoaching: coaching
    })
  } catch (err) {
    console.error('AI 코칭 생성 실패:', err)
    alert('AI 코칭을 생성하는 중 오류가 발생했습니다: ' + err.message)
    close()
  } finally {
    isGenerating.value = false
    if (loadingInterval) {
      clearInterval(loadingInterval)
      loadingInterval = null
    }
  }
}

function regenerateCoaching() {
  if (confirm('AI 코칭을 다시 받으시겠습니까?')) {
    aiCoaching.value = ''
    submitReflection()
  }
}

function confirmCoaching() {
  emit('complete', {
    reflection: reflection.value,
    coaching: aiCoaching.value
  })
  close()
}

function close() {
  // 초기화
  reflection.value = {
    achievements: '',
    challenges: '',
    insights: ''
  }
  aiCoaching.value = ''
  isGenerating.value = false

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
