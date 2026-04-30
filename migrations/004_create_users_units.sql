-- Migration: create users_units N:N relationship table
-- Safe to re-run manually: guards against duplicates using IF NOT EXISTS logic.

CREATE TABLE IF NOT EXISTS users_units (
  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  unit_id BIGINT NOT NULL REFERENCES units(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (user_id, unit_id)
);

CREATE INDEX IF NOT EXISTS idx_users_units_unit_id ON users_units(unit_id);

COMMENT ON TABLE users_units IS 'Maps users to the units they are associated with';
