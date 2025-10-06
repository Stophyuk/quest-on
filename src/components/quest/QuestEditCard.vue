<template>
  <div class="quest-card p-4 relative group">
    <!-- 퀘스트 기본 정보 -->
    <div class="flex items-start justify-between mb-3">
      <div class="flex-1">
        <div class="flex items-center gap-2 mb-1">
          <span class="text-lg">{{ getCategoryIcon(quest.category) }}</span>
          <h3 class="font-semibold text-neutral-800">{{ quest.title }}</h3>
          <span class="text-xs bg-neutral-200 text-neutral-600 px-2 py-1 rounded-full">
            {{ getCategoryLabel(quest.category) }}
          </span>
        </div>
        <p class="text-sm text-neutral-600 mb-2">{{ quest.description }}</p>
        
        <!-- 난이도 정보 -->
        <div class="flex items-center gap-2 text-xs text-neutral-500">
          <span>목표:</span>
          <span class="text-mood-good">😊 {{ quest.difficulty['😊'] }}</span>
          <span class="text-mood-normal">😐 {{ quest.difficulty['😐'] }}</span>
          <span class="text-mood-tired">😞 {{ quest.difficulty['😞'] }}</span>
        </div>
      </div>
      
      <!-- 액션 버튼들 -->
      <div class="flex items-center gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
        <button
          @click="$emit('detail', quest)"
          class="p-2 rounded-lg bg-purple-100 text-purple-600 hover:bg-purple-200 transition-colors"
          title="상세 편집"
        >
          📝
        </button>
        <button
          @click="$emit('edit', quest)"
          class="p-2 rounded-lg bg-blue-100 text-blue-600 hover:bg-blue-200 transition-colors"
          title="빠른 편집"
        >
          ✏️
        </button>
        <button
          @click="$emit('delete', quest.id)"
          class="p-2 rounded-lg bg-red-100 text-red-600 hover:bg-red-200 transition-colors"
          title="삭제"
        >
          🗑️
        </button>
      </div>
    </div>

    <!-- 진행도 섹션 -->
    <div class="space-y-2">
      <div class="flex justify-between items-center text-sm">
        <span class="text-neutral-600">진행도</span>
        <span class="font-medium">{{ quest.progress }} / {{ currentTarget }}</span>
      </div>
      
      <!-- 진행도 바 -->
      <div class="progress-bar">
        <div 
          class="progress-fill"
          :style="{ width: progressPercentage + '%' }"
        ></div>
      </div>
      
      <!-- 진행도 조절 -->
      <div class="flex items-center gap-2">
        <button
          @click="decreaseProgress"
          :disabled="quest.progress <= 0"
          class="w-8 h-8 rounded-full bg-neutral-200 flex items-center justify-center text-neutral-600 disabled:opacity-50 hover:bg-neutral-300 transition-colors"
        >
          -
        </button>
        
        <input
          v-model.number="localProgress"
          @input="updateProgress"
          type="number"
          :min="0"
          :max="currentTarget"
          class="flex-1 text-center py-1 px-2 rounded border border-neutral-300 focus:outline-none focus:ring-2 focus:ring-primary-500"
        >
        
        <button
          @click="increaseProgress"
          :disabled="quest.progress >= currentTarget"
          class="w-8 h-8 rounded-full bg-neutral-200 flex items-center justify-center text-neutral-600 disabled:opacity-50 hover:bg-neutral-300 transition-colors"
        >
          +
        </button>
        
        <button
          @click="completeQuest"
          :disabled="quest.completed"
          class="px-3 py-1 rounded-lg text-sm font-medium transition-colors"
          :class="quest.completed 
            ? 'bg-green-100 text-green-600 cursor-not-allowed' 
            : 'bg-primary-600 text-white hover:bg-primary-700'"
        >
          {{ quest.completed ? '완료됨' : '완료' }}
        </button>
      </div>
    </div>

    <!-- 완료 상태 표시 -->
    <div v-if="quest.completed" class="absolute top-2 right-2">
      <div class="w-6 h-6 bg-green-500 rounded-full flex items-center justify-center">
        <span class="text-white text-xs">✓</span>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, ref, watch } from 'vue'
import { useQuestStore } from '../../stores/quest'

const props = defineProps({
  quest: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['edit', 'detail', 'delete', 'update'])

const questStore = useQuestStore()
const localProgress = ref(props.quest.progress)

// 현재 컨디션에 따른 목표값
const currentTarget = computed(() => {
  return props.quest.difficulty[questStore.currentCondition] || 1
})

// 진행률 계산
const progressPercentage = computed(() => {
  return Math.min((props.quest.progress / currentTarget.value) * 100, 100)
})

// 카테고리 아이콘 매핑
function getCategoryIcon(category) {
  const icons = {
    health: '💚',
    fitness: '💪',
    learning: '📚',
    work: '💼',
    hobby: '🎨',
    custom: '⭐'
  }
  return icons[category] || '⭐'
}

// 카테고리 라벨 매핑
function getCategoryLabel(category) {
  const labels = {
    health: '건강',
    fitness: '운동',
    learning: '학습',
    work: '업무',
    hobby: '취미',
    custom: '기타'
  }
  return labels[category] || '기타'
}

// 진행도 업데이트
function updateProgress() {
  const value = Math.max(0, Math.min(localProgress.value, currentTarget.value))
  emit('update', props.quest.id, value)
}

// 진행도 증가
function increaseProgress() {
  if (props.quest.progress < currentTarget.value) {
    emit('update', props.quest.id, props.quest.progress + 1)
  }
}

// 진행도 감소
function decreaseProgress() {
  if (props.quest.progress > 0) {
    emit('update', props.quest.id, props.quest.progress - 1)
  }
}

// 퀘스트 완료
function completeQuest() {
  if (!props.quest.completed) {
    emit('update', props.quest.id, currentTarget.value)
  }
}

// props 변경 감지
watch(() => props.quest.progress, (newProgress) => {
  localProgress.value = newProgress
})
</script>