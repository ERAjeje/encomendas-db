-- Migration: create receipt_sessions table
-- Safe to re-run manually: guards against duplicates using IF NOT EXISTS logic.

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_type
    WHERE typname = 'receipt_session_status'
  ) THEN
    CREATE TYPE receipt_session_status AS ENUM ('in_progress', 'finalized');
  END IF;
END
$$;

CREATE TABLE IF NOT EXISTS receipt_sessions (
  id BIGSERIAL PRIMARY KEY,
  concierge_id BIGINT NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  status receipt_session_status NOT NULL DEFAULT 'in_progress',
  started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  finalized_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_receipt_sessions_concierge_id ON receipt_sessions(concierge_id);
CREATE INDEX IF NOT EXISTS idx_receipt_sessions_status ON receipt_sessions(status);

COMMENT ON TABLE receipt_sessions IS 'Tracks package intake sessions managed by a concierge';
COMMENT ON COLUMN receipt_sessions.concierge_id IS 'User (concierge) responsible for the session';
COMMENT ON COLUMN receipt_sessions.status IS 'Current state: in_progress or finalized';
COMMENT ON COLUMN receipt_sessions.finalized_at IS 'Timestamp when the session was closed';
