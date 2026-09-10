# hitobito/development

This repository is only the development environment: a Docker Compose setup that composes the
hitobito core with one or more wagons into one running instance. It contains no application code.

The application lives in sibling directories, each its own git repository:

- `hitobito/` — the core. **Read `hitobito/AGENTS.md` for anything about the application.**
- `hitobito_*/` — the wagons in use.

`git status`, `git log` and `git diff` here cover only the development environment, not the
application.

## Where you are running

Your working directory already tells you which it is, so decide now, before running anything.

**If it is under `/usr/src/app`**, you are inside the container. Read `AGENTS_DOCKER_SETUP.md`.

**If it is anywhere else**, you are on the host, outside the containers. There is no Ruby, no
PostgreSQL and no Redis available to you here, and installing them is not the answer — this setup
exists so that nothing but git and Docker is needed on the host. Stop and tell the user to restart
you inside the container:

    # choose one of:
    bin/agent claude
    bin/agent opencode

You may still read files and use git while you wait for that. `bin/agent` works from this directory,
from `hitobito/`, from any wagon and from any worktree — it puts you in the matching directory
inside the container.

See `doc/ai-agents.md` for how this works and what the container sandbox does and does not cover.
