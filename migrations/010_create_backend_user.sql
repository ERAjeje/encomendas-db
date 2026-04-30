-- Migration: create backend application user
-- Safe to re-run manually: guards against duplicates using IF NOT EXISTS logic.

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_roles
    WHERE rolname = 'backend_portaria_db_user'
  ) THEN
    CREATE USER backend_portaria_db_user WITH PASSWORD 'HNUCh3rCojWNKnmCvzl9UQ2fdzdpL8l0MI5coL3G3TI=';
  END IF;
END
$$;

-- Grant necessary permissions
GRANT CONNECT ON DATABASE portaria TO backend_portaria_db_user;
GRANT CONNECT ON DATABASE portaria_app TO backend_portaria_db_user;

-- Grant schema usage
\c portaria
GRANT USAGE ON SCHEMA public TO backend_portaria_db_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO backend_portaria_db_user;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO backend_portaria_db_USER;

-- Grant future table/sequence permissions (PostgreSQL 15+)
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO backend_portaria_db_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE, SELECT ON SEQUENCES TO backend_portaria_db_user;

COMMENT ON ROLE backend_portaria_db_user IS 'Application user for the backend service';
