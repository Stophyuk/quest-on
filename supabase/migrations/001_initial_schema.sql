-- =====================================================
-- Quest ON - Initial Database Schema
-- =====================================================

-- 1. user_profiles 테이블
CREATE TABLE IF NOT EXISTS user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  nickname VARCHAR(10) NOT NULL,
  character_type VARCHAR(20) NOT NULL CHECK (character_type IN ('cat', 'dog', 'pig', 'rabbit')),
  level INTEGER DEFAULT 0 CHECK (level >= 0),
  experience INTEGER DEFAULT 0 CHECK (experience >= 0),
  total_completed INTEGER DEFAULT 0 CHECK (total_completed >= 0),
  join_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_active_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. quests 테이블
CREATE TABLE IF NOT EXISTS quests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL CHECK (char_length(title) > 0),
  difficulty VARCHAR(20) NOT NULL CHECK (difficulty IN ('easy', 'normal', 'hard')),
  is_recurring BOOLEAN DEFAULT FALSE,
  completed BOOLEAN DEFAULT FALSE,
  completed_at TIMESTAMP WITH TIME ZONE,
  streak INTEGER DEFAULT 0 CHECK (streak >= 0),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. vision_profiles 테이블
CREATE TABLE IF NOT EXISTS vision_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE,
  values TEXT[],
  current_identity TEXT,
  future_identity TEXT,
  life_dream TEXT,
  concerns TEXT,
  year_goals TEXT[],
  current_routine TEXT,
  available_time INTEGER,
  learning_style TEXT,
  motivation TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. vision_notes 테이블
CREATE TABLE IF NOT EXISTS vision_notes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  content JSONB NOT NULL,
  version INTEGER DEFAULT 1,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. goal_trees 테이블
CREATE TABLE IF NOT EXISTS goal_trees (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  tree_data JSONB NOT NULL,
  version INTEGER DEFAULT 1,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. weekly_reflections 테이블
CREATE TABLE IF NOT EXISTS weekly_reflections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  week_start_date DATE NOT NULL,
  week_end_date DATE NOT NULL,
  reflection_data JSONB NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, week_start_date)
);

-- 7. quest_history 테이블 (통계용)
CREATE TABLE IF NOT EXISTS quest_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  quest_id UUID REFERENCES quests(id) ON DELETE SET NULL,
  quest_title TEXT NOT NULL,
  difficulty VARCHAR(20) NOT NULL,
  xp_gained INTEGER NOT NULL,
  completed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 8. ai_generation_logs 테이블 (OpenAI 사용량 추적)
CREATE TABLE IF NOT EXISTS ai_generation_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  generation_type VARCHAR(50) NOT NULL,
  tokens_used INTEGER,
  cost_usd DECIMAL(10, 4),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 인덱스 생성
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_quests_user_id ON quests(user_id);
CREATE INDEX IF NOT EXISTS idx_quests_completed ON quests(user_id, completed);
CREATE INDEX IF NOT EXISTS idx_quests_recurring ON quests(user_id, is_recurring);
CREATE INDEX IF NOT EXISTS idx_vision_notes_user_id ON vision_notes(user_id);
CREATE INDEX IF NOT EXISTS idx_goal_trees_user_id ON goal_trees(user_id);
CREATE INDEX IF NOT EXISTS idx_weekly_reflections_user_id ON weekly_reflections(user_id);
CREATE INDEX IF NOT EXISTS idx_quest_history_user_id ON quest_history(user_id);
CREATE INDEX IF NOT EXISTS idx_quest_history_completed_at ON quest_history(user_id, completed_at);
CREATE INDEX IF NOT EXISTS idx_ai_logs_user_id ON ai_generation_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_ai_logs_created_at ON ai_generation_logs(created_at);

-- =====================================================
-- Row Level Security (RLS) 정책
-- =====================================================

-- RLS 활성화
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE quests ENABLE ROW LEVEL SECURITY;
ALTER TABLE vision_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE vision_notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE goal_trees ENABLE ROW LEVEL SECURITY;
ALTER TABLE weekly_reflections ENABLE ROW LEVEL SECURITY;
ALTER TABLE quest_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_generation_logs ENABLE ROW LEVEL SECURITY;

