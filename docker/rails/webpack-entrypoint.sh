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
bundle exec rails webpacker:yarn_install

echo "➡️ Handing control over to '$*''"

echo "⚙️  Executing: $@"
exec bundle exec "$@"
