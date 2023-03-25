#!/bin/bash

docker volume create hitobito_bundle
docker volume create hitobito_yarn_cache

if [ ! -d "app/hitobito" ]; then
    mkdir -p app/hitobito
    git clone https://github.com/hitobito/hitobito.git app/hitobito
fi