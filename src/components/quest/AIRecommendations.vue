<template>
  <div class="card p-4">
    <!-- 헤더 -->
    <div class="flex items-center justify-between mb-4">
      <h3 class="text-lg font-semibold text-neutral-800 flex items-center gap-2">
        <span class="text-xl">🤖</span>
        AI 추천
      </h3>
      <button
        @click="refreshRecommendations"
        :disabled="aiStore.isAnalyzing"
        class="p-2 rounded-lg bg-primary-100 text-primary-600 hover:bg-primary-200 transition-colors disabled:opacity-50"
        title="추천 새로고침"
      >
        <span class="text-sm" :class="{ 'animate-spin': aiStore.isAnalyzing }">🔄</span>
      </button>
    </div>

    <!-- 로딩 상태 -->
    <div v-if="aiStore.isAnalyzing" class="text-center py-8">
      <div class="text-4xl mb-2 animate-pulse">🧠</div>
      <p class="text-neutral-600">AI가 분석 중입니다...</p>
    </div>

    <!-- 추천 결과 -->
    <div v-else-if="recommendations.length > 0" class="space-y-4">
      <div
        v-for="(rec, index) in recommendations"
        :key="index"
        class="border border-gray-200 rounded-lg p-3 hover:shadow-md transition-shadow"
      >
        <!-- 추천 제목과 이유 -->
        <div class="mb-3">
          <h4 class="font-medium text-neutral-800 mb-1">{{ rec.title }}</h4>
          <p class="text-sm text-neutral-600">{{ rec.reason }}</p>
        </div>

        <!-- 추천 퀘스트들 -->
        <div class="space-y-2">
          <div
            v-for="quest in rec.quests"
            :key="quest.id"
            class="flex items-center justify-between p-2 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors"
          >
            <div class="flex-1">
              <div class="flex items-center gap-2 mb-1">
                <span class="font-medium text-sm text-neutral-800">{{ quest.title }}</span>
                <div class="flex gap-1">
                  <span class="text-xs bg-primary-100 text-primary-700 px-2 py-0.5 rounded-full">
                    {{ aiStore.getCategoryLabel(getQuestCategory(quest)) }}
                  </span>
                  <span class="text-xs bg-gray-200 text-gray-600 px-2 py-0.5 rounded-full">
                    {{ quest.timeRequired }}분
                  </span>
                </div>
              </div>
              <p class="text-xs text-neutral-600">{{ quest.description }}</p>
              
              <!-- 혜택 태그들 -->
              <div class="flex flex-wrap gap-1 mt-1">
                <span
                  v-for="benefit in quest.benefits?.slice(0, 2)"
                  :key="benefit"
                  class="text-xs bg-green-100 text-green-700 px-1.5 py-0.5 rounded"
                >
                  {{ benefit }}
                </span>
              </div>
            </div>
            
            <button
              @click="addRecommendedQuest(quest)"
              class="ml-3 px-3 py-1 bg-primary-600 text-white text-xs rounded-lg hover:bg-primary-700 transition-colors"
            >
              추가
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- 빈 상태 -->
    <div v-else class="text-center py-8">
      <div class="text-4xl mb-2">💡</div>
      <p class="text-neutral-600 mb-2">더 많은 퀘스트를 완료하면</p>
      <p class="text-neutral-600">개인 맞춤 추천을 받을 수 있어요!</p>
    </div>

    <!-- 추천 통계 -->
    <div v-if="aiStore.lastAnalysis" class="mt-4 pt-4 border-t border-gray-200">
      <div class="text-xs text-neutral-500 mb-2">마지막 분석: {{ formatDate(aiStore.lastAnalysis.timestamp) }}</div>
      <div class="grid grid-cols-2 gap-2 text-xs">
        <div class="bg-blue-50 p-2 rounded">
          <div class="text-blue-600 font-medium">선호 카테고리</div>
          <div class="text-blue-800">
            {{ getBestCategory() }}
          </div>
        </div>
        <div class="bg-green-50 p-2 rounded">
          <div class="text-green-600 font-medium">최근 완료율</div>
          <div class="text-green-800">
            {{ Math.round(aiStore.lastAnalysis.completionTrends?.recentCompletionRate || 0) }}%
          </div>
        </div>
      </div>
    </div>

    <!-- 성공 토스트 -->
    <div
      v-if="showSuccess"
      class="fixed bottom-24 left-1/2 transform -translate-x-1/2 bg-green-600 text-white px-4 py-2 rounded-lg shadow-lg z-50 animate-slide-up"
    >
      퀘스트가 추가되었습니다! ✨
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useAIStore } from '../../stores/ai'
import { useQuestStore } from '../../stores/quest'
import { storageManager } from '../../stores/storage'

const aiStore = useAIStore()
const questStore = useQuestStore()
const showSuccess = ref(false)

// 추천 결과
const recommendations = computed(() => {
  return aiStore.lastAnalysis?.recommendations || []
})

// 추천 새로고침
function refreshRecommendations() {
  try {
    const questHistory = questStore.quests || []
    const moodHistory = storageManager.loadMoodHistory() || []
    
    if (questHistory.length === 0 && moodHistory.length === 0) {
      console.log('No data available for analysis yet')
      return
    }
    
    aiStore.analyzeUserPatterns(questHistory, moodHistory)
  } catch (error) {
    console.error('Failed to refresh recommendations:', error)
  }
}

// 추천 퀘스트 추가
function addRecommendedQuest(questTemplate) {
  const newQuest = {
    title: questTemplate.title,
    description: questTemplate.description,
    difficulty: questTemplate.difficulty,
    category: getQuestCategory(questTemplate)
  }
  
  questStore.addQuest(newQuest)
  
  // 성공 메시지 표시
  showSuccess.value = true
  setTimeout(() => {
    showSuccess.value = false
  }, 3000)
}

// 퀘스트 카테고리 찾기
function getQuestCategory(quest) {
  for (const [category, quests] of Object.entries(aiStore.questDatabase)) {
    if (quests.some(q => q.id === quest.id)) {
      return category
    }
  }
  return 'custom'
}

// 최고 성과 카테고리
function getBestCategory() {
  if (!aiStore.lastAnalysis?.preferredCategories?.length) return '분석 중...'
  const best = aiStore.lastAnalysis.preferredCategories[0]
  return `${aiStore.getCategoryLabel(best.category)} (${Math.round(best.rate)}%)`
}

// 날짜 포맷팅
function formatDate(timestamp) {
  const date = new Date(timestamp)
  const now = new Date()
  const diffMs = now - date
  const diffMins = Math.floor(diffMs / 60000)
  
  if (diffMins < 1) return '방금 전'
  if (diffMins < 60) return `${diffMins}분 전`
  if (diffMins < 1440) return `${Math.floor(diffMins / 60)}시간 전`
  return `${Math.floor(diffMins / 1440)}일 전`
}

// 컴포넌트 마운트 시 초기 분석
onMounted(() => {
  // 기존 분석이 없거나 오래된 경우 새로 분석
  const lastAnalysis = aiStore.lastAnalysis
  if (!lastAnalysis || isAnalysisStale(lastAnalysis.timestamp)) {
    refreshRecommendations()
  }
})

// 분석이 오래되었는지 확인 (24시간 이상)
function isAnalysisStale(timestamp) {
  const now = new Date()
  const analysisDate = new Date(timestamp)
  const diffHours = (now - analysisDate) / (1000 * 60 * 60)
  return diffHours > 24
}
</script>