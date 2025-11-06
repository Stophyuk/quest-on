// User Profile API
import { supabase } from '@/lib/supabase'

/**
 * 사용자 프로필 조회
 */
export async function getProfile() {
  const { data, error } = await supabase
    .from('user_profiles')
    .select('*')
    .single()

  if (error) throw error
  return data
}

/**
 * 프로필 생성 (회원가입 시)
 */
export async function createProfile(profileData) {
  const { nickname, character } = profileData

  const { data, error } = await supabase
    .from('user_profiles')
    .insert([
      {
        nickname,
        character,
        level: 0,
        experience: 0,
        total_points: 0,
      },
    ])
    .select()
    .single()

  if (error) throw error
  return data
}

/**
 * 프로필 업데이트
 */
export async function updateProfile(updates) {
  const { data, error } = await supabase
    .from('user_profiles')
    .update(updates)
    .eq('id', (await supabase.auth.getUser()).data.user.id)
    .select()
    .single()

  if (error) throw error
  return data
}

/**
 * 경험치 획득 (자동 레벨업 포함)
 */
export async function gainExperience(xpAmount) {
  const { data, error } = await supabase.rpc('gain_experience', {
    xp_amount: xpAmount,
  })

  if (error) throw error
  return data
}

/**
 * 포인트 사용
 */
export async function usePoints(amount) {
  const profile = await getProfile()

  if (profile.total_points < amount) {
    throw new Error('포인트가 부족합니다.')
  }

  const { data, error } = await supabase
    .from('user_profiles')
    .update({
      total_points: profile.total_points - amount,
    })
    .eq('id', profile.id)
    .select()
    .single()

  if (error) throw error
  return data
}

/**
 * 악세서리 구매
 */
export async function purchaseAccessory(accessoryId, price) {
  const profile = await getProfile()

  // 포인트 차감
  await usePoints(price)

  // 악세서리 목록에 추가
  const currentAccessories = profile.purchased_accessories || []
  const { data, error } = await supabase
    .from('user_profiles')
    .update({
      purchased_accessories: [...currentAccessories, accessoryId],
    })
    .eq('id', profile.id)
    .select()
    .single()

  if (error) throw error
  return data
}

/**
 * 악세서리 장착
 */
export async function equipAccessory(accessoryId) {
  const { data, error } = await supabase
    .from('user_profiles')
    .update({
      equipped_accessory: accessoryId,
    })
    .eq('id', (await supabase.auth.getUser()).data.user.id)
    .select()
    .single()

  if (error) throw error
  return data
}

/**
 * 주간 통계 조회
 */
export async function getWeeklyStats() {
  const { data, error } = await supabase.rpc('get_weekly_stats')

  if (error) throw error
  return data
}
