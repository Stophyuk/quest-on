<template>
  <div class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black bg-opacity-50 animate-fade-in">
    <div class="card w-full max-w-md p-6 animate-slide-up">
      <!-- 헤더 -->
      <div class="mb-6">
        <div class="flex justify-between items-center mb-4">
          <h3 class="text-xl font-bold text-neutral-800">
            {{ isEditing ? '퀘스트 편집' : '새 퀘스트 추가' }}
          </h3>
          <button
            @click="$emit('close')"
            class="p-2 rounded-lg hover:bg-neutral-100 transition-colors"
          >
            ✖️
          </button>
        </div>

        <!-- 탭 버튼들 (편집 모드가 아닐 때만) -->
        <div v-if="!isEditing" class="flex bg-neutral-100 rounded-lg p-1">
          <button
            @click="activeTab = 'manual'"
            :class="[
              'flex-1 py-2 px-3 rounded-md text-sm font-medium transition-all duration-200',
              activeTab === 'manual'
                ? 'bg-white text-neutral-800 shadow-sm'
                : 'text-neutral-600 hover:text-neutral-800'
            ]"
          >
            📝 수동 입력
          </button>
          <button
            @click="activeTab = 'ai'"
            :class="[
              'flex-1 py-2 px-3 rounded-md text-sm font-medium transition-all duration-200',
              activeTab === 'ai'
                ? 'bg-white text-neutral-800 shadow-sm'
                : 'text-neutral-600 hover:text-neutral-800'
            ]"
          >
            🤖 AI 추천
          </button>
        </div>
      </div>

      <!-- 수동 입력 폼 -->
      <form v-if="activeTab === 'manual' || isEditing" @submit.prevent="submitForm" class="space-y-4">
        <!-- 제목 -->
        <div>
          <label class="block text-sm font-medium text-neutral-700 mb-1">
            퀘스트 제목 *
          </label>
          <input
            v-model="form.title"
            type="text"
            required
            placeholder="예: 물 마시기"
            class="w-full px-3 py-2 border border-neutral-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
          >
        </div>

        <!-- 설명 -->
        <div>
          <label class="block text-sm font-medium text-neutral-700 mb-1">
            설명
          </label>
          <textarea
            v-model="form.description"
            placeholder="퀘스트에 대한 간단한 설명을 입력하세요"
            rows="2"
            class="w-full px-3 py-2 border border-neutral-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
          ></textarea>
        </div>

        <!-- 카테고리 -->
        <div>
          <label class="block text-sm font-medium text-neutral-700 mb-1">
            카테고리
          </label>
          <select
            v-model="form.category"
            class="w-full px-3 py-2 border border-neutral-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
          >
            <option value="health">💚 건강</option>
            <option value="fitness">💪 운동</option>
            <option value="learning">📚 학습</option>
            <option value="work">💼 업무</option>
            <option value="hobby">🎨 취미</option>
            <option value="custom">⭐ 기타</option>
          </select>
        </div>

        <!-- 난이도 설정 -->
        <div>
          <label class="block text-sm font-medium text-neutral-700 mb-2">
            컨디션별 목표량
          </label>
          <div class="space-y-3">
            <div>
              <label class="block text-sm text-neutral-600 mb-1">😊 좋음</label>
              <input
                v-model.number="form.difficulty['😊']"
                type="number"
                min="1"
                required
                class="w-full px-3 py-2 border border-neutral-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
              >
            </div>
            <div>
              <label class="block text-sm text-neutral-600 mb-1">😐 보통</label>
              <input
                v-model.number="form.difficulty['😐']"
                type="number"
                min="1"
                required
                class="w-full px-3 py-2 border border-neutral-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
              >
            </div>
            <div>
              <label class="block text-sm text-neutral-600 mb-1">😞 힘듦</label>
              <input
                v-model.number="form.difficulty['😞']"
                type="number"
                min="1"
                required
                class="w-full px-3 py-2 border border-neutral-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
              >
            </div>
          </div>
          <p class="text-xs text-neutral-500 mt-2">
            컨디션이 좋지 않을 때는 목표를 낮춰서 부담을 줄여보세요
          </p>
        </div>

        <!-- 퀴크 추천 (수동 입력에서만 표시) -->
        <div v-if="activeTab === 'manual' || isEditing" class="bg-blue-50 border border-blue-200 rounded-lg p-3">
          <div class="flex items-center gap-2 mb-2">
            <span class="text-blue-600">💡</span>
            <span class="text-sm font-medium text-blue-800">빠른 추천</span>
          </div>
          <div class="flex flex-wrap gap-2">
            <button
              v-for="suggestion in quickSuggestions"
              :key="suggestion.id"
              type="button"
              @click="applySuggestion(suggestion)"
              class="text-xs px-2 py-1 bg-blue-100 text-blue-700 rounded-lg hover:bg-blue-200 transition-colors"
            >
              {{ suggestion.title }}
            </button>
          </div>
        </div>

        <!-- 버튼들 -->
        <div class="flex gap-3 pt-4">
          <button
            type="button"
            @click="$emit('close')"
            class="flex-1 py-2 px-4 border border-neutral-300 text-neutral-700 rounded-lg hover:bg-neutral-50 transition-colors"
          >
            취소
          </button>
          <button
            type="submit"
            :disabled="!form.title.trim()"
            class="flex-1 py-2 px-4 bg-primary-600 text-white rounded-lg hover:bg-primary-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
          >
            {{ isEditing ? '수정' : '추가' }}
          </button>
        </div>
      </form>

      <!-- AI 추천 탭 -->
      <div v-if="activeTab === 'ai'" class="space-y-4">
        <!-- 카테고리 선택 -->
        <div>
          <label class="block text-sm font-medium text-neutral-700 mb-3">
            관심 분야를 선택하세요 (여러 개 선택 가능)
          </label>
          <div class="grid grid-cols-2 gap-3">
            <button
              v-for="category in aiCategories"
              :key="category.value"
              type="button"
              @click="toggleAICategory(category.value)"
              :class="[
                'p-3 rounded-lg border-2 transition-all duration-200 text-center relative',
                selectedAICategories.includes(category.value)
                  ? 'border-purple-500 bg-purple-50 text-purple-700'
                  : 'border-neutral-200 hover:border-neutral-300 text-neutral-700'
              ]"
            >
              <!-- 선택 체크 표시 -->
              <div v-if="selectedAICategories.includes(category.value)" class="absolute top-1 right-1 w-5 h-5 bg-purple-500 rounded-full flex items-center justify-center">
                <span class="text-white text-xs">✓</span>
              </div>
              <div class="text-xl mb-1">{{ category.emoji }}</div>
              <div class="text-xs font-medium">{{ category.label }}</div>
            </button>
          </div>
        </div>

        <!-- 추천 받기 버튼 -->
        <div class="text-center">
          <button
            @click="getAIRecommendations"
            :disabled="selectedAICategories.length === 0 || aiLoading"
            class="btn btn-primary w-full"
          >
            <span v-if="aiLoading" class="animate-spin">⏳</span>
            <span v-else>🤖</span>
            {{ aiLoading ? '추천 받는 중...' : 'AI 추천 받기' }}
          </button>

          <p class="text-xs text-neutral-500 mt-2">
            오늘 {{ aiCallsUsed }}/3 사용됨
          </p>
        </div>

        <!-- AI 추천 결과 -->
        <div v-if="aiRecommendations.length > 0" class="space-y-3">
          <h4 class="text-sm font-medium text-neutral-700">추천 퀘스트</h4>
          <div
            v-for="recommendation in aiRecommendations"
            :key="recommendation.id"
            class="border border-neutral-200 rounded-lg p-3 hover:bg-neutral-50 cursor-pointer transition-colors"
            @click="selectAIRecommendation(recommendation)"
          >
            <div class="flex items-start justify-between">
              <div class="flex-1">
                <h5 class="font-medium text-neutral-800">{{ recommendation.title }}</h5>
                <p class="text-sm text-neutral-600 mt-1">{{ recommendation.description }}</p>
                <div class="flex items-center gap-2 mt-2">
                  <span class="text-xs bg-neutral-100 text-neutral-600 px-2 py-1 rounded">
                    {{ getCategoryLabel(recommendation.category) }}
                  </span>
                  <span class="text-xs text-neutral-500">
                    목표: {{ recommendation.difficulty['😊'] }}
                  </span>
                </div>
              </div>
              <button class="text-purple-600 hover:text-purple-700 text-sm">
                선택
              </button>
            </div>
          </div>
        </div>

        <!-- AI 에러 메시지 -->
        <div v-if="aiError" class="bg-red-50 border border-red-200 rounded-lg p-3">
          <div class="flex items-center gap-2">
            <span class="text-red-600">⚠️</span>
            <span class="text-sm text-red-700">{{ aiError }}</span>
          </div>
        </div>

        <!-- 취소 버튼 -->
        <div class="pt-4">
          <button
            @click="$emit('close')"
            class="w-full btn btn-secondary"
          >
            취소
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'

