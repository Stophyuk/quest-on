<template>
  <!-- 악세사리 프리뷰 모달 -->
  <div
    v-if="showPreview"
    class="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-70 animate-fade-in"
    @click="showPreview = false"
  >
    <div class="bg-white rounded-3xl p-8 max-w-sm mx-4 text-center animate-scale-up" @click.stop>
      <h3 class="text-xl font-bold text-neutral-800 mb-4">미리보기</h3>

      <!-- 캐릭터 프리뷰 -->
      <div class="mb-6 relative inline-block">
        <div class="text-9xl">
          {{ userCharacter }}
        </div>
        <div class="absolute -top-4 right-1/2 transform translate-x-1/2">
          <component
            v-if="previewAccessory?.icon"
            :is="previewAccessory.icon"
            :class="previewAccessory.color"
            :size="64"
            :stroke-width="2.5"
          />
        </div>
      </div>

      <p class="text-neutral-600 mb-2">{{ previewAccessory?.name }}</p>
      <div class="flex items-center justify-center gap-1 text-amber-700 mb-6">
        <span>💎</span>
        <span class="font-bold">{{ previewAccessory?.price }}</span>
      </div>

      <div class="flex gap-3">
        <button
          @click="showPreview = false"
          class="flex-1 py-2 px-4 border border-neutral-300 text-neutral-700 rounded-lg hover:bg-neutral-50 transition-colors"
        >
          취소
        </button>
        <button
          @click="confirmPurchase"
          :disabled="!canAfford(previewAccessory?.price)"
          class="flex-1 py-2 px-4 bg-purple-500 text-white rounded-lg hover:bg-purple-600 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
        >
          구매하기
        </button>
      </div>
    </div>
  </div>

  <div class="card p-6">
    <div class="flex items-center justify-between mb-4">
      <h3 class="text-lg font-semibold text-neutral-800 flex items-center gap-2">
        <span class="text-xl">🛍️</span>
        악세사리 상점
      </h3>
      <div class="flex items-center gap-2 bg-amber-100 px-3 py-1 rounded-full">
        <span class="text-base">💎</span>
        <span class="font-bold text-amber-700">{{ questStore.points }}</span>
      </div>
    </div>

    <p class="text-sm text-neutral-600 mb-4">
      레벨업으로 획득한 포인트로 캐릭터를 꾸며보세요!
    </p>

    <!-- 악세사리 그리드 -->
    <div class="grid grid-cols-2 gap-3">
      <div
        v-for="accessory in accessories"
        :key="accessory.id"
        class="border-2 rounded-xl p-4 transition-all duration-200"
        :class="[
          isOwned(accessory.id)
            ? 'border-green-300 bg-green-50'
            : canAfford(accessory.price)
              ? 'border-neutral-200 hover:border-purple-300 hover:bg-purple-50 cursor-pointer'
              : 'border-neutral-200 bg-neutral-50 opacity-60'
        ]"
        @click="handleAccessoryClick(accessory)"
      >
        <!-- 악세사리 아이콘 -->
        <div class="text-center mb-2 flex items-center justify-center">
          <component :is="accessory.icon" :class="accessory.color" :size="48" :stroke-width="2" />
        </div>

        <!-- 악세사리 이름 -->
        <h4 class="text-sm font-medium text-neutral-800 text-center mb-2">
          {{ accessory.name }}
        </h4>

        <!-- 가격 또는 상태 -->
        <div class="text-center">
          <div v-if="isOwned(accessory.id)" class="text-xs text-green-600 font-medium">
            ✓ 보유 중
          </div>
          <div v-else-if="isEquipped(accessory.id)" class="text-xs text-purple-600 font-bold">
            착용 중
          </div>
          <div v-else class="flex items-center justify-center gap-1 text-amber-700">
            <span class="text-xs">💎</span>
            <span class="font-bold text-sm">{{ accessory.price }}</span>
          </div>
        </div>

        <!-- 착용 버튼 (보유 중인 경우) -->
        <button
          v-if="isOwned(accessory.id)"
          @click.stop="equipAccessory(accessory.id)"
          :class="[
            'w-full mt-2 py-1 px-2 rounded-lg text-xs font-medium transition-colors',
            isEquipped(accessory.id)
              ? 'bg-neutral-200 text-neutral-600'
              : 'bg-purple-500 text-white hover:bg-purple-600'
          ]"
        >
          {{ isEquipped(accessory.id) ? '착용 중' : '착용하기' }}
        </button>
      </div>
    </div>

    <!-- 성공 메시지 -->
    <div
      v-if="showSuccess"
      class="fixed bottom-24 left-1/2 transform -translate-x-1/2 bg-green-600 text-white px-4 py-2 rounded-lg shadow-lg z-50 animate-slide-up"
    >
      {{ successMessage }}
    </div>

    <!-- 에러 메시지 -->
    <div
      v-if="showError"
      class="fixed bottom-24 left-1/2 transform -translate-x-1/2 bg-red-600 text-white px-4 py-2 rounded-lg shadow-lg z-50 animate-slide-up"
    >
      {{ errorMessage }}
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useQuestStore } from '../../stores/quest'
import { Crown, Glasses, Sparkles, Heart, Star, Flame, Gift, Trophy, Diamond, Zap } from 'lucide-vue-next'

