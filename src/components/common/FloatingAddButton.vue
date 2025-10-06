<template>
  <div>
    <!-- FAB 버튼 -->
    <button
      @click="showQuickAdd = true"
      class="fixed bottom-20 right-5 w-14 h-14 rounded-full bg-gradient-to-br from-purple-500 to-blue-500 text-white text-3xl shadow-lg z-50 active:scale-95 transition-transform flex items-center justify-center"
    >
      +
    </button>

    <!-- 빠른 추가 모달 -->
    <Teleport to="body">
      <div
        v-if="showQuickAdd"
        class="fixed inset-0 bg-black bg-opacity-50 flex items-end z-50"
        @click.self="close"
      >
        <div class="w-full bg-white rounded-t-3xl animate-slide-up">
          <input
            ref="inputRef"
            v-model="quickTitle"
            @keyup.enter="addQuest"
            @keyup.esc="close"
            type="text"
            placeholder="퀘스트를 입력하세요..."
            class="w-full px-5 py-4 text-lg border-0 focus:outline-none rounded-t-3xl"
            autofocus
          />

          <div class="flex gap-2 p-4 border-t overflow-x-auto">
            <button
              v-for="cat in quickCategories"
              :key="cat.id"
              @click="quickCategory = cat.id"
              :class="[
                'px-4 py-2 rounded-full text-sm whitespace-nowrap flex-shrink-0',
                quickCategory === cat.id ? 'bg-purple-500 text-white' : 'bg-gray-100'
              ]"
            >
              {{ cat.label }}
            </button>
          </div>

          <div class="flex gap-2 p-4 border-t">
            <button
              @click="addQuest"
              class="flex-1 py-3 bg-purple-500 text-white rounded-lg font-medium"
            >
              추가
            </button>
            <button
              @click="close"
              class="px-5 py-3 bg-gray-100 rounded-lg"
            >
              취소
            </button>
          </div>
        </div>
      </div>
    </Teleport>
  </div>
</template>

<script setup>
import { ref, nextTick } from 'vue'
import { useQuestStore } from '@/stores/quest'
import { useQuestMetaStore } from '@/stores/questMeta'

const questStore = useQuestStore()
const questMetaStore = useQuestMetaStore()

const showQuickAdd = ref(false)
const quickTitle = ref('')
const quickCategory = ref('etc')
const inputRef = ref(null)

const quickCategories = [
  { id: 'health', label: '💪 건강' },
  { id: 'work', label: '💼 업무' },
  { id: 'study', label: '📚 학습' },
  { id: 'hobby', label: '🎨 취미' },
  { id: 'etc', label: '📌 기타' }
]

async function addQuest() {
  if (!quickTitle.value.trim()) return

  const newQuest = questStore.addQuest({
    title: quickTitle.value,
    category: quickCategory.value
  })

  if (newQuest) {
    // questMeta에도 기본 정보 저장
    questMetaStore.setQuestMeta(newQuest.id, {
      category: quickCategory.value
    })

    // 햅틱 피드백 (나중에 Capacitor Haptics로 교체)
    if (navigator.vibrate) {
      navigator.vibrate(50)
    }
  }

  quickTitle.value = ''
  quickCategory.value = 'etc'
  close()
}

function close() {
  showQuickAdd.value = false
}

// 모달이 열릴 때 input에 포커스
async function open() {
  showQuickAdd.value = true
  await nextTick()
  inputRef.value?.focus()
}
</script>

<style scoped>
@keyframes slide-up {
  from { transform: translateY(100%); }
  to { transform: translateY(0); }
}
.animate-slide-up {
  animation: slide-up 0.3s ease-out;
}
</style>
