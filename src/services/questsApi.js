// Quests API
import { supabase } from '@/lib/supabase'

/**
 * 모든 퀘스트 조회 (오늘 날짜 기준)
 */
export async function getQuests(date = new Date().toISOString().split('T')[0]) {
  const { data, error } = await supabase
    .from('quests')
    .select('*')
    .eq('quest_date', date)
    .order('created_at', { ascending: false })

  if (error) throw error
  return data || []
}

/**
 * 퀘스트 추가
 */
export async function createQuest(questData) {
  const { title, difficulty, is_recurring, quest_date } = questData

  const { data, error } = await supabase
    .from('quests')
    .insert([
      {
        title,
        difficulty: difficulty || 'normal',
        is_recurring: is_recurring || false,
        quest_date: quest_date || new Date().toISOString().split('T')[0],
        completed: false,
        completed_at: null,
      },
    ])
    .select()
    .single()

  if (error) throw error
  return data
}

/**
 * 퀘스트 완료/취소
 */
export async function toggleQuestComplete(questId, completed) {
  const updates = {
    completed,
    completed_at: completed ? new Date().toISOString() : null,
  }

  const { data, error } = await supabase
    .from('quests')
    .update(updates)
    .eq('id', questId)
    .select()
    .single()

  if (error) throw error

  // 완료 시 퀘스트 히스토리에 추가
  if (completed) {
    await addQuestHistory(data)
  }

  return data
}

/**
 * 퀘스트 수정
 */
export async function updateQuest(questId, updates) {
  const { data, error } = await supabase
    .from('quests')
    .update(updates)
    .eq('id', questId)
    .select()
    .single()

  if (error) throw error
  return data
}

/**
 * 퀘스트 삭제
 */
export async function deleteQuest(questId) {
  const { error } = await supabase.from('quests').delete().eq('id', questId)

  if (error) throw error
}

/**
 * 반복 퀘스트 다음 날로 복사
 */
export async function duplicateRecurringQuests() {
  const today = new Date().toISOString().split('T')[0]

  // 오늘의 반복 퀘스트 조회
  const { data: recurringQuests, error: fetchError } = await supabase
    .from('quests')
    .select('*')
    .eq('quest_date', today)
    .eq('is_recurring', true)

  if (fetchError) throw fetchError

  if (!recurringQuests || recurringQuests.length === 0) {
    return []
  }

  // 내일 날짜 계산
  const tomorrow = new Date()
  tomorrow.setDate(tomorrow.getDate() + 1)
  const tomorrowStr = tomorrow.toISOString().split('T')[0]

  // 내일로 복사
  const newQuests = recurringQuests.map((quest) => ({
    title: quest.title,
    difficulty: quest.difficulty,
    is_recurring: true,
    quest_date: tomorrowStr,
    completed: false,
    completed_at: null,
  }))

  const { data, error } = await supabase.from('quests').insert(newQuests).select()

  if (error) throw error
  return data
}

/**
 * 퀘스트 히스토리에 추가
 */
async function addQuestHistory(quest) {
  const xpGained = getXPByDifficulty(quest.difficulty)

  const { error } = await supabase.from('quest_history').insert([
    {
      quest_title: quest.title,
      difficulty: quest.difficulty,
      completed_at: quest.completed_at,
      xp_gained: xpGained,
    },
  ])

  if (error) {
    console.error('Failed to add quest history:', error)
  }
}

/**
 * 난이도별 XP 계산
 */
function getXPByDifficulty(difficulty) {
  const xpMap = {
    easy: 10,
    normal: 20,
    hard: 30,
  }
  return xpMap[difficulty] || 20
}

/**
 * 주간 목표 조회 (가장 최근)
 */
export async function getCurrentWeekGoal() {
  const { data, error } = await supabase
    .from('quests')
    .select('week_goal')
    .not('week_goal', 'is', null)
    .order('created_at', { ascending: false })
    .limit(1)
    .single()

  if (error && error.code !== 'PGRST116') throw error // PGRST116 = no rows
  return data?.week_goal || null
}

/**
 * AI 퀘스트 추천 (Edge Function 호출)
 */
export async function suggestQuests(currentWeekGoal, condition) {
  const { data: { session } } = await supabase.auth.getSession()

  if (!session) {
    throw new Error('로그인이 필요합니다.')
  }

  const response = await fetch(
    `${import.meta.env.VITE_SUPABASE_URL}/functions/v1/suggest-quests`,
    {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${session.access_token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        currentWeekGoal,
        condition,
      }),
    }
  )

  if (!response.ok) {
    const errorData = await response.json()
    throw new Error(errorData.error || 'Failed to suggest quests')
  }

  const data = await response.json()
  return data.suggestions
}
