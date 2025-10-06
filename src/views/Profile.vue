<template>
  <div class="min-h-screen px-4 pt-6 safe-area-bottom" style="padding-bottom: 80px;">
    <!-- 캐릭터 영역 (상단) -->
    <div class="card p-6 mb-6 text-center bg-gradient-to-br from-purple-50 to-blue-50">
      <!-- 캐릭터 디스플레이 -->
      <div class="mb-4 relative inline-block">
        <div :class="[questStore.characterSizeClass, 'transition-all duration-500']">
          {{ userCharacter }}{{ questStore.characterEffect }}
        </div>
        <!-- 장착한 악세사리 -->
        <div v-if="questStore.equippedAccessory && equippedAccessoryData" class="absolute -top-4 right-1/2 transform translate-x-1/2">
          <component
            :is="equippedAccessoryData.icon"
            :class="equippedAccessoryData.color"
            :size="64"
            :stroke-width="2.5"
          />
        </div>
      </div>

      <!-- 닉네임 및 레벨 -->
      <h2 class="text-2xl font-bold text-neutral-800 mb-1 font-gmarket">
        {{ userNickname }}
      </h2>
      <p class="text-lg text-purple-600 font-bold mb-2">레벨 {{ questStore.level }}</p>
      <p class="text-sm text-neutral-600">{{ getStageLabel(questStore.characterStage) }}</p>

      <!-- 성장 타임라인 -->
      <div class="mt-6 pt-4 border-t border-neutral-200">
        <p class="text-xs text-neutral-500 mb-3">성장 히스토리</p>
        <div class="flex items-center justify-center gap-2">
          <div class="text-center">
            <div class="text-3xl">🐣</div>
            <p class="text-xs text-neutral-500 mt-1">Lv.1</p>
          </div>
          <div class="text-lg text-neutral-400">→</div>
          <div class="text-center" :class="{ 'opacity-50': questStore.level < 4 }">
            <div class="text-4xl">🌟</div>
            <p class="text-xs text-neutral-500 mt-1">Lv.4</p>
          </div>
          <div class="text-lg text-neutral-400">→</div>
          <div class="text-center" :class="{ 'opacity-50': questStore.level < 8 }">
            <div class="text-5xl">👑</div>
            <p class="text-xs text-neutral-500 mt-1">Lv.8</p>
          </div>
        </div>
      </div>
    </div>

    <!-- 연속 달성 배지 컬렉션 -->
    <div class="card p-6 mb-6 bg-gradient-to-br from-orange-50 to-red-50">
      <h3 class="text-lg font-semibold text-neutral-800 mb-4 flex items-center gap-2">
        <span class="text-xl">🔥</span>
        연속 달성 배지
      </h3>

      <div class="flex items-center justify-center mb-4">
        <div class="text-center">
          <div class="text-6xl mb-2 animate-bounce">🔥</div>
          <p class="text-3xl font-bold text-orange-600">{{ questStore.streakCount }}</p>
          <p class="text-sm text-neutral-600">일 연속 달성</p>
        </div>
      </div>

      <div class="grid grid-cols-3 gap-3">
        <!-- 3일 배지 -->
        <div class="text-center p-3 rounded-lg" :class="questStore.streakCount >= 3 ? 'bg-orange-100 border-2 border-orange-300' : 'bg-neutral-100 opacity-50'">
          <div class="text-4xl mb-1">🔥</div>
          <p class="text-xs font-bold" :class="questStore.streakCount >= 3 ? 'text-orange-700' : 'text-neutral-500'">불꽃 시작</p>
          <p class="text-xs text-neutral-500">3일 연속</p>
        </div>

        <!-- 7일 배지 -->
        <div class="text-center p-3 rounded-lg" :class="questStore.streakCount >= 7 ? 'bg-cyan-100 border-2 border-cyan-300' : 'bg-neutral-100 opacity-50'">
          <div class="text-4xl mb-1">💎</div>
          <p class="text-xs font-bold" :class="questStore.streakCount >= 7 ? 'text-cyan-700' : 'text-neutral-500'">다이아 의지</p>
          <p class="text-xs text-neutral-500">7일 연속</p>
        </div>

        <!-- 30일 배지 -->
        <div class="text-center p-3 rounded-lg" :class="questStore.streakCount >= 30 ? 'bg-yellow-100 border-2 border-yellow-300' : 'bg-neutral-100 opacity-50'">
          <div class="text-4xl mb-1">👑</div>
          <p class="text-xs font-bold" :class="questStore.streakCount >= 30 ? 'text-yellow-700' : 'text-neutral-500'">왕관 달성</p>
          <p class="text-xs text-neutral-500">30일 연속</p>
        </div>
      </div>

      <p class="text-xs text-center text-neutral-500 mt-3">
        매일 80% 이상 완료하면 연속 달성! 🎯
      </p>
    </div>

    <!-- 통계 카드 -->
    <div class="card p-6 mb-6">
      <h3 class="text-lg font-semibold text-neutral-800 mb-4 flex items-center gap-2">
        <span class="text-xl">📊</span>
        나의 성장 통계
      </h3>
      <div class="grid grid-cols-2 gap-4">
        <div class="bg-blue-50 rounded-lg p-4 text-center">
          <p class="text-blue-600 text-sm mb-1">완료한 퀘스트</p>
          <p class="text-3xl font-bold text-blue-700">{{ questStore.totalCompleted }}</p>
          <p class="text-xs text-blue-600 mt-1">개</p>
        </div>
        <div class="bg-purple-50 rounded-lg p-4 text-center">
          <p class="text-purple-600 text-sm mb-1">현재 레벨</p>
          <p class="text-3xl font-bold text-purple-700">{{ questStore.level }}</p>
          <p class="text-xs text-purple-600 mt-1">Level</p>
        </div>
        <div class="bg-amber-50 rounded-lg p-4 text-center">
          <p class="text-amber-600 text-sm mb-1">보유 포인트</p>
          <p class="text-3xl font-bold text-amber-700">{{ questStore.points }}</p>
          <p class="text-xs text-amber-600 mt-1">💎</p>
        </div>
        <div class="bg-green-50 rounded-lg p-4 text-center">
          <p class="text-green-600 text-sm mb-1">연속 달성</p>
          <p class="text-3xl font-bold text-green-700">{{ questStore.streakCount }}</p>
          <p class="text-xs text-green-600 mt-1">일</p>
        </div>
      </div>

      <div class="mt-4 bg-gradient-to-r from-purple-100 to-blue-100 rounded-lg p-4 text-center border-2 border-purple-200">
        <p class="text-sm text-neutral-700 font-gmarket">
          <span class="font-bold text-purple-600">{{ questStore.totalCompleted }}개의 퀘스트</span>로<br>
          <span class="font-bold text-blue-600">레벨 {{ questStore.level }}</span> 달성!
        </p>
      </div>
    </div>

    <!-- 주간 리포트 -->
    <WeeklyReport />

    <!-- 악세사리 상점 -->
    <AccessoryShop />

    <!-- 설정 (컨디션 기능 포함) -->
    <div class="card p-6 mt-6">
      <h3 class="text-lg font-semibold text-neutral-800 mb-4 flex items-center gap-2">
        <span class="text-xl">⚙️</span>
        설정
      </h3>

      <button
        @click="showConditionSettings = !showConditionSettings"
        class="w-full flex items-center justify-between p-3 bg-neutral-50 rounded-lg hover:bg-neutral-100 transition-colors"
      >
        <span class="text-neutral-700 font-medium">컨디션 설정</span>
        <span class="text-neutral-500">{{ showConditionSettings ? '▲' : '▼' }}</span>
      </button>

      <div v-if="showConditionSettings" class="mt-4">
        <ConditionSelector />
      </div>
    </div>

    <!-- 데이터 관리 -->
    <DataManagementCard />
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useQuestStore } from '../stores/quest'
import AccessoryShop from '../components/quest/AccessoryShop.vue'
import ConditionSelector from '../components/quest/ConditionSelector.vue'
import DataManagementCard from '../components/quest/DataManagementCard.vue'
import WeeklyReport from '../components/quest/WeeklyReport.vue'
import { getAccessory } from '../utils/accessories'

const questStore = useQuestStore()

const userNickname = ref('')
const userCharacter = ref('🐱')
const showConditionSettings = ref(false)

// 장착한 악세사리 데이터
const equippedAccessoryData = computed(() => {
  if (!questStore.equippedAccessory) return null
  return getAccessory(questStore.equippedAccessory)
})

// 캐릭터 이모지 매핑
const characterEmojis = {
  'cat': '🐱',
  'dog': '🐶',
  'pig': '🐷',
  'rabbit': '🐰'
}

function getStageLabel(stage) {
  const labels = {
    'baby': '🐣 아기 단계 - 귀여운 시작!',
    'teen': '🌟 청소년 단계 - 쑥쑥 성장 중!',
    'adult': '👑 어른 단계 - 당당한 모습!'
  }
  return labels[stage] || ''
}

onMounted(() => {
  userNickname.value = localStorage.getItem('quest-on-user-nickname') || '모험가'
  const characterId = localStorage.getItem('quest-on-user-character') || 'cat'
  userCharacter.value = characterEmojis[characterId] || '🐱'

  questStore.loadData()
})
</script>