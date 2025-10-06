<template>
  <div class="min-h-screen px-4 pt-6 safe-area-bottom" style="padding-bottom: 80px;">
    <!-- 헤더 -->
    <header class="text-center mb-6">
      <h1 class="text-3xl font-bold text-neutral-800 mb-1">📅 캘린더</h1>
      <p class="text-neutral-600 text-sm">퀘스트 일정을 한눈에 확인하세요</p>
    </header>

    <!-- 캘린더 컴포넌트 -->
    <QuestCalendar />
  </div>
</template>

<script setup>
import QuestCalendar from '../components/quest/QuestCalendar.vue'
</script>
