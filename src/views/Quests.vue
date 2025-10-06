<template>
  <div class="min-h-screen px-4 pt-6 safe-area-bottom" style="padding-bottom: 80px;">
    <!-- 헤더 -->
    <header class="text-center mb-6">
      <h1 class="text-3xl font-bold text-neutral-800 mb-1">🎯 퀘스트 관리</h1>
      <p class="text-neutral-600 text-sm">나만의 퀘스트를 설정하고 관리하세요</p>
    </header>

    <!-- 퀘스트 관리 컴포넌트 -->
    <QuestManager />
  </div>
</template>

<script setup>
import QuestManager from '../components/quest/QuestManager.vue'
</script>