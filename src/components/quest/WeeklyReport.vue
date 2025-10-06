<template>
  <div class="card p-6 mb-6">
    <div class="flex items-center justify-between mb-4">
      <h3 class="text-lg font-semibold text-neutral-800 flex items-center gap-2">
        <span class="text-xl">📊</span>
        주간 리포트
      </h3>
      <button
        @click="toggleReport"
        class="text-xs text-purple-600 hover:text-purple-700 font-medium"
      >
        {{ showReport ? '접기' : '보기' }}
      </button>
    </div>

    <div v-if="showReport" class="space-y-4 animate-fade-in">
      <!-- 이번 주 요약 -->
      <div class="bg-gradient-to-br from-purple-50 to-blue-50 rounded-xl p-4 border-2 border-purple-200">
        <div class="text-center mb-3">
          <h4 class="text-xl font-bold text-purple-700 mb-1 font-gmarket">
            이번 주 성과 🎉
          </h4>
          <p class="text-sm text-neutral-600">{{ weekDateRange }}</p>
        </div>

        <div class="grid grid-cols-3 gap-3">
          <div class="bg-white rounded-lg p-3 text-center">
            <p class="text-xs text-neutral-600 mb-1">완료</p>
            <p class="text-2xl font-bold text-blue-600">{{ weeklyStats.totalCompleted }}</p>
            <p class="text-xs text-neutral-500">퀘스트</p>
          </div>
          <div class="bg-white rounded-lg p-3 text-center">
            <p class="text-xs text-neutral-600 mb-1">평균</p>
            <p class="text-2xl font-bold text-purple-600">{{ weeklyStats.averageCompletion }}%</p>
            <p class="text-xs text-neutral-500">달성률</p>
          </div>
          <div class="bg-white rounded-lg p-3 text-center">
            <p class="text-xs text-neutral-600 mb-1">활동</p>
            <p class="text-2xl font-bold text-green-600">{{ weeklyStats.activeDays }}</p>
            <p class="text-xs text-neutral-500">일</p>
          </div>
        </div>
      </div>

      <!-- 일별 기록 -->
      <div class="space-y-2">
        <h5 class="text-sm font-semibold text-neutral-700">일별 기록</h5>
        <div class="space-y-2">
          <div
            v-for="day in weeklyData"
            :key="day.date"
            class="bg-neutral-50 rounded-lg p-3 border border-neutral-200"
          >
            <div class="flex items-center justify-between">
              <div class="flex items-center gap-3">
                <span class="text-2xl">{{ day.mood }}</span>
                <div>
                  <p class="text-sm font-medium text-neutral-800">{{ formatDate(day.date) }}</p>
                  <p class="text-xs text-neutral-500">{{ day.questsCompleted }}개 완료</p>
                </div>
              </div>
              <div class="text-right">
                <p class="text-sm font-bold" :class="getCompletionColor(day.completionRate)">
                  {{ Math.round(day.completionRate) }}%
                </p>
              </div>
            </div>
            <!-- 진행도 바 -->
            <div class="w-full bg-neutral-200 rounded-full h-1.5 mt-2">
              <div
                class="h-1.5 rounded-full transition-all duration-300"
                :class="getCompletionBarColor(day.completionRate)"
                :style="{ width: day.completionRate + '%' }"
              ></div>
            </div>
          </div>

          <!-- 빈 상태 -->
          <div v-if="weeklyData.length === 0" class="text-center py-8">
            <div class="text-4xl mb-2">📅</div>
            <p class="text-neutral-600 text-sm">아직 이번 주 기록이 없어요</p>
            <p class="text-neutral-500 text-xs mt-1">퀘스트를 완료하면 자동으로 기록됩니다</p>
          </div>
        </div>
      </div>

      <!-- 격려 메시지 -->
      <div
        v-if="weeklyStats.totalCompleted > 0"
        class="bg-gradient-to-r from-amber-50 to-yellow-50 rounded-xl p-4 border-2 border-amber-200 text-center"
      >
        <p class="text-amber-800 font-medium font-gmarket">
          {{ getWeeklyEncouragement() }}
        </p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { storageManager } from '../../stores/storage'

