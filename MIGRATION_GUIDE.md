# Quest ON - Supabase 마이그레이션 가이드

## 📋 마이그레이션 전략

현재 앱은 localStorage 기반입니다. Supabase로의 마이그레이션은 **점진적**으로 진행하여 기존 사용자 데이터를 보존합니다.

### 마이그레이션 단계

1. **Phase 1**: Supabase 클라이언트 및 API 레이어 구축 ✅
2. **Phase 2**: 듀얼 모드 구현 (localStorage + Supabase 동시 지원)
3. **Phase 3**: 데이터 마이그레이션 도구 제공
4. **Phase 4**: Supabase를 기본으로 전환
5. **Phase 5**: localStorage 완전 제거

---

## 🔄 Phase 2: 듀얼 모드 구현

### 목표
- 기존 localStorage 사용자: 계속 작동
- 신규 Supabase 사용자: 클라우드 동기화
- 마이그레이션 버튼으로 데이터 이전 가능

### 구현 방법

#### 1. 인증 상태 스토어 생성

```javascript
// src/stores/auth.js
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import * as authApi from '@/services/auth'

export const useAuthStore = defineStore('auth', () => {
  const user = ref(null)
  const session = ref(null)
  const isLoading = ref(true)

  const isAuthenticated = computed(() => !!user.value)
  const useSupabase = computed(() => isAuthenticated.value)

  async function checkSession() {
    try {
      const currentSession = await authApi.getSession()
      if (currentSession) {
        session.value = currentSession
        user.value = currentSession.user
      }
    } catch (error) {
      console.error('Session check failed:', error)
    } finally {
      isLoading.value = false
    }
  }

  async function signIn(email, password) {
    const data = await authApi.signInWithEmail(email, password)
    session.value = data.session
    user.value = data.user
  }

  async function signUp(email, password, nickname) {
    const data = await authApi.signUpWithEmail(email, password, nickname)
    session.value = data.session
    user.value = data.user
  }

  async function signOut() {
    await authApi.signOut()
    user.value = null
    session.value = null
  }

  return {
    user,
    session,
    isLoading,
    isAuthenticated,
    useSupabase,
    checkSession,
    signIn,
    signUp,
    signOut,
  }
})
```

#### 2. Quest Store 수정 (듀얼 모드)

```javascript
// src/stores/quest.js 수정 예시
import { useAuthStore } from './auth'
import * as questsApi from '@/services/questsApi'
import * as profileApi from '@/services/profile'

export const useQuestStore = defineStore('quest', () => {
  const authStore = useAuthStore()

  // ... 기존 상태 유지 ...

  // ==================== 데이터 로드 (듀얼 모드) ====================
  async function loadData() {
    if (authStore.useSupabase) {
      // Supabase에서 로드
      await loadFromSupabase()
    } else {
      // localStorage에서 로드 (기존 방식)
      loadFromLocalStorage()
    }
    isLoaded.value = true
  }

  async function loadFromSupabase() {
    try {
      // 프로필 로드
      const profile = await profileApi.getProfile()
      level.value = profile.level
      experience.value = profile.experience
      totalCompleted.value = profile.total_completed || 0

      // 오늘 퀘스트 로드
      const todayQuests = await questsApi.getQuests()
      quests.value = todayQuests.map(q => ({
        id: q.id,
        title: q.title,
        difficulty: q.difficulty,
        completed: q.completed,
        isRecurring: q.is_recurring,
        createdAt: q.created_at,
        completedAt: q.completed_at,
      }))

      // Vision 데이터 로드
      const visionData = await visionApi.getVisionProfile()
      if (visionData) {
        visionProfile.value = visionData.profile_data
      }

      const visionNoteData = await visionApi.getVisionNote()
      if (visionNoteData) {
        visionNote.value = visionNoteData.content
      }

      const goalTreeData = await visionApi.getGoalTree()
      if (goalTreeData) {
        goalTree.value = goalTreeData.tree_data
      }
    } catch (error) {
      console.error('Failed to load from Supabase:', error)
      // Fallback to localStorage
      loadFromLocalStorage()
    }
  }

  function loadFromLocalStorage() {
    // 기존 loadData() 로직
    const savedData = storageManager.loadQuestData()
    // ... 기존 코드 ...
  }

  // ==================== 데이터 저장 (듀얼 모드) ====================
  async function saveData() {
    if (authStore.useSupabase) {
      await saveToSupabase()
    } else {
      saveToLocalStorage()
    }
  }

  async function saveToSupabase() {
    try {
      // 프로필 업데이트는 자동 (gain_experience RPC 사용)
      // 퀘스트는 개별 저장 (addQuest, completeQuest에서 처리)
    } catch (error) {
      console.error('Failed to save to Supabase:', error)
      // Fallback: 로컬에도 저장
      saveToLocalStorage()
    }
  }

  function saveToLocalStorage() {
    // 기존 saveData() 로직
    // ... 기존 코드 ...
  }

  // ==================== 퀘스트 추가 (듀얼 모드) ====================
  async function addQuest(questData) {
    if (authStore.useSupabase) {
      const newQuest = await questsApi.createQuest(questData)
      quests.value.push({
        id: newQuest.id,
        title: newQuest.title,
        difficulty: newQuest.difficulty,
        completed: newQuest.completed,
        isRecurring: newQuest.is_recurring,
        createdAt: newQuest.created_at,
        completedAt: newQuest.completed_at,
      })
      return newQuest
    } else {
      // 기존 localStorage 로직
      // ... 기존 코드 ...
    }
  }

  // ==================== 퀘스트 완료 (듀얼 모드) ====================
  async function completeQuest(questId) {
    const quest = quests.value.find(q => q.id === questId)
    if (!quest || quest.completed) return { leveledUp: false }

    if (authStore.useSupabase) {
      await questsApi.toggleQuestComplete(questId, true)
      quest.completed = true
      quest.completedAt = new Date().toISOString()

      // 경험치 획득 (Supabase RPC 호출)
      const xp = DIFFICULTY_XP[quest.difficulty] || 10
      const updatedProfile = await profileApi.gainExperience(xp)

      const previousLevel = level.value
      level.value = updatedProfile.level
      experience.value = updatedProfile.experience
      totalCompleted.value++

      return {
        leveledUp: level.value > previousLevel,
        newLevel: level.value,
        levelsGained: level.value - previousLevel,
      }
    } else {
      // 기존 localStorage 로직
      // ... 기존 코드 ...
    }
  }

  return {
    // ... 기존 exports ...
  }
})
```

