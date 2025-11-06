// Vision & Roadmap API
import { supabase } from '@/lib/supabase'

/**
 * 비전 프로필 조회
 */
export async function getVisionProfile() {
  const { data, error } = await supabase
    .from('vision_profiles')
    .select('*')
    .order('created_at', { ascending: false })
    .limit(1)
    .single()

  if (error && error.code !== 'PGRST116') throw error // PGRST116 = no rows
  return data
}

/**
 * 비전 프로필 저장
 */
export async function saveVisionProfile(profileData) {
  const { data, error } = await supabase
    .from('vision_profiles')
    .insert([profileData])
    .select()
    .single()

  if (error) throw error
  return data
}

/**
 * 비전 노트 조회 (가장 최근)
 */
export async function getVisionNote() {
  const { data, error } = await supabase
    .from('vision_notes')
    .select('*')
    .order('created_at', { ascending: false })
    .limit(1)
    .single()

  if (error && error.code !== 'PGRST116') throw error
  return data
}

/**
 * AI 비전 노트 생성 (Edge Function 호출)
 */
export async function generateVisionNote(visionProfile) {
  const { data: { session } } = await supabase.auth.getSession()

  if (!session) {
    throw new Error('로그인이 필요합니다.')
  }

  const response = await fetch(
    `${import.meta.env.VITE_SUPABASE_URL}/functions/v1/generate-vision-note`,
    {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${session.access_token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ visionProfile }),
    }
  )

  if (!response.ok) {
    const errorData = await response.json()
    throw new Error(errorData.error || 'Failed to generate vision note')
  }

  const data = await response.json()
  return data.visionNote
}

/**
 * 목표 트리 조회 (가장 최근)
 */
export async function getGoalTree() {
  const { data, error } = await supabase
    .from('goal_trees')
    .select('*')
    .order('created_at', { ascending: false })
    .limit(1)
    .single()

  if (error && error.code !== 'PGRST116') throw error
  return data
}

/**
 * AI 목표 트리 생성 (Edge Function 호출)
 */
export async function generateGoalTree(visionNote, yearGoals) {
  const { data: { session } } = await supabase.auth.getSession()

  if (!session) {
    throw new Error('로그인이 필요합니다.')
  }

  const response = await fetch(
    `${import.meta.env.VITE_SUPABASE_URL}/functions/v1/generate-goal-tree`,
    {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${session.access_token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        visionNote,
        yearGoals,
      }),
    }
  )

  if (!response.ok) {
    const errorData = await response.json()
    throw new Error(errorData.error || 'Failed to generate goal tree')
  }

  const data = await response.json()
  return data.goalTree
}

/**
 * 주간 회고 저장
 */
export async function saveWeeklyReflection(reflectionData) {
  const { data, error } = await supabase
    .from('weekly_reflections')
    .insert([
      {
        reflection_data: reflectionData,
      },
    ])
    .select()
    .single()

  if (error) throw error
  return data
}

/**
 * 주간 회고 조회 (최근 4주)
 */
export async function getRecentReflections(limit = 4) {
  const { data, error } = await supabase
    .from('weekly_reflections')
    .select('*')
    .order('created_at', { ascending: false })
    .limit(limit)

  if (error) throw error
  return data || []
}

/**
 * 특정 주차 회고 조회
 */
export async function getReflectionByWeek(weekNumber) {
  const { data, error } = await supabase
    .from('weekly_reflections')
    .select('*')
    .eq('week_number', weekNumber)
    .single()

  if (error && error.code !== 'PGRST116') throw error
  return data
}

/**
 * AI 사용량 통계 조회 (현재 월)
 */
export async function getCurrentMonthAIUsage() {
  const startOfMonth = new Date()
  startOfMonth.setDate(1)
  startOfMonth.setHours(0, 0, 0, 0)

  const { data, error } = await supabase
    .from('ai_generation_logs')
    .select('generation_type, tokens_used, cost_usd')
    .gte('created_at', startOfMonth.toISOString())

  if (error) throw error

  // 타입별로 집계
  const summary = {
    total_tokens: 0,
    total_cost: 0,
    by_type: {},
  }

  data?.forEach((log) => {
    summary.total_tokens += log.tokens_used
    summary.total_cost += log.cost_usd

    if (!summary.by_type[log.generation_type]) {
      summary.by_type[log.generation_type] = {
        count: 0,
        tokens: 0,
        cost: 0,
      }
    }

    summary.by_type[log.generation_type].count += 1
    summary.by_type[log.generation_type].tokens += log.tokens_used
    summary.by_type[log.generation_type].cost += log.cost_usd
  })

  return summary
}
