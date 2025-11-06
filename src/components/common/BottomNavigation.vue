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
          class="flex flex-col items-center p-3 rounded-xl transition-all duration-300 min-w-0 flex-1 relative"
          :class="getNavItemClasses(item.name)"
        >
          <!-- 활성 탭 상단 인디케이터 -->
          <div
            v-if="$route.name === item.name"
            class="absolute -top-2 left-1/2 transform -translate-x-1/2 w-8 h-1 rounded-full transition-all duration-300"
            :class="getIndicatorClasses(item.name)"
          ></div>

          <!-- 아이콘 배경 -->
          <div class="relative mb-1">
            <div
              class="w-9 h-9 rounded-lg flex items-center justify-center transition-all duration-300"
              :class="getIconBackgroundClasses(item.name)"
            >
              <span class="text-xl transition-transform" :class="$route.name === item.name ? 'scale-110' : ''">{{ item.icon }}</span>
            </div>
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
  { name: 'Vision', path: '/vision', icon: '🌟', label: '비전', color: 'pink' },
  { name: 'Roadmap', path: '/roadmap', icon: '🗺️', label: '로드맵', color: 'orange' },
  { name: 'Quests', path: '/quests', icon: '🎯', label: '퀘스트', color: 'purple' },
  { name: 'Profile', path: '/profile', icon: '👤', label: '통계', color: 'green' }
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
      pink: 'bg-pink-100 border border-pink-200',
      orange: 'bg-orange-100 border border-orange-200',
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
      pink: 'text-pink-700 font-semibold',
      orange: 'text-orange-700 font-semibold',
      green: 'text-green-700 font-semibold'
    }
    return activeClasses[color] || 'text-gray-700 font-semibold'
  }

  return 'text-gray-500'
}

// 상단 인디케이터 클래스
function getIndicatorClasses(itemName) {
  const item = navItems.find(nav => nav.name === itemName)
  const color = item?.color || 'gray'

  const indicatorClasses = {
    blue: 'bg-gradient-to-r from-blue-400 to-blue-600',
    purple: 'bg-gradient-to-r from-purple-400 to-purple-600',
    pink: 'bg-gradient-to-r from-pink-400 to-pink-600',
    orange: 'bg-gradient-to-r from-orange-400 to-orange-600',
    green: 'bg-gradient-to-r from-green-400 to-green-600'
  }
  return indicatorClasses[color] || 'bg-gray-600'
}
</script>