const questStore = useQuestStore()

// 프리뷰 모달
const showPreview = ref(false)
const previewAccessory = ref(null)
const userCharacter = ref('🐱')

// 성공/에러 메시지
const showSuccess = ref(false)
const successMessage = ref('')
const showError = ref(false)
const errorMessage = ref('')

// 캐릭터 이모지 매핑
const characterEmojis = {
  'cat': '🐱',
  'dog': '🐶',
  'pig': '🐷',
  'rabbit': '🐰'
}

// 악세사리 목록 (Lucide Icons 사용)
const accessories = ref([
  { id: 'glasses', name: '안경', icon: Glasses, price: 50, rarity: 'basic', color: 'text-gray-600' },
  { id: 'heart', name: '하트', icon: Heart, price: 50, rarity: 'basic', color: 'text-pink-500' },
  { id: 'gift', name: '선물', icon: Gift, price: 50, rarity: 'basic', color: 'text-blue-500' },
  { id: 'crown', name: '왕관', icon: Crown, price: 150, rarity: 'rare', color: 'text-yellow-500' },
  { id: 'diamond', name: '다이아', icon: Diamond, price: 150, rarity: 'rare', color: 'text-cyan-400' },
  { id: 'trophy', name: '트로피', icon: Trophy, price: 150, rarity: 'rare', color: 'text-amber-500' },
  { id: 'star', name: '별', icon: Star, price: 300, rarity: 'special', color: 'text-purple-500' },
  { id: 'sparkles', name: '반짝임', icon: Sparkles, price: 300, rarity: 'special', color: 'text-yellow-400' },
  { id: 'flame', name: '불꽃', icon: Flame, price: 300, rarity: 'special', color: 'text-orange-500' },
  { id: 'zap', name: '번개', icon: Zap, price: 300, rarity: 'special', color: 'text-blue-400' },
])

// 보유 여부 체크
function isOwned(accessoryId) {
  return questStore.accessories.includes(accessoryId)
}

// 착용 여부 체크
function isEquipped(accessoryId) {
  return questStore.equippedAccessory === accessoryId
}

// 구매 가능 여부 체크
function canAfford(price) {
  return questStore.points >= price
}

// 악세사리 클릭 핸들러
function handleAccessoryClick(accessory) {
  if (isOwned(accessory.id)) {
    equipAccessory(accessory.id)
  } else {
    // 프리뷰 모달 표시
    previewAccessory.value = accessory
    showPreview.value = true
  }
}

// 프리뷰에서 구매 확정
function confirmPurchase() {
  if (!previewAccessory.value) return

  buyAccessory(previewAccessory.value)
  showPreview.value = false
}

// 악세사리 구매
function buyAccessory(accessory) {
  if (!canAfford(accessory.price)) {
    showErrorMessage('포인트가 부족합니다!')
    return
  }

  const success = questStore.buyAccessory(accessory)
  if (success) {
    showSuccessMessage(`${accessory.name}을(를) 구매했습니다! 🎉`)
  } else {
    showErrorMessage('구매에 실패했습니다')
  }
}

// 악세사리 착용
function equipAccessory(accessoryId) {
  if (isEquipped(accessoryId)) {
    // 이미 착용 중이면 해제
    questStore.equipAccessory(null)
    showSuccessMessage('악세사리를 해제했습니다')
  } else {
    const success = questStore.equipAccessory(accessoryId)
    if (success) {
      const accessory = accessories.value.find(a => a.id === accessoryId)
      showSuccessMessage(`${accessory?.name}을(를) 착용했습니다! ✨`)
    }
  }
}

// 성공 메시지 표시
function showSuccessMessage(message) {
  successMessage.value = message
  showSuccess.value = true
  setTimeout(() => {
    showSuccess.value = false
  }, 2000)
}

// 에러 메시지 표시
function showErrorMessage(message) {
  errorMessage.value = message
  showError.value = true
  setTimeout(() => {
    showError.value = false
  }, 2000)
}

onMounted(() => {
  const characterId = localStorage.getItem('quest-on-user-character') || 'cat'
  userCharacter.value = characterEmojis[characterId] || '🐱'
})
</script>

<style scoped>
@keyframes slide-up {
  from {
    opacity: 0;
    transform: translate(-50%, 20px);
  }
  to {
    opacity: 1;
    transform: translate(-50%, 0);
  }
}

@keyframes fade-in {
  from { opacity: 0; }
  to { opacity: 1; }
}

@keyframes scale-up {
  from {
    opacity: 0;
    transform: scale(0.8);
  }
  to {
    opacity: 1;
    transform: scale(1);
  }
}

.animate-slide-up {
  animation: slide-up 0.3s ease-out;
}

.animate-fade-in {
  animation: fade-in 0.3s ease-out;
}

.animate-scale-up {
  animation: scale-up 0.4s cubic-bezier(0.34, 1.56, 0.64, 1);
}
</style>
