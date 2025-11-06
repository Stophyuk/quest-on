// Authentication Store
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import * as authApi from '@/services/auth'
import { supabase } from '@/lib/supabase'
import { setSentryUser } from '@/lib/sentry'

export const useAuthStore = defineStore('auth', () => {
  // ==================== 상태 ====================
  const user = ref(null)
  const session = ref(null)
  const isLoading = ref(true)
  const error = ref(null)

  // ==================== 계산된 값 ====================
  const isAuthenticated = computed(() => !!user.value)
  const useSupabase = computed(() => isAuthenticated.value)
  const userEmail = computed(() => user.value?.email || null)
  const userId = computed(() => user.value?.id || null)

  // ==================== 세션 확인 ====================
  async function checkSession() {
    try {
      isLoading.value = true
      const currentSession = await authApi.getSession()

      if (currentSession) {
        session.value = currentSession
        user.value = currentSession.user
        setSentryUser(currentSession.user) // Sentry에 사용자 정보 전송
      } else {
        // 세션 없음 - localStorage 사용자일 수 있음
        session.value = null
        user.value = null
        setSentryUser(null)
      }
    } catch (err) {
      console.error('Session check failed:', err)
      error.value = err.message
    } finally {
      isLoading.value = false
    }
  }

  // ==================== 회원가입 ====================
  async function signUp(email, password, nickname) {
    try {
      error.value = null
      isLoading.value = true

      const data = await authApi.signUpWithEmail(email, password, nickname)
      session.value = data.session
      user.value = data.user
      setSentryUser(data.user) // Sentry에 사용자 정보 전송

      return { success: true, data }
    } catch (err) {
      console.error('Sign up failed:', err)
      error.value = err.message
      return { success: false, error: err.message }
    } finally {
      isLoading.value = false
    }
  }

  // ==================== 로그인 ====================
  async function signIn(email, password) {
    try {
      error.value = null
      isLoading.value = true

      const data = await authApi.signInWithEmail(email, password)
      session.value = data.session
      user.value = data.user
      setSentryUser(data.user) // Sentry에 사용자 정보 전송

      return { success: true, data }
    } catch (err) {
      console.error('Sign in failed:', err)
      error.value = err.message
      return { success: false, error: err.message }
    } finally {
      isLoading.value = false
    }
  }

  // ==================== Google 로그인 ====================
  async function signInWithGoogle() {
    try {
      error.value = null
      await authApi.signInWithGoogle()
      // OAuth는 리다이렉트되므로 여기서 반환값 없음
      return { success: true }
    } catch (err) {
      console.error('Google sign in failed:', err)
      error.value = err.message
      return { success: false, error: err.message }
    }
  }

  // ==================== 로그아웃 ====================
  async function signOut() {
    try {
      error.value = null
      await authApi.signOut()
      user.value = null
      session.value = null
      setSentryUser(null) // Sentry에서 사용자 정보 제거

      // localStorage도 정리 (옵션)
      // localStorage.clear()

      return { success: true }
    } catch (err) {
      console.error('Sign out failed:', err)
      error.value = err.message
      return { success: false, error: err.message }
    }
  }

  // ==================== 비밀번호 재설정 ====================
  async function resetPassword(email) {
    try {
      error.value = null
      await authApi.resetPassword(email)
      return { success: true }
    } catch (err) {
      console.error('Password reset failed:', err)
      error.value = err.message
      return { success: false, error: err.message }
    }
  }

  // ==================== 비밀번호 업데이트 ====================
  async function updatePassword(newPassword) {
    try {
      error.value = null
      await authApi.updatePassword(newPassword)
      return { success: true }
    } catch (err) {
      console.error('Password update failed:', err)
      error.value = err.message
      return { success: false, error: err.message }
    }
  }

  // ==================== 인증 상태 변경 리스너 ====================
  function initAuthListener() {
    supabase.auth.onAuthStateChange((event, newSession) => {
      console.log('Auth state changed:', event)

      if (event === 'SIGNED_IN' && newSession) {
        session.value = newSession
        user.value = newSession.user
      } else if (event === 'SIGNED_OUT') {
        session.value = null
        user.value = null
      } else if (event === 'TOKEN_REFRESHED' && newSession) {
        session.value = newSession
        user.value = newSession.user
      }
    })
  }

  // ==================== 액세스 토큰 가져오기 ====================
  function getAccessToken() {
    return session.value?.access_token || null
  }

  // ==================== Export ====================
  return {
    // 상태
    user,
    session,
    isLoading,
    error,

    // 계산된 값
    isAuthenticated,
    useSupabase,
    userEmail,
    userId,

    // 함수
    checkSession,
    signUp,
    signIn,
    signInWithGoogle,
    signOut,
    resetPassword,
    updatePassword,
    initAuthListener,
    getAccessToken,
  }
})
