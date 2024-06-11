#!/bin/bash

set -e

rm -f tmp/pids/server.pid

while [ ! -f "/usr/src/app/hitobito/Wagonfile" ]; do
    echo "Waiting for Wagonfile"
    sleep 1
done

while ! bundle check >/dev/null 2>&1; do
    echo -n "."
    sleep 1
done

echo "Running yarn install"
yarn install

echo "⚙️  Testing DB connection"
timeout 300s waitfortcp "${RAILS_DB_HOST-db}" "${RAILS_DB_PORT-3306}"
echo "✅ DB server is ready"

echo "➡️ Handing control over to '$*''"

echo "⚙️  Executing: $@"
exec bundle exec "$@"
