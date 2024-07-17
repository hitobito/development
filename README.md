# Hitobito Development 👩🏽‍💻

New here? Install our docker development [setup](doc/setup.md)!

## Development

Start developing by editing files locally with your preferred editor in the app/hitobito\* folders.
Those directories are mounted inside the containers. So every saved file is instantly available inside the containers.

:bulb: If you don't know where to begin changing something, have a look at our hitobito cheatsheet in [English](./doc/hitobito-cheatsheet-en.pdf) and [German](./doc/hitobito-cheatsheet.pdf).

To initialize the `hit` command, run `source bin/dev-env.sh` in your console.

### hit dev $command

Examples:
to start the development environment

```bash
hit dev up
```

Access hitobito by browser: http://localhost:3000

| $command | description               |
| -------- | ------------------------- |
| u\|up    | start dev environment     |
| d\|down  | shutdown dev environment  |
| p\|ps    | print dev env status info |

### hit rails $command

Examples:

```bash
hit rails bash
```

Or maybe better directly to the rails console ?

```bash
hit rails console
```

| $command   | description                             |
| ---------- | --------------------------------------- |
| b\|bash    | start bash in rails container           |
| c\|console | rails console                           |
| l\|logs    | attach to rails container logs          |
| r\|routes  | Print rails routes                      |
| a\|attach  | Attach to rails container for debugging |

### Running tests

#### Open a test shell

When using this for the first time, once daily or after assets changed run the prep command

```bash
hit test prep
```

Get a shell to run core or wagon specs

```bash
hit test
```

#### Run desired tests

Either, to run all tests

```bash
rspec
```

or, to run specific tests:

```bash
rspec spec/models/person_spec.rb
```

### HTTP request debugging with pry

For debugging with pry during a HTTP request, you can attach to the running docker container (detach with Ctrl+c):

```bash
hit rails attach
```

### Access Development Database

```bash
hit db console
```

### Rerunning seeds

Useful when adding new seeds

```bash
hit db seed
```

### Shutdown

🍺 finished work ? execute **hit dev down** to shut down all running containers
