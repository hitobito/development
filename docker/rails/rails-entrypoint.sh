#!/bin/bash -i

set -e

checkout_root() {
    case "$PWD" in
        /usr/src/app/worktrees/*/*)
            local rest="${PWD#/usr/src/app/worktrees/}"
            echo "/usr/src/app/worktrees/${rest%%/*}"
            ;;
        *) echo "/usr/src/app" ;;
    esac
}

initialize() {
    local root
    root="$(checkout_root)"
    echo "⚙ Initializing $root"
    cd "$root/hitobito"

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

    /usr/src/app/docker/rails/init-local-files.sh "$root"

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

    if [ -z "$SKIP_RAILS_MIGRATIONS" ]; then
        echo "⚙️  Performing migrations"
        bundle exec rails db:migrate wagon:migrate
        echo "✅ Migrations done"
    fi

    local seed_marker="/seed/done${RAILS_DB_NAME:+-$RAILS_DB_NAME}"
    if [ -z "$SKIP_SEEDS" ]; then
        if [ ! -f "$seed_marker" ]; then
            echo "⚙️  Seeding $RAILS_DB_NAME"
            if [ -f /shared/.env.generated ]; then
                set -o allexport
                source /shared/.env.generated
                set +o allexport
            fi
            bundle exec rails db:seed wagon:seed && date > "$seed_marker"
            echo "✅ Seeding done"
        else
            echo "↪️  Skipping seeding because already done on $(cat "$seed_marker")"
        fi
    fi

    cd - >/dev/null
}

if [ -d /usr/src/app/app ]; then
    echo "*****************************************************************"
    echo "CAUTION: You seem to be using the old directory structure with"
    echo "hitobito and wagons inside an app directory."
    echo ""
    echo "************* AUTO-MIGRATING TO THE NEW STRUCTURE. **************"
    echo "*****************************************************************"

    # Move everything in the extra app directory one level up
    find /usr/src/app/app -maxdepth 1 -not -name 'app' -print0 | xargs -0r mv -t /usr/src/app
    # Remove the obsolete extra app directory
    rmdir /usr/src/app/app
    # Remove the obsolete Gemfile.lock copy
    rm -f /usr/src/app/docker/rails/Gemfile.lock
    # The seed marker is per database now, because worktrees have their own development database
    [ -f /seed/done ] && mv /seed/done /seed/done-hitobito_development
fi

if [ -z "$SKIP_INIT" ]; then
    initialize
    echo "⚙️  Executing: $@"
fi

if [ -z "$JWT_SIGNING_KEY" ]; then
    export JWT_SIGNING_KEY=$(cat jwt_signing_key.pem)
fi

exec "$@"
