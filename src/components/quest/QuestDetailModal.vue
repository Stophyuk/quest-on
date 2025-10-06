<template>
  <Teleport to="body">
    <div class="fixed inset-0 bg-black bg-opacity-50 flex items-end z-50" @click.self="$emit('close')">
      <div class="w-full max-h-[90vh] bg-white rounded-t-3xl overflow-y-auto animate-slide-up">
        <!-- 헤더 -->
        <div class="sticky top-0 bg-white border-b px-5 py-4 flex justify-between items-center">
          <h2 class="text-xl font-bold">{{ quest ? '퀘스트 수정' : '새 퀘스트' }}</h2>
          <button @click="$emit('close')" class="text-2xl text-gray-400 hover:text-gray-600">×</button>
        </div>

        <!-- 폼 -->
        <div class="p-5 space-y-6">
          <!-- 제목 -->
          <div>
            <label class="block text-sm font-semibold text-gray-700 mb-2">📝 제목 *</label>
            <input
              v-model="form.title"
              type="text"
              placeholder="퀘스트 제목을 입력하세요"
              class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500"
            />
          </div>

          <!-- 카테고리 -->
          <div>
            <label class="block text-sm font-semibold text-gray-700 mb-2">📂 카테고리</label>
            <div class="grid grid-cols-4 gap-2">
              <button
                v-for="cat in categories"
                :key="cat.id"
                @click="form.category = cat.id"
                :class="[
                  'p-3 rounded-lg text-center transition-all',
                  form.category === cat.id
                    ? 'bg-purple-500 text-white shadow-md scale-105'
                    : 'bg-gray-100 text-gray-700'
                ]"
              >
                <div class="text-2xl mb-1">{{ cat.label.split(' ')[0] }}</div>
                <div class="text-xs">{{ cat.label.split(' ')[1] }}</div>
              </button>
            </div>
          </div>

          <!-- 우선순위 (긴급도 + 중요도) -->
          <div>
            <label class="block text-sm font-semibold text-gray-700 mb-2">🎯 우선순위</label>
            <div class="grid grid-cols-2 gap-4">
              <div>
                <label class="text-xs text-gray-600 mb-1 block">긴급도</label>
                <select
                  v-model="form.urgency"
                  class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500"
                >
                  <option value="low">낮음</option>
                  <option value="high">높음</option>
                </select>
              </div>
              <div>
                <label class="text-xs text-gray-600 mb-1 block">중요도</label>
                <select
                  v-model="form.importance"
                  class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500"
                >
                  <option value="low">낮음</option>
                  <option value="high">높음</option>
                </select>
              </div>
            </div>
            <div class="mt-2 p-3 bg-gray-50 rounded-lg text-sm">
              {{ priorityLabel.label }}
            </div>
          </div>

          <!-- 날짜 설정 -->
          <div>
            <label class="block text-sm font-semibold text-gray-700 mb-2">📅 일정</label>
            <div class="grid grid-cols-2 gap-4">
              <div>
                <label class="text-xs text-gray-600 mb-1 block">시작일</label>
                <input
                  v-model="form.scheduledDate"
                  type="date"
                  class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500"
                />
              </div>
              <div>
                <label class="text-xs text-gray-600 mb-1 block">마감일</label>
                <input
                  v-model="form.deadline"
                  type="date"
                  class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500"
                />
              </div>
            </div>
          </div>

          <!-- 예상 소요 시간 -->
          <div>
            <label class="block text-sm font-semibold text-gray-700 mb-2">⏱️ 예상 소요 시간</label>
            <div class="flex items-center gap-2">
              <input
                v-model.number="form.estimatedMinutes"
                type="number"
                min="0"
                step="15"
                placeholder="분"
                class="flex-1 px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500"
              />
              <span class="text-gray-600">분</span>
            </div>
          </div>

          <!-- 알림 설정 -->
          <div>
            <div class="flex items-center justify-between mb-2">
              <label class="text-sm font-semibold text-gray-700">🔔 알림</label>
              <button
                @click="form.hasNotification = !form.hasNotification"
                :class="[
                  'relative w-12 h-6 rounded-full transition-colors',
                  form.hasNotification ? 'bg-purple-500' : 'bg-gray-300'
                ]"
              >
                <span
                  :class="[
                    'absolute top-0.5 left-0.5 w-5 h-5 bg-white rounded-full transition-transform',
                    form.hasNotification ? 'translate-x-6' : 'translate-x-0'
                  ]"
                ></span>
              </button>
            </div>
            <div v-if="form.hasNotification" class="space-y-3">
              <input
                v-model="form.notificationTime"
                type="time"
                class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500"
              />
              <div>
                <label class="text-xs text-gray-600 mb-1 block">사전 알림</label>
                <select
                  v-model.number="form.notificationMinutesBefore"
                  class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500"
                >
                  <option :value="0">정시</option>
                  <option :value="5">5분 전</option>
                  <option :value="10">10분 전</option>
                  <option :value="15">15분 전</option>
                  <option :value="30">30분 전</option>
                  <option :value="60">1시간 전</option>
                </select>
              </div>
            </div>
          </div>

          <!-- 반복 설정 -->
          <div>
            <div class="flex items-center justify-between mb-2">
              <label class="text-sm font-semibold text-gray-700">🔄 반복 퀘스트</label>
              <button
                @click="form.isRecurring = !form.isRecurring"
                :class="[
                  'relative w-12 h-6 rounded-full transition-colors',
                  form.isRecurring ? 'bg-purple-500' : 'bg-gray-300'
                ]"
              >
                <span
                  :class="[
                    'absolute top-0.5 left-0.5 w-5 h-5 bg-white rounded-full transition-transform',
                    form.isRecurring ? 'translate-x-6' : 'translate-x-0'
                  ]"
                ></span>
              </button>
            </div>
            <button
              v-if="form.isRecurring"
              @click="showRecurringModal = true"
              class="w-full px-4 py-2 bg-purple-50 text-purple-600 rounded-lg text-sm font-medium"
            >
              반복 설정 상세 편집 →
            </button>
          </div>

          <!-- 메모 -->
          <div>
            <label class="block text-sm font-semibold text-gray-700 mb-2">📄 메모</label>
            <textarea
              v-model="form.notes"
              rows="4"
              placeholder="추가 메모를 입력하세요"
              class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500 resize-none"
            ></textarea>
          </div>
        </div>

        <!-- 하단 버튼 -->
        <div class="sticky bottom-0 bg-white border-t p-4 flex gap-3">
          <button
            @click="$emit('close')"
            class="flex-1 py-3 bg-gray-100 text-gray-700 rounded-lg font-medium"
          >
            취소
          </button>
          <button
            @click="handleSave"
            :disabled="!form.title.trim()"
            class="flex-1 py-3 bg-purple-500 text-white rounded-lg font-medium disabled:opacity-50 disabled:cursor-not-allowed"
          >
            저장
          </button>
        </div>
      </div>
    </div>

    <!-- 반복 설정 모달 -->
    <RecurringQuestModal
      v-if="showRecurringModal"
      :recurring-config="form"
      @save="handleRecurringSave"
      @close="showRecurringModal = false"
    />
  </Teleport>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { CATEGORIES, getPriorityLabel } from '@/stores/questMeta'
