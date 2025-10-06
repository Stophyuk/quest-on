<template>
  <div id="app" class="min-h-screen bg-gradient-calm safe-area-top">
    <router-view />
    <BottomNavigation />
    <FloatingAddButton />

    <!-- 온보딩 모달 -->
    <OnboardingModal
      v-if="showOnboarding"
      @complete="handleOnboardingComplete"
    />
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import BottomNavigation from './components/common/BottomNavigation.vue'
import OnboardingModal from './components/OnboardingModal.vue'
import FloatingAddButton from './components/common/FloatingAddButton.vue'
import { useQuestStore } from './stores/quest'
import { useQuestMetaStore } from './stores/questMeta'
import { storage, migrateToCapacitorPreferences } from './utils/storage'

const questStore = useQuestStore()
const questMetaStore = useQuestMetaStore()
const showOnboarding = ref(false)

function handleOnboardingComplete(data) {
  showOnboarding.value = false

  // 온보딩 완료 후 처리 (선택사항)
  console.log('온보딩 완료:', data)
}

async function checkOnboardingStatus() {
  const isCompleted = await storage.get('quest-on-onboarding-completed')
  if (!isCompleted) {
    showOnboarding.value = true
  }
}

// 반복 퀘스트 자동 생성 (앱 시작 시)
function initRecurringQuests() {
  try {
    questStore.generateRecurringQuests(questMetaStore)
  } catch (error) {
    console.error('[App] Failed to generate recurring quests:', error)
  }
}

// 앱 초기화
async function initApp() {
  // 1. localStorage → Capacitor Preferences 마이그레이션 (네이티브에서만)
  await migrateToCapacitorPreferences()

  // 2. 온보딩 상태 확인
  await checkOnboardingStatus()

  // 3. 반복 퀘스트 자동 생성
  initRecurringQuests()
}

onMounted(() => {
  initApp()
})
</script>
