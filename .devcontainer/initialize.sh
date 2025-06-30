#!/bin/bash

# This script will be run _outside_ the container everytime you create a devcontainer (locally or in the cloud)

docker volume create hitobito_bundle
docker volume create hitobito_yarn_cache
touch docker/rails/Gemfile.lock

# Ensure .gitconfig exists

if [ -z "$HOME" ]; then
  # Codespaces or other environments where HOME might not be set
  echo "HOME environment variable is not set. Using /etc/.gitconfig."
  GITCONFIG_PATH="/etc/.gitconfig"
else
  # Regular environments where HOME is set
  echo "HOME environment variable is set. Using $HOME/.gitconfig"
  GITCONFIG_PATH="$HOME/.gitconfig"
fi

if [ ! -f "$GITCONFIG_PATH" ]; then
  # If the .gitconfig file does not exist, create it. If it is missing, git commands in devcontainer may fail, as docker then creates a directory instead of a file.
  echo "Ensuring $GITCONFIG_PATH exists…"
  touch "$GITCONFIG_PATH"
else
  echo "Using existing $GITCONFIG_PATH"
fi

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
