<template>
  <Teleport to="body">
    <div class="fixed inset-0 bg-black bg-opacity-70 flex items-center justify-center z-[60] p-4" @click.self="$emit('close')">
      <div class="w-full max-w-md bg-white rounded-2xl overflow-hidden animate-scale-up">
        <!-- 헤더 -->
        <div class="bg-purple-500 text-white px-5 py-4">
          <div class="flex justify-between items-center">
            <h3 class="text-lg font-bold">🔄 반복 설정</h3>
            <button @click="$emit('close')" class="text-2xl">×</button>
          </div>
        </div>

        <!-- 컨텐츠 -->
        <div class="p-5 space-y-5 max-h-[70vh] overflow-y-auto">
          <!-- 반복 유형 -->
          <div>
            <label class="block text-sm font-semibold text-gray-700 mb-2">반복 유형</label>
            <div class="grid grid-cols-3 gap-2">
              <button
                v-for="type in recurrenceTypes"
                :key="type.value"
                @click="form.recurrenceType = type.value"
                :class="[
                  'px-3 py-2 rounded-lg text-sm font-medium transition-all',
                  form.recurrenceType === type.value
                    ? 'bg-purple-500 text-white'
                    : 'bg-gray-100 text-gray-700'
                ]"
              >
                {{ type.label }}
              </button>
            </div>
          </div>

          <!-- 반복 요일 (daily 또는 weekly일 때) -->
          <div v-if="form.recurrenceType === 'daily' || form.recurrenceType === 'weekly'">
            <label class="block text-sm font-semibold text-gray-700 mb-2">반복 요일</label>
            <div class="grid grid-cols-7 gap-2">
              <button
                v-for="(day, index) in weekDays"
                :key="index"
                @click="toggleDay(index)"
                :class="[
                  'aspect-square flex items-center justify-center rounded-lg text-sm font-medium transition-all',
                  form.recurrenceDays.includes(index)
                    ? 'bg-purple-500 text-white'
                    : 'bg-gray-100 text-gray-700'
                ]"
              >
                {{ day }}
              </button>
            </div>
            <p class="text-xs text-gray-500 mt-2">
              {{ form.recurrenceType === 'daily' ? '선택하지 않으면 매일 반복됩니다' : '반복할 요일을 선택하세요' }}
            </p>
          </div>

          <!-- 반복 시간 -->
          <div>
            <label class="block text-sm font-semibold text-gray-700 mb-2">반복 시간</label>
            <input
              v-model="form.recurrenceTime"
              type="time"
              class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500"
            />
          </div>

          <!-- 종료 조건 -->
          <div>
            <label class="block text-sm font-semibold text-gray-700 mb-2">종료 조건</label>
            <div class="space-y-3">
              <!-- 무한 반복 -->
              <label class="flex items-center gap-2 cursor-pointer">
                <input
                  type="radio"
                  value="never"
                  v-model="form.recurrenceEndType"
                  class="w-4 h-4 text-purple-500"
                />
                <span class="text-sm">무한 반복</span>
              </label>

              <!-- 날짜까지 -->
              <label class="flex items-center gap-2 cursor-pointer">
                <input
                  type="radio"
                  value="date"
                  v-model="form.recurrenceEndType"
                  class="w-4 h-4 text-purple-500"
                />
                <span class="text-sm">특정 날짜까지</span>
              </label>
              <input
                v-if="form.recurrenceEndType === 'date'"
                v-model="form.recurrenceEndDate"
                type="date"
                class="w-full ml-6 px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500"
              />

              <!-- 횟수 제한 -->
              <label class="flex items-center gap-2 cursor-pointer">
                <input
                  type="radio"
                  value="count"
                  v-model="form.recurrenceEndType"
                  class="w-4 h-4 text-purple-500"
                />
                <span class="text-sm">특정 횟수만</span>
              </label>
              <div v-if="form.recurrenceEndType === 'count'" class="flex items-center gap-2 ml-6">
                <input
                  v-model.number="form.recurrenceCount"
                  type="number"
                  min="1"
                  placeholder="횟수"
                  class="flex-1 px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500"
                />
                <span class="text-sm text-gray-600">회</span>
              </div>
            </div>
          </div>

          <!-- 미리보기 -->
          <div class="bg-purple-50 p-4 rounded-lg">
            <div class="text-sm font-semibold text-purple-800 mb-2">📋 설정 요약</div>
            <div class="text-sm text-purple-700 space-y-1">
              <div>• {{ recurrenceTypeLabel }}</div>
              <div v-if="form.recurrenceDays.length > 0">
                • 반복 요일: {{ selectedDaysLabel }}
              </div>
              <div>• 시간: {{ form.recurrenceTime }}</div>
              <div>• {{ endTypeLabel }}</div>
            </div>
          </div>
        </div>

        <!-- 하단 버튼 -->
        <div class="border-t p-4 flex gap-3">
          <button
            @click="$emit('close')"
            class="flex-1 py-2 bg-gray-100 text-gray-700 rounded-lg font-medium"
          >
            취소
          </button>
          <button
            @click="handleSave"
            class="flex-1 py-2 bg-purple-500 text-white rounded-lg font-medium"
          >
            저장
          </button>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'

