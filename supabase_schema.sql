-- ============================================
-- Quest ON v2.0 - Supabase Database Schema
-- ============================================
-- 작성일: 2025-11-10
-- 설명: 비전, 목표, 회고 테이블 정의 및 RLS 정책
-- ============================================

-- 1. visions 테이블 (비전 노트)
-- ============================================
CREATE TABLE IF NOT EXISTS public.visions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    answers JSONB NOT NULL DEFAULT '{}'::jsonb,
    vision_note TEXT NOT NULL DEFAULT '',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE
);

-- visions 테이블 인덱스
CREATE INDEX IF NOT EXISTS visions_user_id_idx ON public.visions(user_id);
CREATE INDEX IF NOT EXISTS visions_created_at_idx ON public.visions(created_at DESC);

-- visions 테이블 RLS 활성화
ALTER TABLE public.visions ENABLE ROW LEVEL SECURITY;

-- visions 테이블 RLS 정책
CREATE POLICY "Users can view their own visions"
    ON public.visions FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own visions"
    ON public.visions FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own visions"
    ON public.visions FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own visions"
    ON public.visions FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================
-- 2. goal_trees 테이블 (목표 트리)
-- ============================================
CREATE TABLE IF NOT EXISTS public.goal_trees (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    vision_id UUID NOT NULL REFERENCES public.visions(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE
);

-- goal_trees 테이블 인덱스
CREATE INDEX IF NOT EXISTS goal_trees_user_id_idx ON public.goal_trees(user_id);
CREATE INDEX IF NOT EXISTS goal_trees_vision_id_idx ON public.goal_trees(vision_id);

-- goal_trees 테이블 RLS 활성화
ALTER TABLE public.goal_trees ENABLE ROW LEVEL SECURITY;

-- goal_trees 테이블 RLS 정책
CREATE POLICY "Users can view their own goal trees"
    ON public.goal_trees FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own goal trees"
    ON public.goal_trees FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own goal trees"
    ON public.goal_trees FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own goal trees"
    ON public.goal_trees FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================
-- 3. goals 테이블 (개별 목표)
-- ============================================
CREATE TABLE IF NOT EXISTS public.goals (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    goal_tree_id UUID NOT NULL REFERENCES public.goal_trees(id) ON DELETE CASCADE,
    parent_goal_id UUID REFERENCES public.goals(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    timeframe TEXT NOT NULL CHECK (timeframe IN ('longTerm', 'midTerm', 'shortTerm', 'weekly')),
    order_index INTEGER NOT NULL DEFAULT 0,
    is_completed BOOLEAN NOT NULL DEFAULT FALSE,
    target_date TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    completed_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
);

-- goals 테이블 인덱스
CREATE INDEX IF NOT EXISTS goals_user_id_idx ON public.goals(user_id);
CREATE INDEX IF NOT EXISTS goals_goal_tree_id_idx ON public.goals(goal_tree_id);
CREATE INDEX IF NOT EXISTS goals_parent_goal_id_idx ON public.goals(parent_goal_id);
CREATE INDEX IF NOT EXISTS goals_timeframe_idx ON public.goals(timeframe);
CREATE INDEX IF NOT EXISTS goals_is_completed_idx ON public.goals(is_completed);

-- goals 테이블 RLS 활성화
ALTER TABLE public.goals ENABLE ROW LEVEL SECURITY;

-- goals 테이블 RLS 정책
CREATE POLICY "Users can view their own goals"
    ON public.goals FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own goals"
    ON public.goals FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own goals"
    ON public.goals FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own goals"
    ON public.goals FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================
-- 4. reflections 테이블 (회고)
-- ============================================
CREATE TABLE IF NOT EXISTS public.reflections (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN ('weekly', 'monthly')),
    start_date TIMESTAMP WITH TIME ZONE NOT NULL,
    end_date TIMESTAMP WITH TIME ZONE NOT NULL,
    total_quests INTEGER NOT NULL DEFAULT 0,
    completed_quests INTEGER NOT NULL DEFAULT 0,
    user_thoughts TEXT,
    ai_coaching_message TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- reflections 테이블 인덱스
CREATE INDEX IF NOT EXISTS reflections_user_id_idx ON public.reflections(user_id);
CREATE INDEX IF NOT EXISTS reflections_type_idx ON public.reflections(type);
CREATE INDEX IF NOT EXISTS reflections_created_at_idx ON public.reflections(created_at DESC);
CREATE INDEX IF NOT EXISTS reflections_date_range_idx ON public.reflections(start_date, end_date);

-- reflections 테이블 RLS 활성화
ALTER TABLE public.reflections ENABLE ROW LEVEL SECURITY;

-- reflections 테이블 RLS 정책
CREATE POLICY "Users can view their own reflections"
    ON public.reflections FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own reflections"
    ON public.reflections FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own reflections"
    ON public.reflections FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own reflections"
    ON public.reflections FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================
-- 5. 유틸리티 함수
-- ============================================

-- updated_at 자동 업데이트 트리거 함수
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = TIMEZONE('utc'::text, NOW());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- visions 테이블 updated_at 트리거
DROP TRIGGER IF EXISTS set_visions_updated_at ON public.visions;
CREATE TRIGGER set_visions_updated_at
    BEFORE UPDATE ON public.visions
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- goal_trees 테이블 updated_at 트리거
DROP TRIGGER IF EXISTS set_goal_trees_updated_at ON public.goal_trees;
CREATE TRIGGER set_goal_trees_updated_at
    BEFORE UPDATE ON public.goal_trees
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- goals 테이블 updated_at 트리거
DROP TRIGGER IF EXISTS set_goals_updated_at ON public.goals;
CREATE TRIGGER set_goals_updated_at
    BEFORE UPDATE ON public.goals
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- ============================================
-- 6. 초기 데이터 확인 쿼리
-- ============================================

-- 모든 테이블 확인
-- SELECT table_name FROM information_schema.tables
-- WHERE table_schema = 'public'
-- AND table_name IN ('visions', 'goal_trees', 'goals', 'reflections');

-- RLS 정책 확인
-- SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
-- FROM pg_policies
-- WHERE tablename IN ('visions', 'goal_trees', 'goals', 'reflections');
