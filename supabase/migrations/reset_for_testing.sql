-- ⚠️ WARNING: This will delete ALL data! Use for testing only!
-- Reset database for clean testing

-- Delete all data (in correct order to handle foreign keys)
DELETE FROM quests;
DELETE FROM vision_notes;
DELETE FROM goal_trees;
DELETE FROM vision_surveys;
DELETE FROM user_stats;

-- Optionally reset auth users (comment out if you want to keep them)
-- This requires supabase admin to run manually

-- Reset sequences if needed
-- ALTER SEQUENCE IF EXISTS some_sequence RESTART WITH 1;

-- Confirm deletion
SELECT 'All data deleted' AS status;
