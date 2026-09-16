#!/bin/bash
#
#   assets-entrypoint.sh js|css
#
# One watcher per container, so the two have independent logs and can be
# restarted independently. Only the js one installs the node modules; the css
# one waits for them.

set -e

target="${1:?usage: assets-entrypoint.sh js|css}"

while [ ! -f ./Wagonfile ]; do
    echo "Waiting for Wagonfile"
    sleep 1
done

while ! bundle check >/dev/null 2>&1; do
    echo -n "."
    sleep 1
done

case "$target" in
  js)
    echo "Running yarn install"
    yarn install
    ;;
  css)
    while [ ! -f ./node_modules/.yarn-integrity ]; do
        echo "Waiting for yarn install"
        sleep 1
    done
    ;;
  *)
    echo "assets-entrypoint: unknown target '$target', expected js or css" >&2
    exit 1
    ;;
esac

exec bundle exec rake "assets:watch_$target"
