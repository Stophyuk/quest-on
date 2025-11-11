-- Quest ON Database Schema
-- Supabase SQL Editor에서 실행하세요

-- ============================================================
-- 1. PROFILES 테이블 (비전 시스템)
-- ============================================================

CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  values TEXT[] NOT NULL,
  goal TEXT NOT NULL,
  reasons TEXT[] NOT NULL,
  vision_note TEXT,
  goal_tree JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ,

  UNIQUE(user_id)
);

-- RLS 정책
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own profile"
  ON profiles FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = user_id);

-- ============================================================
-- 2. QUESTS 테이블 (퀘스트 시스템)
-- ============================================================

CREATE TABLE IF NOT EXISTS quests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  category TEXT NOT NULL,
  difficulty TEXT NOT NULL,
  target_count INTEGER NOT NULL,
  current_count INTEGER NOT NULL DEFAULT 0,
  is_completed BOOLEAN NOT NULL DEFAULT FALSE,
  exp_reward INTEGER NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  deleted_at TIMESTAMPTZ,

  CONSTRAINT target_count_positive CHECK (target_count > 0),
  CONSTRAINT current_count_non_negative CHECK (current_count >= 0)
);

-- 인덱스
CREATE INDEX IF NOT EXISTS idx_quests_user_id ON quests(user_id);
CREATE INDEX IF NOT EXISTS idx_quests_is_completed ON quests(is_completed);
CREATE INDEX IF NOT EXISTS idx_quests_deleted_at ON quests(deleted_at);

-- RLS 정책
ALTER TABLE quests ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own quests"
  ON quests FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own quests"
  ON quests FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own quests"
  ON quests FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own quests"
  ON quests FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================================
-- 3. USER_STATS 테이블 (레벨 시스템)
-- ============================================================

CREATE TABLE IF NOT EXISTS user_stats (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  level INTEGER NOT NULL DEFAULT 1,
  current_exp INTEGER NOT NULL DEFAULT 0,
  total_exp INTEGER NOT NULL DEFAULT 0,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT level_positive CHECK (level > 0),
  CONSTRAINT exp_non_negative CHECK (current_exp >= 0 AND total_exp >= 0)
);

-- RLS 정책
ALTER TABLE user_stats ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own stats"
  ON user_stats FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own stats"
  ON user_stats FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own stats"
  ON user_stats FOR UPDATE
  USING (auth.uid() = user_id);

-- ============================================================
-- 4. 자동 업데이트 트리거 (updated_at)
-- ============================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- profiles 테이블 트리거
DROP TRIGGER IF EXISTS update_profiles_updated_at ON profiles;
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- user_stats 테이블 트리거
DROP TRIGGER IF EXISTS update_user_stats_updated_at ON user_stats;
CREATE TRIGGER update_user_stats_updated_at
  BEFORE UPDATE ON user_stats
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================================
-- 완료 메시지
-- ============================================================

DO $$
BEGIN
  RAISE NOTICE 'Quest ON 데이터베이스 스키마 생성 완료!';
  RAISE NOTICE '다음 단계:';
  RAISE NOTICE '1. Edge Functions 배포 (generate-vision-note, generate-goal-tree)';
  RAISE NOTICE '2. Flutter 앱에서 Supabase URL 및 Anon Key 확인';
END $$;