const props = defineProps({
  quest: {
    type: Object,
    default: null
  }
})

const emit = defineEmits(['save', 'close'])

const isEditing = computed(() => !!props.quest)

// 탭 관리
const activeTab = ref('manual')

// 폼 데이터
const form = ref({
  title: '',
  description: '',
  category: 'custom',
  difficulty: {
    '😊': 3,
    '😐': 2,
    '😞': 1
  }
})

// AI 추천 상태
const selectedAICategories = ref([])
const aiRecommendations = ref([])
const aiLoading = ref(false)
const aiError = ref('')
const aiCallsUsed = ref(0)

// AI 카테고리
const aiCategories = ref([
  { value: 'health', label: '건강', emoji: '💚' },
  { value: 'fitness', label: '운동', emoji: '💪' },
  { value: 'learning', label: '학습', emoji: '📚' },
  { value: 'work', label: '업무', emoji: '💼' },
  { value: 'hobby', label: '취미', emoji: '🎨' },
  { value: 'mindfulness', label: '마음챙김', emoji: '🧘' }
])

// 빠른 추천 (기존 스마트 추천)
const quickSuggestions = ref([
  {
    id: 'water',
    title: '물 8잔 마시기',
    description: '하루 권장 수분 섭취량',
    category: 'health',
    difficulty: { '😊': 8, '😐': 6, '😞': 4 }
  },
  {
    id: 'exercise',
    title: '30분 운동하기',
    description: '적당한 강도의 운동',
    category: 'fitness',
    difficulty: { '😊': 30, '😐': 20, '😞': 10 }
  },
  {
    id: 'reading',
    title: '책 읽기',
    description: '독서로 지식 쌓기',
    category: 'learning',
    difficulty: { '😊': 60, '😐': 30, '😞': 15 }
  },
  {
    id: 'meditation',
    title: '명상하기',
    description: '마음의 평온 찾기',
    category: 'mindfulness',
    difficulty: { '😊': 20, '😐': 15, '😞': 5 }
  }
])