import RecurringQuestModal from './RecurringQuestModal.vue'

const props = defineProps({
  quest: { type: Object, default: null },
  questMeta: { type: Object, default: null }
})

const emit = defineEmits(['save', 'close'])

const showRecurringModal = ref(false)

// 폼 데이터
const form = ref({
  // 기본 정보
  title: '',

  // questMeta 정보
  category: 'etc',
  urgency: 'low',
  importance: 'low',
  scheduledDate: null,
  deadline: null,
  estimatedMinutes: null,
  hasNotification: false,
  notificationTime: '09:00',
  notificationMinutesBefore: 0,
  isRecurring: false,
  recurrenceType: 'daily',
  recurrenceDays: [],
  recurrenceTime: '09:00',
  recurrenceEndType: 'never',
  recurrenceEndDate: null,
  recurrenceCount: null,
  notes: ''
})

const categories = CATEGORIES

// 우선순위 라벨
const priorityLabel = computed(() => {
  return getPriorityLabel(form.value.urgency, form.value.importance)
})

// 초기 데이터 로드
onMounted(() => {
  if (props.quest) {
    form.value.title = props.quest.title || ''
  }
  if (props.questMeta) {
    Object.assign(form.value, props.questMeta)
  }
})

// 반복 설정 저장
function handleRecurringSave(recurringData) {
  Object.assign(form.value, recurringData)
  showRecurringModal.value = false
}

// 저장
function handleSave() {
  if (!form.value.title.trim()) return

  emit('save', {
    title: form.value.title,
    meta: {
      category: form.value.category,
      urgency: form.value.urgency,
      importance: form.value.importance,
      scheduledDate: form.value.scheduledDate,
      deadline: form.value.deadline,
      estimatedMinutes: form.value.estimatedMinutes,
      hasNotification: form.value.hasNotification,
      notificationTime: form.value.notificationTime,
      notificationMinutesBefore: form.value.notificationMinutesBefore,
      isRecurring: form.value.isRecurring,
      recurrenceType: form.value.recurrenceType,
      recurrenceDays: form.value.recurrenceDays,
      recurrenceTime: form.value.recurrenceTime,
      recurrenceEndType: form.value.recurrenceEndType,
      recurrenceEndDate: form.value.recurrenceEndDate,
      recurrenceCount: form.value.recurrenceCount,
      notes: form.value.notes
    }
  })
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
