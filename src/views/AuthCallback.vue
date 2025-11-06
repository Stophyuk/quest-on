<template>
  <div class="min-h-screen bg-gradient-to-br from-purple-50 via-pink-50 to-blue-50 flex items-center justify-center px-4">
    <div class="text-center">
      <div class="animate-spin w-16 h-16 border-4 border-purple-200 border-t-purple-600 rounded-full mx-auto mb-4"></div>
      <p class="text-gray-600">로그인 중입니다...</p>
    </div>
  </div>
</template>

<script setup>
import { onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const authStore = useAuthStore()

onMounted(async () => {
  try {
    // OAuth 콜백에서 세션 확인
    await authStore.checkSession()

    if (authStore.isAuthenticated) {
      // 로그인 성공 - 홈으로 이동
      router.push('/')
    } else {
      // 로그인 실패 - 로그인 페이지로
      router.push('/login')
    }
  } catch (error) {
    console.error('Auth callback error:', error)
    router.push('/login')
  }
})
</script>
