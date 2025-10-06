<template>
  <div class="min-h-screen pb-24 px-4 pt-6 safe-area-bottom" style="padding-bottom: 80px;">
    <!-- 캐릭터 대사 -->
    <CharacterDialogue :trigger="dialogueTrigger" :data="dialogueData" />

    <!-- 상단 헤더 -->
    <header class="flex items-center justify-between mb-4">
      <!-- 로고 -->
      <div class="flex items-center">
        <h1 class="text-xl font-pixel text-purple font-bold">Quest ON</h1>
      </div>

      <!-- 포인트 표시 -->
      <div class="flex items-center gap-2 bg-amber-100 px-3 py-1 rounded-full">
        <span class="text-base">💎</span>
        <span class="font-bold text-amber-700">{{ questStore.points }}</span>
      </div>
    </header>

    <!-- 캐릭터 영역 (화면의 1/2 차지) -->
    <div class="card p-8 mb-6 text-center bg-gradient-to-br from-purple-50 to-blue-50" style="min-height: 50vh;">
      <!-- 캐릭터 디스플레이 -->
      <div class="mb-6 relative">
        <div :class="[
          questStore.characterSizeClass,
          'transition-all duration-500',
          { 'animate-character-jump': isCharacterJumping }
        ]">
          {{ userCharacter }}{{ questStore.characterEffect }}
        </div>
        <!-- 장착한 악세사리 -->
        <div v-if="questStore.equippedAccessory && equippedAccessoryData" class="absolute top-0 right-1/2 transform translate-x-1/2 -translate-y-2">
          <component
            :is="equippedAccessoryData.icon"
            :class="equippedAccessoryData.color"
            :size="56"
            :stroke-width="2.5"
          />
        </div>
      </div>

      <!-- 레벨 및 닉네임 -->
      <h2 class="text-xl font-bold text-neutral-800 mb-1 font-gmarket">
        레벨 {{ questStore.level }} {{ userNickname }}
      </h2>
      <p class="text-sm text-neutral-600 mb-4">{{ getStageLabel(questStore.characterStage) }}</p>

      <!-- 연속 달성 배지 -->
      <div class="flex items-center justify-center gap-2 mb-4">
        <div class="flex items-center gap-1 px-4 py-2 bg-gradient-to-r from-orange-100 to-red-100 rounded-full border-2 border-orange-300">
          <span class="text-2xl">🔥</span>
          <span class="text-lg font-bold text-orange-700">{{ questStore.streakCount }}</span>
          <span class="text-xs text-orange-600 ml-1">일 연속</span>
        </div>
      </div>

      <!-- 연속 달성 마일스톤 -->
      <div class="flex items-center justify-center gap-3 mb-6">
        <div class="text-center" :class="{ 'opacity-30': questStore.streakCount < 3 }">
          <div class="text-2xl">🔥</div>
          <p class="text-xs text-neutral-500">3일</p>
        </div>
        <div class="text-center" :class="{ 'opacity-30': questStore.streakCount < 7 }">
          <div class="text-3xl">💎</div>
          <p class="text-xs text-neutral-500">7일</p>
        </div>
        <div class="text-center" :class="{ 'opacity-30': questStore.streakCount < 30 }">
          <div class="text-4xl">👑</div>
          <p class="text-xs text-neutral-500">30일</p>
        </div>
      </div>

      <!-- 경험치 바 -->
      <div class="w-full bg-neutral-200 rounded-full h-3 mb-2 overflow-hidden relative">
        <div
          class="h-full rounded-full transition-all duration-700 ease-out xp-bar-shimmer"
          :style="{ width: `${questStore.progressPercentage}%` }"
        ></div>
      </div>
      <p class="text-xs text-neutral-600">
        <span class="font-bold text-purple-600">{{ questStore.experience }}</span> / {{ questStore.experienceToNextLevel }} XP
        <span class="text-xs text-neutral-500 ml-2">
          ({{ Math.ceil((questStore.experienceToNextLevel - questStore.experience) / 10) }}개 퀘스트 남음)
        </span>
      </p>
    </div>

    <!-- 컨디션 간단 표시 (작게) -->
    <div class="flex items-center justify-between mb-4 text-sm text-neutral-600">
      <span>오늘 컨디션: {{ questStore.currentCondition }}</span>
      <button @click="showConditionSelector = !showConditionSelector" class="text-purple-600 hover:text-purple-700">
        {{ showConditionSelector ? '접기' : '변경' }}
      </button>
    </div>

    <!-- 컨디션 선택기 (펼쳤을 때만) -->
    <ConditionSelector v-if="showConditionSelector" />

    <!-- 오늘의 퀘스트 -->
    <div class="mb-6">
      <TodayQuests />
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useQuestStore } from '../stores/quest.js'
import ConditionSelector from '../components/quest/ConditionSelector.vue'
import TodayQuests from '../components/quest/TodayQuests.vue'
import CharacterDialogue from '../components/quest/CharacterDialogue.vue'
import { getAccessory } from '../utils/accessories'

