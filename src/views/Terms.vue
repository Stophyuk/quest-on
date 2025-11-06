<template>
  <div class="min-h-screen bg-white">
    <div class="max-w-3xl mx-auto px-4 py-6">
      <!-- 헤더 -->
      <div class="flex items-center justify-between mb-6">
        <h1 class="text-2xl font-bold text-gray-800">이용약관</h1>
        <button
          @click="$router.back()"
          class="text-purple-600 hover:text-purple-700 font-medium"
        >
          ← 뒤로
        </button>
      </div>

      <!-- 마크다운 콘텐츠 -->
      <div class="prose prose-sm max-w-none">
        <div v-html="renderedContent" class="text-gray-700 leading-relaxed"></div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { marked } from 'marked'

const renderedContent = ref('')

onMounted(async () => {
  try {
    const response = await fetch('/terms-of-service.md')
    const markdown = await response.text()
    renderedContent.value = marked(markdown)
  } catch (error) {
    console.error('Failed to load terms:', error)
    renderedContent.value = '<p>이용약관을 불러오는 데 실패했습니다.</p>'
  }
})
</script>

<style>
.prose h1 {
  @apply text-2xl font-bold text-gray-900 mt-8 mb-4;
}

.prose h2 {
  @apply text-xl font-bold text-gray-800 mt-6 mb-3;
}

.prose h3 {
  @apply text-lg font-semibold text-gray-800 mt-4 mb-2;
}

.prose p {
  @apply text-gray-700 mb-4;
}

.prose ul, .prose ol {
  @apply mb-4 ml-6;
}

.prose li {
  @apply mb-2;
}

.prose strong {
  @apply font-semibold text-gray-900;
}

.prose hr {
  @apply my-8 border-gray-200;
}
</style>
