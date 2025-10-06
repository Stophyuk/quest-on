import { Crown, Glasses, Sparkles, Heart, Star, Flame, Gift, Trophy, Diamond, Zap } from 'lucide-vue-next'

export const accessoryMap = {
  'glasses': { icon: Glasses, color: 'text-gray-600' },
  'heart': { icon: Heart, color: 'text-pink-500' },
  'gift': { icon: Gift, color: 'text-blue-500' },
  'crown': { icon: Crown, color: 'text-yellow-500' },
  'diamond': { icon: Diamond, color: 'text-cyan-400' },
  'trophy': { icon: Trophy, color: 'text-amber-500' },
  'star': { icon: Star, color: 'text-purple-500' },
  'sparkles': { icon: Sparkles, color: 'text-yellow-400' },
  'flame': { icon: Flame, color: 'text-orange-500' },
  'zap': { icon: Zap, color: 'text-blue-400' },
}

export function getAccessory(id) {
  return accessoryMap[id] || null
}
