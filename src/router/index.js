import { createRouter, createWebHistory } from 'vue-router'
import Home from '../views/Home.vue'
import Quests from '../views/Quests.vue'
import Profile from '../views/Profile.vue'
import Vision from '../views/Vision.vue'
import Roadmap from '../views/Roadmap.vue'
import Login from '../views/Login.vue'
import Signup from '../views/Signup.vue'

const routes = [
  {
    path: '/',
    name: 'Home',
    component: Home
  },
  {
    path: '/quests',
    name: 'Quests',
    component: Quests
  },
  {
    path: '/vision',
    name: 'Vision',
    component: Vision
  },
  {
    path: '/roadmap',
    name: 'Roadmap',
    component: Roadmap
  },
  {
    path: '/profile',
    name: 'Profile',
    component: Profile
  },
  {
    path: '/login',
    name: 'Login',
    component: Login,
    meta: { requiresGuest: true }
  },
  {
    path: '/signup',
    name: 'Signup',
    component: Signup,
    meta: { requiresGuest: true }
  },
  {
    path: '/auth/callback',
    name: 'AuthCallback',
    component: () => import('../views/AuthCallback.vue')
  },
  {
    path: '/terms',
    name: 'Terms',
    component: () => import('../views/Terms.vue')
  },
  {
    path: '/privacy',
    name: 'Privacy',
    component: () => import('../views/Privacy.vue')
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// 라우터 가드 (현재는 비활성화 - localStorage와 Supabase 듀얼 모드)
// 추후 Supabase 전환 시 활성화
/*
import { useAuthStore } from '@/stores/auth'

router.beforeEach(async (to, from, next) => {
  const authStore = useAuthStore()

  // 인증 체크
  if (authStore.isLoading) {
    await authStore.checkSession()
  }

  // 게스트 전용 페이지 (로그인/회원가입)
  if (to.meta.requiresGuest && authStore.isAuthenticated) {
    return next({ name: 'Home' })
  }

  // 인증 필요 페이지
  if (to.meta.requiresAuth && !authStore.isAuthenticated) {
    return next({ name: 'Login' })
  }

  next()
})
*/

export default router