const props = defineProps({
  recurringConfig: { type: Object, required: true }
})

const emit = defineEmits(['save', 'close'])

const form = ref({
  recurrenceType: 'daily',
  recurrenceDays: [],
  recurrenceTime: '09:00',
  recurrenceEndType: 'never',
  recurrenceEndDate: null,
  recurrenceCount: null
})

const recurrenceTypes = [
  { value: 'daily', label: '매일' },
  { value: 'weekly', label: '매주' },
  { value: 'monthly', label: '매월' }
]

const weekDays = ['일', '월', '화', '수', '목', '금', '토']

// 요일 토글
function toggleDay(dayIndex) {
  const index = form.value.recurrenceDays.indexOf(dayIndex)
  if (index === -1) {
    form.value.recurrenceDays.push(dayIndex)
  } else {
    form.value.recurrenceDays.splice(index, 1)
  }
  form.value.recurrenceDays.sort((a, b) => a - b)
}

// 계산된 라벨들
const recurrenceTypeLabel = computed(() => {
  const type = recurrenceTypes.find(t => t.value === form.value.recurrenceType)
  return type ? type.label : ''
})

const selectedDaysLabel = computed(() => {
  if (form.value.recurrenceDays.length === 0) return '매일'
  if (form.value.recurrenceDays.length === 7) return '매일'
  return form.value.recurrenceDays.map(d => weekDays[d]).join(', ')
})

const endTypeLabel = computed(() => {
  if (form.value.recurrenceEndType === 'never') return '무한 반복'
  if (form.value.recurrenceEndType === 'date') {
    return `${form.value.recurrenceEndDate}까지`
  }
  if (form.value.recurrenceEndType === 'count') {
    return `${form.value.recurrenceCount}회 반복`
  }
  return ''
})

// 초기 데이터 로드
onMounted(() => {
  if (props.recurringConfig) {
    form.value = {
      recurrenceType: props.recurringConfig.recurrenceType || 'daily',
      recurrenceDays: [...(props.recurringConfig.recurrenceDays || [])],
      recurrenceTime: props.recurringConfig.recurrenceTime || '09:00',
      recurrenceEndType: props.recurringConfig.recurrenceEndType || 'never',
      recurrenceEndDate: props.recurringConfig.recurrenceEndDate || null,
      recurrenceCount: props.recurringConfig.recurrenceCount || null
    }
  }
})

// 저장
function handleSave() {
  emit('save', form.value)
}
</script>

<style scoped>
@keyframes scale-up {
  from {
    transform: scale(0.9);
    opacity: 0;
  }
  to {
    transform: scale(1);
    opacity: 1;
  }
}
.animate-scale-up {
  animation: scale-up 0.2s ease-out;
}
</style>
