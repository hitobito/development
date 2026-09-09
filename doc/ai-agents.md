# AI coding agents 🤖

The dev image ships [Claude Code](https://claude.com/claude-code) and
[opencode](https://opencode.ai). Running them inside the containers gives the agent a sandbox to work in.

## Which directory to open in your IDE

Open the **`hitobito/development` checkout** — this directory. Core, wagons and all instruction
files are then inside one workspace root, which is what agents and IDEs work best with.

- VS Code / Windsurf / Cursor: open this folder, or `app.code-workspace` for a multi-root
  workspace that lists the core separately (the wagons appear under the `app` root).
- Devcontainers: open `.devcontainer/<instance>`; its workspace is `/usr/src/app`, the same
  checkout seen from inside the container.
- IntelliJ / RubyMine: open this folder; mark `hitobito` and the wagons as git repositories.

## Starting an agent

```bash
bin/agent claude          # or: bin/agent opencode
```

The working directory inside the container mirrors the one you call this from, so run it from
`hitobito/` to work on the core, from `hitobito_pbs/` to work on that wagon, or from the top to
default to the core. It is a thin wrapper around:

```bash
docker compose run --rm -it --workdir /usr/src/app/hitobito agent claude
```

You do not necessarily need `docker compose up` first — `run` starts the database on its own. Log in
on the first start; the credentials and your conversation history are stored in
`docker/rails/home/.claude` (and `.../.local/share/opencode`) on your machine, so they survive
`docker compose down`, rebuilds and image updates. They are per hitobito instance, so a second
checkout asks you to log in again.

Update the agents by rebuilding the image: `docker compose build rails`. They cannot update
themselves — the binaries live in `/usr/local/bin` and the container user cannot write there.

The agent can use the running hitobito application via Capybara and create and manage worktrees. A
worktree is for editing, specs and rake tasks; to also *run* one, alongside your main instance:

```bash
bin/worktree run my-feature        # http://localhost:3001, or pass your own port
```

A worktree is treated as a fork of your main instance. Creating one copies `node_modules` and the
JWT key; the first `run` forks the development database into `hitobito_dev_<name>` with `pg_dump`
and compiles the worktree's own webpack packs. That is seconds rather than the minutes an install
and a seed would take, and you start from the data you already had. From then on the two diverge:
its own database, assets, JWT key, delayed-job worker and ActionCable channel, so this branch's
migrations and dependency changes cannot reach your main instance. `bin/worktree remove` drops the
database again.

Only Postgres, Redis and mailcatcher are shared, as servers — the worktree has its own database and
its own Redis index inside them. If the branch changes `yarn.lock`, `run` says so: `node_modules`
was copied at creation time, so run `yarn install` in the worktree to update it.

## What the sandbox does and does not cover

The `agent` service runs with `no-new-privileges`, drops all capabilities, publishes no ports and
has no docker socket, so an agent cannot become root, cannot reach your machine and cannot touch
the other containers. That is why it — and only it — auto-approves the agent's actions, so you do
not have to confirm every command (`bypassPermissions` in Claude Code, `"permission": "allow"` in
opencode).

The agents are installed in every container built from this image, so you can also run `claude` in
the `rails` container or in a devcontainer. Those are **not** sandboxes: the container user has
passwordless `sudo`, and a devcontainer additionally runs `privileged` with the docker socket
mounted, which is a direct route to your host. They deliberately do not get the
`bypassPermissions` policy, so you keep the normal approval prompts there. Use `bin/agent` when you
want an agent working on its own.

It does **not** sandbox everything, so keep an eye on:

- **Your repositories.** The whole checkout is mounted read-write, `.git` directories included. An
  agent can commit, rewrite history and push with your credentials.
- **The network.** Outbound traffic is unrestricted.
- **The devcontainer setup.** `.devcontainer/docker-compose.yml` mounts the docker socket and runs
  `privileged: true`, so an agent there can start a container that mounts your whole filesystem.
  Auto mode is not enabled there for that reason; do not enable it by hand.