-- user_profiles 정책
CREATE POLICY "Users can view own profile" ON user_profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON user_profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON user_profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- quests 정책
CREATE POLICY "Users can view own quests" ON quests
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own quests" ON quests
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own quests" ON quests
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own quests" ON quests
  FOR DELETE USING (auth.uid() = user_id);

-- vision_profiles 정책
CREATE POLICY "Users can view own vision profile" ON vision_profiles
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own vision profile" ON vision_profiles
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own vision profile" ON vision_profiles
  FOR UPDATE USING (auth.uid() = user_id);

-- vision_notes 정책
CREATE POLICY "Users can view own vision notes" ON vision_notes
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own vision notes" ON vision_notes
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- goal_trees 정책
CREATE POLICY "Users can view own goal trees" ON goal_trees
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own goal trees" ON goal_trees
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- weekly_reflections 정책
CREATE POLICY "Users can view own reflections" ON weekly_reflections
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own reflections" ON weekly_reflections
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own reflections" ON weekly_reflections
  FOR UPDATE USING (auth.uid() = user_id);

-- quest_history 정책
CREATE POLICY "Users can view own quest history" ON quest_history
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own quest history" ON quest_history
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ai_generation_logs 정책
CREATE POLICY "Users can view own ai logs" ON ai_generation_logs
  FOR SELECT USING (auth.uid() = user_id);

-- =====================================================
-- 트리거 함수
-- =====================================================

-- updated_at 자동 업데이트
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 트리거 적용
CREATE TRIGGER update_user_profiles_updated_at
  BEFORE UPDATE ON user_profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_quests_updated_at
  BEFORE UPDATE ON quests
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_vision_profiles_updated_at
  BEFORE UPDATE ON vision_profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- RPC 함수들
-- =====================================================

-- 경험치 획득 및 레벨업 처리
CREATE OR REPLACE FUNCTION gain_experience(xp_amount INTEGER)
RETURNS user_profiles AS $$
DECLARE
  current_profile user_profiles;
  required_xp INTEGER;
BEGIN
  -- 현재 프로필 가져오기
  SELECT * INTO current_profile
  FROM user_profiles
  WHERE id = auth.uid();

  -- 경험치 추가
  current_profile.experience := current_profile.experience + xp_amount;

  -- 레벨업 체크 루프
  LOOP
    -- 필요 경험치 계산
    IF current_profile.level = 0 THEN
      required_xp := 30;
    ELSIF current_profile.level <= 4 THEN
      required_xp := 50 + (current_profile.level * 50);
    ELSE
      required_xp := 200 + ((current_profile.level - 4) * 100);
    END IF;

    -- 레벨업 가능한지 체크
    IF current_profile.experience >= required_xp THEN
      current_profile.level := current_profile.level + 1;
      current_profile.experience := current_profile.experience - required_xp;
    ELSE
      EXIT;
    END IF;
  END LOOP;

  -- 업데이트
  UPDATE user_profiles
  SET
    level = current_profile.level,
    experience = current_profile.experience,
    updated_at = NOW()
  WHERE id = auth.uid();

  RETURN current_profile;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 주간 통계 조회
CREATE OR REPLACE FUNCTION get_weekly_stats()
RETURNS TABLE(
  total_completed INTEGER,
  easy_count INTEGER,
  normal_count INTEGER,
  hard_count INTEGER,
  total_xp INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    COUNT(*)::INTEGER AS total_completed,
    COUNT(*) FILTER (WHERE difficulty = 'easy')::INTEGER AS easy_count,
    COUNT(*) FILTER (WHERE difficulty = 'normal')::INTEGER AS normal_count,
    COUNT(*) FILTER (WHERE difficulty = 'hard')::INTEGER AS hard_count,
    SUM(xp_gained)::INTEGER AS total_xp
  FROM quest_history
  WHERE
    user_id = auth.uid() AND
    completed_at >= NOW() - INTERVAL '7 days';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 초기 데이터 / 헬퍼 함수
-- =====================================================

-- 회원가입 시 프로필 자동 생성 트리거
CREATE OR REPLACE FUNCTION create_user_profile()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO user_profiles (id, nickname, character_type)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'nickname', '모험가'),
    COALESCE(NEW.raw_user_meta_data->>'character_type', 'cat')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION create_user_profile();
