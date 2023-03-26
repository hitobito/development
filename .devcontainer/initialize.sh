#!/bin/bash

docker volume create hitobito_bundle
docker volume create hitobito_yarn_cache

# Check if an argument was provided
if [ $# -eq 0 ]
then
  echo "Usage: $0 url1 url2 url3 ..."
  exit 1
fi

if [ -d "app/hitobito" ]; then
    echo "Already cloned, skipping…"
    exit 0
fi

# Create the app directory if it doesn't exist
mkdir -p app

# Loop over the URLs and clone each repository into the app directory
for url in "$@"
do
  echo "Cloning $url into app/$(basename $url .git)"
  git clone "$url" "app/$(basename $url .git)"
done
