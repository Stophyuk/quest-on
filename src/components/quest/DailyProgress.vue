<template>
  <div class="bg-white rounded-lg shadow-sm border border-gray-100 p-6">
    <h3 class="text-gray-900 text-lg font-semibold mb-4">오늘의 진행상황</h3>

    <!-- 원형 진행도 -->
    <div class="flex items-center justify-center mb-6">
      <div class="relative w-32 h-32">
        <svg class="w-32 h-32 transform -rotate-90" viewBox="0 0 36 36">
          <!-- 배경 원 -->
          <circle
            cx="18" cy="18" r="15.5"
            fill="transparent"
            stroke="#e5e7eb"
            stroke-width="2"
          />
          <!-- 진행도 원 -->
          <circle
            cx="18" cy="18" r="15.5"
            fill="transparent"
            stroke="url(#progressGradient)"
            stroke-width="3"
            stroke-dasharray="97.4"
            :stroke-dashoffset="97.4 - (completionRate * 0.974)"
            stroke-linecap="round"
            class="transition-all duration-700 ease-out"
          />
          <defs>
            <linearGradient id="progressGradient" x1="0%" y1="0%" x2="100%" y2="0%">
              <stop offset="0%" style="stop-color:#3b82f6"/>
              <stop offset="50%" style="stop-color:#10b981"/>
              <stop offset="100%" style="stop-color:#059669"/>
            </linearGradient>
          </defs>
        </svg>
        <div class="absolute inset-0 flex items-center justify-center">
          <div class="text-center">
            <div class="text-2xl font-bold text-gray-900">{{ Math.round(completionRate) }}%</div>
            <div class="text-xs text-gray-500 mt-1">완료율</div>
          </div>
        </div>
      </div>
    </div>

    <!-- 통계 카드들 -->
    <div class="grid grid-cols-3 gap-3">
      <div class="bg-blue-50 rounded-lg p-3 text-center border border-blue-100">
        <div class="text-blue-600 text-xs font-medium mb-1">완료</div>
        <div class="text-blue-900 font-bold text-lg">{{ completedQuests.length }}</div>
      </div>
      <div class="bg-gray-50 rounded-lg p-3 text-center border border-gray-200">
        <div class="text-gray-600 text-xs font-medium mb-1">전체</div>
        <div class="text-gray-900 font-bold text-lg">{{ todayQuests.length }}</div>
      </div>
      <div class="bg-green-50 rounded-lg p-3 text-center border border-green-100">
        <div class="text-green-600 text-xs font-medium mb-1">EXP</div>
        <div class="text-green-900 font-bold text-lg">{{ earnedExp }}</div>
      </div>
    </div>

    <!-- 격려 메시지 -->
    <div class="mt-4 bg-gradient-to-r from-blue-50 to-green-50 rounded-lg p-4 border border-blue-100">
      <div class="text-center">
        <div class="text-sm font-medium text-gray-900 mb-1">{{ getEncouragementTitle() }}</div>
        <div class="text-xs text-gray-600">{{ getEncouragementMessage() }}</div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useQuestStore } from '../../stores/quest'

const questStore = useQuestStore()
const completionRate = computed(() => questStore.completionRate)
const completedQuests = computed(() => questStore.completedQuests)
const todayQuests = computed(() => questStore.todayQuests)

// 오늘 획득한 경험치 계산
const earnedExp = computed(() => {
  return completedQuests.value.length * 25
})

// 격려 제목
function getEncouragementTitle() {
  const rate = completionRate.value
  if (rate >= 100) return '🎉 모든 퀘스트 완료!'
  if (rate >= 80) return '🔥 거의 다 왔어요!'
  if (rate >= 50) return '💪 절반 성공!'
  if (rate >= 25) return '🌱 좋은 시작이에요!'
  return '✨ 첫 퀘스트를 시작해보세요!'
}

// 격려 메시지
function getEncouragementMessage() {
  const rate = completionRate.value
  const condition = questStore.currentCondition

  if (rate >= 100) {
    return condition === '😞' ? '힘든 중에도 완벽해요!' : '정말 대단합니다!'
  }
  if (rate >= 80) {
    return '마지막 퀘스트까지 화이팅!'
  }
  if (rate >= 50) {
    return '이 페이스로 계속 진행해보세요!'
  }
  if (rate >= 25) {
    return '꾸준함이 가장 중요해요!'
  }
  return '작은 단계부터 시작해보세요!'
}
</script>