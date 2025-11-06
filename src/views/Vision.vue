<template>
  <div class="min-h-screen px-4 pt-6" style="padding-bottom: 90px;">
    <!-- 헤더 -->
    <header class="flex items-center justify-between mb-6">
      <h1 class="text-2xl font-pixel text-purple font-bold">나의 비전</h1>
      <router-link
        to="/"
        class="text-sm text-purple-600 hover:text-purple-700 font-medium"
      >
        ← 홈으로
      </router-link>
    </header>

    <!-- 비전 노트가 없는 경우 -->
    <div v-if="!visionNote" class="text-center py-12">
      <div class="text-6xl mb-4">🌟</div>
      <h3 class="text-xl font-bold text-gray-900 mb-3">아직 비전 노트가 없습니다</h3>
      <p class="text-gray-600 mb-6">비전 설문을 완료하면 AI가 작성한<br>당신만의 비전 노트를 볼 수 있습니다</p>
      <router-link
        to="/"
        class="inline-block px-6 py-3 bg-gradient-to-r from-purple-500 to-indigo-600 text-white rounded-xl font-medium hover:shadow-lg transition-all"
      >
        홈으로 돌아가기
      </router-link>
    </div>

    <!-- 비전 노트 표시 -->
    <div v-else class="space-y-4">
      <!-- 1. 당신에 대한 이해 -->
      <div class="card bg-gradient-to-br from-blue-50 to-indigo-50 border-2 border-blue-200">
        <h3 class="text-lg font-bold text-blue-900 mb-3 flex items-center gap-2">
          <span>🔍</span> 당신에 대한 이해
        </h3>
        <div class="space-y-3">
          <div class="bg-white rounded-lg p-3">
            <p class="text-xs font-semibold text-blue-700 mb-1">현재 위치</p>
            <p class="text-sm text-gray-800 leading-relaxed">{{ visionNote.understanding?.currentPosition }}</p>
          </div>
          <div class="bg-white rounded-lg p-3">
            <p class="text-xs font-semibold text-blue-700 mb-1">내면의 갈등</p>
            <p class="text-sm text-gray-800 leading-relaxed">{{ visionNote.understanding?.innerConflict }}</p>
          </div>
        </div>
      </div>

      <!-- 2. 당신만의 성장 방정식 -->
      <div class="card bg-gradient-to-br from-purple-50 to-pink-50 border-2 border-purple-200">
        <h3 class="text-lg font-bold text-purple-900 mb-3 flex items-center gap-2">
          <span>💫</span> 당신만의 성장 방정식
        </h3>
        <div class="space-y-3">
          <div class="bg-white rounded-lg p-3">
            <p class="text-xs font-semibold text-purple-700 mb-1">가치관이 말하는 것</p>
            <p class="text-sm text-gray-800 leading-relaxed">{{ visionNote.growthFormula?.valueAnalysis }}</p>
          </div>
          <div class="bg-white rounded-lg p-3">
            <p class="text-xs font-semibold text-purple-700 mb-1">5년 비전의 핵심</p>
            <p class="text-sm text-gray-800 leading-relaxed">{{ visionNote.growthFormula?.visionCore }}</p>
          </div>
        </div>
      </div>

      <!-- 3. 1년 후의 변화 -->
      <div class="card bg-gradient-to-br from-green-50 to-emerald-50 border-2 border-green-200">
        <h3 class="text-lg font-bold text-green-900 mb-3 flex items-center gap-2">
          <span>🎯</span> 1년 후, 가장 의미 있는 변화
        </h3>
        <div class="space-y-3">
          <div class="bg-white rounded-lg p-3">
            <p class="text-sm text-gray-800 leading-relaxed mb-3">{{ visionNote.oneYearChange?.overview }}</p>
          </div>

          <div class="bg-white rounded-lg p-3">
            <p class="text-xs font-semibold text-green-700 mb-2">핵심 마일스톤</p>
            <ul class="space-y-1">
              <li v-for="(milestone, index) in visionNote.oneYearChange?.milestones" :key="index" class="text-sm text-gray-800 flex items-start gap-2">
                <span class="text-green-600 font-bold">✓</span>
                <span>{{ milestone }}</span>
              </li>
            </ul>
          </div>

          <div class="bg-white rounded-lg p-3">
            <p class="text-xs font-semibold text-orange-700 mb-2">예상되는 도전</p>
            <ul class="space-y-1">
              <li v-for="(challenge, index) in visionNote.oneYearChange?.challenges" :key="index" class="text-sm text-gray-800 flex items-start gap-2">
                <span class="text-orange-600 font-bold">⚠</span>
                <span>{{ challenge }}</span>
              </li>
            </ul>
          </div>

          <div class="bg-white rounded-lg p-3">
            <p class="text-xs font-semibold text-blue-700 mb-2">돌파 전략</p>
            <ul class="space-y-1">
              <li v-for="(strategy, index) in visionNote.oneYearChange?.strategies" :key="index" class="text-sm text-gray-800 flex items-start gap-2">
                <span class="text-blue-600 font-bold">→</span>
                <span>{{ strategy }}</span>
              </li>
            </ul>
          </div>
        </div>
      </div>

      <!-- 4. 실행 전략 -->
      <div class="card bg-gradient-to-br from-orange-50 to-yellow-50 border-2 border-orange-200">
        <h3 class="text-lg font-bold text-orange-900 mb-3 flex items-center gap-2">
          <span>⚡</span> 당신에게 맞는 실행 전략
        </h3>
        <div class="space-y-3">
          <div class="bg-white rounded-lg p-3">
            <p class="text-xs font-semibold text-orange-700 mb-1">시간 설계</p>
            <p class="text-sm text-gray-800 leading-relaxed">{{ visionNote.actionStrategy?.timeDesign }}</p>
          </div>
          <div class="bg-white rounded-lg p-3">
            <p class="text-xs font-semibold text-orange-700 mb-1">학습 최적화</p>
            <p class="text-sm text-gray-800 leading-relaxed">{{ visionNote.actionStrategy?.learningOptimization }}</p>
          </div>
          <div class="bg-white rounded-lg p-3">
            <p class="text-xs font-semibold text-orange-700 mb-1">동기 유지 시스템</p>
            <p class="text-sm text-gray-800 leading-relaxed">{{ visionNote.actionStrategy?.motivationSystem }}</p>
          </div>
        </div>
      </div>

      <!-- 5. 코치의 통찰 -->
      <div class="card bg-gradient-to-br from-pink-50 to-rose-50 border-2 border-pink-200">
        <h3 class="text-lg font-bold text-pink-900 mb-3 flex items-center gap-2">
          <span>💬</span> 코치의 통찰
        </h3>
        <div class="bg-white rounded-lg p-4">
          <p class="text-sm text-gray-800 leading-relaxed italic">{{ visionNote.coachingInsight?.message }}</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useQuestStore } from '@/stores/quest'

const questStore = useQuestStore()

// 저장된 비전 노트
const visionNote = computed(() => questStore.visionNote)
</script>
