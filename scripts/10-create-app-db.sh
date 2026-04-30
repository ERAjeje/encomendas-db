#!/usr/bin/env sh
set -e

if [ -z "$POSTGRES_INIT_APP_DB" ]; then
  echo "[initdb] POSTGRES_INIT_APP_DB not set; skipping extra database creation"
  exit 0
fi

echo "[initdb] Ensuring application database exists: $POSTGRES_INIT_APP_DB"
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname postgres <<-EOSQL
  SELECT 'CREATE DATABASE "$POSTGRES_INIT_APP_DB"'
  WHERE NOT EXISTS (
    SELECT FROM pg_database WHERE datname = '$POSTGRES_INIT_APP_DB'
  );
  \gexec
EOSQL
