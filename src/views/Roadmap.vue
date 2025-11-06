<template>
  <div class="min-h-screen px-4 pt-6" style="padding-bottom: 90px;">
    <!-- 헤더 -->
    <header class="flex items-center justify-between mb-6">
      <h1 class="text-2xl font-pixel text-purple font-bold">목표 로드맵</h1>
      <router-link
        to="/"
        class="text-sm text-purple-600 hover:text-purple-700 font-medium"
      >
        ← 홈으로
      </router-link>
    </header>

    <!-- 목표 트리가 없는 경우 -->
    <div v-if="!goalTree || goalTree.length === 0" class="text-center py-12">
      <div class="text-6xl mb-4">🎯</div>
      <h3 class="text-xl font-bold text-gray-900 mb-3">아직 목표 로드맵이 없습니다</h3>
      <p class="text-gray-600 mb-6">비전 설문을 완료하면 AI가 생성한<br>1년 로드맵을 볼 수 있습니다</p>
      <router-link
        to="/"
        class="inline-block px-6 py-3 bg-gradient-to-r from-purple-500 to-indigo-600 text-white rounded-xl font-medium hover:shadow-lg transition-all"
      >
        홈으로 돌아가기
      </router-link>
    </div>

    <!-- 목표 트리 표시 -->
    <div v-else class="space-y-6">
      <div v-for="(yearlyGoal, yIndex) in goalTree" :key="yearlyGoal.id || yIndex" class="space-y-4">
        <!-- 연간 목표 -->
        <div class="bg-gradient-to-r from-purple-500 to-indigo-600 rounded-2xl p-5 text-white shadow-lg">
          <div class="flex items-start gap-3">
            <div class="text-4xl">🎯</div>
            <div class="flex-1">
              <h3 class="text-lg font-bold mb-2">{{ yearlyGoal.title }}</h3>
              <p class="text-sm opacity-90">{{ yearlyGoal.description }}</p>
            </div>
          </div>
        </div>

        <!-- 분기별 아코디언 -->
        <div v-if="yearlyGoal.quarters && yearlyGoal.quarters.length > 0" class="ml-8 space-y-3">
          <div
            v-for="(quarter, qIndex) in yearlyGoal.quarters"
            :key="quarter.id || qIndex"
            class="border-2 border-blue-200 rounded-xl overflow-hidden bg-white"
          >
            <!-- 분기 헤더 (클릭 가능) -->
            <button
              @click="toggleQuarter(`${yIndex}-${qIndex}`)"
              class="w-full p-4 bg-blue-50 hover:bg-blue-100 transition-colors text-left flex items-center justify-between"
            >
              <div class="flex items-center gap-3">
                <span class="text-2xl">📅</span>
                <div>
                  <h4 class="font-semibold text-gray-900">{{ quarter.title }}</h4>
                  <p v-if="quarter.months" class="text-xs text-gray-600">{{ quarter.months.length }}개월 계획</p>
                </div>
              </div>
              <svg
                class="w-5 h-5 text-gray-600 transition-transform"
                :class="{ 'transform rotate-180': expandedQuarters.has(`${yIndex}-${qIndex}`) }"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
              </svg>
            </button>

            <!-- 분기 내용 (확장되면 표시) -->
            <div v-if="expandedQuarters.has(`${yIndex}-${qIndex}`)" class="p-4 space-y-3 bg-blue-25">
              <div
                v-for="(month, mIndex) in quarter.months"
                :key="month.id || mIndex"
                class="border-l-4 border-green-400 pl-4 bg-green-50 rounded-r-lg p-3"
              >
                <div class="flex items-start gap-2 mb-2">
                  <span class="text-xl">📆</span>
                  <h5 class="font-medium text-gray-900">{{ month.title }}</h5>
                </div>

                <!-- 주간 목표 -->
                <div v-if="month.weeks && month.weeks.length > 0" class="ml-6 space-y-2">
                  <div
                    v-for="(week, wIndex) in month.weeks"
                    :key="week.id || wIndex"
                    class="bg-white rounded-lg p-3 border-l-4 border-orange-400"
                  >
                    <div class="flex items-start gap-2 mb-2">
                      <span class="text-lg">⭐</span>
                      <h6 class="text-sm font-medium text-gray-800">{{ week.title }}</h6>
                    </div>

                    <!-- 실행 항목 -->
                    <div v-if="week.suggestedQuests && week.suggestedQuests.length > 0" class="ml-6">
                      <p class="text-xs font-semibold text-gray-600 mb-1">실행 항목:</p>
                      <ul class="space-y-0.5">
                        <li
                          v-for="(quest, questIndex) in week.suggestedQuests"
                          :key="questIndex"
                          class="text-xs text-gray-700 flex items-start gap-1"
                        >
                          <span class="text-orange-500 text-sm">•</span>
                          <span>{{ quest }}</span>
                        </li>
                      </ul>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useQuestStore } from '@/stores/quest'

const questStore = useQuestStore()

// 저장된 목표 트리
const goalTree = computed(() => questStore.goalTree)

// 확장된 분기 추적
const expandedQuarters = ref(new Set(['0-0'])) // 첫 번째 분기는 기본 확장

function toggleQuarter(id) {
  if (expandedQuarters.value.has(id)) {
    expandedQuarters.value.delete(id)
  } else {
    expandedQuarters.value.add(id)
  }
  // Set을 새로 만들어서 반응성 트리거
  expandedQuarters.value = new Set(expandedQuarters.value)
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
</style>
