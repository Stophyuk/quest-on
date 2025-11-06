<template>
  <div v-if="show" class="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50 p-4">
    <div class="bg-white rounded-3xl shadow-2xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
      <!-- 헤더 -->
      <div class="sticky top-0 bg-white border-b border-gray-200 px-6 py-4 rounded-t-3xl">
        <h2 class="text-2xl font-bold text-gray-900">✨ 당신의 비전 설정</h2>
        <p class="text-sm text-gray-600 mt-1">{{ currentStep }}/10 단계</p>
        <!-- 진행률 바 -->
        <div class="mt-3 bg-gray-200 rounded-full h-2 overflow-hidden">
          <div
            class="bg-gradient-to-r from-blue-500 to-purple-600 h-full transition-all duration-300"
            :style="{ width: `${(currentStep / 10) * 100}%` }"
          ></div>
        </div>
      </div>

      <!-- 질문 영역 -->
      <div class="p-6">
        <!-- 질문 1: 가치관 (복수선택) -->
        <div v-if="currentStep === 1" class="space-y-4">
          <h3 class="text-xl font-semibold text-gray-900">당신의 핵심 가치관은 무엇인가요?</h3>
          <p class="text-sm text-gray-600">가장 중요하게 생각하는 가치를 선택해주세요 (복수 선택 가능)</p>
          <div class="grid grid-cols-2 gap-3">
            <label
              v-for="value in valueOptions"
              :key="value"
              class="flex items-center gap-2 p-3 border-2 rounded-lg cursor-pointer transition-all"
              :class="profile.values.includes(value) ? 'border-blue-500 bg-blue-50' : 'border-gray-300 hover:border-gray-400'"
            >
              <input
                type="checkbox"
                :value="value"
                v-model="profile.values"
                class="w-5 h-5 text-blue-600"
              />
              <span class="text-gray-900">{{ value }}</span>
            </label>
          </div>

          <!-- 기타 직접입력 -->
          <div class="space-y-2">
            <label class="flex items-center gap-2 p-3 border-2 rounded-lg cursor-pointer transition-all"
              :class="showCustomValue ? 'border-blue-500 bg-blue-50' : 'border-gray-300 hover:border-gray-400'"
            >
              <input
                type="checkbox"
                v-model="showCustomValue"
                @change="toggleCustomValue"
                class="w-5 h-5 text-blue-600"
              />
              <span class="text-gray-900">기타 (직접 입력)</span>
            </label>

            <div v-if="showCustomValue" class="pl-9">
              <input
                type="text"
                v-model="profile.customValue"
                placeholder="가치관을 입력하세요 (10자 이내)"
                maxlength="10"
                class="w-full px-4 py-2 border-2 border-blue-300 rounded-lg focus:outline-none focus:border-blue-500"
              />
              <p class="text-xs text-gray-500 mt-1">{{ profile.customValue.length }}/10</p>
            </div>
          </div>
        </div>

        <!-- 질문 2: 현재 정체성 -->
        <div v-if="currentStep === 2" class="space-y-4">
          <h3 class="text-xl font-semibold text-gray-900">지금 이 순간, 당신은 스스로를 어떻게 소개하시나요?</h3>
          <p class="text-sm text-gray-600">타인의 평가가 아닌, 진짜 내가 느끼는 나의 모습을 표현해주세요</p>
          <input
            type="text"
            v-model="profile.currentIdentity"
            placeholder="예: 새로운 것을 배우는 걸 좋아하지만, 끝까지 해내는 것에 어려움을 느끼는 사람"
            class="w-full px-4 py-3 border-2 border-gray-300 rounded-lg focus:outline-none focus:border-blue-500"
            maxlength="80"
            @keyup.enter="nextStep"
          />
          <p class="text-xs text-gray-500 text-right">{{ profile.currentIdentity.length }}/80</p>
        </div>

        <!-- 질문 3: 5년 후 정체성 -->
        <div v-if="currentStep === 3" class="space-y-4">
          <h3 class="text-xl font-semibold text-gray-900">5년 후, 당신은 어떤 사람으로 성장해있고 싶나요?</h3>
          <p class="text-sm text-gray-600">직업이나 지위가 아닌, 어떤 능력과 가치를 갖춘 사람이 되고 싶은지 구체적으로 그려보세요</p>
          <input
            type="text"
            v-model="profile.futureIdentity"
            placeholder="예: 기술로 사람들의 문제를 해결하고, 팀을 이끌며 함께 성장하는 것에 보람을 느끼는 개발자"
            class="w-full px-4 py-3 border-2 border-gray-300 rounded-lg focus:outline-none focus:border-blue-500"
            maxlength="100"
            @keyup.enter="nextStep"
          />
          <p class="text-xs text-gray-500 text-right">{{ profile.futureIdentity.length }}/100</p>
        </div>

        <!-- 질문 4: 인생의 꿈 -->
        <div v-if="currentStep === 4" class="space-y-4">
          <h3 class="text-xl font-semibold text-gray-900">인생을 살면서 꼭 이루고 싶은 것은 무엇인가요?</h3>
          <p class="text-sm text-gray-600">성공의 기준이나 타인의 시선이 아닌, 진심으로 간절히 원하는 것을 자유롭게 표현해주세요</p>
          <textarea
            v-model="profile.lifeDream"
            placeholder="예: 기술을 통해 사회적 가치를 만들고 싶습니다. 특히 정보 접근성이 낮은 사람들에게 도움이 되는 서비스를 만들어, 누군가의 삶이 조금이라도 나아졌다는 피드백을 받고 싶어요. 그리고 그 과정에서 함께 일하는 사람들과 진정성 있는 관계를 맺으며 성장하고 싶습니다."
            class="w-full px-4 py-3 border-2 border-gray-300 rounded-lg focus:outline-none focus:border-blue-500 h-40 resize-none"
            maxlength="300"
          ></textarea>
          <p class="text-xs text-gray-500 text-right">{{ profile.lifeDream.length }}/300</p>
        </div>

        <!-- 질문 5: 현재 가장 큰 고민 -->
        <div v-if="currentStep === 5" class="space-y-4">
          <h3 class="text-xl font-semibold text-gray-900">지금 당신을 가장 힘들게 하는 것은 무엇인가요?</h3>
          <p class="text-sm text-gray-600">목표 달성을 가로막거나, 마음속에서 자꾸 신경 쓰이는 것들을 솔직하게 나눠주세요</p>
          <textarea
            v-model="profile.concerns"
            placeholder="예: 하고 싶은 건 많은데 끝까지 해내지 못하는 제 자신에게 실망할 때가 많아요. 시작은 열정적이지만 중간에 흥미를 잃거나, 어려움이 오면 쉽게 포기하게 됩니다. 이런 패턴이 반복되면서 자신감도 많이 떨어진 상태예요."
            class="w-full px-4 py-3 border-2 border-gray-300 rounded-lg focus:outline-none focus:border-blue-500 h-40 resize-none"
            maxlength="300"
          ></textarea>
          <p class="text-xs text-gray-500 text-right">{{ profile.concerns.length }}/300</p>
        </div>

        <!-- 질문 6: 1년 후 목표 3개 -->
        <div v-if="currentStep === 6" class="space-y-4">
          <h3 class="text-xl font-semibold text-gray-900">1년 후, 어떤 모습이 되어있다면 가장 뿌듯할까요?</h3>
          <p class="text-sm text-gray-600">측정 가능하고 구체적인 목표 3가지를 적어주세요. "~을 할 수 있다", "~을 완성한다" 같은 형태로요</p>
          <div class="space-y-3">
            <div v-for="i in 3" :key="i">
              <label class="text-sm font-semibold text-gray-700 mb-1 block">목표 {{ i }}</label>
              <input
                type="text"
                v-model="profile.yearGoals[i - 1]"
                :placeholder="`예: ${goalExamples[i - 1]}`"
                class="w-full px-4 py-3 border-2 border-gray-300 rounded-lg focus:outline-none focus:border-blue-500"
                maxlength="120"
              />
            </div>
          </div>
        </div>

        <!-- 질문 7: 현재 루틴 -->
        <div v-if="currentStep === 7" class="space-y-4">
          <h3 class="text-xl font-semibold text-gray-900">현재 당신의 하루는 어떻게 흘러가나요?</h3>
          <p class="text-sm text-gray-600">평일 기준으로, 주요 시간대별 활동과 그 시간 동안의 기분이나 에너지 상태도 함께 적어주세요</p>
          <textarea
            v-model="profile.currentRoutine"
            placeholder="예: 오전 9시-6시는 회사에서 일합니다. 점심 이후 오후 2-3시에 가장 집중이 잘 되고, 퇴근 후에는 피곤하지만 뭔가 배우고 싶은 욕구가 생겨요. 저녁 7-9시에 유튜브로 공부하거나 독서를 하려고 하는데, 실제로는 SNS를 보다 끝나는 날이 많습니다."
            class="w-full px-4 py-3 border-2 border-gray-300 rounded-lg focus:outline-none focus:border-blue-500 h-40 resize-none"
            maxlength="300"
          ></textarea>
          <p class="text-xs text-gray-500 text-right">{{ profile.currentRoutine.length }}/300</p>
        </div>

        <!-- 질문 8: 가능한 시간 -->
        <div v-if="currentStep === 8" class="space-y-4">
          <h3 class="text-xl font-semibold text-gray-900">하루에 목표를 위해 온전히 집중할 수 있는 시간은 얼마나 될까요?</h3>
          <p class="text-sm text-gray-600">현실적으로 지속 가능한 시간을 선택해주세요. 너무 욕심내지 마세요 :)</p>
          <div class="bg-blue-50 rounded-lg p-4 mb-4">
            <div class="text-center mb-2">
              <span class="text-4xl font-bold text-blue-600">{{ profile.availableTime }}</span>
              <span class="text-lg text-blue-600">시간</span>
            </div>
            <input
              type="range"
              v-model.number="profile.availableTime"
              min="0.5"
              max="6"
              step="0.5"
              class="w-full h-3 bg-blue-200 rounded-lg appearance-none cursor-pointer"
            />
          </div>
          <div class="grid grid-cols-4 gap-2">
            <button
              v-for="time in [0.5, 1, 2, 3]"
              :key="time"
              @click="profile.availableTime = time"
              class="px-3 py-2 text-sm rounded-lg transition-all font-medium"
              :class="profile.availableTime === time ? 'bg-blue-500 text-white' : 'bg-gray-100 text-gray-700 hover:bg-gray-200'"
            >
              {{ time }}시간
            </button>
          </div>
          <p class="text-xs text-gray-500 text-center mt-2">
            💡 팁: 처음엔 작게 시작하세요. 1시간도 꾸준히 하면 큰 변화를 만들 수 있습니다!
          </p>
        </div>

        <!-- 질문 9: 선호 학습 방식 -->
        <div v-if="currentStep === 9" class="space-y-4">
          <h3 class="text-xl font-semibold text-gray-900">무언가를 배울 때, 어떤 방식이 가장 잘 맞나요?</h3>
          <p class="text-sm text-gray-600">과거 경험을 떠올려보며 가장 효과적이었던 학습 방식을 선택해주세요</p>
          <div class="space-y-2">
            <label
              v-for="(style, index) in learningStyles"
              :key="style.value"
              class="flex items-start gap-3 p-4 border-2 rounded-lg cursor-pointer transition-all"
              :class="profile.learningStyle === style.value ? 'border-blue-500 bg-blue-50' : 'border-gray-300 hover:border-gray-400'"
            >
              <input
                type="radio"
                :value="style.value"
                v-model="profile.learningStyle"
                class="w-5 h-5 text-blue-600 mt-0.5"
              />
              <div class="flex-1">
                <span class="text-gray-900 font-medium block">{{ style.value }}</span>
                <span class="text-sm text-gray-600">{{ style.description }}</span>
              </div>
            </label>
          </div>
        </div>

        <!-- 질문 10: 동기부여 요소 -->
        <div v-if="currentStep === 10" class="space-y-4">
          <h3 class="text-xl font-semibold text-gray-900">힘들 때, 무엇이 당신을 다시 일으켜 세우나요?</h3>
          <p class="text-sm text-gray-600">포기하고 싶을 때 계속 나아가게 하는 힘, 당신만의 동력은 무엇인가요?</p>
          <div class="space-y-2">
            <label
              v-for="(motivation, index) in motivationOptions"
              :key="motivation.value"
              class="flex items-start gap-3 p-4 border-2 rounded-lg cursor-pointer transition-all"
              :class="profile.motivation === motivation.value ? 'border-blue-500 bg-blue-50' : 'border-gray-300 hover:border-gray-400'"
            >
              <input
                type="radio"
                :value="motivation.value"
                v-model="profile.motivation"
                class="w-5 h-5 text-blue-600 mt-0.5"
              />
              <div class="flex-1">
                <span class="text-gray-900 font-medium block">{{ motivation.value }}</span>
                <span class="text-sm text-gray-600">{{ motivation.description }}</span>
              </div>
            </label>
          </div>
        </div>
      </div>

      <!-- 하단 버튼 -->
      <div class="sticky bottom-0 bg-white border-t border-gray-200 px-6 py-4 flex gap-3 rounded-b-3xl">
        <button
          v-if="currentStep > 1"
          @click="prevStep"
          class="px-6 py-3 bg-gray-100 text-gray-700 rounded-xl font-medium hover:bg-gray-200 transition-colors"
        >
          이전
        </button>
        <button
          v-if="currentStep < 10"
          @click="nextStep"
          :disabled="!canProceed"
          class="flex-1 px-6 py-3 rounded-xl font-medium transition-all"
          :class="canProceed ? 'bg-gradient-to-r from-blue-500 to-purple-600 text-white hover:shadow-lg' : 'bg-gray-300 text-gray-500 cursor-not-allowed'"
        >
          다음
        </button>
        <button
          v-if="currentStep === 10"
          @click="completeSurvey"
          :disabled="!canProceed"
          class="flex-1 px-6 py-3 rounded-xl font-medium transition-all"
          :class="canProceed ? 'bg-gradient-to-r from-green-500 to-emerald-600 text-white hover:shadow-lg' : 'bg-gray-300 text-gray-500 cursor-not-allowed'"
        >
          완료
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'

