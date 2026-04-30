-- Migration: add verification fields to delivery_sessions
-- Safe to re-run manually: guards against duplicates using IF NOT EXISTS logic.

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_type
    WHERE typname = 'delivery_verification_method'
  ) THEN
    CREATE TYPE delivery_verification_method AS ENUM ('qr_code', 'manual');
  END IF;
END
$$;

ALTER TABLE delivery_sessions ADD COLUMN IF NOT EXISTS verification_method delivery_verification_method NOT NULL DEFAULT 'qr_code';
ALTER TABLE delivery_sessions ADD COLUMN IF NOT EXISTS document_type VARCHAR(32);
ALTER TABLE delivery_sessions ADD COLUMN IF NOT EXISTS document_number VARCHAR(64);
ALTER TABLE delivery_sessions ADD COLUMN IF NOT EXISTS override_reason TEXT;

COMMENT ON COLUMN delivery_sessions.verification_method IS 'Method used to verify package pickup (qr_code or manual)';
COMMENT ON COLUMN delivery_sessions.document_type IS 'Type of ID document provided during manual pickup (e.g., RG, CPF, CNH)';
COMMENT ON COLUMN delivery_sessions.document_number IS 'Full ID document number';
COMMENT ON COLUMN delivery_sessions.override_reason IS 'Justification for manual delivery override';
