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

      <!-- 회원가입 폼 -->
      <div class="bg-white rounded-2xl shadow-xl p-8">
        <h2 class="text-2xl font-bold text-gray-800 mb-6">회원가입</h2>

        <!-- 에러 메시지 -->
        <div v-if="errorMessage" class="mb-4 p-3 bg-red-50 border border-red-200 rounded-lg">
          <p class="text-sm text-red-600">{{ errorMessage }}</p>
        </div>

        <!-- 닉네임 -->
        <div class="mb-4">
          <label class="block text-sm font-medium text-gray-700 mb-2">닉네임</label>
          <input
            v-model="nickname"
            type="text"
            placeholder="2~10자"
            maxlength="10"
            class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
          />
        </div>

        <!-- 이메일 -->
        <div class="mb-4">
          <label class="block text-sm font-medium text-gray-700 mb-2">이메일</label>
          <input
            v-model="email"
            type="email"
            placeholder="example@email.com"
            class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
          />
        </div>

        <!-- 비밀번호 -->
        <div class="mb-4">
          <label class="block text-sm font-medium text-gray-700 mb-2">비밀번호</label>
          <input
            v-model="password"
            type="password"
            placeholder="6자 이상"
            class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
          />
          <p v-if="password && password.length < 6" class="text-xs text-red-500 mt-1">
            6자 이상 입력해주세요
          </p>
        </div>

        <!-- 비밀번호 확인 -->
        <div class="mb-6">
          <label class="block text-sm font-medium text-gray-700 mb-2">비밀번호 확인</label>
          <input
            v-model="passwordConfirm"
            type="password"
            placeholder="비밀번호 재입력"
            class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
            @keyup.enter="handleSignup"
          />
          <p v-if="passwordConfirm && password !== passwordConfirm" class="text-xs text-red-500 mt-1">
            비밀번호가 일치하지 않습니다
          </p>
        </div>

        <!-- 약관 동의 -->
        <div class="mb-6 space-y-2">
          <label class="flex items-start gap-2">
            <input v-model="agreeTerms" type="checkbox" class="mt-1" />
            <span class="text-sm text-gray-700">
              <router-link to="/terms" class="text-purple-600 hover:underline">이용약관</router-link>에 동의합니다 (필수)
            </span>
          </label>
          <label class="flex items-start gap-2">
            <input v-model="agreePrivacy" type="checkbox" class="mt-1" />
            <span class="text-sm text-gray-700">
              <router-link to="/privacy" class="text-purple-600 hover:underline">개인정보처리방침</router-link>에 동의합니다 (필수)
            </span>
          </label>
        </div>

        <!-- 회원가입 버튼 -->
        <button
          @click="handleSignup"
          :disabled="!canSubmit"
          class="w-full bg-gradient-to-r from-purple-600 to-pink-600 text-white py-3 rounded-lg font-medium hover:shadow-lg transition-all disabled:opacity-50 disabled:cursor-not-allowed mb-4"
        >
          <span v-if="!isLoading">회원가입</span>
          <span v-else>가입 중...</span>
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

        <!-- Google 회원가입 -->
        <button
          @click="handleGoogleSignup"
          class="w-full border border-gray-300 py-3 rounded-lg font-medium hover:bg-gray-50 transition-colors flex items-center justify-center gap-2 mb-4"
        >
          <span class="text-xl">🔍</span>
          <span>Google로 계속하기</span>
        </button>

        <!-- 로그인 링크 -->
        <div class="text-center text-sm">
          <span class="text-gray-600">이미 계정이 있으신가요?</span>
          <router-link to="/login" class="text-purple-600 font-medium ml-1 hover:underline">
            로그인
          </router-link>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const authStore = useAuthStore()

const nickname = ref('')
const email = ref('')
const password = ref('')
const passwordConfirm = ref('')
const agreeTerms = ref(false)
const agreePrivacy = ref(false)
const errorMessage = ref('')
const isLoading = ref(false)

const canSubmit = computed(() => {
  return (
    nickname.value.length >= 2 &&
    email.value.includes('@') &&
    password.value.length >= 6 &&
    password.value === passwordConfirm.value &&
    agreeTerms.value &&
    agreePrivacy.value &&
    !isLoading.value
  )
})

async function handleSignup() {
  if (!canSubmit.value) return

  errorMessage.value = ''
  isLoading.value = true

  const result = await authStore.signUp(email.value, password.value, nickname.value)

  if (result.success) {
    // 회원가입 성공 - 온보딩으로 이동
    router.push('/')
  } else {
    // 회원가입 실패
    if (result.error.includes('already registered')) {
      errorMessage.value = '이미 가입된 이메일입니다.'
    } else {
      errorMessage.value = result.error || '회원가입에 실패했습니다.'
    }
  }

  isLoading.value = false
}

async function handleGoogleSignup() {
  if (!agreeTerms.value || !agreePrivacy.value) {
    errorMessage.value = '이용약관과 개인정보처리방침에 동의해주세요.'
    return
  }

  errorMessage.value = ''
  const result = await authStore.signInWithGoogle()

  if (!result.success) {
    errorMessage.value = result.error || 'Google 회원가입에 실패했습니다.'
  }
}
</script>
