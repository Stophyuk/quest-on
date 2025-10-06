<template>
  <div v-if="show" class="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-70 animate-fade-in">
    <div class="relative w-full max-w-md mx-4 text-center animate-scale-up">
      <!-- 배경 이펙트 -->
      <div class="absolute inset-0 bg-gradient-to-br from-yellow-400 via-purple-500 to-blue-500 rounded-3xl blur-2xl opacity-60 animate-pulse"></div>

      <!-- 메인 카드 (글래스모피즘) -->
      <div class="relative rounded-3xl p-8 shadow-2xl level-up-card">
        <!-- 폭죽 이모지 (더 많이) -->
        <div class="absolute top-0 left-0 text-4xl animate-bounce" style="animation-delay: 0s;">🎉</div>
        <div class="absolute top-0 right-0 text-4xl animate-bounce" style="animation-delay: 0.2s;">✨</div>
        <div class="absolute top-10 left-1/4 text-3xl animate-bounce" style="animation-delay: 0.3s;">🌟</div>
        <div class="absolute top-10 right-1/4 text-3xl animate-bounce" style="animation-delay: 0.5s;">💫</div>
        <div class="absolute bottom-24 left-4 text-3xl animate-bounce" style="animation-delay: 0.4s;">⭐</div>
        <div class="absolute bottom-24 right-4 text-3xl animate-bounce" style="animation-delay: 0.6s;">🌟</div>

        <!-- 레벨업 텍스트 -->
        <div class="mb-4">
          <h2 class="text-4xl font-bold text-transparent bg-clip-text bg-gradient-to-r from-purple-600 to-blue-600 mb-2 font-gmarket animate-bounce">
            레벨 업!
          </h2>
          <p class="text-neutral-600">축하합니다!</p>
        </div>

        <!-- 캐릭터 디스플레이 -->
        <div class="my-6">
          <div class="flex items-center justify-center gap-4">
            <div class="text-center">
              <div :class="getCharacterSizeClass(levelData.oldLevel)">
                {{ character }}
              </div>
              <p class="text-sm text-neutral-500 mt-2">Lv.{{ levelData.oldLevel }}</p>
            </div>

            <div class="text-4xl text-purple-500 animate-pulse">→</div>

            <div class="text-center">
              <div :class="getCharacterSizeClass(levelData.newLevel)" class="animate-bounce">
                {{ character }}{{ getCharacterEffect(levelData.newLevel) }}
              </div>
              <p class="text-sm font-bold text-purple-600 mt-2">Lv.{{ levelData.newLevel }}</p>
            </div>
          </div>

          <!-- 진화 메시지 -->
          <div v-if="hasEvolved" class="mt-4 bg-purple-100 border-2 border-purple-300 rounded-xl p-3">
            <p class="text-purple-700 font-bold">
              🎊 {{ evolutionMessage }} 🎊
            </p>
          </div>
        </div>

        <!-- 보상 정보 -->
        <div class="bg-gradient-to-r from-amber-50 to-yellow-50 rounded-xl p-4 mb-6 border-2 border-amber-200">
          <div class="flex items-center justify-center gap-2 mb-2">
            <span class="text-2xl">💎</span>
            <span class="text-3xl font-bold text-amber-700">+{{ levelData.pointsEarned }}</span>
          </div>
          <p class="text-sm text-amber-800">포인트 획득!</p>
        </div>

        <!-- 현재 스탯 -->
        <div class="grid grid-cols-2 gap-3 mb-6 text-sm">
          <div class="bg-blue-50 rounded-lg p-3">
            <p class="text-blue-600 font-medium">완료한 퀘스트</p>
            <p class="text-2xl font-bold text-blue-700">{{ totalCompleted }}</p>
          </div>
          <div class="bg-purple-50 rounded-lg p-3">
            <p class="text-purple-600 font-medium">보유 포인트</p>
            <p class="text-2xl font-bold text-purple-700">{{ totalPoints }}</p>
          </div>
        </div>

        <!-- 닫기 버튼 -->
        <button
          @click="close"
          class="w-full py-3 px-6 text-white font-bold rounded-xl transition-all duration-200 shadow-lg hover:shadow-xl hover:scale-105"
          style="background: linear-gradient(to right, #8b5cf6, #3b82f6)"
        >
          계속하기 🚀
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted } from 'vue'
import confetti from 'canvas-confetti'

