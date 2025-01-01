#!/bin/bash
set -e

function postgres_ready(){
/usr/bin/pg_isready -h "$DB_HOST" -p "$DB_PORT" -U "$POSTGRES_USER"
}

until postgres_ready; do
  echo "Postgres is unavailable - sleeping"
  sleep 2
done

echo "Postgres is up - executing command"

# Remove a potentially pre-existing server.pid for Rails
rm -f /app/tmp/pids/server.pid

# Then exec the container's main process (what's set as CMD in the Dockerfile)
exec "$@"
