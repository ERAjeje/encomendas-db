-- Migration: add receipt_session_id to packages
-- Safe to re-run manually: guards against duplicates using IF NOT EXISTS logic.

ALTER TABLE packages ADD COLUMN IF NOT EXISTS receipt_session_id BIGINT REFERENCES receipt_sessions(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_packages_receipt_session_id ON packages(receipt_session_id);

COMMENT ON COLUMN packages.receipt_session_id IS 'Links the package to the receipt session during intake';
