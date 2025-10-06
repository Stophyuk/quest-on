<template>
  <div class="card">
    <div class="text-center mb-4">
      <span class="text-2xl mb-2 block">💾</span>
      <h3 class="text-lg font-semibold text-neutral-800 mb-1">데이터 관리</h3>
      <p class="text-xs text-neutral-500">앱 데이터를 백업하거나 복원하세요</p>
    </div>

    <!-- 간소화된 액션 버튼들 -->
    <div class="space-y-3">
      <div class="flex gap-3">
        <button
          @click="exportData"
          class="flex-1 btn btn-secondary text-sm"
        >
          📤 백업
        </button>

        <label class="flex-1 btn btn-secondary text-sm cursor-pointer">
          📥 복원
          <input
            type="file"
            accept=".json"
            @change="importData"
            class="hidden"
          >
        </label>
      </div>

      <button
        @click="showDeleteConfirm = true"
        class="w-full py-2 px-3 text-red-600 text-sm hover:bg-red-50 rounded-lg transition-colors border border-red-200"
      >
        🗑️ 모든 데이터 삭제
      </button>
    </div>

    <!-- 간소화된 삭제 확인 모달 -->
    <div v-if="showDeleteConfirm" class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black bg-opacity-50">
      <div class="bg-white rounded-xl p-6 w-full max-w-sm shadow-2xl">
        <div class="text-center mb-4">
          <span class="text-4xl mb-2 block">⚠️</span>
          <h3 class="text-lg font-bold text-neutral-800 mb-2">정말 삭제하시겠어요?</h3>
          <p class="text-sm text-neutral-600">
            모든 퀘스트와 기록이 사라져요.
          </p>
        </div>

        <div class="flex gap-3">
          <button
            @click="showDeleteConfirm = false"
            class="flex-1 btn btn-secondary text-sm"
          >
            취소
          </button>
          <button
            @click="deleteAllData"
            class="flex-1 py-2 px-3 bg-red-500 text-white rounded-lg hover:bg-red-600 transition-colors text-sm font-medium"
          >
            삭제
          </button>
        </div>
      </div>
    </div>

    <!-- 개선된 알림 토스트 -->
    <div
      v-if="showToast"
      class="fixed bottom-28 left-1/2 transform -translate-x-1/2 bg-gray-900 text-white px-6 py-3 rounded-xl shadow-2xl z-50 max-w-sm mx-4"
      style="animation: slideUp 0.3s ease-out, fadeOut 0.3s ease-in 2.7s"
    >
      <div class="flex items-center gap-2">
        <span class="text-green-400">✓</span>
        <span class="text-sm font-medium">{{ toastMessage }}</span>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useQuestStore } from '../../stores/quest'

const questStore = useQuestStore()
const storageInfo = ref(null)
const showDeleteConfirm = ref(false)
const showToast = ref(false)
const toastMessage = ref('')

// 스토리지 정보 가져오기
function updateStorageInfo() {
  storageInfo.value = questStore.getStorageInfo()
}

// 데이터 내보내기
function exportData() {
  try {
    const dataString = questStore.exportData()
    if (dataString) {
      const blob = new Blob([dataString], { type: 'application/json' })
      const url = URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      a.download = `quest-on-backup-${new Date().toISOString().split('T')[0]}.json`
      document.body.appendChild(a)
      a.click()
      document.body.removeChild(a)
      URL.revokeObjectURL(url)
      
      showToastMessage('데이터가 성공적으로 내보내졌습니다')
    }
  } catch (error) {
    console.error('Export failed:', error)
    showToastMessage('내보내기에 실패했습니다')
  }
}

// 데이터 가져오기
function importData(event) {
  const file = event.target.files[0]
  if (!file) return
  
  const reader = new FileReader()
  reader.onload = (e) => {
    try {
      const success = questStore.importData(e.target.result)
      if (success) {
        showToastMessage('데이터가 성공적으로 복원되었습니다')
        updateStorageInfo()
      } else {
        showToastMessage('잘못된 파일 형식입니다')
      }
    } catch (error) {
      console.error('Import failed:', error)
      showToastMessage('가져오기에 실패했습니다')
    }
  }
  reader.readAsText(file)
  
  // 파일 입력 초기화
  event.target.value = ''
}

// 일일 진행도 초기화
function resetDailyProgress() {
  if (confirm('오늘의 퀘스트 진행도를 초기화하시겠습니까?')) {
    questStore.resetDailyQuests()
    showToastMessage('일일 진행도가 초기화되었습니다')
  }
}

// 모든 데이터 삭제
function deleteAllData() {
  try {
    questStore.getStorageInfo() // localStorage 접근 확인
    localStorage.clear()
    
    // 페이지 새로고침으로 초기 상태로 돌아가기
    window.location.reload()
  } catch (error) {
    console.error('Delete failed:', error)
    showToastMessage('삭제에 실패했습니다')
  }
  showDeleteConfirm.value = false
}

// 토스트 메시지 표시
function showToastMessage(message) {
  toastMessage.value = message
  showToast.value = true
  
  setTimeout(() => {
    showToast.value = false
  }, 3000)
}

// 컴포넌트 마운트 시 스토리지 정보 업데이트
onMounted(() => {
  updateStorageInfo()
})
</script>