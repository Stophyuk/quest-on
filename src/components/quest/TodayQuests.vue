<template>
  <!-- 레벨업 모달 -->
  <LevelUpModal
    :show="showLevelUpModal"
    :levelData="levelUpData"
    :character="userCharacter"
    :totalCompleted="questStore.totalCompleted"
    :totalPoints="questStore.points"
    @close="showLevelUpModal = false"
  />

  <!-- XP 획득 플로팅 애니메이션 -->
  <div
    v-for="xp in floatingXPs"
    :key="xp.id"
    class="fixed z-50 pointer-events-none animate-float-up"
    :style="{ left: xp.x + 'px', top: xp.y + 'px' }"
  >
    <div class="text-2xl font-bold text-green-600 drop-shadow-lg">
      +{{ xp.amount }} XP ✨
    </div>
  </div>

  <div class="bg-white rounded-lg shadow-sm border border-gray-100 p-6 relative">
    <div class="flex items-center justify-between mb-4">
      <h3 class="text-gray-900 text-lg font-semibold">오늘의 퀘스트</h3>
      <div class="flex items-center gap-3">
        <span class="text-sm text-gray-500">{{ completedCount }} / {{ todayQuests.length }} 완료</span>
        <button
          @click="showAllQuests = !showAllQuests"
          class="text-xs text-purple-600 hover:text-purple-700 font-medium"
        >
          {{ showAllQuests ? '3개만 보기' : '전체 보기' }}
        </button>
      </div>
    </div>

    <!-- 빈 상태 -->
    <div v-if="todayQuests.length === 0" class="text-center py-12">
      <div class="text-6xl mb-4">🎯</div>
      <h4 class="text-lg font-semibold text-neutral-800 mb-2">아직 퀘스트가 없어요</h4>
      <p class="text-neutral-600 text-sm mb-4">첫 퀘스트를 추가해보세요!</p>
      <router-link
        to="/quests"
        class="inline-block px-6 py-2 bg-purple-500 text-white rounded-lg hover:bg-purple-600 transition-colors"
      >
        퀘스트 추가하기 ✨
      </router-link>
    </div>

    <div v-else class="space-y-3">
      <div
        v-for="quest in displayedQuests"
        :key="quest.id"
        class="bg-gray-50 rounded-lg p-4 border border-gray-100 hover:border-gray-200 transition-colors duration-200"
      >
        <div class="flex items-start gap-3">
          <button
            @click="(e) => toggleQuest(quest.id, e)"
            class="flex-shrink-0 w-5 h-5 rounded border-2 transition-all duration-200 flex items-center justify-center mt-0.5"
            :class="[
              quest.completed
                ? 'bg-green-500 border-green-500 text-white'
                : 'border-gray-300 hover:border-gray-400 bg-white'
            ]"
          >
            <svg v-if="quest.completed" class="w-3 h-3" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/>
            </svg>
          </button>

          <div class="flex-1 min-w-0">
            <div class="flex items-center justify-between mb-1">
              <h4 class="font-medium text-gray-900" :class="{ 'line-through text-gray-500': quest.completed }">
                {{ quest.title }}
              </h4>
              <span
                class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium ml-2"
                :class="getCategoryClasses(quest.category)"
              >
                {{ getCategoryLabel(quest.category) }}
              </span>
            </div>

            <p class="text-gray-600 text-sm mb-3">{{ quest.description }}</p>

            <!-- 간단한 진행도 바 -->
            <div class="flex items-center gap-3">
              <div class="flex-1">
                <div class="w-full bg-gray-200 rounded-full h-2">
                  <div
                    class="h-2 rounded-full transition-all duration-300"
                    :class="getCategoryProgressColor(quest.category)"
                    :style="{ width: Math.min((quest.progress / quest.targetValue) * 100, 100) + '%' }"
                  ></div>
                </div>
              </div>
              <span class="text-xs text-gray-500 font-medium">
                {{ quest.progress }} / {{ quest.targetValue }}
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <router-link
      to="/quests"
      class="block mt-4 text-center text-blue-600 hover:text-blue-700 transition-colors text-sm font-medium"
    >
      모든 퀘스트 보기 →
    </router-link>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useQuestStore } from '../../stores/quest'
import LevelUpModal from './LevelUpModal.vue'

const questStore = useQuestStore()
const todayQuests = computed(() => questStore.todayQuests)
const completedCount = computed(() => questStore.completedQuests.length)

// 퀘스트 표시 설정
const showAllQuests = ref(false)
const displayedQuests = computed(() => {
  return showAllQuests.value ? todayQuests.value : todayQuests.value.slice(0, 3)
})

// 레벨업 모달 상태
const showLevelUpModal = ref(false)
const levelUpData = ref({
  oldLevel: 1,
  newLevel: 2,
  pointsEarned: 100
})
const userCharacter = ref('🐱')

