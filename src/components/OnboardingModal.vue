<template>
  <div class="fixed inset-0 z-50 bg-gradient-calm animate-fade-in overflow-hidden">
    <div class="h-full flex items-center justify-center p-4 overflow-y-auto">
      <div class="w-full max-w-md mx-auto">
        <!-- 브랜드 헤더 - 고정 위치 -->
        <div class="text-center mb-12 pt-8">
          <h1 class="text-5xl font-bold font-pixel text-purple mb-2">
            Quest ON
          </h1>
          <p class="text-neutral-600 text-base font-gmarket font-light">내일을 ON하는 오늘의 퀘스트</p>
        </div>

        <div class="animate-slide-up">

        <!-- 진행 바 -->
        <div class="card p-6 mb-4">
          <div class="flex justify-between text-xs text-neutral-500 mb-2">
            <span>단계 {{ currentStep }}/{{ totalSteps }}</span>
            <span>{{ Math.round((currentStep / totalSteps) * 100) }}%</span>
          </div>
          <div class="w-full bg-neutral-200 rounded-full h-2">
            <div
              class="h-2 rounded-full transition-all duration-300"
              style="background: linear-gradient(to right, #8b5cf6, #3b82f6)"
              :style="{ width: `${(currentStep / totalSteps) * 100}%` }"
            ></div>
          </div>
        </div>

        <div class="card p-6">

        <!-- 환영 단계 -->
        <div v-if="currentStep === 1" class="text-center space-y-4">
          <div class="text-6xl mb-4 animate-bounce">⚡</div>
          <h2 class="text-2xl font-bold text-neutral-800">Quest ON에<br>오신 것을 환영합니다!</h2>
          <p class="text-neutral-600 font-gmarket">
            습관을 게임처럼 재미있게!<br>
            매일 작은 성취로 성장해보세요
          </p>
          <div class="pt-4">
            <button
              @click="nextStep"
              class="w-full py-3 px-4 text-white rounded-lg transition-all duration-200 font-medium shadow-md hover:opacity-90"
              style="background: linear-gradient(to right, #8b5cf6, #3b82f6)"
            >
              시작하기 ✨
            </button>
          </div>
        </div>

        <!-- 핵심 가치 설명 단계 -->
        <div v-if="currentStep === 2" class="text-center space-y-6">
          <div class="text-4xl mb-3">🎯</div>
          <h2 class="text-2xl font-bold text-neutral-800">Quest ON은<br>특별해요</h2>

          <!-- 캐릭터 성장 시각화 -->
          <div class="flex items-center justify-center gap-4 py-4">
            <div class="text-center">
              <div class="text-4xl mb-1">🐱</div>
              <p class="text-xs text-neutral-500">레벨 1</p>
            </div>
            <div class="text-2xl text-purple-500">→</div>
            <div class="text-center">
              <div class="text-6xl mb-1">🐱😊</div>
              <p class="text-xs text-neutral-500">레벨 5</p>
            </div>
            <div class="text-2xl text-purple-500">→</div>
            <div class="text-center">
              <div class="text-7xl mb-1">🐱✨</div>
              <p class="text-xs text-neutral-500">레벨 8+</p>
            </div>
          </div>

          <div class="bg-purple-50 border-2 border-purple-200 rounded-xl p-4 text-left">
            <p class="text-neutral-700 font-gmarket leading-relaxed">
              퀘스트를 완료할수록<br>
              <span class="font-bold text-purple-600">당신의 캐릭터가 성장합니다</span><br><br>
              <span class="text-sm text-neutral-600">
              초반에는 빠르게 레벨업!<br>
              약 2-3일마다 성장하는 모습을 볼 수 있어요
              </span>
            </p>
          </div>

          <p class="text-lg font-bold text-purple-600 font-gmarket">
            캐릭터의 성장 = 당신의 성장 ✨
          </p>

          <div class="flex gap-3 pt-4">
            <button
              @click="prevStep"
              class="flex-1 py-2 px-4 border border-neutral-300 text-neutral-700 rounded-lg hover:bg-neutral-50 transition-colors"
            >
              이전
            </button>
            <button
              @click="nextStep"
              class="flex-1 py-2 px-4 text-white rounded-lg transition-all duration-200 hover:opacity-90"
              style="background: linear-gradient(to right, #8b5cf6, #3b82f6)"
            >
              다음
            </button>
          </div>
        </div>

        <!-- 캐릭터 선택 단계 -->
        <div v-if="currentStep === 3" class="space-y-4">
          <div class="text-center">
            <h3 class="text-xl font-bold text-neutral-800 mb-2">캐릭터를 선택해주세요</h3>
            <p class="text-neutral-600 text-sm">함께할 픽셀 친구를 골라보세요</p>
          </div>

          <div class="grid grid-cols-2 gap-4">
            <button
              v-for="character in characters"
              :key="character.id"
              @click="selectCharacter(character.id)"
              :class="[
                'p-6 rounded-xl border-3 transition-all duration-200 text-center bg-white hover:scale-105',
                onboardingData.character === character.id
                  ? 'border-purple-500 bg-purple-50 shadow-lg'
                  : 'border-neutral-200 hover:border-neutral-300'
              ]"
            >
              <div class="text-6xl mb-2">{{ character.emoji }}</div>
              <div class="text-sm font-medium text-neutral-700">{{ character.name }}</div>
            </button>
          </div>

          <div class="flex gap-3 pt-4">
            <button
              @click="prevStep"
              class="flex-1 py-2 px-4 border border-neutral-300 text-neutral-700 rounded-lg hover:bg-neutral-50 transition-colors"
            >
              이전
            </button>
            <button
              @click="nextStep"
              :disabled="!onboardingData.character"
              class="flex-1 py-2 px-4 text-white rounded-lg disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-200 hover:opacity-90"
              style="background: linear-gradient(to right, #8b5cf6, #3b82f6)"
            >
              다음
            </button>
          </div>
        </div>

        <!-- 닉네임 설정 단계 -->
        <div v-if="currentStep === 4" class="space-y-4">
          <div class="text-center">
            <div class="text-4xl mb-4">{{ getSelectedCharacter()?.emoji }}</div>
            <h3 class="text-xl font-bold text-neutral-800 mb-2">어떻게 불러드릴까요?</h3>
            <p class="text-neutral-600 text-sm">앞으로 사용할 닉네임을 설정해주세요<br>
              <span class="text-xs text-neutral-500">한글, 영어, 숫자만 사용 가능 (2-10자)</span>
            </p>
          </div>

          <div>
            <input
              v-model="onboardingData.nickname"
              type="text"
              placeholder="닉네임을 입력하세요"
              maxlength="10"
              class="w-full px-4 py-3 border border-neutral-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500 text-center text-lg"
              @keyup.enter="nextStep"
            >
            <p class="text-xs text-neutral-500 mt-1 text-center">
              {{ onboardingData.nickname.length }}/10
            </p>
          </div>

          <div class="flex gap-3 pt-4">
            <button
              @click="prevStep"
              class="flex-1 py-2 px-4 border border-neutral-300 text-neutral-700 rounded-lg hover:bg-neutral-50 transition-colors"
            >
              이전
            </button>
            <button
              @click="nextStep"
              :disabled="!isValidNickname()"
              class="flex-1 py-2 px-4 text-white rounded-lg disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-200 hover:opacity-90"
              style="background: linear-gradient(to right, #8b5cf6, #3b82f6)"
            >
              다음
            </button>
          </div>
        </div>

        <!-- 관심 분야 선택 단계 -->
        <div v-if="currentStep === 5" class="space-y-4">
          <div class="text-center">
            <div class="text-4xl mb-4">🎯</div>
            <h3 class="text-xl font-bold text-neutral-800 mb-2">관심 분야를 선택해주세요</h3>
            <p class="text-neutral-600 text-sm">관심 있는 분야를 선택하면 맞춤 퀘스트를 추천해드려요</p>
          </div>

          <div class="grid grid-cols-2 gap-3">
            <button
              v-for="category in categories"
              :key="category.value"
              @click="toggleCategory(category.value)"
              :class="[
                'p-4 rounded-lg border-2 transition-all duration-200 text-center',
                onboardingData.interests.includes(category.value)
                  ? 'border-purple bg-primary-100 text-purple font-semibold transform scale-105'
                  : 'border-neutral-200 hover:border-neutral-300 text-neutral-700 hover:bg-neutral-50'
              ]"
            >
              <div class="text-2xl mb-1">{{ category.emoji }}</div>
              <div class="text-sm font-medium">{{ category.label }}</div>
            </button>
          </div>

          <div class="flex gap-3 pt-4">
            <button
              @click="prevStep"
              class="flex-1 py-2 px-4 border border-neutral-300 text-neutral-700 rounded-lg hover:bg-neutral-50 transition-colors"
            >
              이전
            </button>
            <button
              @click="nextStep"
              :disabled="onboardingData.interests.length === 0"
              class="flex-1 py-2 px-4 text-white rounded-lg disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-200 hover:opacity-90"
              style="background: linear-gradient(to right, #8b5cf6, #3b82f6)"
            >
              다음
            </button>
          </div>
        </div>

        <!-- 완료 단계 (온보딩 퀘스트 완료) -->
        <div v-if="currentStep === 6" class="text-center space-y-4">
          <div class="text-6xl mb-4">🎉</div>
          <h3 class="text-2xl font-bold text-neutral-800 font-gmarket">온보딩 완료!<br>퀘스트 달성</h3>
          <p class="text-neutral-600 font-gmarket">
            <span class="font-medium text-purple">{{ onboardingData.nickname }}</span>님이<br>
            첫 번째 퀘스트를 완료했습니다!
          </p>

          <!-- 온보딩 완료 퀘스트 -->
          <div class="bg-primary-100 rounded-lg p-4 border-2 border-primary-200">
            <div class="text-center mb-3">
              <span class="text-5xl">🎯</span>
            </div>
            <h4 class="font-bold text-lg text-neutral-800 font-gmarket mb-2">온보딩 완료 퀘스트 달성</h4>
            <p class="text-sm text-neutral-600 mb-3">프로필 설정 및 관심분야 선택 완료</p>

            <button
              @click="completeTutorialQuest"
              :disabled="tutorialQuestCompleted"
              :class="[
                'w-full py-2 px-3 rounded-lg font-medium transition-all duration-200',
                tutorialQuestCompleted
                  ? 'bg-green-100 text-green-700 cursor-not-allowed'
                  : 'bg-green-500 text-white hover:bg-green-600'
              ]"
            >
              {{ tutorialQuestCompleted ? '완료! ✅' : '확인' }}
            </button>
          </div>

          <div v-if="tutorialQuestCompleted" class="pt-4 space-y-3">
            <!-- 레벨업 알림 -->
            <div class="bg-gold bg-opacity-20 border border-gold rounded-lg p-3 text-center">
              <div class="text-2xl mb-1">⭐</div>
              <div class="font-semibold text-neutral-800 font-gmarket">레벨 업!</div>
              <div class="text-sm text-neutral-600">
                <span class="text-lg font-bold text-primary">0</span> →
                <span class="text-lg font-bold text-success">1</span>
              </div>
            </div>

            <button
              @click="completeOnboarding"
              class="w-full py-3 px-4 text-white rounded-lg transition-all duration-200 font-medium shadow-md hover:opacity-90"
              style="background: linear-gradient(to right, #8b5cf6, #3b82f6)"
            >
              Quest ON 시작하기! 🚀
            </button>
          </div>
        </div>

        </div> <!-- card p-6 닫기 -->
        </div> <!-- animate-slide-up 닫기 -->
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useQuestStore } from '../stores/quest.js'
import { usePersonalizationStore } from '../stores/personalization.js'