const showReport = ref(false)
const weeklyData = ref([])

// 주간 통계
const weeklyStats = computed(() => {
  if (weeklyData.value.length === 0) {
    return {
      totalCompleted: 0,
      averageCompletion: 0,
      activeDays: 0
    }
  }

  const totalCompleted = weeklyData.value.reduce((sum, day) => sum + day.questsCompleted, 0)
  const totalCompletion = weeklyData.value.reduce((sum, day) => sum + day.completionRate, 0)
  const averageCompletion = Math.round(totalCompletion / weeklyData.value.length)
  const activeDays = weeklyData.value.length

  return {
    totalCompleted,
    averageCompletion,
    activeDays
  }
})

// 주간 날짜 범위
const weekDateRange = computed(() => {
  if (weeklyData.value.length === 0) return '이번 주'

  const dates = weeklyData.value.map(d => new Date(d.date))
  const firstDate = new Date(Math.min(...dates))
  const lastDate = new Date(Math.max(...dates))

  const formatDateShort = (date) => {
    return `${date.getMonth() + 1}/${date.getDate()}`
  }

  return `${formatDateShort(firstDate)} - ${formatDateShort(lastDate)}`
})

function toggleReport() {
  showReport.value = !showReport.value
}

function loadWeeklyData() {
  const moodHistory = storageManager.loadMoodHistory()

  // 최근 7일 데이터 필터링
  const sevenDaysAgo = new Date()
  sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7)

  weeklyData.value = moodHistory
    .filter(entry => new Date(entry.date) >= sevenDaysAgo)
    .sort((a, b) => new Date(a.date) - new Date(b.date))
}

function formatDate(dateString) {
  const date = new Date(dateString)
  const today = new Date()
  const yesterday = new Date(today)
  yesterday.setDate(yesterday.getDate() - 1)

  if (date.toDateString() === today.toDateString()) {
    return '오늘'
  } else if (date.toDateString() === yesterday.toDateString()) {
    return '어제'
  } else {
    const days = ['일', '월', '화', '수', '목', '금', '토']
    return `${date.getMonth() + 1}/${date.getDate()} (${days[date.getDay()]})`
  }
}

function getCompletionColor(rate) {
  if (rate >= 80) return 'text-green-600'
  if (rate >= 40) return 'text-blue-600'
  return 'text-neutral-600'
}

function getCompletionBarColor(rate) {
  if (rate >= 80) return 'bg-green-500'
  if (rate >= 40) return 'bg-blue-500'
  return 'bg-neutral-400'
}

function getWeeklyEncouragement() {
  const avg = weeklyStats.value.averageCompletion
  const total = weeklyStats.value.totalCompleted

  if (avg >= 80) {
    return `와우! 평균 ${avg}% 달성으로 정말 대단한 한 주를 보냈어요! 🌟`
  } else if (avg >= 60) {
    return `${total}개의 퀘스트 완료! 꾸준한 노력이 빛나는 한 주였어요! 💪`
  } else if (avg >= 40) {
    return `${weeklyStats.value.activeDays}일 동안 꾸준히 활동했어요. 멋져요! 👏`
  } else if (total > 0) {
    return `${total}개의 퀘스트를 완료했어요. 작은 성취도 큰 의미가 있어요! 💝`
  } else {
    return '새로운 시작을 응원합니다! 오늘부터 함께 해봐요! 🚀'
  }
}

onMounted(() => {
  loadWeeklyData()
})
</script>

<style scoped>
@keyframes fade-in {
  from { opacity: 0; transform: translateY(-10px); }
  to { opacity: 1; transform: translateY(0); }
}

.animate-fade-in {
  animation: fade-in 0.3s ease-out;
}
</style>
