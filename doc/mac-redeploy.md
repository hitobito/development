# Redeploy Development Environment on macOS (with existing data)

This guide helps you redeploy this development stack on Mac while preserving your existing data.

## 1. Create and use a dedicated branch

If not already done:

```bash
git checkout -b chore/mac-dev-redeploy
```

## 2. Pre-migration backup on your current machine

From the repository root:

```bash
bin/dump_database
```

This creates a compressed SQL dump in `dumps/`.

Recommended extra backups:

```bash
# Optional: backup local app sources mounted into containers
tar -czf app-backup-$(date +%F-%H-%M-%S).tar.gz app/

# Optional: backup shared folder if used by your workflow
tar -czf shared-backup-$(date +%F-%H-%M-%S).tar.gz shared/
```

Then copy to your Mac:

```bash
scp dumps/<your-latest-dump>.sql.gz <mac-user>@<mac-host>:~/
```

## 3. Prepare macOS dependencies

Install:

1. Docker Desktop
2. Git

Verify:

```bash
docker --version
docker compose version
git --version
```

## 4. Clone repository on Mac

```bash
mkdir -p ~/git && cd ~/git
git clone <your-repo-url> GalleApp
cd GalleApp
git checkout chore/mac-dev-redeploy
```

If your current work is not pushed yet, transfer your repository snapshot first (or push your branch before moving).

## 5. Configure shell and volumes on Mac

Initialize the `hit` helper:

```bash
bin/dev-env.sh
```

Create required external volumes (one-time):

```bash
docker volume create hitobito_bundle
docker volume create hitobito_yarn_cache
```

Set your UID (important on macOS to avoid permission mismatch):

```bash
echo 'export RAILS_UID=$(id -u)' >> ~/.zshrc
source ~/.zshrc
```

## 6. Start containers once

```bash
docker compose up -d
docker compose ps
```

Wait until services are healthy.

## 7. Restore your existing database

Copy your dump file into the repository (for example into `dumps/`) then run:

```bash
bin/load_database dumps/<your-latest-dump>.sql.gz
```

## 8. Validate data and runtime

Run sanity checks:

```bash
docker compose ps
hit db console
```

Inside PostgreSQL:

```sql
\dt
SELECT count(*) FROM people;
SELECT count(*) FROM groups;
```

Then open:

1. http://localhost:3000
2. http://localhost:1080

## 9. Optional cleanup and reset commands

Stop environment:

```bash
hit down
```

If you need to rebuild images after Dockerfile changes:

```bash
docker compose build --no-cache
docker compose up -d
```

## 10. Notes specific to this repository

1. This repository uses Docker volumes named `postgres`, `seed`, `hitobito_bundle`, and `hitobito_yarn_cache`.
2. `postgres` contains your live DB state in Docker; SQL dump/restore is the safest cross-machine migration path.
3. `docker-compose.override.yml` currently scopes wagons to EEDS. Keep it if that is intended for your setup.