const emit = defineEmits(['complete'])

const questStore = useQuestStore()
const personalizationStore = usePersonalizationStore()

const currentStep = ref(1)
const totalSteps = 6
const tutorialQuestCompleted = ref(false)

const onboardingData = ref({
  character: '',
  nickname: '',
  interests: []
})

const characters = [
  { id: 'cat', name: '고양이', emoji: '🐱' },
  { id: 'dog', name: '강아지', emoji: '🐶' },
  { id: 'pig', name: '돼지', emoji: '🐷' },
  { id: 'rabbit', name: '토끼', emoji: '🐰' }
]

const categories = [
  { value: 'health', label: '건강', emoji: '💚' },
  { value: 'fitness', label: '운동', emoji: '💪' },
  { value: 'learning', label: '학습', emoji: '📚' },
  { value: 'work', label: '업무', emoji: '💼' },
  { value: 'hobby', label: '취미', emoji: '🎨' },
  { value: 'mindfulness', label: '마음챙김', emoji: '🧘' }
]

// 관심 분야별 샘플 퀘스트
const questTemplates = {
  health: [
    { title: '물 8잔 마시기', description: '하루 권장 수분 섭취량', difficulty: { '😊': 8, '😐': 6, '😞': 4 } },
    { title: '비타민 챙겨먹기', description: '건강한 영양 보충', difficulty: { '😊': 1, '😐': 1, '😞': 1 } }
  ],
  fitness: [
    { title: '30분 운동하기', description: '적당한 강도의 운동', difficulty: { '😊': 30, '😐': 20, '😞': 10 } },
    { title: '만보 걷기', description: '하루 1만보 목표', difficulty: { '😊': 10000, '😐': 7000, '😞': 5000 } }
  ],
  learning: [
    { title: '책 읽기', description: '독서로 지식 쌓기', difficulty: { '😊': 60, '😐': 30, '😞': 15 } },
    { title: '새로운 단어 외우기', description: '어휘력 향상', difficulty: { '😊': 10, '😐': 5, '😞': 3 } }
  ],
  work: [
    { title: '투두리스트 완료하기', description: '오늘의 할 일 체크', difficulty: { '😊': 5, '😐': 3, '😞': 2 } },
    { title: '집중 시간 갖기', description: '집중해서 업무하기', difficulty: { '😊': 120, '😐': 90, '😞': 60 } }
  ],
  hobby: [
    { title: '취미 활동하기', description: '나만의 시간 갖기', difficulty: { '😊': 60, '😐': 30, '😞': 15 } },
    { title: '창작 활동하기', description: '그림, 글쓰기 등', difficulty: { '😊': 30, '😐': 20, '😞': 10 } }
  ],
  mindfulness: [
    { title: '명상하기', description: '마음의 평온 찾기', difficulty: { '😊': 20, '😐': 15, '😞': 5 } },
    { title: '감사 일기 쓰기', description: '긍정적 마음가짐', difficulty: { '😊': 1, '😐': 1, '😞': 1 } }
  ]
}

