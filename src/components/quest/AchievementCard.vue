<template>
  <div class="bg-white rounded-lg shadow-sm border border-gray-100 p-6">
    <div class="flex items-center justify-between mb-6">
      <h3 class="text-gray-900 text-lg font-semibold">🏆 업적</h3>
      <span class="text-sm text-gray-500">{{ unlockedCount }} / {{ achievements.length }} 달성</span>
    </div>

    <!-- 업적 진행도 바 -->
    <div class="mb-6">
      <div class="flex justify-between items-center mb-2">
        <span class="text-sm font-medium text-gray-700">전체 진행도</span>
        <span class="text-sm text-gray-600">{{ Math.round(progressPercentage) }}%</span>
      </div>
      <div class="w-full bg-gray-200 rounded-full h-3">
        <div
          class="bg-gradient-to-r from-yellow-400 to-orange-500 h-3 rounded-full transition-all duration-500"
          :style="{ width: progressPercentage + '%' }"
        ></div>
      </div>
    </div>

    <!-- 업적 그리드 -->
    <div class="grid grid-cols-1 gap-3">
      <div
        v-for="achievement in achievements"
        :key="achievement.id"
        class="relative flex items-center p-4 rounded-xl border transition-all duration-300 hover:shadow-md"
        :class="getAchievementClasses(achievement)"
      >
        <!-- 업적 아이콘 -->
        <div class="relative mr-4">
          <div
            class="w-14 h-14 rounded-full flex items-center justify-center text-2xl transition-all duration-300"
            :class="getIconClasses(achievement)"
          >
            {{ achievement.icon }}
          </div>

          <!-- 잠금 오버레이 -->
          <div
            v-if="!achievement.unlocked"
            class="absolute inset-0 bg-gray-400 bg-opacity-70 rounded-full flex items-center justify-center"
          >
            <span class="text-white text-lg">🔒</span>
          </div>

          <!-- 달성 효과 -->
          <div
            v-if="achievement.unlocked"
            class="absolute -top-1 -right-1 w-6 h-6 bg-yellow-400 rounded-full flex items-center justify-center animate-pulse"
          >
            <span class="text-white text-xs">✓</span>
          </div>
        </div>

        <!-- 업적 정보 -->
        <div class="flex-1 min-w-0">
          <h4
            class="font-semibold text-base mb-1 transition-colors duration-300"
            :class="achievement.unlocked ? 'text-gray-900' : 'text-gray-500'"
          >
            {{ achievement.title }}
          </h4>
          <p
            class="text-sm transition-colors duration-300"
            :class="achievement.unlocked ? 'text-gray-600' : 'text-gray-400'"
          >
            {{ achievement.description }}
          </p>

          <!-- 진행도 표시 (미달성 업적의 경우) -->
          <div v-if="!achievement.unlocked && achievement.progress" class="mt-2">
            <div class="flex justify-between items-center mb-1">
              <span class="text-xs text-gray-500">
                {{ achievement.current }} / {{ achievement.target }}
              </span>
              <span class="text-xs text-gray-500">
                {{ Math.round(achievement.progress) }}%
              </span>
            </div>
            <div class="w-full bg-gray-200 rounded-full h-1.5">
              <div
                class="bg-gray-400 h-1.5 rounded-full transition-all duration-300"
                :style="{ width: achievement.progress + '%' }"
              ></div>
            </div>
          </div>
        </div>

        <!-- 달성 날짜 (달성된 업적의 경우) -->
        <div v-if="achievement.unlocked" class="text-right">
          <div class="text-yellow-500 text-2xl mb-1">🏅</div>
          <div class="text-xs text-gray-500">달성!</div>
        </div>
      </div>
    </div>

    <!-- 다음 업적 미리보기 -->
    <div v-if="nextAchievement" class="mt-6 p-4 bg-blue-50 rounded-lg border border-blue-100">
      <h4 class="text-sm font-medium text-blue-900 mb-2">🎯 다음 목표</h4>
      <div class="flex items-center gap-3">
        <span class="text-xl opacity-50">{{ nextAchievement.icon }}</span>
        <div class="flex-1">
          <p class="text-sm font-medium text-blue-800">{{ nextAchievement.title }}</p>
          <p class="text-xs text-blue-600">{{ nextAchievement.description }}</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useQuestStore } from '../../stores/quest'

const questStore = useQuestStore()

const achievements = computed(() => [
  {
    id: 1,
    title: '첫 걸음',
    description: '첫 번째 퀘스트 완료',
    icon: '👶',
    target: 1,
    current: questStore.totalCompleted,
    unlocked: questStore.totalCompleted >= 1,
    progress: Math.min((questStore.totalCompleted / 1) * 100, 100)
  },
  {
    id: 2,
    title: '습관 형성',
    description: '5개 퀘스트 완료',
    icon: '🔥',
    target: 5,
    current: questStore.totalCompleted,
    unlocked: questStore.totalCompleted >= 5,
    progress: Math.min((questStore.totalCompleted / 5) * 100, 100)
  },
  {
    id: 3,
    title: '퀘스트 마스터',
    description: '10개 퀘스트 완료',
    icon: '⚔️',
    target: 10,
    current: questStore.totalCompleted,
    unlocked: questStore.totalCompleted >= 10,
    progress: Math.min((questStore.totalCompleted / 10) * 100, 100)
  },
  {
    id: 4,
    title: '레벨업!',
    description: '레벨 2 달성',
    icon: '📈',
    target: 2,
    current: questStore.level,
    unlocked: questStore.level >= 2,
    progress: Math.min((questStore.level / 2) * 100, 100)
  },
  {
    id: 5,
    title: '완벽주의자',
    description: '하루 100% 달성',
    icon: '💯',
    target: 100,
    current: Math.round(questStore.completionRate),
    unlocked: questStore.completionRate >= 100,
    progress: questStore.completionRate
  },
  {
    id: 6,
    title: '갓생러',
    description: '레벨 5 달성',
    icon: '👑',
    target: 5,
    current: questStore.level,
    unlocked: questStore.level >= 5,
    progress: Math.min((questStore.level / 5) * 100, 100)
  },
  {
    id: 7,
    title: '연속 달성',
    description: '3일 연속 퀘스트 완료',
    icon: '🔗',
    target: 3,
    current: questStore.streakCount,
    unlocked: questStore.streakCount >= 3,
    progress: Math.min((questStore.streakCount / 3) * 100, 100)
  },
  {
    id: 8,
    title: '전설의 모험가',
    description: '레벨 10 달성',
    icon: '🌟',
    target: 10,
    current: questStore.level,
    unlocked: questStore.level >= 10,
    progress: Math.min((questStore.level / 10) * 100, 100)
  }
])

// 달성된 업적 수
const unlockedCount = computed(() =>
  achievements.value.filter(achievement => achievement.unlocked).length
)

// 전체 진행도
const progressPercentage = computed(() =>
  (unlockedCount.value / achievements.value.length) * 100
)

// 다음 달성 가능한 업적
const nextAchievement = computed(() =>
  achievements.value.find(achievement => !achievement.unlocked)
)

// 업적 카드 클래스
function getAchievementClasses(achievement) {
  if (achievement.unlocked) {
    return 'bg-gradient-to-r from-yellow-50 to-orange-50 border-yellow-200 shadow-md'
  }
  return 'bg-gray-50 border-gray-200'
}

// 아이콘 클래스
function getIconClasses(achievement) {
  if (achievement.unlocked) {
    return 'bg-gradient-to-br from-yellow-400 to-orange-500 text-white shadow-lg'
  }
  return 'bg-gray-200 text-gray-400'
}
</script>