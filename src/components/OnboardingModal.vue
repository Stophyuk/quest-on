<template>
  <div class="fixed inset-0 z-50 bg-gradient-calm animate-fade-in">
    <div class="h-full overflow-y-auto flex items-center">
      <div class="w-full max-w-md mx-auto px-4 py-6">
        <!-- 브랜드 헤더 -->
        <div class="text-center mb-4">
          <h1 class="text-4xl font-bold font-pixel text-purple mb-1">
            Quest ON
          </h1>
          <p class="text-neutral-600 text-sm font-gmarket font-light">내일을 ON하는 오늘의 퀘스트</p>
        </div>

        <div class="animate-slide-up">
          <!-- 진행 바 -->
          <div class="card p-4 mb-3">
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

          <div class="card p-4">
            <!-- Step 1: 환영 + 캐릭터 선택 (통합) -->
            <div v-if="currentStep === 1" class="space-y-4">
              <div class="text-center">
                <div class="text-5xl mb-3 animate-bounce">⚡</div>
                <h2 class="text-xl font-bold text-neutral-800 mb-2">Quest ON에<br>오신 것을 환영합니다!</h2>
                <p class="text-neutral-600 font-gmarket text-xs mb-4">
                  매일 작은 성취로 성장하는<br>나만의 캐릭터를 키워보세요
                </p>
              </div>

              <!-- 캐릭터 선택 -->
              <div>
                <h3 class="text-center text-base font-bold text-neutral-800 mb-3">함께할 친구를 선택하세요</h3>
                <div class="grid grid-cols-2 gap-3">
                  <button
                    v-for="character in characters"
                    :key="character.id"
                    @click="selectCharacter(character.id)"
                    :class="[
                      'p-4 rounded-xl border-3 transition-all duration-200 text-center bg-white hover:scale-105',
                      onboardingData.character === character.id
                        ? 'border-purple-500 bg-purple-50 shadow-lg'
                        : 'border-neutral-200 hover:border-neutral-300'
                    ]"
                  >
                    <div class="text-5xl mb-1">{{ character.emoji }}</div>
                    <div class="text-xs font-medium text-neutral-700">{{ character.name }}</div>
                  </button>
                </div>
              </div>

              <button
                @click="nextStep"
                :disabled="!onboardingData.character"
                class="w-full py-2.5 px-4 text-white rounded-lg disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-200 hover:opacity-90 text-sm"
                style="background: linear-gradient(to right, #8b5cf6, #3b82f6)"
              >
                다음 ✨
              </button>
            </div>

            <!-- Step 2: 닉네임 설정 -->
            <div v-if="currentStep === 2" class="space-y-3">
              <div class="text-center">
                <div class="text-4xl mb-3">{{ getSelectedCharacter()?.emoji }}</div>
                <h3 class="text-lg font-bold text-neutral-800 mb-1">어떻게 불러드릴까요?</h3>
                <p class="text-neutral-600 text-xs">앞으로 사용할 닉네임을 설정해주세요<br>
                  <span class="text-xs text-neutral-500">한글, 영어, 숫자만 사용 가능 (2-10자)</span>
                </p>
              </div>

              <div>
                <input
                  v-model="onboardingData.nickname"
                  type="text"
                  placeholder="닉네임을 입력하세요"
                  maxlength="10"
                  class="w-full px-4 py-2.5 border border-neutral-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500 text-center text-base"
                  @keyup.enter="nextStep"
                >
                <p class="text-xs text-neutral-500 mt-1 text-center">
                  {{ onboardingData.nickname.length }}/10
                </p>
              </div>

              <div class="flex gap-2 pt-2">
                <button
                  @click="prevStep"
                  class="flex-1 py-2 px-3 border border-neutral-300 text-neutral-700 rounded-lg hover:bg-neutral-50 transition-colors text-sm"
                >
                  이전
                </button>
                <button
                  @click="nextStep"
                  :disabled="!isValidNickname()"
                  class="flex-1 py-2 px-3 text-white rounded-lg disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-200 hover:opacity-90 text-sm"
                  style="background: linear-gradient(to right, #8b5cf6, #3b82f6)"
                >
                  다음
                </button>
              </div>
            </div>

            <!-- Step 3: 비전 설문 안내 -->
            <div v-if="currentStep === 3" class="text-center space-y-4">
              <div class="text-5xl mb-2">✨</div>
              <h3 class="text-xl font-bold text-neutral-800 font-gmarket">당신의 비전을 설정하세요</h3>
              <p class="text-neutral-600 font-gmarket text-sm">
                <span class="font-medium text-purple">{{ onboardingData.nickname }}</span>님의<br>
                꿈과 목표를 알려주세요!
              </p>

              <div class="bg-blue-50 rounded-lg p-4 text-left border-2 border-blue-200">
                <h4 class="font-bold text-sm text-neutral-800 mb-2 text-center">📋 비전 설문이란?</h4>
                <ul class="space-y-2 text-xs text-neutral-700">
                  <li class="flex items-start gap-2">
                    <span class="text-blue-600 font-bold">•</span>
                    <span>10개의 질문으로 구성 (약 3분 소요)</span>
                  </li>
                  <li class="flex items-start gap-2">
                    <span class="text-blue-600 font-bold">•</span>
                    <span>AI가 당신만의 비전 노트를 작성</span>
                  </li>
                  <li class="flex items-start gap-2">
                    <span class="text-blue-600 font-bold">•</span>
                    <span>목표에 맞는 퀘스트를 자동 추천</span>
                  </li>
                </ul>
              </div>

              <div class="flex gap-2">
                <button
                  @click="prevStep"
                  class="flex-1 py-2 px-3 border border-neutral-300 text-neutral-700 rounded-lg hover:bg-neutral-50 transition-colors text-sm"
                >
                  이전
                </button>
                <button
                  @click="startVisionSurvey"
                  class="flex-[2] py-2.5 px-3 text-white rounded-lg transition-all duration-200 font-medium shadow-md hover:opacity-90 text-sm"
                  style="background: linear-gradient(to right, #8b5cf6, #3b82f6)"
                >
                  비전 설문 시작하기 🎯
                </button>
              </div>
            </div>

            <!-- Step 4: 완료 -->
            <div v-if="currentStep === 4" class="text-center space-y-3">
              <div class="text-5xl mb-2">🎉</div>
              <h3 class="text-xl font-bold text-neutral-800 font-gmarket">모든 준비 완료!</h3>
              <p class="text-neutral-600 font-gmarket text-sm">
                <span class="font-medium text-purple">{{ onboardingData.nickname }}</span>님과
                <span class="text-3xl">{{ getSelectedCharacter()?.emoji }}</span>의
                모험이 시작됩니다!
              </p>

              <!-- 시작 가이드 -->
              <div class="bg-primary-50 rounded-lg p-3 text-left border-2 border-primary-200">
                <h4 class="font-bold text-sm text-neutral-800 mb-2 text-center">💡 빠른 시작 가이드</h4>
                <ul class="space-y-1.5 text-xs text-neutral-700">
                  <li class="flex items-start gap-2">
                    <span class="text-primary font-bold">1.</span>
                    <span>AI가 생성한 비전 노트를 확인하세요</span>
                  </li>
                  <li class="flex items-start gap-2">
                    <span class="text-primary font-bold">2.</span>
                    <span>매일 추천되는 퀘스트를 완료하세요</span>
                  </li>
                  <li class="flex items-start gap-2">
                    <span class="text-primary font-bold">3.</span>
                    <span>레벨업하며 목표에 다가갑니다</span>
                  </li>
                </ul>
              </div>

              <div class="flex gap-2">
                <button
                  @click="prevStep"
                  class="flex-1 py-2 px-3 border border-neutral-300 text-neutral-700 rounded-lg hover:bg-neutral-50 transition-colors text-sm"
                >
                  이전
                </button>
                <button
                  @click="completeOnboarding"
                  class="flex-[2] py-2.5 px-3 text-white rounded-lg transition-all duration-200 font-medium shadow-md hover:opacity-90 text-sm"
                  style="background: linear-gradient(to right, #8b5cf6, #3b82f6)"
                >
                  Quest ON 시작하기! 🚀
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 비전 설문 모달 -->
    <VisionSurveyModal
      :show="showVisionSurvey"
      @complete="handleVisionSurveyComplete"
      @close="showVisionSurvey = false"
    />

    <!-- 비전 노트 생성기 -->
    <VisionNoteGenerator
      :show="showVisionNoteGenerator"
      :visionProfile="onboardingData.visionProfile || {}"
      @complete="handleVisionNoteComplete"
      @skip="handleVisionNoteSkip"
      @close="showVisionNoteGenerator = false"
    />

    <!-- 목표 트리 생성기 -->
    <GoalTreeGenerator
      :show="showGoalTreeGenerator"
      :visionNote="onboardingData.visionNote || ''"
      :yearGoals="onboardingData.visionProfile?.yearGoals || []"
      @complete="handleGoalTreeComplete"
      @skip="handleGoalTreeSkip"
      @close="showGoalTreeGenerator = false"
    />
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useQuestStore } from '../stores/quest.js'
import { storage } from '@/utils/storage'
import VisionSurveyModal from './vision/VisionSurveyModal.vue'
import VisionNoteGenerator from './vision/VisionNoteGenerator.vue'
import GoalTreeGenerator from './vision/GoalTreeGenerator_new.vue'