---

## 🔧 Phase 3: 데이터 마이그레이션 도구

### 마이그레이션 컴포넌트 생성

```vue
<!-- src/components/MigrationTool.vue -->
<template>
  <div class="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
    <div class="bg-white rounded-2xl p-6 max-w-md w-full mx-4">
      <h2 class="text-xl font-bold mb-4">클라우드 동기화 활성화</h2>

      <div v-if="step === 'info'" class="space-y-4">
        <p class="text-sm text-gray-600">
          로컬 데이터를 클라우드에 백업하고 여러 기기에서 동기화하세요.
        </p>

        <div class="bg-purple-50 p-4 rounded-lg">
          <div class="text-sm space-y-2">
            <div class="flex justify-between">
              <span>레벨</span>
              <span class="font-bold">{{ localData.level }}</span>
            </div>
            <div class="flex justify-between">
              <span>완료한 퀘스트</span>
              <span class="font-bold">{{ localData.totalCompleted }}</span>
            </div>
            <div class="flex justify-between">
              <span>저장된 퀘스트</span>
              <span class="font-bold">{{ localData.quests.length }}</span>
            </div>
          </div>
        </div>

        <button
          @click="startMigration"
          class="w-full bg-purple-600 text-white py-3 rounded-lg"
        >
          마이그레이션 시작
        </button>
      </div>

      <div v-if="step === 'migrating'" class="text-center py-8">
        <div class="animate-spin w-12 h-12 border-4 border-purple-200 border-t-purple-600 rounded-full mx-auto mb-4"></div>
        <p class="text-gray-600">{{ progress }}</p>
      </div>

      <div v-if="step === 'complete'" class="text-center py-8">
        <div class="text-6xl mb-4">✅</div>
        <h3 class="text-xl font-bold mb-2">마이그레이션 완료!</h3>
        <p class="text-sm text-gray-600 mb-4">
          데이터가 안전하게 클라우드에 저장되었습니다.
        </p>
        <button
          @click="$emit('close')"
          class="bg-purple-600 text-white px-6 py-2 rounded-lg"
        >
          확인
        </button>
      </div>

      <div v-if="step === 'error'" class="text-center py-8">
        <div class="text-6xl mb-4">❌</div>
        <h3 class="text-xl font-bold mb-2">마이그레이션 실패</h3>
        <p class="text-sm text-red-600 mb-4">{{ errorMessage }}</p>
        <button
          @click="step = 'info'"
          class="bg-gray-600 text-white px-6 py-2 rounded-lg"
        >
          다시 시도
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useQuestStore } from '@/stores/quest'
import { useAuthStore } from '@/stores/auth'
import * as profileApi from '@/services/profile'
import * as questsApi from '@/services/questsApi'
import * as visionApi from '@/services/visionApi'

const questStore = useQuestStore()
const authStore = useAuthStore()

const step = ref('info') // 'info' | 'migrating' | 'complete' | 'error'
const progress = ref('')
const errorMessage = ref('')
const localData = ref({
  level: 0,
  totalCompleted: 0,
  quests: [],
})

onMounted(() => {
  localData.value = {
    level: questStore.level,
    totalCompleted: questStore.totalCompleted,
    quests: questStore.quests,
  }
})

async function startMigration() {
  step.value = 'migrating'

  try {
    // 1. 프로필 생성
    progress.value = '프로필 생성 중...'
    await profileApi.createProfile({
      nickname: localStorage.getItem('userNickname') || '퀘스터',
      character: localStorage.getItem('userCharacter') || '🌱',
    })

    // 2. 레벨/경험치 동기화
    progress.value = '경험치 동기화 중...'
    if (questStore.level > 0 || questStore.experience > 0) {
      // 경험치를 한 번에 부여
      const totalXP = calculateTotalXP(questStore.level, questStore.experience)
      await profileApi.gainExperience(totalXP)
    }

    // 3. 오늘 퀘스트 마이그레이션
    progress.value = '퀘스트 마이그레이션 중...'
    const today = new Date().toISOString().split('T')[0]
    for (const quest of questStore.quests) {
      await questsApi.createQuest({
        title: quest.title,
        difficulty: quest.difficulty,
        is_recurring: quest.isRecurring,
        quest_date: today,
      })
    }

    // 4. Vision 데이터 마이그레이션
    if (questStore.visionProfile.yearGoals.length > 0) {
      progress.value = 'Vision 데이터 마이그레이션 중...'
      await visionApi.saveVisionProfile(questStore.visionProfile)
    }

    // 완료
    step.value = 'complete'
  } catch (error) {
    console.error('Migration failed:', error)
    errorMessage.value = error.message
    step.value = 'error'
  }
}

function calculateTotalXP(level, experience) {
  let total = experience
  for (let lv = 0; lv < level; lv++) {
    if (lv === 0) total += 30
    else if (lv <= 4) total += 50 + (lv * 50)
    else total += 200 + ((lv - 4) * 100)
  }
  return total
}
</script>
```

