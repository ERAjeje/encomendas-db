-- Migration: create users enum/table
-- Safe to re-run manually: guards against duplicates using IF NOT EXISTS logic.

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_type
    WHERE typname = 'user_status'
  ) THEN
    CREATE TYPE user_status AS ENUM ('pending_approval', 'active');
  END IF;
END
$$;

CREATE TABLE IF NOT EXISTS users (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  role_id BIGINT NOT NULL REFERENCES roles(id) ON DELETE RESTRICT,
  status user_status NOT NULL DEFAULT 'pending_approval',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_users_role_id ON users(role_id);

COMMENT ON TYPE user_status IS 'Lifecycle status of a user account';
COMMENT ON TABLE users IS 'Stores user accounts and their assigned roles';
