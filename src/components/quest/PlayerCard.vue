<template>
  <div class="card p-6">
    <!-- 캐릭터 & 레벨 -->
    <div class="flex items-center gap-4 mb-6">
      <!-- 캐릭터 -->
      <div class="relative">
        <div :class="characterSizeClass">
          {{ characterEmoji }}{{ characterEffect }}
        </div>
      </div>

      <!-- 정보 -->
      <div class="flex-1">
        <h3 class="text-gray-900 font-bold text-lg">{{ userNickname }}</h3>
        <div class="flex items-center gap-2 mt-1">
          <span class="bg-purple-100 text-purple-800 text-sm font-bold px-3 py-1 rounded-full">
            Lv.{{ level }}
          </span>
          <span class="text-gray-500 text-sm">{{ stageName }}</span>
        </div>
      </div>
    </div>

    <!-- 경험치 바 -->
    <div>
      <div class="flex items-center justify-between mb-2">
        <div class="flex items-center gap-2">
          <span class="text-yellow-500">⭐</span>
          <span class="text-sm font-medium text-gray-700">경험치</span>
        </div>
        <span class="text-xs text-gray-500 font-medium">
          {{ experience }}/{{ experienceToNextLevel }} XP
        </span>
      </div>
      <div class="w-full bg-gray-200 rounded-full h-4 overflow-hidden">
        <div
          class="h-4 rounded-full transition-all duration-500 bg-gradient-to-r from-yellow-400 via-orange-400 to-orange-500"
          :style="{ width: progressPercentage + '%' }"
        >
          <div class="w-full h-full bg-gradient-to-r from-transparent via-white to-transparent opacity-30 animate-shimmer"></div>
        </div>
      </div>
    </div>

    <!-- 통계 -->
    <div class="grid grid-cols-2 gap-3 mt-6">
      <div class="bg-gradient-to-br from-blue-50 to-purple-50 rounded-lg p-3 text-center border border-purple-100">
        <div class="text-purple-600 text-xs font-medium mb-1">총 완료</div>
        <div class="text-purple-900 font-bold text-xl">{{ totalCompleted }}</div>
      </div>
      <div class="bg-gradient-to-br from-purple-50 to-pink-50 rounded-lg p-3 text-center border border-pink-100">
        <div class="text-pink-600 text-xs font-medium mb-1">다음 진화까지</div>
        <div class="text-pink-900 font-bold text-xl">
          <span v-if="levelsToNextStage > 0">Lv.{{ levelsToNextStage }}</span>
          <span v-else>완료!</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, ref, onMounted } from 'vue'
import { useQuestStore } from '@/stores/quest'
import { storage } from '@/utils/storage'

const questStore = useQuestStore()

// Store 데이터
const level = computed(() => questStore.level)
const experience = computed(() => questStore.experience)
const totalCompleted = computed(() => questStore.totalCompleted)
const experienceToNextLevel = computed(() => questStore.experienceToNextLevel)
const progressPercentage = computed(() => questStore.progressPercentage)
const characterStage = computed(() => questStore.characterStage)
const characterSizeClass = computed(() => questStore.characterSizeClass)
const characterEffect = computed(() => questStore.characterEffect)

// 사용자 정보
const userNickname = ref('모험가')
const userCharacter = ref('🐱')

// 캐릭터 이모지
const characterEmoji = computed(() => {
  const emoji = {
    'cat': '🐱',
    'dog': '🐶',
    'pig': '🐷',
    'rabbit': '🐰'
  }
  return emoji[userCharacter.value] || userCharacter.value
})

// 단계 이름
const stageName = computed(() => {
  const names = {
    'baby': '아기',
    'teen': '청소년',
    'adult': '어른'
  }
  return names[characterStage.value] || '아기'
})

// 다음 진화까지 필요한 레벨
const levelsToNextStage = computed(() => {
  const lv = level.value
  if (lv < 4) return 4 - lv  // 청소년까지
  if (lv < 8) return 8 - lv  // 어른까지
  return 0  // 최종 진화 완료
})

// 사용자 정보 로드
onMounted(async () => {
  const nickname = await storage.get('quest-on-user-nickname')
  const character = await storage.get('quest-on-user-character')

  if (nickname) userNickname.value = nickname
  if (character) userCharacter.value = character
})
</script>

<style scoped>
@keyframes shimmer {
  0% {
    transform: translateX(-100%);
  }
  100% {
    transform: translateX(100%);
  }
}

.animate-shimmer {
  animation: shimmer 2s infinite;
}
</style>
