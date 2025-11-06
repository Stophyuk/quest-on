<template>
  <button
    @click="openQuestModal"
    class="fixed bottom-20 right-5 w-14 h-14 rounded-full bg-gradient-to-br from-orange-500 to-pink-500 text-white text-3xl shadow-lg z-50 active:scale-95 transition-transform flex items-center justify-center hover:shadow-xl hover:from-orange-600 hover:to-pink-600"
    aria-label="새 퀘스트 추가"
    title="새 퀘스트 추가"
  >
    +
  </button>
</template>

<script setup>
function openQuestModal() {
  // Home.vue의 QuestModal 열기
  window.dispatchEvent(new CustomEvent('open-quest-modal'))
}
</script>