const questStore = useQuestStore()

// 사용자 정보
const userNickname = ref('')
const userCharacter = ref('🧑‍💻')
const showConditionSelector = ref(false)

// 캐릭터 대사
const dialogueTrigger = ref('')
const dialogueData = ref({})

// 장착한 악세사리 데이터
const equippedAccessoryData = computed(() => {
  if (!questStore.equippedAccessory) return null
  return getAccessory(questStore.equippedAccessory)
})

// 캐릭터 점프 상태
const isCharacterJumping = ref(false)

function getStageLabel(stage) {
  const labels = {
    'baby': '🐣 아기 단계 - 귀여운 시작!',
    'teen': '🌟 청소년 단계 - 쑥쑥 성장 중!',
    'adult': '👑 어른 단계 - 당당한 모습!'
  }
  return labels[stage] || ''
}

// 캐릭터 이모지 매핑
const characterEmojis = {
  'cat': '🐱',
  'dog': '🐶',
  'pig': '🐷',
  'rabbit': '🐰'
}

onMounted(() => {
  // localStorage에서 사용자 정보 불러오기
  userNickname.value = localStorage.getItem('quest-on-user-nickname') || '모험가'
  const characterId = localStorage.getItem('quest-on-user-character') || 'cat'
  userCharacter.value = characterEmojis[characterId] || '🧑‍💻'

  // quest 데이터 로드
  questStore.loadData()

  // 캐릭터 점프 이벤트 리스너
  window.addEventListener('character-jump', () => {
    isCharacterJumping.value = true
    setTimeout(() => {
      isCharacterJumping.value = false
    }, 600)
  })

  // 퀘스트 완료 대사 이벤트 리스너
  window.addEventListener('quest-complete-dialogue', () => {
    dialogueTrigger.value = 'questComplete'
    dialogueData.value = {}
    // 트리거 리셋
    setTimeout(() => {
      dialogueTrigger.value = ''
    }, 100)
  })

  // 아침 인사 또는 격려 메시지 표시 (하루에 한 번)
  const today = new Date().toDateString()
  const lastGreeting = localStorage.getItem('quest-on-last-greeting-date')

  if (lastGreeting !== today) {
    // 아침 인사
    const hour = new Date().getHours()
    if (hour >= 6 && hour < 12) {
      setTimeout(() => {
        dialogueTrigger.value = 'morning'
        dialogueData.value = {}
      }, 1000)
    }

    localStorage.setItem('quest-on-last-greeting-date', today)
  }
})
</script>

<style scoped>
@keyframes shimmer {
  0% {
    background-position: -200% center;
  }
  100% {
    background-position: 200% center;
  }
}

.xp-bar-shimmer {
  background: linear-gradient(
    90deg,
    #8b5cf6 0%,
    #a78bfa 25%,
    #c4b5fd 50%,
    #a78bfa 75%,
    #3b82f6 100%
  );
  background-size: 200% 100%;
  animation: shimmer 3s ease-in-out infinite;
}

@keyframes character-jump {
  0% {
    transform: translateY(0) scale(1);
  }
  30% {
    transform: translateY(-30px) scale(1.1) rotate(-5deg);
  }
  50% {
    transform: translateY(-40px) scale(1.15) rotate(0deg);
  }
  70% {
    transform: translateY(-30px) scale(1.1) rotate(5deg);
  }
  100% {
    transform: translateY(0) scale(1) rotate(0deg);
  }
}

.animate-character-jump {
  animation: character-jump 0.6s cubic-bezier(0.25, 0.46, 0.45, 0.94);
}
</style>