const props = defineProps({
  show: {
    type: Boolean,
    default: false
  },
  levelData: {
    type: Object,
    default: () => ({
      oldLevel: 1,
      newLevel: 2,
      pointsEarned: 100
    })
  },
  character: {
    type: String,
    default: '🐱'
  },
  totalCompleted: {
    type: Number,
    default: 0
  },
  totalPoints: {
    type: Number,
    default: 0
  }
})

const emit = defineEmits(['close'])

// 진화 여부 체크
const hasEvolved = computed(() => {
  const oldStage = getStage(props.levelData.oldLevel)
  const newStage = getStage(props.levelData.newLevel)
  return oldStage !== newStage
})

// 진화 메시지
const evolutionMessage = computed(() => {
  const stage = getStage(props.levelData.newLevel)
  if (stage === 'teen') return '청소년 단계로 진화!'
  if (stage === 'adult') return '어른 단계로 진화!'
  return ''
})

function getStage(level) {
  if (level >= 8) return 'adult'
  if (level >= 4) return 'teen'
  return 'baby'
}

function getCharacterSizeClass(level) {
  const stage = getStage(level)
  if (stage === 'adult') return 'text-9xl'
  if (stage === 'teen') return 'text-8xl'
  return 'text-6xl'
}

function getCharacterEffect(level) {
  const stage = getStage(level)
  if (stage === 'adult') return '✨'
  if (stage === 'teen') return '😊'
  return ''
}

function close() {
  emit('close')
}

// Confetti 효과 함수
function fireConfetti() {
  const count = 200
  const defaults = {
    origin: { y: 0.7 }
  }

  function fire(particleRatio, opts) {
    confetti({
      ...defaults,
      ...opts,
      particleCount: Math.floor(count * particleRatio),
      spread: 100,
      scalar: 1.2,
    })
  }

  fire(0.25, {
    spread: 26,
    startVelocity: 55,
  })

  fire(0.2, {
    spread: 60,
  })

  fire(0.35, {
    spread: 100,
    decay: 0.91,
    scalar: 0.8
  })

  fire(0.1, {
    spread: 120,
    startVelocity: 25,
    decay: 0.92,
    scalar: 1.2
  })

  fire(0.1, {
    spread: 120,
    startVelocity: 45,
  })
}

// 자동 햅틱 피드백 + Confetti
watch(() => props.show, (newVal) => {
  if (newVal) {
    // 햅틱 피드백
    if ('vibrate' in navigator) {
      navigator.vibrate([100, 50, 100, 50, 200])
    }

    // Confetti 효과 (약간의 딜레이 후)
    setTimeout(() => {
      fireConfetti()
    }, 300)

    // 진화 시 추가 Confetti
    if (hasEvolved.value) {
      setTimeout(() => {
        fireConfetti()
      }, 1000)
    }
  }
})
</script>

<style scoped>
@keyframes fade-in {
  from { opacity: 0; }
  to { opacity: 1; }
}

@keyframes scale-up {
  from {
    opacity: 0;
    transform: scale(0.8) rotate(-5deg);
  }
  50% {
    transform: scale(1.05) rotate(2deg);
  }
  to {
    opacity: 1;
    transform: scale(1) rotate(0deg);
  }
}

.animate-fade-in {
  animation: fade-in 0.3s ease-out;
}

.animate-scale-up {
  animation: scale-up 0.6s cubic-bezier(0.34, 1.56, 0.64, 1);
}

.level-up-card {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border: 2px solid rgba(255, 255, 255, 0.5);
}

@keyframes rainbow-pulse {
  0%, 100% {
    box-shadow: 0 0 40px rgba(139, 92, 246, 0.5);
  }
  25% {
    box-shadow: 0 0 40px rgba(236, 72, 153, 0.5);
  }
  50% {
    box-shadow: 0 0 40px rgba(59, 130, 246, 0.5);
  }
  75% {
    box-shadow: 0 0 40px rgba(34, 197, 94, 0.5);
  }
}

.level-up-card {
  animation: rainbow-pulse 3s ease-in-out infinite;
}
</style>
