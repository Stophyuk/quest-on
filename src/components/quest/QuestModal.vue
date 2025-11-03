<template>
  <div class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black bg-opacity-50 animate-fade-in">
    <div class="card w-full max-w-md p-6 animate-slide-up">
      <!-- 헤더 -->
      <div class="flex justify-between items-center mb-6">
        <h3 class="text-xl font-bold text-neutral-800">
          새 퀘스트 추가
        </h3>
        <button
          @click="$emit('close')"
          class="p-2 rounded-lg hover:bg-neutral-100 transition-colors"
        >
          ✖️
        </button>
      </div>

      <!-- 폼 -->
      <form @submit.prevent="submitForm" class="space-y-4">
        <!-- 제목 -->
        <div>
          <label class="block text-sm font-medium text-neutral-700 mb-1">
            퀘스트 제목 *
          </label>
          <input
            v-model="form.title"
            type="text"
            required
            placeholder="예: 물 8잔 마시기"
            class="w-full px-3 py-2 border border-neutral-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
          >
        </div>

        <!-- 매일 반복 -->
        <div class="bg-purple-50 border border-purple-200 rounded-lg p-3">
          <label class="flex items-center gap-2 cursor-pointer">
            <input
              v-model="form.isRecurring"
              type="checkbox"
              class="w-5 h-5 rounded border-purple-300 text-purple-600 focus:ring-purple-500"
            >
            <div class="flex-1">
              <div class="font-medium text-purple-900">매일 반복하기 🔄</div>
              <div class="text-xs text-purple-600 mt-0.5">
                매일 자정에 자동으로 리셋되며 연속 달성 일수를 추적합니다
              </div>
            </div>
          </label>
        </div>

        <!-- 난이도 -->
        <div>
          <label class="block text-sm font-medium text-neutral-700 mb-2">
            난이도 선택
          </label>
          <div class="grid grid-cols-3 gap-3">
            <button
              v-for="level in difficulties"
              :key="level.value"
              type="button"
              @click="form.difficulty = level.value"
              :class="[
                'p-4 rounded-xl border-2 transition-all duration-200 text-center relative',
                form.difficulty === level.value
                  ? 'border-purple-500 bg-purple-100 shadow-md scale-105'
                  : 'border-neutral-200 hover:border-neutral-300 hover:bg-neutral-50'
              ]"
            >
              <!-- 선택 체크마크 -->
              <div
                v-if="form.difficulty === level.value"
                class="absolute -top-1 -right-1 w-5 h-5 bg-purple-500 rounded-full flex items-center justify-center"
              >
                <span class="text-white text-xs">✓</span>
              </div>
              <div class="text-2xl mb-1">{{ level.emoji }}</div>
              <div
                class="text-xs font-medium"
                :class="form.difficulty === level.value ? 'text-purple-700' : 'text-neutral-700'"
              >
                {{ level.label }}
              </div>
              <div
                class="text-xs mt-1"
                :class="form.difficulty === level.value ? 'text-purple-600 font-semibold' : 'text-neutral-500'"
              >
                {{ level.xp }}XP
              </div>
            </button>
          </div>
        </div>

        <!-- 빠른 추천 -->
        <div class="bg-blue-50 border border-blue-200 rounded-lg p-3">
          <div class="flex items-center gap-2 mb-2">
            <span class="text-blue-600">💡</span>
            <span class="text-sm font-medium text-blue-800">빠른 추천</span>
          </div>
          <div class="flex flex-wrap gap-2">
            <button
              v-for="suggestion in quickSuggestions"
              :key="suggestion.id"
              type="button"
              @click="applySuggestion(suggestion)"
              class="text-xs px-2 py-1 bg-blue-100 text-blue-700 rounded-lg hover:bg-blue-200 transition-colors"
            >
              {{ suggestion.title }}
            </button>
          </div>
        </div>

        <!-- 버튼들 -->
        <div class="flex gap-3 pt-4">
          <button
            type="button"
            @click="$emit('close')"
            class="flex-1 py-2 px-4 border border-neutral-300 text-neutral-700 rounded-lg hover:bg-neutral-50 transition-colors"
          >
            취소
          </button>
          <button
            type="submit"
            :disabled="!form.title.trim()"
            class="flex-1 py-2 px-4 bg-primary-600 text-white rounded-lg hover:bg-primary-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
          >
            추가
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useQuestStore } from '@/stores/quest'

const emit = defineEmits(['close'])

const questStore = useQuestStore()

// 난이도 옵션
const difficulties = [
  { value: 'easy', label: '쉬움', emoji: '😊', xp: 10 },
  { value: 'normal', label: '보통', emoji: '😐', xp: 20 },
  { value: 'hard', label: '어려움', emoji: '😞', xp: 30 }
]

// 폼 데이터
const form = ref({
  title: '',
  difficulty: 'normal',
  isRecurring: false
})

// 빠른 추천
const quickSuggestions = ref([
  { id: 'water', title: '물 8잔 마시기', difficulty: 'easy' },
  { id: 'exercise', title: '30분 운동하기', difficulty: 'normal' },
  { id: 'reading', title: '1시간 독서하기', difficulty: 'normal' },
  { id: 'meditation', title: '10분 명상하기', difficulty: 'easy' }
])

// 빠른 추천 적용
function applySuggestion(suggestion) {
  form.value.title = suggestion.title
  form.value.difficulty = suggestion.difficulty
}

// 폼 제출
function submitForm() {
  if (!form.value.title.trim()) return

  questStore.addQuest({
    title: form.value.title.trim(),
    difficulty: form.value.difficulty,
    isRecurring: form.value.isRecurring
  })

  emit('close')
}
</script>

<style scoped>
@keyframes fade-in {
  from { opacity: 0; }
  to { opacity: 1; }
}

@keyframes slide-up {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.animate-fade-in {
  animation: fade-in 0.2s ease-out;
}

.animate-slide-up {
  animation: slide-up 0.3s ease-out;
}
</style>