const props = defineProps({
  show: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['complete', 'close'])

const currentStep = ref(1)
const showCustomValue = ref(false)

const profile = ref({
  values: [],
  customValue: '',
  currentIdentity: '',
  futureIdentity: '',
  lifeDream: '',
  concerns: '',
  yearGoals: ['', '', ''],
  currentRoutine: '',
  availableTime: 2,
  learningStyle: '',
  motivation: ''
})

// 선택지 데이터
const valueOptions = [
  '성장', '자유', '안정', '도전',
  '관계', '창의성', '기여', '인정',
  '건강', '균형', '성취', '즐거움'
]

const goalExamples = [
  'React와 TypeScript로 실무 프로젝트 3개 완성하고, 기술 블로그에 회고 작성하기',
  '주 3회 이상 영어로 된 기술 아티클을 읽고, 슬랙에서 영어로 소통할 수 있게 되기',
  '실제 사용자 100명 이상이 사용하는 웹 서비스 1개를 기획부터 배포까지 완성하기'
]

const learningStyles = [
  {
    value: '책이나 글로 배우기',
    description: '체계적인 지식을 차근차근 쌓아가는 것이 좋아요. 정리하고 메모하며 깊이 이해하고 싶어요.'
  },
  {
    value: '영상으로 배우기',
    description: '시각적으로 보면서 따라하는 게 편해요. 유튜브나 온라인 강의가 잘 맞아요.'
  },
  {
    value: '직접 만들며 배우기',
    description: '이론보다 실전! 일단 해보면서 부딪히고 해결하며 배우는 게 더 재밌어요.'
  },
  {
    value: '함께 대화하며 배우기',
    description: '혼자보다 스터디나 멘토링 등 사람들과 소통하면서 배우는 게 효과적이에요.'
  }
]

const motivationOptions = [
  {
    value: '눈에 보이는 성과와 결과물',
    description: '내가 만든 것, 이룬 것이 쌓여가는 걸 보면 뿌듯하고 더 열심히 하게 돼요.'
  },
  {
    value: '주변의 인정과 응원',
    description: '가족, 친구, 동료가 인정해주고 칭찬해줄 때 가장 힘이 나요.'
  },
  {
    value: '어제보다 나은 내 모습',
    description: '남과의 비교보다, 과거의 나보다 성장하는 제 모습이 가장 큰 원동력이에요.'
  },
  {
    value: '경쟁과 도전 의식',
    description: '누군가와 비교되거나 경쟁 상황에 놓이면 오히려 불타올라요.'
  },
  {
    value: '과정 자체의 즐거움',
    description: '결과보다 배우고 만드는 과정 자체가 재미있고 즐거워요.'
  }
]

// 다음 단계로 진행 가능 여부
const canProceed = computed(() => {
  switch (currentStep.value) {
    case 1:
      // 일반 가치관 선택 또는 기타 입력 완료
      const hasValues = profile.value.values.length > 0
      const hasCustomValue = showCustomValue.value && profile.value.customValue.trim().length > 0
      return hasValues || hasCustomValue
    case 2:
      return profile.value.currentIdentity.trim().length > 0
    case 3:
      return profile.value.futureIdentity.trim().length > 0
    case 4:
      return profile.value.lifeDream.trim().length > 0
    case 5:
      return profile.value.concerns.trim().length > 0
    case 6:
      return profile.value.yearGoals.filter(g => g.trim()).length === 3
    case 7:
      return profile.value.currentRoutine.trim().length > 0
    case 8:
      return profile.value.availableTime > 0
    case 9:
      return profile.value.learningStyle.length > 0
    case 10:
      return profile.value.motivation.length > 0
    default:
      return false
  }
})

function toggleCustomValue() {
  if (!showCustomValue.value) {
    // 기타 체크 해제 시 입력 내용 초기화
    profile.value.customValue = ''
  }
}

function nextStep() {
  if (canProceed.value && currentStep.value < 10) {
    currentStep.value++
  }
}

function prevStep() {
  if (currentStep.value > 1) {
    currentStep.value--
  }
}

function completeSurvey() {
  if (canProceed.value) {
    // customValue를 values 배열에 추가
    const finalValues = [...profile.value.values]
    if (showCustomValue.value && profile.value.customValue.trim()) {
      finalValues.push(profile.value.customValue.trim())
    }

    // yearGoals 배열에서 빈 문자열 제거
    const cleanedProfile = {
      ...profile.value,
      values: finalValues,
      yearGoals: profile.value.yearGoals.filter(g => g.trim())
    }

    // customValue는 제거 (이미 values에 포함됨)
    delete cleanedProfile.customValue

    emit('complete', cleanedProfile)
  }
}
</script>

<style scoped>
/* 스크롤바 스타일링 */
div::-webkit-scrollbar {
  width: 8px;
}

div::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 10px;
}

div::-webkit-scrollbar-thumb {
  background: #888;
  border-radius: 10px;
}

div::-webkit-scrollbar-thumb:hover {
  background: #555;
}

/* Range input 스타일링 */
input[type="range"]::-webkit-slider-thumb {
  appearance: none;
  width: 20px;
  height: 20px;
  background: #3b82f6;
  cursor: pointer;
  border-radius: 50%;
}

input[type="range"]::-moz-range-thumb {
  width: 20px;
  height: 20px;
  background: #3b82f6;
  cursor: pointer;
  border-radius: 50%;
  border: none;
}
</style>
