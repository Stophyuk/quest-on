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

const showOnboarding = ref(false)

function handleOnboardingComplete(data) {
  showOnboarding.value = false

  // 온보딩 완료 후 처리 (선택사항)
  console.log('온보딩 완료:', data)
}

function checkOnboardingStatus() {
  const isCompleted = localStorage.getItem('quest-on-onboarding-completed')
  if (!isCompleted) {
    showOnboarding.value = true
  }
}

onMounted(() => {
  checkOnboardingStatus()
})
</script>
