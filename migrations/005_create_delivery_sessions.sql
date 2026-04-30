-- Migration: create delivery_sessions table
-- Safe to re-run manually: guards against duplicates using IF NOT EXISTS logic.

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_type
    WHERE typname = 'delivery_session_status'
  ) THEN
    CREATE TYPE delivery_session_status AS ENUM ('open', 'completed');
  END IF;
END
$$;

CREATE TABLE IF NOT EXISTS delivery_sessions (
  id BIGSERIAL PRIMARY KEY,
  unit_id BIGINT NOT NULL REFERENCES units(id) ON DELETE RESTRICT,
  pickup_code TEXT NOT NULL UNIQUE,
  status delivery_session_status NOT NULL DEFAULT 'open',
  picked_up_by_user_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  CONSTRAINT chk_delivery_sessions_pickup_code CHECK (pickup_code ~ '^[A-Za-z0-9]{4}-[A-Za-z0-9]{4}-[0-9]{8}$')
);

CREATE INDEX IF NOT EXISTS idx_delivery_sessions_unit_id ON delivery_sessions(unit_id);
CREATE INDEX IF NOT EXISTS idx_delivery_sessions_picked_up_by ON delivery_sessions(picked_up_by_user_id);

COMMENT ON TABLE delivery_sessions IS 'Tracks package delivery sessions for condominium units';
COMMENT ON COLUMN delivery_sessions.pickup_code IS 'Unique code in format: [4 chars]-[4 chars]-[8 digits date]';
