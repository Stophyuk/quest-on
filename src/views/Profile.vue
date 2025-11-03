<template>
  <div class="min-h-screen px-4 pt-6" style="padding-bottom: 90px;">
    <!-- 헤더 -->
    <header class="flex items-center justify-between mb-6">
      <h1 class="text-2xl font-pixel text-purple font-bold">통계</h1>
      <router-link
        to="/"
        class="text-sm text-purple-600 hover:text-purple-700 font-medium"
      >
        ← 홈으로
      </router-link>
    </header>

    <!-- 주간 리포트 -->
    <div class="card p-6 mb-6">
      <h3 class="text-lg font-bold text-gray-900 mb-4 flex items-center gap-2">
        <span>📊</span>
        주간 리포트
      </h3>

      <div class="space-y-4">
        <!-- 총 완료 -->
        <div class="bg-gradient-to-br from-blue-50 to-purple-50 rounded-lg p-4 border border-purple-100">
          <div class="flex items-center justify-between">
            <span class="text-sm text-purple-600 font-medium">총 완료</span>
            <span class="text-2xl font-bold text-purple-900">{{ weeklyStats.totalCompleted }}</span>
          </div>
          <p class="text-xs text-purple-600 mt-1">최근 7일간</p>
        </div>

        <!-- 난이도별 통계 -->
        <div class="grid grid-cols-3 gap-3">
          <div class="bg-green-50 rounded-lg p-3 text-center border border-green-100">
            <div class="text-2xl mb-1">😊</div>
            <div class="text-xl font-bold text-green-900">{{ weeklyStats.byDifficulty.easy }}</div>
            <div class="text-xs text-green-600">쉬움</div>
          </div>
          <div class="bg-blue-50 rounded-lg p-3 text-center border border-blue-100">
            <div class="text-2xl mb-1">😐</div>
            <div class="text-xl font-bold text-blue-900">{{ weeklyStats.byDifficulty.normal }}</div>
            <div class="text-xs text-blue-600">보통</div>
          </div>
          <div class="bg-red-50 rounded-lg p-3 text-center border border-red-100">
            <div class="text-2xl mb-1">😞</div>
            <div class="text-xl font-bold text-red-900">{{ weeklyStats.byDifficulty.hard }}</div>
            <div class="text-xs text-red-600">어려움</div>
          </div>
        </div>

        <!-- 획득 경험치 -->
        <div class="bg-gradient-to-br from-yellow-50 to-orange-50 rounded-lg p-4 border border-orange-100">
          <div class="flex items-center justify-between">
            <span class="text-sm text-orange-600 font-medium">획득 경험치</span>
            <span class="text-2xl font-bold text-orange-900">{{ weeklyStats.totalXP }} XP</span>
          </div>
          <p class="text-xs text-orange-600 mt-1">최근 7일간</p>
        </div>
      </div>
    </div>

    <!-- 전체 통계 -->
    <div class="card p-6 mb-6">
      <h3 class="text-lg font-bold text-gray-900 mb-4 flex items-center gap-2">
        <span>🏆</span>
        전체 기록
      </h3>

      <div class="grid grid-cols-2 gap-4">
        <div class="bg-gray-50 rounded-lg p-4 text-center border border-gray-200">
          <div class="text-3xl mb-2">🎯</div>
          <div class="text-2xl font-bold text-gray-900">{{ totalCompleted }}</div>
          <div class="text-xs text-gray-600 mt-1">총 완료 퀘스트</div>
        </div>

        <div class="bg-gray-50 rounded-lg p-4 text-center border border-gray-200">
          <div class="text-3xl mb-2">⭐</div>
          <div class="text-2xl font-bold text-gray-900">{{ currentLevel }}</div>
          <div class="text-xs text-gray-600 mt-1">현재 레벨</div>
        </div>
      </div>
    </div>

    <!-- 데이터 관리 -->
    <div class="card p-6">
      <h3 class="text-lg font-bold text-gray-900 mb-4 flex items-center gap-2">
        <span>⚙️</span>
        데이터 관리
      </h3>

      <div class="space-y-3">
        <button
          @click="exportData"
          class="w-full py-3 px-4 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors font-medium"
        >
          📤 데이터 내보내기
        </button>

        <button
          @click="importData"
          class="w-full py-3 px-4 bg-green-500 text-white rounded-lg hover:bg-green-600 transition-colors font-medium"
        >
          📥 데이터 가져오기
        </button>

        <button
          @click="resetData"
          class="w-full py-3 px-4 bg-red-500 text-white rounded-lg hover:bg-red-600 transition-colors font-medium"
        >
          🗑️ 모든 데이터 초기화
        </button>
      </div>

      <p class="text-xs text-gray-500 mt-4 text-center">
        저장 용량: {{ storageInfo.used }} / {{ storageInfo.total }}
      </p>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useQuestStore } from '@/stores/quest'

const questStore = useQuestStore()

// 주간 통계
const weeklyStats = computed(() => questStore.getWeeklyStats())

// 전체 기록 (computed로 반응성 보장)
const totalCompleted = computed(() => questStore.totalCompleted)
const currentLevel = computed(() => questStore.level)

// 저장 용량 정보
const storageInfo = computed(() => questStore.getStorageInfo())

// 데이터 내보내기
function exportData() {
  const data = questStore.exportData()
  const blob = new Blob([data], { type: 'application/json' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = `quest-on-backup-${new Date().toISOString().split('T')[0]}.json`
  a.click()
  URL.revokeObjectURL(url)
}

// 데이터 가져오기
function importData() {
  const input = document.createElement('input')
  input.type = 'file'
  input.accept = 'application/json'

  input.onchange = (e) => {
    const file = e.target.files[0]
    if (!file) return

    const reader = new FileReader()
    reader.onload = (event) => {
      try {
        const success = questStore.importData(event.target.result)
        if (success) {
          alert('✅ 데이터를 성공적으로 가져왔습니다!')
          location.reload()
        } else {
          alert('❌ 데이터 가져오기에 실패했습니다.')
        }
      } catch (error) {
        alert('❌ 잘못된 파일 형식입니다.')
      }
    }
    reader.readAsText(file)
  }

  input.click()
}

// 데이터 초기화
function resetData() {
  if (confirm('⚠️ 정말로 모든 데이터를 초기화하시겠습니까?\n이 작업은 되돌릴 수 없습니다.')) {
    if (confirm('⚠️ 마지막 확인: 정말로 삭제하시겠습니까?')) {
      localStorage.clear()
      alert('✅ 모든 데이터가 초기화되었습니다.')
      location.reload()
    }
  }
}

// onMounted에서 loadData()를 호출하지 않음
// store는 이미 초기화 시에 데이터를 로드하고 watch를 통해 자동 저장됨
</script>
