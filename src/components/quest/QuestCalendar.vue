<template>
  <div class="space-y-4">
    <!-- v-calendar -->
    <div class="bg-white rounded-2xl shadow-sm p-4">
      <Calendar
        :attributes="calendarAttributes"
        @dayclick="handleDayClick"
        expanded
        borderless
        transparent
      />
    </div>

    <!-- 선택된 날짜의 퀘스트 목록 -->
    <div v-if="selectedDate" class="bg-white rounded-2xl shadow-sm p-4">
      <div class="flex justify-between items-center mb-4">
        <h3 class="text-lg font-bold text-gray-800">
          {{ formattedSelectedDate }}
        </h3>
        <button @click="selectedDate = null" class="text-gray-400 text-xl">×</button>
      </div>

      <!-- 스케줄된 퀘스트 -->
      <div v-if="scheduledQuests.length > 0" class="mb-4">
        <h4 class="text-sm font-semibold text-gray-600 mb-2">📌 예정된 퀘스트</h4>
        <div class="space-y-2">
          <div
            v-for="quest in scheduledQuests"
            :key="'scheduled-' + quest.id"
            class="p-3 bg-blue-50 rounded-lg"
          >
            <div class="flex items-center gap-2">
              <span>{{ getCategoryEmoji(quest.meta.category) }}</span>
              <span class="font-medium text-gray-800">{{ quest.title }}</span>
            </div>
            <div v-if="quest.meta.estimatedMinutes" class="text-xs text-gray-600 mt-1">
              ⏱️ 예상 {{ quest.meta.estimatedMinutes }}분
            </div>
          </div>
        </div>
      </div>

      <!-- 마감일인 퀘스트 -->
      <div v-if="deadlineQuests.length > 0">
        <h4 class="text-sm font-semibold text-gray-600 mb-2">🚨 마감 퀘스트</h4>
        <div class="space-y-2">
          <div
            v-for="quest in deadlineQuests"
            :key="'deadline-' + quest.id"
            class="p-3 bg-red-50 rounded-lg"
          >
            <div class="flex items-center gap-2">
              <span>{{ getCategoryEmoji(quest.meta.category) }}</span>
              <span class="font-medium text-gray-800">{{ quest.title }}</span>
            </div>
            <div class="text-xs text-red-600 mt-1">
              🔔 마감일입니다!
            </div>
          </div>
        </div>
      </div>

      <!-- 퀘스트가 없을 때 -->
      <div v-if="scheduledQuests.length === 0 && deadlineQuests.length === 0" class="text-center py-8 text-gray-400">
        <div class="text-3xl mb-2">📭</div>
        <p class="text-sm">이 날짜에는 예정된 퀘스트가 없습니다</p>
      </div>
    </div>

    <!-- 범례 -->
    <div class="bg-white rounded-2xl shadow-sm p-4">
      <h3 class="text-sm font-semibold text-gray-700 mb-3">📊 범례</h3>
      <div class="grid grid-cols-2 gap-2 text-xs">
        <div class="flex items-center gap-2">
          <div class="w-3 h-3 rounded-full bg-blue-500"></div>
          <span>예정된 퀘스트</span>
        </div>
        <div class="flex items-center gap-2">
          <div class="w-3 h-3 rounded-full bg-red-500"></div>
          <span>마감일</span>
        </div>
        <div class="flex items-center gap-2">
          <div class="w-3 h-3 rounded-full bg-purple-500"></div>
          <span>반복 퀘스트</span>
        </div>
        <div class="flex items-center gap-2">
          <div class="w-3 h-3 rounded-full bg-green-500"></div>
          <span>완료됨</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { Calendar } from 'v-calendar'
import { useQuestStore } from '@/stores/quest'
import { useQuestMetaStore, CATEGORIES } from '@/stores/questMeta'
import 'v-calendar/style.css'

const questStore = useQuestStore()
const questMetaStore = useQuestMetaStore()

