#!/bin/bash -i
#
# -i is required so .bashrc is read

set -e

initialize() {
    cd /usr/src/app/hitobito

    rm -f tmp/pids/server.pid

    if [ -d /shared ]; then
        if [ ! -f /shared/.env.generated ]; then
            echo "⚙ Generating some environment values"
            touch /shared/.env.generated
            echo "NEXTCLOUD_OIDC_CLIENT_ID=$(openssl rand -base64 33)" >> /shared/.env.generated
            echo "NEXTCLOUD_OIDC_CLIENT_SECRET=$(openssl rand -base64 33)" >> /shared/.env.generated
        fi
    fi

    if [ ! -f ./jwt_signing_key.pem ]; then
        echo "⚙ Generating a JWT signing key"
        openssl genpkey -algorithm RSA -out jwt_signing_key.pem -pkeyopt rsa_keygen_bits:2048
    fi

    if [ -z "$SKIP_WAGONFILE" ]; then
        echo "⚙ Activating Wagonfile.development"
        cp /usr/src/app/hitobito/Wagonfile{.development,}
    fi

    if [ -z "$SKIP_BUNDLE_INSTALL" ]; then
        echo "Installing gems if necessary"
        bundle check >/dev/null 2>&1 || bundle install
    else
        echo "Waiting for gems to be installed"
        while ! bundle check >/dev/null 2>&1; do
            echo -n "."
            sleep 1
        done
    fi

    echo "⚙️  Testing DB connection"
    timeout 300s waitfortcp "${RAILS_DB_HOST-db}" "${RAILS_DB_PORT-3306}"
    echo "✅ DB server is ready"

    if [ -z "$SKIP_RAILS_MIGRATIONS" ]; then
        echo "⚙️  Performing migrations"
        bundle exec rails db:migrate wagon:migrate
        echo "✅ Migrations done"
    fi

    if [ -z "$SKIP_SEEDS" ]; then
        if [ ! -f /seed/done ]; then
            echo "⚙️  Seeding DB"
            if [ -f /shared/.env.generated ]; then
                set -o allexport
                source /shared/.env.generated
                set +o allexport
            fi
            bundle exec rails db:seed wagon:seed && date > /seed/done
            echo "✅ Seeding done"
        else
            echo "↪️  Skipping seeding because already done on $(cat /seed/done)"
        fi
    fi

    cd - >/dev/null
}

if [ -z "$SKIP_INIT" ]; then
    initialize
    echo "⚙️  Executing: $@"
fi

if [ -z "$JWT_SIGNING_KEY" ]; then
    export JWT_SIGNING_KEY=$(cat jwt_signing_key.pem)
fi

exec "$@"
