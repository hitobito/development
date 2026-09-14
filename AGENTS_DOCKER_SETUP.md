# Docker dev setup

You are reading this because your working directory is under `/usr/src/app`, which means you are
inside the container of a `hitobito/development` checkout. `IS_DOCKER_DEV_ENV` is set here too, if
you ever need to detect this from a script.

## IMPORTANT: Stop if a database dump is loaded

**Before anything else, list `/seed/`. If it contains a `dump-in-*` file, stop.** A database dump
has been loaded, and it may hold production data about real people. Do not query the database, do
not run specs against it, do not read or summarise its contents, and do not work around this by
loading a dump yourself. Tell the user which marker you found and stop there.

This is not the same as the `done-*` files next to it — those only record that seeding has run, and
are normal.

## Layout

The whole `hitobito/development` checkout is mounted at `/usr/src/app`:

- `/usr/src/app/hitobito` — the core.
- `/usr/src/app/hitobito_*` — the wagons in use.
- `/usr/src/app/worktrees/<name>/hitobito*` — git worktrees, if any exist.

Each of those directories is an independent git repository. The rest of `/usr/src/app` is the
development environment itself and is a third git repository.

## What you can do here

Everything runs in your own container, off the same image and the same gem volume as the
application: `bin/rails` (including `bin/rails runner` and `bin/rails console`),
`bundle exec rspec`, `bundle exec rake` for any task -- including `jobs:workoff` and the rubocop
and brakeman tasks under "Static analysis" below -- and `psql` with
`PGPASSWORD=hitobito psql -h postgres -U hitobito -d hitobito_development`.  Always prefix `rake`
and `rspec` with `bundle exec`.

`BUNDLE_GEMFILE` is set to `Gemfile.local`, a copy of `Gemfile` that the containers create next to
it in the core and in every wagon. It exists so bundler never resolves against the checked out
`Gemfile.lock`: the local `Wagonfile` points at `../hitobito_*`, and bundler would otherwise write
those paths into the lockfile you are about to commit. Leave the variable alone, and never
`git add` a `Gemfile.lock` containing `../hitobito_*`.

**Changing the core's dependencies** therefore takes an extra step: edit `Gemfile`, run bundler as
usual, then carry the result back into the committed `Gemfile` and `Gemfile.lock`. Read
[Avoid changes in Gemfile.lock due to local wagon configuration](../hitobito/doc/developer/local_setup.md#avoid-changes-in-gemfilelock-due-to-local-wagon-configuration)
before you touch either file.

The following services are reachable over the docker network:

| Service | Host | Notes |
|---|---|---|
| PostgreSQL | `postgres` | user/password/db `hitobito` / `hitobito` / `hitobito_development` |
| Redis | `redis` | |
| Mailcatcher | `mailcatcher` | SMTP on 1025, web UI on 1080 |

## What you cannot do here

- **Restart the application.** The long-running `rails`, `worker` and `assets` containers are
  separate and you have no docker socket. Rails reloads changed application code by itself, but
  after a change to the `Gemfile`, to `config/initializers/*` or to any other boot-time file, ask
  the user to run e.g. `docker compose restart rails worker`.
- **Reach the internet-facing ports.** Your container publishes nothing. The user's browser talks to
  the `rails` container on http://localhost:3000, not to yours. See "Checking a change in the
  running application" below for accessing the webapp.
- **Become root.** `sudo` is disabled in the `agent` container on purpose. If `sudo` does work,
  you are in the `rails` container or a devcontainer instead — those are not sandboxes, so ask
  before doing anything you cannot undo.

## Running specs

Run them from the directory whose specs you want: the core for core specs, a wagon directory for
that wagon's specs. Once per directory:

    bin/rails db:test:prepare
    bundle exec rspec spec/models/person_spec.rb

`db:test:prepare` builds the right schema either way — for a wagon that is the core schema plus
that wagon's own migrations. The database name is derived from the working directory's path, so it
is never the development database, and separate checkouts and worktrees each get their own. Running
specs while the application is up, or in parallel with another worktree, is therefore safe.

`bin/hit test <wagon>` on the host does the same in a throwaway container with a freshly created
database. Ask the user for it when you want a guaranteed-clean schema; the two commands above are
faster when you are already in here.

Feature specs (`js: true`) need no separate preparation: jsbundling-rails/cssbundling-rails hook
`javascript:build`/`css:build` into `db:test:prepare` itself, so assets are already built by the
time you run specs. To rebuild after changing assets without re-running `db:test:prepare`, run
`bundle exec rake assets:build` from the core; it does not disturb the running application, which
is served from its own `app/assets/builds` directory by the `assets` container rather than from
this one's.

## Checking a change in the running application

You can reach the running app over the docker network and drive it with the chromium that is
already in this image — useful for confirming a change actually works, without writing a feature
spec. `docker/rails/dev_browser.rb` sets that up and logs in as the instance's root user:

    # quick look at one page
    bundle exec ruby /usr/src/app/docker/rails/dev_browser.rb /de/groups

    # anything more, from your own throwaway script
    require "/usr/src/app/docker/rails/dev_browser.rb"
    page = DevBrowser.signed_in_session   # a Capybara::Session
    page.visit "/de/groups/1"
    page.click_link "Bearbeiten"
    puts page.first("h1").text
    DevBrowser.screenshot(page)           # writes hitobito/tmp/dev_browser.png

Two things to keep in mind. It targets the instance belonging to the directory you run it from —
the main one, or a worktree's if `bin/worktree run` is serving it — never localhost, which is your
own container and publishes nothing. And this is the **development** app with the development data
and no transaction rollback, so anything you click really happens; prefer specs for anything
destructive.

`curl` works for quick checks too, and `http://mailcatcher:1080` shows the mails the app sent.

## Static analysis

Use these rake tasks rather than the bare binaries; they are not equivalent, see
`../hitobito/lib/tasks/analyze.rake`:

    bundle exec rake rubocop          # whole repo, minus the Wagons/PatchedMethod cop; aborts on any issue
    bundle exec rake rubocop:changed  # modified and untracked .rb files only, excluding spec/ and test/
    bundle exec rake brakeman         # security analysis, with a timeout, into brakeman-output.tabs

Bare `rubocop` also reports `Wagons/PatchedMethod`. For a quick single file, keep the exclusion:
`bundle exec rubocop --except Wagons/PatchedMethod app/models/person.rb`.

## Worktrees

Worktrees live in `/usr/src/app/worktrees/<name>/` and hold a checkout of the core *and* of every
wagon, all on the same branch. You can create and remove them:

    /usr/src/app/bin/worktree <name> [branch]   # create
    /usr/src/app/bin/worktree remove <name>     # remove, including the branch

Work in one exactly as in the main checkout. The test databases are separate from the main
checkout's, so specs run in parallel with them. Run `bin/rails db:test:prepare` once per worktree
directory.

Use the script rather than `git worktree add` directly. The host and this container see the
checkout at different paths, so the absolute paths git writes are valid on only one side; the
script rewrites them to relative ones, which keeps `git status`, `diff`, `log`, `commit`,
`worktree list` and `worktree prune` correct for you *and* for the user's editor on the host.
`git worktree remove` is the one command that rejects a relative path, which is why removal goes
through the script too.

The long-running `rails`, `assets` and `worker` containers keep serving the main checkout, so a
worktree is for editing, specs and rake tasks. `bin/worktree run <name> [port]` serves a worktree's
own application — forked database, assets and worker, so it cannot disturb the main instance — but
it needs Docker access and occupies a terminal until stopped. So ask the user to run that command
when they (or you) want to test a feature implemented in a worktree.
