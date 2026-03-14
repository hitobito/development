#!/bin/bash

# This script will be run _outside_ the container everytime you create a devcontainer (locally or in the cloud)

docker volume create hitobito_bundle
docker volume create hitobito_yarn_cache

# Check if an argument was provided
if [ $# -eq 0 ]
then
  echo "Usage: $0 url1 url2 url3 ..."
  exit 1
fi

if [ -d "hitobito" ]; then
    echo "Already cloned, skipping…"
    exit 0
fi

# Loop over the URLs and clone each repository
for url in "$@"
do
  echo "Cloning $url into $(basename $url .git)"
  git clone "$url" "$(basename $url .git)"
done