const emit = defineEmits(['complete'])

const questStore = useQuestStore()

const currentStep = ref(1)
const totalSteps = 4 // 캐릭터 → 닉네임 → 비전 설문 → 완료

const onboardingData = ref({
  character: '',
  nickname: '',
  visionProfile: null,
  visionNote: '',
  goalTree: []
})

const showVisionSurvey = ref(false)
const showVisionNoteGenerator = ref(false)
const showGoalTreeGenerator = ref(false)

const characters = [
  { id: 'cat', name: '고양이', emoji: '🐱' },
  { id: 'dog', name: '강아지', emoji: '🐶' },
  { id: 'pig', name: '돼지', emoji: '🐷' },
  { id: 'rabbit', name: '토끼', emoji: '🐰' }
]

function selectCharacter(characterId) {
  onboardingData.value.character = characterId
}

function getSelectedCharacter() {
  return characters.find(c => c.id === onboardingData.value.character)
}

function validateNickname(nickname) {
  const regex = /^[가-힣a-zA-Z0-9]+$/
  return regex.test(nickname) && nickname.length >= 2 && nickname.length <= 10
}

function isValidNickname() {
  return onboardingData.value.nickname.trim() && validateNickname(onboardingData.value.nickname)
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

function startVisionSurvey() {
  showVisionSurvey.value = true
}

function handleVisionSurveyComplete(visionProfile) {
  onboardingData.value.visionProfile = visionProfile
  showVisionSurvey.value = false

  // 비전 설문 완료 후 AI 비전 노트 생성 시작
  questStore.setVisionProfile(visionProfile)
  showVisionNoteGenerator.value = true
}

function handleVisionNoteComplete(visionNote) {
  onboardingData.value.visionNote = visionNote
  showVisionNoteGenerator.value = false

  // 비전 노트 생성 완료 후 목표 트리 생성 시작
  showGoalTreeGenerator.value = true
}

function handleVisionNoteSkip() {
  showVisionNoteGenerator.value = false
  // 건너뛰어도 목표 트리 생성 시도 (yearGoals가 있으면)
  if (onboardingData.value.visionProfile?.yearGoals?.length > 0) {
    showGoalTreeGenerator.value = true
  } else {
    nextStep()
  }
}

function handleGoalTreeComplete(goalTree) {
  onboardingData.value.goalTree = goalTree
  showGoalTreeGenerator.value = false

  // 목표 트리 생성 완료 후 다음 단계로
  nextStep()
}

function handleGoalTreeSkip() {
  showGoalTreeGenerator.value = false
  // 건너뛰어도 다음 단계로
  nextStep()
}

async function completeOnboarding() {
  // 온보딩 완료로 레벨 0 → 1 (30 XP)
  questStore.gainExperience(30)

  // 온보딩 완료 상태 저장
  await storage.set('quest-on-onboarding-completed', 'true')
  await storage.set('quest-on-user-nickname', onboardingData.value.nickname)
  await storage.set('quest-on-user-character', onboardingData.value.character)

  // 온보딩 완료 이벤트 발생
  emit('complete', {
    character: onboardingData.value.character,
    nickname: onboardingData.value.nickname,
    visionProfile: onboardingData.value.visionProfile
  })
}
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
