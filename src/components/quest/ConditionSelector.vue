<template>
  <div class="card p-6 mb-6 animate-fade-in">
    <!-- 시간대별 인사말 -->
    <div class="text-center mb-4">
      <h3 class="text-2xl font-bold text-neutral-800 mb-1">{{ getGreeting() }}</h3>
      <p class="text-neutral-600 text-sm">오늘 컨디션은 어떠세요?</p>
    </div>

    <!-- 감정 체크인 버튼들 -->
    <div class="grid grid-cols-3 gap-4 mb-6">
      <button
        v-for="mood in moods"
        :key="mood.value"
        @click="selectMood(mood.value)"
        class="btn-mood flex flex-col items-center justify-center touch-optimized"
        :class="[
          currentMood === mood.value ? 'active' : '',
          getMoodClasses(mood.value)
        ]"
        :aria-label="`${mood.label} 선택`"
      >
        <span class="text-4xl mb-2 transition-transform duration-200" 
              :class="{ 'animate-bounce-gentle': currentMood === mood.value }">
          {{ mood.emoji }}
        </span>
        <span class="font-semibold text-sm">{{ mood.label }}</span>
        <span class="text-xs opacity-75 mt-1">{{ mood.shortDesc }}</span>
      </button>
    </div>

    <!-- 선택된 기분에 대한 상세 설명과 격려 -->
    <div class="text-center animate-slide-up" v-if="selectedMood && !isConfirmed">
      <div class="bg-neutral-50 rounded-xl p-4 border border-neutral-200">
        <p class="text-neutral-700 font-medium mb-2">{{ selectedMood.description }}</p>
        <p class="text-sm text-neutral-600">{{ selectedMood.encouragement }}</p>

        <!-- 목표 조정 안내 -->
        <div class="mt-3 text-xs text-neutral-500 bg-white rounded-lg p-3 border">
          <span class="font-medium">📋 오늘의 목표:</span>
          {{ selectedMood.questAdjustment }}
        </div>

        <!-- 결정 버튼 -->
        <button
          @click="confirmCondition"
          class="w-full mt-4 py-3 px-4 bg-gradient-to-r from-purple-500 to-blue-500 text-white rounded-lg hover:from-purple-600 hover:to-blue-600 transition-all duration-200 font-medium shadow-md"
          style="color: white !important;"
        >
          컨디션 결정하기 ✨
        </button>
      </div>
    </div>

    <!-- 축소된 상태 -->
    <div v-if="isConfirmed" class="text-center bg-neutral-50 rounded-lg p-3 border animate-slide-up">
      <div class="flex items-center justify-center gap-3">
        <span class="text-2xl">{{ currentMood }}</span>
        <div class="text-left">
          <p class="text-sm font-medium text-neutral-700">오늘 컨디션: {{ selectedMood?.label }}</p>
          <p class="text-xs text-neutral-500">{{ formatTime(lastCheckedTime) }}에 설정</p>
        </div>
        <button
          @click="changeCondition"
          class="text-xs text-purple-600 hover:text-purple-700 underline ml-auto"
        >
          변경
        </button>
      </div>
    </div>

    <!-- 컨디션 변경 토스트 -->
    <div
      v-if="showToast"
      class="fixed bottom-24 left-1/2 transform -translate-x-1/2 bg-purple-600 text-white px-6 py-3 rounded-lg shadow-lg z-50 animate-slide-up"
    >
      <div class="flex items-center gap-2">
        <span class="text-lg">✨</span>
        <p class="font-medium">{{ toastMessage }}</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, ref, onMounted } from 'vue'
import { useQuestStore } from '../../stores/quest'

const questStore = useQuestStore()
const currentMood = computed(() => questStore.currentCondition)
const lastCheckedTime = ref(new Date())
const isConfirmed = ref(false)

// 토스트 메시지
const showToast = ref(false)
const toastMessage = ref('')

// 오늘 이미 설정했는지 확인
function checkTodayConditionSet() {
  const today = new Date().toDateString()
  const lastSetDate = localStorage.getItem('quest-on-last-condition-set-date')
  return lastSetDate === today
}

onMounted(() => {
  // 오늘 이미 설정했다면 축소된 상태로 시작
  if (checkTodayConditionSet()) {
    isConfirmed.value = true
    const lastSetTime = localStorage.getItem('quest-on-last-condition-set-time')
    if (lastSetTime) {
      lastCheckedTime.value = new Date(lastSetTime)
    }
  }
})

