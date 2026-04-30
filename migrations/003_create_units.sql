-- Migration: create units table
-- Safe to re-run manually: guards against duplicates using IF NOT EXISTS logic.

CREATE TABLE IF NOT EXISTS units (
  id BIGSERIAL PRIMARY KEY,
  tower TEXT NOT NULL,
  block TEXT NOT NULL,
  apartment TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT uq_units_location UNIQUE (tower, block, apartment)
);

CREATE INDEX IF NOT EXISTS idx_units_block_tower ON units(block, tower);

COMMENT ON TABLE units IS 'Represents physical condominium units';
