<template>
  <div
    v-if="showDialogue"
    class="fixed top-24 left-1/2 transform -translate-x-1/2 max-w-sm mx-4 z-40 animate-slide-down"
  >
    <div class="bg-white rounded-2xl p-4 shadow-2xl border-2 border-purple-200 relative">
      <!-- 말풍선 꼬리 -->
      <div class="absolute -bottom-3 left-1/2 transform -translate-x-1/2 w-0 h-0 border-l-[12px] border-l-transparent border-r-[12px] border-r-transparent border-t-[12px] border-t-purple-200"></div>
      <div class="absolute -bottom-2 left-1/2 transform -translate-x-1/2 w-0 h-0 border-l-[10px] border-l-transparent border-r-[10px] border-r-transparent border-t-[10px] border-t-white"></div>

      <!-- 대사 내용 -->
      <div class="flex items-start gap-3">
        <div class="text-3xl">{{ characterEmoji }}</div>
        <div class="flex-1">
          <p class="text-sm font-medium text-purple-600 mb-1">{{ characterName }}</p>
          <p class="text-neutral-800 leading-relaxed">{{ currentDialogue }}</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, watch, onMounted } from 'vue'
import { useQuestStore } from '../../stores/quest'

const props = defineProps({
  trigger: {
    type: String,
    default: '' // 'levelUp', 'evolution', 'questComplete', 'morning', 'encouragement'
  },
  data: {
    type: Object,
    default: () => ({})
  }
})

const questStore = useQuestStore()
const showDialogue = ref(false)
const currentDialogue = ref('')
const characterEmoji = ref('🐱')
const characterName = ref('')

// 캐릭터 이모지 매핑
const characterEmojis = {
  'cat': '🐱',
  'dog': '🐶',
  'pig': '🐷',
  'rabbit': '🐰'
}

// 대사 데이터
const dialogues = {
  levelUp: [
    '와! 레벨업이에요! 함께 성장하니까 너무 기쁜걸요? 💪',
    '레벨업 축하해요! 당신의 노력이 정말 대단해요! ✨',
    '한 단계 더 성장했어요! 이 기세로 계속 가봐요! 🚀',
    '레벨 올랐어요! 점점 더 강해지는 게 느껴져요! 🌟'
  ],
  evolution: {
    baby_to_teen: '앗! 몸이 커졌어요! 이제 청소년이 됐나 봐요! 😊',
    teen_to_adult: '와아! 완전히 성장했어요! 이제 뭐든지 할 수 있을 것 같아요! ✨'
  },
  questComplete: [
    '퀘스트 완료! 정말 멋져요! 👏',
    '해냈어요! 당신은 정말 대단해요! 🎉',
    '완료! 이 조자로만 계속 가요! 💪',
    '성공이에요! 자랑스러워요! ⭐'
  ],
  morning: [
    '좋은 아침이에요! 오늘도 화이팅! 🌅',
    '새로운 하루가 시작됐어요! 함께 멋진 하루 만들어봐요! ☀️',
    '일어났군요! 오늘은 어떤 퀘스트를 도전할까요? 🎯'
  ],
  encouragement: {
    low: '괜찮아요. 천천히 해도 돼요. 저는 항상 당신을 응원해요! 🤗',
    medium: '좋아요! 이 페이스로 꾸준히 가봐요! 💪',
    high: '와! 정말 잘하고 있어요! 계속 이렇게만 해요! 🌟'
  },
  condition: {
    '😊': '오늘 컨디션이 좋으시네요! 멋진 하루 만들어봐요! 🚀',
    '😐': '평범한 하루도 충분해요. 꾸준함이 가장 중요하니까요! 💪',
    '😞': '힘든 날이네요... 오늘은 작은 것부터 천천히 해봐요. 저도 함께 있을게요! 🤗'
  }
}

function getRandomDialogue(array) {
  return array[Math.floor(Math.random() * array.length)]
}

function showDialogueMessage(message, duration = 4000) {
  currentDialogue.value = message
  showDialogue.value = true

  setTimeout(() => {
    showDialogue.value = false
  }, duration)
}

function handleTrigger() {
  let message = ''

  switch (props.trigger) {
    case 'levelUp':
      message = getRandomDialogue(dialogues.levelUp)
      break

    case 'evolution':
      const stage = props.data.stage || 'baby_to_teen'
      message = dialogues.evolution[stage] || dialogues.evolution.baby_to_teen
      break

    case 'questComplete':
      message = getRandomDialogue(dialogues.questComplete)
      break

    case 'morning':
      message = getRandomDialogue(dialogues.morning)
      break

    case 'encouragement':
      const level = props.data.level || 'medium'
      message = dialogues.encouragement[level]
      break

    case 'condition':
      const condition = props.data.condition || '😊'
      message = dialogues.condition[condition]
      break

    default:
      return
  }

  if (message) {
    showDialogueMessage(message)
  }
}

onMounted(() => {
  // 캐릭터 로드
  const characterId = localStorage.getItem('quest-on-user-character') || 'cat'
  characterEmoji.value = characterEmojis[characterId] || '🐱'
  characterName.value = localStorage.getItem('quest-on-user-nickname') || '모험가'
})

// trigger 변경 감지
watch(() => props.trigger, (newTrigger) => {
  if (newTrigger) {
    handleTrigger()
  }
}, { immediate: true })
</script>

<style scoped>
@keyframes slide-down {
  from {
    opacity: 0;
    transform: translate(-50%, -20px);
  }
  to {
    opacity: 1;
    transform: translate(-50%, 0);
  }
}

.animate-slide-down {
  animation: slide-down 0.4s ease-out;
}
</style>
