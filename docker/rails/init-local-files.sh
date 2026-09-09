#!/usr/bin/env bash
#
# Create the files a hitobito checkout needs but does not track: the Wagonfile, and the
# Gemfile.local copies that bundler resolves against so the local wagon paths never land in the
# checked out Gemfile.lock.
#
#   docker/rails/init-local-files.sh <checkout-root>
#
# <checkout-root> holds hitobito/ and hitobito_*/ -- /usr/src/app in the containers, or
# worktrees/<name> for a worktree. Called by docker/rails/rails-entrypoint.sh and by bin/worktree,
# so those two cannot drift apart. Idempotent.
#
# Honours SKIP_WAGONFILE and BUNDLE_GEMFILE from the environment.

set -euo pipefail

root="${1:?usage: init-local-files.sh <checkout-root>}"
core="$root/hitobito"
gemfile="${BUNDLE_GEMFILE:-Gemfile.local}"

[ -d "$core" ] || { echo "init-local-files: no hitobito checkout in $root" >&2; exit 1; }

mkdir -p "$core/tmp/pids" "$core/log"

if [ -z "${SKIP_WAGONFILE:-}" ]; then
  echo "⚙ Activating Wagonfile.development"
  cp "$core/Wagonfile.development" "$core/Wagonfile"
fi

echo "⚙ Creating local copies of Gemfile and Gemfile.lock"
cp "$core/Gemfile" "$core/$gemfile"
cp "$core/Gemfile.lock" "$core/$gemfile.lock"

# Wagons get the same treatment, because bundler is also run from a wagon directory -- by
# `hit test`, by a shell, or by an agent. Without a local copy there, bundler resolves against the
# checked out Gemfile/Gemfile.lock and writes the local wagon paths into them. A wagon's lockfile
# is the core's, see the core's doc/developer/local_setup.md.
for wagon in "$root"/hitobito_*; do
  [ -f "$wagon/Gemfile" ] || continue
  cp "$wagon/Gemfile" "$wagon/$gemfile"
  cp "$core/Gemfile.lock" "$wagon/$gemfile.lock"
done