// XP 플로팅 애니메이션
const floatingXPs = ref([])
let xpIdCounter = 0

// 캐릭터 이모지 매핑
const characterEmojis = {
  'cat': '🐱',
  'dog': '🐶',
  'pig': '🐷',
  'rabbit': '🐰'
}

function toggleQuest(questId, event) {
  const quest = questStore.quests.find(q => q.id === questId)
  if (quest && !quest.completed) {
    const oldStage = getStage(questStore.level)

    // 1단계: 체크 애니메이션 + 햅틱
    if ('vibrate' in navigator) {
      navigator.vibrate(50)
    }

    // 퀘스트 완료 처리
    const result = questStore.completeQuest(questId)

    // 2단계: XP 획득 애니메이션 표시 (캐릭터로 날아감)
    showFloatingXPToCharacter(10, event)

    // 3단계: 캐릭터 점프 애니메이션 트리거
    triggerCharacterJump()

    // 4단계: 랜덤 대사 표시
    setTimeout(() => {
      emitQuestCompleteDialogue()
    }, 300)

    // 레벨업 발생 시 모달 표시
    if (result && result.leveledUp) {
      const newStage = getStage(result.newLevel)
      const hasEvolved = oldStage !== newStage

      levelUpData.value = {
        oldLevel: result.newLevel - 1,
        newLevel: result.newLevel,
        pointsEarned: result.pointsEarned,
        hasEvolved
      }
      showLevelUpModal.value = true
    }
  }
}

function getStage(level) {
  if (level >= 8) return 'adult'
  if (level >= 4) return 'teen'
  return 'baby'
}

// XP가 캐릭터로 날아가는 애니메이션
function showFloatingXPToCharacter(amount, event) {
  const x = event?.clientX || window.innerWidth / 2
  const y = event?.clientY || window.innerHeight / 2

  // 캐릭터 위치 (화면 상단 중앙)
  const targetX = window.innerWidth / 2
  const targetY = 150

  const xp = {
    id: xpIdCounter++,
    amount,
    x: x - 50,
    y: y - 30,
    targetX,
    targetY,
    isFlying: true
  }

  floatingXPs.value.push(xp)

  // 0.8초 후 제거 (날아가는 시간)
  setTimeout(() => {
    const index = floatingXPs.value.findIndex(item => item.id === xp.id)
    if (index > -1) {
      floatingXPs.value.splice(index, 1)
    }
  }, 800)
}

// 캐릭터 점프 애니메이션 트리거
function triggerCharacterJump() {
  // 부모 컴포넌트에 이벤트 전달
  window.dispatchEvent(new CustomEvent('character-jump'))
}

// 퀘스트 완료 대사 트리거
function emitQuestCompleteDialogue() {
  window.dispatchEvent(new CustomEvent('quest-complete-dialogue'))
}

onMounted(() => {
  // 캐릭터 로드
  const characterId = localStorage.getItem('quest-on-user-character') || 'cat'
  userCharacter.value = characterEmojis[characterId] || '🐱'
})

function getCategoryLabel(category) {
  const labels = {
    health: '건강',
    fitness: '운동',
    learning: '학습',
    work: '업무',
    hobby: '취미',
    custom: '일반'
  }
  return labels[category] || category
}

function getCategoryClasses(category) {
  const classes = {
    health: 'bg-green-100 text-green-800',
    fitness: 'bg-red-100 text-red-800',
    learning: 'bg-blue-100 text-blue-800',
    work: 'bg-purple-100 text-purple-800',
    hobby: 'bg-yellow-100 text-yellow-800',
    custom: 'bg-gray-100 text-gray-800'
  }
  return classes[category] || classes.custom
}

function getCategoryProgressColor(category) {
  const colors = {
    health: 'bg-green-500',
    fitness: 'bg-red-500',
    learning: 'bg-blue-500',
    work: 'bg-purple-500',
    hobby: 'bg-yellow-500',
    custom: 'bg-gray-500'
  }
  return colors[category] || colors.custom
}
</script>

<style scoped>
@keyframes float-to-character {
  0% {
    opacity: 0;
    transform: translate(0, 0) scale(0.5);
  }
  10% {
    opacity: 1;
    transform: translate(0, -20px) scale(1);
  }
  100% {
    opacity: 0;
    transform: translate(calc(var(--target-x) - var(--start-x)), calc(var(--target-y) - var(--start-y))) scale(0.3);
  }
}

.animate-float-up {
  animation: float-to-character 0.8s cubic-bezier(0.25, 0.46, 0.45, 0.94) forwards;
  --start-x: 0px;
  --start-y: 0px;
  --target-x: 0px;
  --target-y: -300px;
}

@keyframes pulse-success {
  0%, 100% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.1);
  }
}
</style>