// 시간대별 인사말
function getGreeting() {
  const hour = new Date().getHours()
  if (hour < 6) return '🌙 좋은 새벽이에요'
  if (hour < 12) return '🌅 좋은 아침이에요'
  if (hour < 18) return '☀️ 좋은 오후에요'
  if (hour < 22) return '🌆 좋은 저녁이에요'
  return '🌃 늦은 시간이네요'
}

// 감정 상태 정의
const moods = [
  {
    value: '😊',
    emoji: '😊',
    label: '좋음',
    shortDesc: '최고!',
    description: '컨디션이 최고예요! 오늘은 도전적인 목표도 달성할 수 있을 거예요.',
    encouragement: '이 기세로 멋진 하루 만들어봐요! 🚀',
    questAdjustment: '3개의 목표로 알찬 하루를 계획했어요',
    color: 'mood-good',
    bgColor: 'bg-green-50',
    borderColor: 'border-green-200'
  },
  {
    value: '😐',
    emoji: '😐', 
    label: '보통',
    shortDesc: '그럭저럭',
    description: '평범한 컨디션이네요. 부담스럽지 않게 차근차근 해봐요.',
    encouragement: '꾸준함이 가장 중요해요. 오늘도 화이팅! 💪',
    questAdjustment: '2개의 목표로 안정적인 페이스를 유지해요',
    color: 'mood-normal',
    bgColor: 'bg-blue-50',
    borderColor: 'border-blue-200'
  },
  {
    value: '😞',
    emoji: '😞',
    label: '힘듦',
    shortDesc: '어려워',
    description: '오늘은 힘든 하루네요. 작은 것부터 천천히 시작해봐요.',
    encouragement: '괜찮아요. 이런 날도 있는 거예요. 자신을 다독여주세요 🤗',
    questAdjustment: '1개의 작은 목표로 부담없이 시작해요',
    color: 'mood-tired',
    bgColor: 'bg-pink-50',
    borderColor: 'border-pink-200'
  }
]

const selectedMood = computed(() => {
  return moods.find(mood => mood.value === currentMood.value) || null
})

// 기분별 스타일 클래스
function getMoodClasses(moodValue) {
  const mood = moods.find(m => m.value === moodValue)
  if (!mood) return ''
  
  const isActive = currentMood.value === moodValue
  return [
    mood.bgColor,
    mood.borderColor,
    isActive ? `shadow-${mood.color} scale-105` : 'hover:scale-102 shadow-soft',
    isActive ? 'border-2' : 'border',
    'text-neutral-700'
  ].join(' ')
}

// 기분 선택
function selectMood(mood) {
  questStore.setCondition(mood)
  isConfirmed.value = false // 선택시 확정 해제

  // 햅틱 피드백 (모바일에서 지원하는 경우)
  if ('vibrate' in navigator) {
    navigator.vibrate(50)
  }
}

// 컨디션 확정
function confirmCondition() {
  isConfirmed.value = true
  const now = new Date()
  lastCheckedTime.value = now

  // 오늘 설정 완료 기록
  localStorage.setItem('quest-on-last-condition-set-date', now.toDateString())
  localStorage.setItem('quest-on-last-condition-set-time', now.toISOString())

  // 토스트 메시지 표시
  const moodLabel = selectedMood.value?.label || '컨디션'
  toastMessage.value = `${moodLabel} 상태로 설정되었어요. 목표가 조정되었습니다!`
  showToast.value = true

  // 햅틱 피드백
  if ('vibrate' in navigator) {
    navigator.vibrate(100)
  }

  // 3초 후 토스트 숨김
  setTimeout(() => {
    showToast.value = false
  }, 3000)
}

// 컨디션 변경
function changeCondition() {
  isConfirmed.value = false

  // 변경 토스트 표시
  toastMessage.value = '컨디션을 다시 선택해주세요'
  showToast.value = true

  // 2초 후 토스트 숨김
  setTimeout(() => {
    showToast.value = false
  }, 2000)
}

// 시간 포맷팅
function formatTime(date) {
  return date.toLocaleTimeString('ko-KR', { 
    hour: '2-digit', 
    minute: '2-digit'
  })
}
</script>