<template>
  <div class="bg-white rounded-lg shadow-sm border border-gray-100 p-6">
    <!-- Habitica 스타일 플레이어 정보 -->
    <div class="flex items-center gap-4 mb-6">
      <div class="w-16 h-16 bg-gradient-to-br from-blue-500 to-purple-600 rounded-full flex items-center justify-center shadow-lg">
        <span class="text-3xl">{{ userCharacter }}</span>
      </div>
      <div class="flex-1">
        <h3 class="text-gray-900 font-bold text-lg">{{ userNickname }}</h3>
        <div class="flex items-center gap-2 mt-1">
          <span class="bg-blue-100 text-blue-800 text-xs font-medium px-2 py-1 rounded-full">
            레벨 {{ level }}
          </span>
          <span class="text-gray-500 text-sm">퀘스트 마스터</span>
        </div>
      </div>
    </div>

    <!-- Habitica 스타일 상태바들 -->
    <div class="space-y-4">
      <!-- HP (건강도) -->
      <div>
        <div class="flex items-center justify-between mb-2">
          <div class="flex items-center gap-2">
            <span class="text-red-500 text-sm">❤️</span>
            <span class="text-sm font-medium text-gray-700">건강도</span>
          </div>
          <span class="text-xs text-gray-500">{{ healthPoints }}/100</span>
        </div>
        <div class="w-full bg-gray-200 rounded-full h-3">
          <div
            class="bg-gradient-to-r from-red-400 to-red-500 h-3 rounded-full transition-all duration-300"
            :style="{ width: healthPoints + '%' }"
          ></div>
        </div>
      </div>

      <!-- EXP (경험치) -->
      <div>
        <div class="flex items-center justify-between mb-2">
          <div class="flex items-center gap-2">
            <span class="text-yellow-500 text-sm">⭐</span>
            <span class="text-sm font-medium text-gray-700">경험치</span>
          </div>
          <span class="text-xs text-gray-500">{{ experience }}/{{ experienceToNextLevel }}</span>
        </div>
        <div class="w-full bg-gray-200 rounded-full h-3">
          <div
            class="bg-gradient-to-r from-yellow-400 to-orange-500 h-3 rounded-full transition-all duration-300"
            :style="{ width: progressPercentage + '%' }"
          ></div>
        </div>
      </div>

      <!-- MP (마나/동기) -->
      <div>
        <div class="flex items-center justify-between mb-2">
          <div class="flex items-center gap-2">
            <span class="text-blue-500 text-sm">💙</span>
            <span class="text-sm font-medium text-gray-700">동기</span>
          </div>
          <span class="text-xs text-gray-500">{{ motivation }}/100</span>
        </div>
        <div class="w-full bg-gray-200 rounded-full h-3">
          <div
            class="bg-gradient-to-r from-blue-400 to-blue-500 h-3 rounded-full transition-all duration-300"
            :style="{ width: motivation + '%' }"
          ></div>
        </div>
      </div>
    </div>

    <!-- 통계 요약 -->
    <div class="grid grid-cols-2 gap-3 mt-6">
      <div class="bg-gray-50 rounded-lg p-3 text-center border border-gray-200">
        <div class="text-gray-600 text-xs font-medium mb-1">총 완료</div>
        <div class="text-gray-900 font-bold text-lg">{{ totalCompleted }}</div>
      </div>
      <div class="bg-gray-50 rounded-lg p-3 text-center border border-gray-200">
        <div class="text-gray-600 text-xs font-medium mb-1">연속 달성</div>
        <div class="text-gray-900 font-bold text-lg">{{ streakCount }}</div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, ref, onMounted } from 'vue'
import { useQuestStore } from '../../stores/quest'

const questStore = useQuestStore()
const level = computed(() => questStore.level)
const experience = computed(() => questStore.experience)
const totalCompleted = computed(() => questStore.totalCompleted)
const experienceToNextLevel = computed(() => questStore.experienceToNextLevel)
const progressPercentage = computed(() => questStore.progressPercentage)
const streakCount = computed(() => questStore.streakCount)

// 사용자 정보
const userNickname = ref('')
const userCharacter = ref('🎮')

// Habitica 스타일 상태바들
const healthPoints = computed(() => {
  // 컨디션에 따른 건강도 계산
  const condition = questStore.currentCondition
  const baseHealth = {
    '😊': 85,
    '😐': 65,
    '😞': 45
  }

  // 퀘스트 완료에 따른 추가 건강도
  const completionBonus = Math.min(questStore.completionRate * 0.3, 30)
  return Math.min(baseHealth[condition] + completionBonus, 100)
})

const motivation = computed(() => {
  // 연속 달성과 완료율에 따른 동기 계산
  const streakBonus = Math.min(streakCount.value * 5, 30)
  const completionBonus = Math.min(questStore.completionRate * 0.7, 70)
  return Math.min(streakBonus + completionBonus, 100)
})

onMounted(() => {
  // localStorage에서 사용자 정보 불러오기
  userNickname.value = localStorage.getItem('quest-on-user-nickname') || '모험가'
  userCharacter.value = localStorage.getItem('quest-on-user-character') || '🎮'
})
</script>