---

## 🎯 Phase 4: Supabase를 기본으로 전환

### 변경 사항
1. 신규 사용자는 반드시 로그인 필요
2. 로그인 전에는 온보딩 페이지만 표시
3. 기존 localStorage 사용자에게 마이그레이션 권장 모달 표시

### 라우터 가드 추가

```javascript
// src/router/index.js
import { useAuthStore } from '@/stores/auth'

router.beforeEach(async (to, from, next) => {
  const authStore = useAuthStore()

  // 인증 체크
  if (!authStore.isLoading) {
    await authStore.checkSession()
  }

  // 로그인 페이지는 항상 접근 가능
  if (to.name === 'Login' || to.name === 'Signup') {
    return next()
  }

  // 인증되지 않은 사용자
  if (!authStore.isAuthenticated) {
    // localStorage에 데이터가 있으면 마이그레이션 권장
    const hasLocalData = localStorage.getItem('quest-data')
    if (hasLocalData) {
      // 마이그레이션 모달 표시 (메타 태그로 전달)
      to.meta.showMigrationModal = true
    }
    return next({ name: 'Login' })
  }

  next()
})
```

---

## 📊 Phase 5: localStorage 완전 제거

### 체크리스트
- [ ] 모든 사용자가 Supabase로 마이그레이션했는지 확인
- [ ] 마이그레이션 기한 공지 (예: 3개월)
- [ ] 로컬 데이터 export 기능 제공 (백업용)
- [ ] localStorage 관련 코드 제거
- [ ] `storageManager.js` 삭제
- [ ] 듀얼 모드 로직 제거

---

## 🔒 보안 고려사항

### RLS 정책 확인
모든 테이블에 RLS가 활성화되어 있으므로 사용자는 자신의 데이터만 접근 가능합니다.

```sql
-- 예: quests 테이블 RLS
CREATE POLICY "Users can view own quests"
  ON quests FOR SELECT
  USING (auth.uid() = user_id);
```

### API 키 보호
- `VITE_SUPABASE_ANON_KEY`만 클라이언트에 노출
- `service_role` 키는 절대 노출 금지
- Edge Functions 환경변수로 OpenAI API 키 관리

---

## 🧪 테스트 시나리오

### 시나리오 1: 신규 사용자
1. 앱 설치
2. 회원가입
3. 온보딩 완료
4. 퀘스트 추가 → Supabase에 저장 확인

### 시나리오 2: 기존 사용자 (마이그레이션)
1. localStorage에 데이터 있음
2. 로그인 유도 모달 표시
3. 회원가입/로그인
4. 마이그레이션 도구 실행
5. 데이터 확인 → Supabase에 저장 확인

### 시나리오 3: 오프라인 모드
1. 네트워크 끊김
2. 로컬 캐시로 계속 사용
3. 네트워크 복구 시 자동 동기화

---

## 📝 다음 단계

1. ✅ Supabase 클라이언트 및 API 레이어 생성 완료
2. ⏭️ `useAuthStore` 생성
3. ⏭️ `useQuestStore` 듀얼 모드 구현
4. ⏭️ 마이그레이션 도구 컴포넌트 작성
5. ⏭️ 로그인/회원가입 페이지 작성

계속 진행하시겠습니까?
