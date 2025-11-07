-- Add nickname and character columns to user_stats table

ALTER TABLE user_stats
ADD COLUMN IF NOT EXISTS nickname TEXT,
ADD COLUMN IF NOT EXISTS character TEXT;

-- Set default values for existing rows
UPDATE user_stats
SET
  nickname = 'Player',
  character = '🐰'
WHERE nickname IS NULL OR character IS NULL;

-- Make columns NOT NULL after setting defaults
ALTER TABLE user_stats
ALTER COLUMN nickname SET NOT NULL,
ALTER COLUMN character SET NOT NULL;

-- Add check constraint for character (must be one of the valid emojis)
ALTER TABLE user_stats
ADD CONSTRAINT valid_character CHECK (character IN ('🐰', '🐻', '🐱', '🦊'));

-- Add check constraint for nickname length (2-10 characters)
ALTER TABLE user_stats
ADD CONSTRAINT nickname_length CHECK (LENGTH(nickname) >= 2 AND LENGTH(nickname) <= 10);
