# Hitobito Development 👩🏽‍💻

new here? install our docker developmet [setup](doc/setup.md)!

## Development

Start developing by editing files locally with your prefered editor in the app/hitobito* folders. Those directories are mounted inside the containers. So every saved file is instantly available inside the containers.

:bulb: If you don't know where to begin changing something, have a look at our hitobito cheatsheet in [English](./doc/hitobito-cheatsheet-en.pdf) and [German](./doc/hitobito-cheatsheet.pdf).

to initialize the `hit` command, run `source bin/dev-env.sh` in your console.

### Running rails tasks, console

For executing tasks like **rails routes** or starting the rails console in **development** environment, run the following command:

```bash
hit rails bash
```

Or maybe better directly to the rails console ?
```bash
hit rails console
```

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

# To run a capybara feature spec, which runs inside a real browser, pass the following flag:
rspec --tag type:feature spec/features/person/person_tags_spec.rb
```

### HTTP request debugging with pry

For debugging with pry during a HTTP request, you can attach to the running docker container (detach with Ctrl+c):

```bash
bin/attach_to_rails
```

### Access Development Database
```bash
bin/database_console
```
### Shutdown

🍺 finished work ? execute **docker compose down** to shut down all running containers
