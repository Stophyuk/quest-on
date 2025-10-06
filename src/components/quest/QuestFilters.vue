<template>
  <div class="space-y-4 bg-white rounded-2xl p-4 shadow-sm">
    <!-- 카테고리 필터 -->
    <div>
      <h3 class="text-sm font-semibold text-neutral-600 mb-2">📂 카테고리</h3>
      <div class="flex flex-wrap gap-2">
        <button
          @click="$emit('update:category', null)"
          :class="[
            'px-3 py-1.5 rounded-full text-sm font-medium transition-all',
            !selectedCategory ? 'bg-purple-500 text-white shadow-md' : 'bg-gray-100 text-gray-600'
          ]"
        >
          전체
        </button>
        <button
          v-for="cat in categories"
          :key="cat.id"
          @click="$emit('update:category', cat.id)"
          :class="[
            'px-3 py-1.5 rounded-full text-sm font-medium transition-all',
            selectedCategory === cat.id ? 'bg-purple-500 text-white shadow-md' : 'bg-gray-100 text-gray-600'
          ]"
        >
          {{ cat.label }}
        </button>
      </div>
    </div>

    <!-- 우선순위 필터 -->
    <div>
      <h3 class="text-sm font-semibold text-neutral-600 mb-2">🎯 우선순위</h3>
      <div class="flex flex-wrap gap-2">
        <button
          @click="$emit('update:priority', null)"
          :class="[
            'px-3 py-1.5 rounded-full text-sm font-medium transition-all',
            !selectedPriority ? 'bg-purple-500 text-white shadow-md' : 'bg-gray-100 text-gray-600'
          ]"
        >
          전체
        </button>
        <button
          v-for="p in priorities"
          :key="p.priority"
          @click="$emit('update:priority', p.priority)"
          :class="[
            'px-3 py-1.5 rounded-full text-sm font-medium transition-all',
            selectedPriority === p.priority ? `bg-${p.color}-500 text-white shadow-md` : 'bg-gray-100 text-gray-600'
          ]"
        >
          {{ p.label }}
        </button>
      </div>
    </div>

    <!-- 정렬 -->
    <div>
      <h3 class="text-sm font-semibold text-neutral-600 mb-2">📊 정렬</h3>
      <div class="flex flex-wrap gap-2">
        <button
          v-for="sort in sortOptions"
          :key="sort.value"
          @click="$emit('update:sort', sort.value)"
          :class="[
            'px-3 py-1.5 rounded-full text-sm font-medium transition-all',
            selectedSort === sort.value ? 'bg-purple-500 text-white shadow-md' : 'bg-gray-100 text-gray-600'
          ]"
        >
          {{ sort.label }}
        </button>
      </div>
    </div>

    <!-- 완료된 퀘스트 표시 토글 -->
    <div class="flex items-center justify-between">
      <label class="text-sm font-semibold text-neutral-600">✅ 완료된 퀘스트 표시</label>
      <button
        @click="$emit('update:showCompleted', !showCompleted)"
        :class="[
          'relative w-12 h-6 rounded-full transition-colors',
          showCompleted ? 'bg-purple-500' : 'bg-gray-300'
        ]"
      >
        <span
          :class="[
            'absolute top-0.5 left-0.5 w-5 h-5 bg-white rounded-full transition-transform',
            showCompleted ? 'translate-x-6' : 'translate-x-0'
          ]"
        ></span>
      </button>
    </div>

    <!-- 필터 초기화 버튼 -->
    <button
      @click="$emit('reset')"
      class="w-full py-2 text-sm text-purple-600 font-medium hover:bg-purple-50 rounded-lg transition-colors"
    >
      🔄 필터 초기화
    </button>
  </div>
</template>

<script setup>
import { CATEGORIES } from '@/stores/questMeta'

defineProps({
  selectedCategory: { type: String, default: null },
  selectedPriority: { type: Number, default: null },
  selectedSort: { type: String, default: 'default' },
  showCompleted: { type: Boolean, default: true }
})

defineEmits(['update:category', 'update:priority', 'update:sort', 'update:showCompleted', 'reset'])

const categories = CATEGORIES

const priorities = [
  { label: '🔴 지금 당장', priority: 1, color: 'red' },
  { label: '🟡 계획 세우기', priority: 2, color: 'yellow' },
  { label: '🟠 위임 고려', priority: 3, color: 'orange' },
  { label: '🟢 여유있게', priority: 4, color: 'green' }
]

const sortOptions = [
  { label: '기본순', value: 'default' },
  { label: '우선순위순', value: 'priority' },
  { label: '마감일순', value: 'deadline' },
  { label: '카테고리순', value: 'category' },
  { label: '생성일순', value: 'createdAt' }
]
</script>
