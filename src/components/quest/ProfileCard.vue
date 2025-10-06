<template>
  <div class="card p-6 text-center">
    <div class="w-20 h-20 bg-purple-500 rounded-full flex items-center justify-center mx-auto mb-4">
      <span class="text-4xl">🎮</span>
    </div>
    
    <h2 class="text-neutral-800 text-2xl font-bold mb-2">퀘스트 마스터</h2>
    <p class="text-neutral-600 mb-4">레벨 {{ level }}</p>
    
    <div class="bg-gray-50 rounded-lg p-4 mb-4">
      <div class="flex justify-between text-neutral-600 text-sm mb-2">
        <span>다음 레벨까지</span>
        <span>{{ experience }} / {{ experienceToNextLevel }}</span>
      </div>
      <div class="progress-bar h-3">
        <div 
          class="bg-gradient-to-r from-yellow-400 to-orange-500 h-3 rounded-full transition-all duration-500"
          :style="{ width: progressPercentage + '%' }"
        ></div>
      </div>
    </div>

    <!-- 오늘의 컨디션 -->
    <div class="bg-primary-100 rounded-lg p-3 mb-4">
      <div class="flex items-center justify-center gap-2">
        <span class="text-2xl">{{ currentCondition }}</span>
        <div class="text-center">
          <p class="text-neutral-800 font-medium">오늘의 컨디션</p>
          <p class="text-neutral-600 text-sm">{{ getCurrentConditionLabel() }}</p>
        </div>
      </div>
    </div>

    <div class="grid grid-cols-2 gap-4">
      <div class="bg-gray-50 rounded-lg p-3">
        <p class="text-neutral-800 font-bold text-xl">{{ totalCompleted }}</p>
        <p class="text-neutral-600 text-sm">총 완료</p>
      </div>
      <div class="bg-gray-50 rounded-lg p-3">
        <p class="text-neutral-800 font-bold text-xl">{{ streakCount }}</p>
        <p class="text-neutral-600 text-sm">연속 달성</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useQuestStore } from '../../stores/quest'

const questStore = useQuestStore()
const level = computed(() => questStore.level)
const experience = computed(() => questStore.experience)
const totalCompleted = computed(() => questStore.totalCompleted)
const streakCount = computed(() => questStore.streakCount)
const experienceToNextLevel = computed(() => questStore.experienceToNextLevel)
const progressPercentage = computed(() => questStore.progressPercentage)
const currentCondition = computed(() => questStore.currentCondition)

// 컨디션 라벨 가져오기
function getCurrentConditionLabel() {
  const conditionLabels = {
    '😊': '좋음',
    '😐': '보통',
    '😞': '힘듦'
  }
  return conditionLabels[currentCondition.value] || '미설정'
}
</script>