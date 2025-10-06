<template>
  <div class="card p-4">
    <h3 class="text-neutral-800 text-lg font-semibold mb-4">통계</h3>
    
    <div class="space-y-4">
      <div class="flex items-center justify-between">
        <div class="flex items-center">
          <span class="text-2xl mr-3">📊</span>
          <div>
            <p class="text-neutral-800 font-medium">완료율</p>
            <p class="text-neutral-600 text-sm">오늘</p>
          </div>
        </div>
        <span class="text-neutral-800 font-bold text-xl">{{ Math.round(completionRate) }}%</span>
      </div>

      <div class="flex items-center justify-between">
        <div class="flex items-center">
          <span class="text-2xl mr-3">🎯</span>
          <div>
            <p class="text-neutral-800 font-medium">활성 퀘스트</p>
            <p class="text-neutral-600 text-sm">진행중</p>
          </div>
        </div>
        <span class="text-neutral-800 font-bold text-xl">{{ todayQuests.length }}</span>
      </div>

      <div class="flex items-center justify-between">
        <div class="flex items-center">
          <span class="text-2xl mr-3">⭐</span>
          <div>
            <p class="text-neutral-800 font-medium">경험치</p>
            <p class="text-neutral-600 text-sm">총 획득</p>
          </div>
        </div>
        <span class="text-neutral-800 font-bold text-xl">{{ (level - 1) * 100 + experience }}</span>
      </div>

      <div class="flex items-center justify-between">
        <div class="flex items-center">
          <span class="text-2xl mr-3">🏆</span>
          <div>
            <p class="text-neutral-800 font-medium">최고 연속</p>
            <p class="text-neutral-600 text-sm">달성 기록</p>
          </div>
        </div>
        <span class="text-neutral-800 font-bold text-xl">{{ Math.max(streakCount, totalCompleted > 0 ? 1 : 0) }}</span>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useQuestStore } from '../../stores/quest'

const questStore = useQuestStore()
const completionRate = computed(() => questStore.completionRate)
const todayQuests = computed(() => questStore.todayQuests)
const level = computed(() => questStore.level)
const experience = computed(() => questStore.experience)
const streakCount = computed(() => questStore.streakCount)
const totalCompleted = computed(() => questStore.totalCompleted)
</script>