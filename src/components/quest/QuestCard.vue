<template>
  <div class="bg-white rounded-lg shadow-sm border border-gray-100 p-4 mb-3 hover:shadow-md transition-shadow duration-200">
    <!-- 체크박스와 제목 영역 -->
    <div class="flex items-start gap-3 mb-3">
      <button
        @click="toggleComplete"
        class="flex-shrink-0 w-6 h-6 rounded border-2 transition-all duration-200 flex items-center justify-center mt-0.5"
        :class="[
          quest.completed
            ? 'bg-green-500 border-green-500 text-white'
            : 'border-gray-300 hover:border-gray-400 bg-white'
        ]"
      >
        <svg v-if="quest.completed" class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
          <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/>
        </svg>
      </button>

      <div class="flex-1 min-w-0">
        <div class="flex items-center justify-between">
          <h3 class="font-medium text-gray-900 text-base" :class="{ 'line-through text-gray-500': quest.completed }">
            {{ quest.title }}
          </h3>
          <span
            class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ml-2"
            :class="getCategoryClasses(quest.category)"
          >
            {{ getCategoryLabel(quest.category) }}
          </span>
        </div>
        <p class="text-gray-600 text-sm mt-1">{{ quest.description }}</p>
      </div>
    </div>

    <!-- 진행도 바 -->
    <div class="mb-4">
      <div class="flex justify-between items-center mb-2">
        <span class="text-sm text-gray-600">진행도</span>
        <span class="text-sm font-medium text-gray-900">{{ quest.progress }} / {{ quest.targetValue }}</span>
      </div>

      <div class="w-full bg-gray-200 rounded-full h-2.5">
        <div
          class="h-2.5 rounded-full transition-all duration-300"
          :class="getCategoryProgressColor(quest.category)"
          :style="{ width: progressPercentage + '%' }"
        ></div>
      </div>
    </div>

    <!-- 카운터 UI -->
    <div class="flex items-center justify-between bg-gray-50 rounded-lg p-3">
      <button
        @click="decreaseProgress"
        :disabled="quest.progress <= 0"
        class="w-8 h-8 rounded-full bg-white border border-gray-300 flex items-center justify-center text-gray-600 font-medium disabled:opacity-40 disabled:cursor-not-allowed hover:bg-gray-50 transition-colors duration-200 shadow-sm"
      >
        −
      </button>

      <div class="text-center">
        <div class="text-lg font-semibold text-gray-900">
          {{ quest.progress }}
        </div>
        <div class="text-xs text-gray-500">
          {{ getProgressText() }}
        </div>
      </div>

      <button
        @click="increaseProgress"
        :disabled="quest.progress >= quest.targetValue"
        class="w-8 h-8 rounded-full bg-white border border-gray-300 flex items-center justify-center text-gray-600 font-medium disabled:opacity-40 disabled:cursor-not-allowed hover:bg-gray-50 transition-colors duration-200 shadow-sm"
      >
        +
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue'

const props = defineProps({
  quest: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['update'])

const localProgress = ref(props.quest.progress)

const progressPercentage = computed(() => {
  return Math.min((props.quest.progress / props.quest.targetValue) * 100, 100)
})

watch(() => props.quest.progress, (newProgress) => {
  localProgress.value = newProgress
})

function getCategoryLabel(category) {
  const labels = {
    health: '건강',
    fitness: '운동',
    learning: '학습',
    work: '업무',
    hobby: '취미',
    custom: '일반'
  }
  return labels[category] || category
}

function getCategoryClasses(category) {
  const classes = {
    health: 'bg-green-100 text-green-800',
    fitness: 'bg-red-100 text-red-800',
    learning: 'bg-blue-100 text-blue-800',
    work: 'bg-purple-100 text-purple-800',
    hobby: 'bg-yellow-100 text-yellow-800',
    custom: 'bg-gray-100 text-gray-800'
  }
  return classes[category] || classes.custom
}

function getCategoryProgressColor(category) {
  const colors = {
    health: 'bg-green-500',
    fitness: 'bg-red-500',
    learning: 'bg-blue-500',
    work: 'bg-purple-500',
    hobby: 'bg-yellow-500',
    custom: 'bg-gray-500'
  }
  return colors[category] || colors.custom
}

function toggleComplete() {
  if (!props.quest.completed) {
    emit('update', props.quest.id, props.quest.targetValue)
  }
}

function updateProgress() {
  const value = Math.max(0, Math.min(localProgress.value, props.quest.targetValue))
  emit('update', props.quest.id, value)
}

function increaseProgress() {
  if (props.quest.progress < props.quest.targetValue) {
    emit('update', props.quest.id, props.quest.progress + 1)
  }
}

function decreaseProgress() {
  if (props.quest.progress > 0) {
    emit('update', props.quest.id, props.quest.progress - 1)
  }
}

function getProgressText() {
  if (props.quest.progress === 0) return '시작해보세요!'
  if (props.quest.progress === props.quest.targetValue) return '완료!'

  const percentage = Math.round((props.quest.progress / props.quest.targetValue) * 100)
  return `${percentage}% 달성`
}
</script>