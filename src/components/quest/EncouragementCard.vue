<template>
  <div class="card text-center relative overflow-hidden">
    <div
      v-if="showCelebration"
      class="absolute inset-0 bg-gradient-to-r from-purple-100 to-blue-100 animate-pulse"
    ></div>

    <div class="relative z-10">
      <div class="text-5xl mb-4 animate-bounce-gentle">{{ getEmoji() }}</div>
      <p class="text-neutral-800 font-semibold text-xl mb-2">{{ encouragementMessage }}</p>
      <p class="text-neutral-600 text-sm mb-4">{{ getMotivationalQuote() }}</p>

      <!-- 진행 상황 표시 -->
      <div v-if="questStore.completionRate > 0" class="bg-neutral-100 rounded-full p-1 mb-4">
        <div class="flex items-center justify-between text-xs text-neutral-600 mb-1">
          <span>오늘의 진행률</span>
          <span>{{ Math.round(questStore.completionRate) }}%</span>
        </div>
        <div class="bg-neutral-200 rounded-full h-2 overflow-hidden">
          <div
            class="h-full rounded-full bg-gradient-to-r from-purple-500 to-blue-500 transition-all duration-1000 ease-out"
            :style="{ width: `${questStore.completionRate}%` }"
          ></div>
        </div>
      </div>

      <!-- 연속 달성 표시 -->
      <div v-if="questStore.streakCount > 0" class="flex items-center justify-center gap-2 text-sm">
        <span class="text-orange-500">🔥</span>
        <span class="text-neutral-600">{{ questStore.streakCount }}일 연속 달성!</span>
      </div>
    </div>

    <!-- 완료 시 축하 효과 -->
    <div
      v-if="showCompletionEffect"
      class="absolute inset-0 pointer-events-none animate-fade-in"
    >
      <div class="absolute top-4 left-4 text-2xl animate-bounce" style="animation-delay: 0.1s;">🎉</div>
      <div class="absolute top-6 right-6 text-xl animate-bounce" style="animation-delay: 0.3s;">✨</div>
      <div class="absolute bottom-8 left-8 text-2xl animate-bounce" style="animation-delay: 0.5s;">🌟</div>
      <div class="absolute bottom-4 right-4 text-xl animate-bounce" style="animation-delay: 0.7s;">💫</div>
    </div>
  </div>
</template>

<script setup>
import { computed, ref, watch } from 'vue'
import { useQuestStore } from '../../stores/quest'

const questStore = useQuestStore()
const encouragementMessage = computed(() => questStore.getEncouragementMessage())

// 축하 효과 상태
const showCelebration = ref(false)
const showCompletionEffect = ref(false)
const lastCompletionRate = ref(questStore.completionRate)

// 완료율 변화 감지하여 축하 효과 트리거
watch(
  () => questStore.completionRate,
  (newRate, oldRate) => {
    if (newRate > oldRate && newRate >= 80) {
      triggerCelebration()
    }
    lastCompletionRate.value = newRate
  }
)

function triggerCelebration() {
  showCelebration.value = true
  showCompletionEffect.value = true

  // 3초 후 효과 끄기
  setTimeout(() => {
    showCelebration.value = false
  }, 3000)

  // 5초 후 완료 효과 끄기
  setTimeout(() => {
    showCompletionEffect.value = false
  }, 5000)
}

function getEmoji() {
  const rate = questStore.completionRate
  if (rate >= 80) return '🎉'
  if (rate >= 60) return '💪'
  if (rate >= 40) return '👍'
  if (rate >= 20) return '😊'
  return '🤗'
}

function getMotivationalQuote() {
  const rate = questStore.completionRate
  const condition = questStore.currentCondition

  const quotes = {
    high: [
      '대단해요! 오늘도 완벽하게 해내셨네요 🌟',
      '목표 달성을 축하드려요! 내일도 화이팅! 🎉',
      '와! 정말 멋진 하루를 보내셨어요 ✨'
    ],
    good: [
      '훌륭해요! 꾸준히 잘 해나가고 있어요 👏',
      '좋은 페이스로 진행하고 있네요! 💪',
      '이 기세로 계속 가보세요! 🚀'
    ],
    medium: [
      '절반 이상 달성! 정말 잘하고 있어요 👍',
      '꾸준함이 가장 중요해요. 화이팅! 😊',
      '오늘도 한 걸음 나아갔네요 🌱'
    ],
    low: [
      '괜찮아요! 작은 시작이 큰 변화를 만들어요 🤗',
      '완벽하지 않아도 돼요. 천천히 해봐요 💝',
      '오늘 하루도 수고했어요! 내일은 더 나을 거예요 🌈'
    ],
    none: [
      '새로운 하루가 시작됐어요! 화이팅! ⚡',
      '오늘은 어떤 멋진 일들이 기다리고 있을까요? 🎯',
      '작은 한 걸음부터 시작해봐요! 💫'
    ]
  }

  let category
  if (rate >= 80) category = 'high'
  else if (rate >= 60) category = 'good'
  else if (rate >= 30) category = 'medium'
  else if (rate > 0) category = 'low'
  else category = 'none'

  const categoryQuotes = quotes[category]
  return categoryQuotes[Math.floor(Math.random() * categoryQuotes.length)]
}
</script>