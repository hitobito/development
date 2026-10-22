# `hit` command

## Usage

`bin/hit` is a regular executable, so it works right away from a shell in this directory — no
setup step needed. It also works from `hitobito/`, from any wagon and from any worktree.

To start the development environment, run:

```bash
# This command might take a very long time on the first run, as the database needs to be seeded…
bin/hit up
```

Access hitobito via http://localhost:3000

Get a list of available commands with:

```bash
bin/hit help
```

To call it as plain `hit` instead of `bin/hit`, add this directory's `bin` folder to your `PATH`,
e.g. by adding `export PATH="$PWD/bin:$PATH"` to your shell profile while in this directory.

## Running tests

### Open a test shell

Get a shell to run core or wagon specs:

```bash
bin/hit test
```

### Run desired tests

Either, to run all tests:

```bash
rspec
```

or, to run specific tests:

```bash
rspec spec/models/person_spec.rb
```

## HTTP request debugging with pry

For debugging with pry during a HTTP request, you can attach to the running docker container (detach with Ctrl+c):

```bash
bin/hit rails attach
```

## Access Development Database

```bash
bin/hit db console
```

## Loading a database dump

Put the dump in the `dumps/` directory, then load it by name:

```bash
bin/load_database 2026-09-10-14-22-01.sql.gz
```

`bin/load_database` reads only from `dumps/`, so that is where dumps belong. Plain `.sql` and
gzipped `.sql.gz` files both work. `bin/dump_database` writes its dumps there too.

## Rerunning seeds

Useful when adding new seeds

```bash
bin/hit rails seed
```

## Updating Images

When you have made changes to the images of this project, execute the following command to update them locally:

```bash
docker compose build --no-cache
```

The `rails` image is built on top of `ghcr.io/hitobito/development/hitobito-base`, which is produced by the `base` stage of the core [hitobito Dockerfile](https://github.com/hitobito/hitobito/blob/master/Dockerfile) and rebuilt nightly by github actions. It is pulled automatically when missing. To build it locally (no local checkout of the core repo needed, the build context is the GitHub URL):

```bash
docker compose --profile manual build hitobito-base
```

Images are built and published with github actions.

## Shutdown

🍺 finished work ? execute `bin/hit down` to shut down all running containers