// AI 카테고리 토글
function toggleAICategory(category) {
  const index = selectedAICategories.value.indexOf(category)
  if (index > -1) {
    selectedAICategories.value.splice(index, 1)
  } else {
    selectedAICategories.value.push(category)
  }
}

// AI 추천 요청
async function getAIRecommendations() {
  if (aiCallsUsed.value >= 3) {
    aiError.value = '오늘 추천을 모두 사용했어요. 내일 다시 시도해주세요!'
    return
  }

  aiLoading.value = true
  aiError.value = ''

  try {
    // 모의 AI 추천 (실제 구현에서는 OpenAI API 호출)
    await new Promise(resolve => setTimeout(resolve, 2000)) // 로딩 시뮬레이션

    const mockRecommendations = generateMockRecommendations(selectedAICategories.value)
    aiRecommendations.value = mockRecommendations
    aiCallsUsed.value++

    // localStorage에 사용 횟수 저장
    const today = new Date().toDateString()
    localStorage.setItem(`quest-on-ai-calls-${today}`, aiCallsUsed.value.toString())

  } catch (error) {
    aiError.value = '연결 실패. 다시 시도해주세요'
  } finally {
    aiLoading.value = false
  }
}

// 모의 AI 추천 생성
function generateMockRecommendations(categories) {
  const templates = {
    health: [
      { title: '비타민 D 보충제 챙기기', description: '면역력 강화를 위한 필수 영양소', difficulty: { '😊': 1, '😐': 1, '😞': 1 } },
      { title: '하루 1만보 걷기', description: '건강한 심혈관 시스템 유지', difficulty: { '😊': 10000, '😐': 7000, '😞': 5000 } },
      { title: '금연 실천하기', description: '건강한 폐를 위한 첫걸음', difficulty: { '😊': 1, '😐': 1, '😞': 1 } }
    ],
    fitness: [
      { title: '홈트레이닝 루틴', description: '집에서 하는 전신 운동', difficulty: { '😊': 45, '😐': 30, '😞': 15 } },
      { title: '요가 매트 운동', description: '유연성과 근력을 동시에', difficulty: { '😊': 60, '😐': 30, '😞': 15 } },
      { title: '계단 오르기', description: '엘리베이터 대신 계단 이용', difficulty: { '😊': 20, '😐': 15, '😞': 10 } }
    ],
    learning: [
      { title: '온라인 강의 듣기', description: '새로운 기술 습득하기', difficulty: { '😊': 120, '😐': 60, '😞': 30 } },
      { title: '외국어 단어 암기', description: '어휘력 향상의 기본', difficulty: { '😊': 20, '😐': 10, '😞': 5 } },
      { title: '뉴스 기사 읽기', description: '시사 상식 늘리기', difficulty: { '😊': 3, '😐': 2, '😞': 1 } }
    ],
    work: [
      { title: '업무 일정 정리', description: '효율적인 시간 관리', difficulty: { '😊': 1, '😐': 1, '😞': 1 } },
      { title: '동료와 소통하기', description: '팀워크 향상을 위한 대화', difficulty: { '😊': 3, '😐': 2, '😞': 1 } },
      { title: '자기계발서 읽기', description: '업무 역량 강화', difficulty: { '😊': 60, '😐': 30, '😞': 15 } }
    ],
    hobby: [
      { title: '그림 그리기', description: '창작 활동으로 스트레스 해소', difficulty: { '😊': 60, '😐': 30, '😞': 15 } },
      { title: '음악 감상하기', description: '마음을 편안하게 하는 시간', difficulty: { '😊': 60, '😐': 30, '😞': 15 } },
      { title: '새로운 레시피 도전', description: '요리로 즐거움 찾기', difficulty: { '😊': 1, '😐': 1, '😞': 1 } }
    ],
    mindfulness: [
      { title: '감사 인사 전하기', description: '주변 사람들에게 고마움 표현', difficulty: { '😊': 3, '😐': 2, '😞': 1 } },
      { title: '자연 관찰하기', description: '산책하며 자연의 아름다움 느끼기', difficulty: { '😊': 30, '😐': 20, '😞': 10 } },
      { title: '디지털 디톡스', description: '스마트폰 없는 시간 갖기', difficulty: { '😊': 120, '😐': 60, '😞': 30 } }
    ]
  }

  const recommendations = []
  let id = 1

  categories.forEach(category => {
    if (templates[category]) {
      const categoryTemplates = templates[category]
      const randomTemplate = categoryTemplates[Math.floor(Math.random() * categoryTemplates.length)]

      recommendations.push({
        id: id++,
        ...randomTemplate,
        category
      })
    }
  })

  return recommendations.slice(0, 3) // 최대 3개 추천
}