function selectCharacter(characterId) {
  onboardingData.value.character = characterId
}

function getSelectedCharacter() {
  return characters.find(c => c.id === onboardingData.value.character)
}

function completeTutorialQuest() {
  tutorialQuestCompleted.value = true
  // 축하 효과 추가 가능
}

const sampleQuests = computed(() => {
  const quests = []
  let questId = Date.now()

  onboardingData.value.interests.forEach(interest => {
    if (questTemplates[interest]) {
      const template = questTemplates[interest][0]
      quests.push({
        id: questId++,
        ...template,
        category: interest,
        completed: false,
        progress: 0,
        createdAt: new Date().toISOString()
      })
    }
  })

  return quests
})

function toggleCategory(category) {
  const index = onboardingData.value.interests.indexOf(category)
  if (index > -1) {
    onboardingData.value.interests.splice(index, 1)
  } else {
    onboardingData.value.interests.push(category)
  }
}

function getCategoryEmoji(category) {
  const cat = categories.find(c => c.value === category)
  return cat ? cat.emoji : '⭐'
}

function nextStep() {
  if (currentStep.value < totalSteps) {
    currentStep.value++
  }
}

function prevStep() {
  if (currentStep.value > 1) {
    currentStep.value--
  }
}

function completeOnboarding() {
  // 사용자 프로필 설정
  personalizationStore.userProfile.preferences.categories = onboardingData.value.interests
  personalizationStore.savePersonalizationData()

  // 온보딩 완료로 레벨업 (0 → 1)
  questStore.gainExperience(100) // 충분한 경험치를 줘서 레벨업

  // 샘플 퀘스트 추가
  sampleQuests.value.forEach(quest => {
    questStore.addQuest(quest)
  })

  // 온보딩 완료 상태 localStorage에 저장
  localStorage.setItem('quest-on-onboarding-completed', 'true')
  localStorage.setItem('quest-on-user-nickname', onboardingData.value.nickname)
  localStorage.setItem('quest-on-user-character', onboardingData.value.character)

  // 온보딩 완료 이벤트 발생
  emit('complete', {
    character: onboardingData.value.character,
    nickname: onboardingData.value.nickname,
    interests: onboardingData.value.interests,
    questsAdded: sampleQuests.value.length
  })
}

// 닉네임 검증 함수
function validateNickname(nickname) {
  // 한글, 영어, 숫자만 허용 (특수문자 제외)
  const regex = /^[가-힣a-zA-Z0-9]+$/
  return regex.test(nickname) && nickname.length >= 2 && nickname.length <= 10
}

function isValidNickname() {
  return onboardingData.value.nickname.trim() && validateNickname(onboardingData.value.nickname)
}

onMounted(() => {
  // 예시 제거 - 빈 상태로 시작
})
</script>

<style scoped>
@keyframes fade-in {
  from { opacity: 0; }
  to { opacity: 1; }
}

@keyframes slide-up {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.animate-fade-in {
  animation: fade-in 0.3s ease-out;
}

.animate-slide-up {
  animation: slide-up 0.4s ease-out;
}
</style>