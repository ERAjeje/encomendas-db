-- Migration: create packages table
-- Safe to re-run manually: guards against duplicates using IF NOT EXISTS logic.

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_type
    WHERE typname = 'package_status'
  ) THEN
    CREATE TYPE package_status AS ENUM ('received', 'picked_up');
  END IF;
END
$$;

CREATE TABLE IF NOT EXISTS packages (
  id BIGSERIAL PRIMARY KEY,
  delivery_session_id BIGINT NOT NULL REFERENCES delivery_sessions(id) ON DELETE CASCADE,
  unit_id BIGINT NOT NULL REFERENCES units(id) ON DELETE RESTRICT,
  received_by_user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  description TEXT,
  photo_url TEXT,
  status package_status NOT NULL DEFAULT 'received',
  received_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  picked_up_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_packages_delivery_session_id ON packages(delivery_session_id);
CREATE INDEX IF NOT EXISTS idx_packages_unit_id ON packages(unit_id);
CREATE INDEX IF NOT EXISTS idx_packages_received_by ON packages(received_by_user_id);

COMMENT ON TABLE packages IS 'Tracks individual packages associated with a delivery session';
COMMENT ON COLUMN packages.description IS 'Carrier or sender description (e.g., "Amazon")';
COMMENT ON COLUMN packages.photo_url IS 'URL to the package photo';
COMMENT ON COLUMN packages.status IS 'Current state: received or picked_up';