// AI 추천 선택
function selectAIRecommendation(recommendation) {
  // 수동 입력 폼에 데이터 설정
  form.value.title = recommendation.title
  form.value.description = recommendation.description
  form.value.category = recommendation.category
  form.value.difficulty = { ...recommendation.difficulty }

  // 수동 입력 탭으로 전환
  activeTab.value = 'manual'
}

// 빠른 추천 적용 (기존 함수)
function applySuggestion(suggestion) {
  form.value.title = suggestion.title
  form.value.description = suggestion.description
  form.value.category = suggestion.category
  form.value.difficulty = { ...suggestion.difficulty }
}

// 카테고리 레이블 가져오기
function getCategoryLabel(category) {
  const labels = {
    health: '건강',
    fitness: '운동',
    learning: '학습',
    work: '업무',
    hobby: '취미',
    mindfulness: '마음챙김',
    custom: '기타'
  }
  return labels[category] || category
}

// 폼 제출
function submitForm() {
  if (!form.value.title.trim()) return
  
  emit('save', {
    title: form.value.title.trim(),
    description: form.value.description.trim(),
    category: form.value.category,
    difficulty: { ...form.value.difficulty }
  })
}

// 편집 모드일 때 기존 데이터 로드
onMounted(() => {
  if (props.quest) {
    form.value = {
      title: props.quest.title,
      description: props.quest.description,
      category: props.quest.category,
      difficulty: { ...props.quest.difficulty }
    }
  }

  // AI 호출 횟수 로드
  const today = new Date().toDateString()
  const savedCalls = localStorage.getItem(`quest-on-ai-calls-${today}`)
  aiCallsUsed.value = savedCalls ? parseInt(savedCalls, 10) : 0
})
</script>