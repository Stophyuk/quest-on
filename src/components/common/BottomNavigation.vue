<template>
  <!-- Habitica 스타일 하단 네비게이션 -->
  <nav class="fixed bottom-0 left-0 right-0 z-40">
    <!-- 분리된 배경과 쉐도우 -->
    <div class="bg-white border-t border-gray-200 shadow-2xl">
      <div class="flex justify-around items-center py-2 pb-safe max-w-md mx-auto">
        <router-link
          v-for="item in navItems"
          :key="item.name"
          :to="item.path"
          class="flex flex-col items-center p-3 rounded-xl transition-all duration-300 min-w-0 flex-1"
          :class="getNavItemClasses(item.name)"
        >
          <!-- 아이콘 배경 -->
          <div class="relative mb-1">
            <div
              class="w-8 h-8 rounded-lg flex items-center justify-center transition-all duration-300"
              :class="getIconBackgroundClasses(item.name)"
            >
              <span class="text-lg">{{ item.icon }}</span>
            </div>
            <!-- 활성화 상태 표시점 -->
            <div
              v-if="$route.name === item.name"
              class="absolute -top-1 -right-1 w-3 h-3 bg-blue-500 rounded-full border-2 border-white animate-pulse"
            ></div>
          </div>

          <!-- 라벨 -->
          <span
            class="text-xs font-medium transition-all duration-300"
            :class="getLabelClasses(item.name)"
          >
            {{ item.label }}
          </span>
        </router-link>
      </div>
    </div>
  </nav>
</template>

<script setup>
import { useRoute } from 'vue-router'

const route = useRoute()

const navItems = [
  { name: 'Home', path: '/', icon: '🏠', label: '홈', color: 'blue' },
  { name: 'Quests', path: '/quests', icon: '🎯', label: '퀘스트', color: 'purple' },
  { name: 'Profile', path: '/profile', icon: '👤', label: '프로필', color: 'green' }
]

// 네비게이션 아이템 클래스
function getNavItemClasses(itemName) {
  const isActive = route.name === itemName
  return isActive ? 'transform scale-105' : 'hover:transform hover:scale-105'
}

// 아이콘 배경 클래스
function getIconBackgroundClasses(itemName) {
  const isActive = route.name === itemName
  const item = navItems.find(nav => nav.name === itemName)
  const color = item?.color || 'gray'

  if (isActive) {
    const activeClasses = {
      blue: 'bg-blue-100 border border-blue-200',
      purple: 'bg-purple-100 border border-purple-200',
      green: 'bg-green-100 border border-green-200'
    }
    return activeClasses[color] || activeClasses.gray
  }

  return 'bg-gray-50 hover:bg-gray-100'
}

// 라벨 클래스
function getLabelClasses(itemName) {
  const isActive = route.name === itemName
  const item = navItems.find(nav => nav.name === itemName)
  const color = item?.color || 'gray'

  if (isActive) {
    const activeClasses = {
      blue: 'text-blue-700 font-semibold',
      purple: 'text-purple-700 font-semibold',
      green: 'text-green-700 font-semibold'
    }
    return activeClasses[color] || 'text-gray-700 font-semibold'
  }

  return 'text-gray-500'
}
</script>