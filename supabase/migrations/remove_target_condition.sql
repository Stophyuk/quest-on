-- Remove target_condition column from quests table
-- This migration removes the condition feature from the quests system

ALTER TABLE quests DROP COLUMN IF EXISTS target_condition;

-- Add comment
COMMENT ON TABLE quests IS 'Quests table without condition feature';
