<template>
  <div class="min-h-screen bg-gradient-to-br from-purple-50 via-pink-50 to-blue-50 flex items-center justify-center px-4">
    <div class="max-w-md w-full">
      <!-- 로고 -->
      <div class="text-center mb-8">
        <h1 class="text-4xl font-black text-transparent bg-clip-text bg-gradient-to-r from-purple-600 to-pink-600 mb-2">
          QUEST ON
        </h1>
        <p class="text-gray-600">컨디션 기반 퀘스트 관리</p>
      </div>

      <!-- 로그인 폼 -->
      <div class="bg-white rounded-2xl shadow-xl p-8">
        <h2 class="text-2xl font-bold text-gray-800 mb-6">로그인</h2>

        <!-- 에러 메시지 -->
        <div v-if="errorMessage" class="mb-4 p-3 bg-red-50 border border-red-200 rounded-lg">
          <p class="text-sm text-red-600">{{ errorMessage }}</p>
        </div>

        <!-- 이메일 -->
        <div class="mb-4">
          <label class="block text-sm font-medium text-gray-700 mb-2">이메일</label>
          <input
            v-model="email"
            type="email"
            placeholder="example@email.com"
            class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
            @keyup.enter="handleLogin"
          />
        </div>

        <!-- 비밀번호 -->
        <div class="mb-6">
          <label class="block text-sm font-medium text-gray-700 mb-2">비밀번호</label>
          <input
            v-model="password"
            type="password"
            placeholder="6자 이상"
            class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
            @keyup.enter="handleLogin"
          />
        </div>

        <!-- 로그인 버튼 -->
        <button
          @click="handleLogin"
          :disabled="isLoading || !email || !password"
          class="w-full bg-gradient-to-r from-purple-600 to-pink-600 text-white py-3 rounded-lg font-medium hover:shadow-lg transition-all disabled:opacity-50 disabled:cursor-not-allowed mb-4"
        >
          <span v-if="!isLoading">로그인</span>
          <span v-else>로그인 중...</span>
        </button>

        <!-- 구분선 -->
        <div class="relative my-6">
          <div class="absolute inset-0 flex items-center">
            <div class="w-full border-t border-gray-300"></div>
          </div>
          <div class="relative flex justify-center text-sm">
            <span class="px-2 bg-white text-gray-500">또는</span>
          </div>
        </div>

        <!-- Google 로그인 -->
        <button
          @click="handleGoogleLogin"
          class="w-full border border-gray-300 py-3 rounded-lg font-medium hover:bg-gray-50 transition-colors flex items-center justify-center gap-2 mb-4"
        >
          <span class="text-xl">🔍</span>
          <span>Google로 계속하기</span>
        </button>

        <!-- 회원가입 링크 -->
        <div class="text-center text-sm">
          <span class="text-gray-600">계정이 없으신가요?</span>
          <router-link to="/signup" class="text-purple-600 font-medium ml-1 hover:underline">
            회원가입
          </router-link>
        </div>

        <!-- 비밀번호 찾기 -->
        <div class="text-center text-sm mt-3">
          <button @click="showResetPassword = true" class="text-gray-500 hover:text-gray-700">
            비밀번호를 잊으셨나요?
          </button>
        </div>
      </div>

      <!-- localStorage 사용자 -->
      <div v-if="hasLocalData" class="mt-6 bg-yellow-50 border border-yellow-200 rounded-lg p-4">
        <p class="text-sm text-yellow-800 mb-2">
          💾 로컬에 저장된 데이터가 있습니다.
        </p>
        <p class="text-xs text-yellow-700 mb-3">
          로그인하면 클라우드에 백업하고 여러 기기에서 동기화할 수 있습니다.
        </p>
        <button
          @click="continueWithLocal"
          class="text-sm text-yellow-700 font-medium hover:underline"
        >
          로그인 없이 계속하기 →
        </button>
      </div>
    </div>

    <!-- 비밀번호 재설정 모달 -->
    <div v-if="showResetPassword" class="fixed inset-0 bg-black/50 flex items-center justify-center z-50 px-4">
      <div class="bg-white rounded-2xl p-6 max-w-sm w-full">
        <h3 class="text-xl font-bold mb-4">비밀번호 재설정</h3>
        <p class="text-sm text-gray-600 mb-4">
          가입하신 이메일을 입력하시면 비밀번호 재설정 링크를 보내드립니다.
        </p>

        <input
          v-model="resetEmail"
          type="email"
          placeholder="example@email.com"
          class="w-full px-4 py-3 border border-gray-300 rounded-lg mb-4 focus:ring-2 focus:ring-purple-500"
        />

        <div v-if="resetSuccess" class="mb-4 p-3 bg-green-50 border border-green-200 rounded-lg">
          <p class="text-sm text-green-600">이메일이 발송되었습니다!</p>
        </div>

        <div class="flex gap-2">
          <button
            @click="showResetPassword = false"
            class="flex-1 py-2 border border-gray-300 rounded-lg hover:bg-gray-50"
          >
            취소
          </button>
          <button
            @click="handleResetPassword"
            :disabled="!resetEmail"
            class="flex-1 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700 disabled:opacity-50"
          >
            발송
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const authStore = useAuthStore()

const email = ref('')
const password = ref('')
const errorMessage = ref('')
const isLoading = ref(false)
const hasLocalData = ref(false)

const showResetPassword = ref(false)
const resetEmail = ref('')
const resetSuccess = ref(false)

onMounted(() => {
  // localStorage 데이터 확인
  const savedData = localStorage.getItem('quest-data')
  hasLocalData.value = !!savedData
})

async function handleLogin() {
  if (!email.value || !password.value) return

  errorMessage.value = ''
  isLoading.value = true

  const result = await authStore.signIn(email.value, password.value)

  if (result.success) {
    // 로그인 성공 - 홈으로 이동
    router.push('/')
  } else {
    // 로그인 실패
    errorMessage.value = result.error || '로그인에 실패했습니다.'
  }

  isLoading.value = false
}

async function handleGoogleLogin() {
  errorMessage.value = ''
  const result = await authStore.signInWithGoogle()

  if (!result.success) {
    errorMessage.value = result.error || 'Google 로그인에 실패했습니다.'
  }
  // OAuth는 리다이렉트되므로 성공 시 여기로 돌아오지 않음
}

async function handleResetPassword() {
  if (!resetEmail.value) return

  const result = await authStore.resetPassword(resetEmail.value)

  if (result.success) {
    resetSuccess.value = true
    setTimeout(() => {
      showResetPassword.value = false
      resetSuccess.value = false
      resetEmail.value = ''
    }, 2000)
  }
}

function continueWithLocal() {
  // localStorage 모드로 홈으로 이동
  router.push('/')
}
</script>
