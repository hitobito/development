#!/bin/bash

set -e

while [ ! -f ./Wagonfile ]; do
    echo "Waiting for Wagonfile"
    sleep 1
done

while ! bundle check >/dev/null 2>&1; do
    echo -n "."
    sleep 1
done

echo "Running yarn install"
yarn install

yarn build --watch &
yarn build:css --watch &

wait