const selectedDate = ref(null)

// 퀘스트와 메타 데이터 결합
const questsWithMeta = computed(() => {
  return questStore.quests.map(quest => ({
    ...quest,
    meta: questMetaStore.getQuestMeta(quest.id)
  }))
})

// 캘린더 속성 (날짜별 점과 색상)
const calendarAttributes = computed(() => {
  const attrs = []

  questsWithMeta.value.forEach(quest => {
    // 시작일
    if (quest.meta.scheduledDate) {
      attrs.push({
        key: `scheduled-${quest.id}`,
        dot: {
          color: quest.isCompleted ? 'green' : 'blue'
        },
        dates: new Date(quest.meta.scheduledDate)
      })
    }

    // 마감일
    if (quest.meta.deadline) {
      attrs.push({
        key: `deadline-${quest.id}`,
        dot: {
          color: quest.isCompleted ? 'green' : 'red'
        },
        dates: new Date(quest.meta.deadline)
      })
    }

    // 반복 퀘스트 (간단한 시각화)
    if (quest.meta.isRecurring && !quest.meta.parentQuestId) {
      // 반복 퀘스트는 보라색 점으로 표시 (향후 자동 생성 날짜 표시 가능)
      attrs.push({
        key: `recurring-${quest.id}`,
        dot: {
          color: 'purple'
        },
        dates: quest.meta.recurrenceDays?.length > 0
          ? { weekdays: quest.meta.recurrenceDays.map(d => d + 1) } // v-calendar는 1-7 (일-토)
          : new Date()
      })
    }
  })

  return attrs
})

// 날짜 클릭 핸들러
function handleDayClick(day) {
  selectedDate.value = day.date
}

// 선택된 날짜 포맷
const formattedSelectedDate = computed(() => {
  if (!selectedDate.value) return ''
  const date = new Date(selectedDate.value)
  const year = date.getFullYear()
  const month = date.getMonth() + 1
  const day = date.getDate()
  const weekdays = ['일', '월', '화', '수', '목', '금', '토']
  const weekday = weekdays[date.getDay()]
  return `${year}년 ${month}월 ${day}일 (${weekday})`
})

// 선택된 날짜의 스케줄된 퀘스트
const scheduledQuests = computed(() => {
  if (!selectedDate.value) return []
  const dateString = formatDateString(selectedDate.value)
  return questsWithMeta.value.filter(q => q.meta.scheduledDate === dateString)
})

// 선택된 날짜의 마감 퀘스트
const deadlineQuests = computed(() => {
  if (!selectedDate.value) return []
  const dateString = formatDateString(selectedDate.value)
  return questsWithMeta.value.filter(q => q.meta.deadline === dateString)
})

// 날짜 포맷 (YYYY-MM-DD)
function formatDateString(date) {
  const d = new Date(date)
  const year = d.getFullYear()
  const month = String(d.getMonth() + 1).padStart(2, '0')
  const day = String(d.getDate()).padStart(2, '0')
  return `${year}-${month}-${day}`
}

// 카테고리 이모지 가져오기
function getCategoryEmoji(categoryId) {
  const category = CATEGORIES.find(c => c.id === categoryId)
  return category ? category.label.split(' ')[0] : '📌'
}
</script>

<style>
/* v-calendar 커스터마이징 */
.vc-container {
  --vc-accent-50: rgb(243 232 255);
  --vc-accent-100: rgb(233 213 255);
  --vc-accent-200: rgb(216 180 254);
  --vc-accent-300: rgb(192 132 252);
  --vc-accent-400: rgb(168 85 247);
  --vc-accent-500: rgb(147 51 234);
  --vc-accent-600: rgb(126 34 206);
  --vc-accent-700: rgb(107 33 168);
  --vc-accent-800: rgb(88 28 135);
  --vc-accent-900: rgb(71 23 109);
  border: none !important;
}
</style>
