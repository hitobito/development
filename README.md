# Hitobito Development 👩🏽‍💻

new here? install our docker developmet [setup](doc/setup.md)!

## Development

Start developing by editing files locally with your prefered editor in the app/hitobito* folders. Those directories are mounted inside the containers. So every saved file is instantly available inside the containers.

:bulb: If you don't know where to begin changing something, have a look at our hitobito cheatsheet in [English](./doc/hitobito-cheatsheet-en.pdf) and [German](./doc/hitobito-cheatsheet.pdf).

### Running rails tasks, console

For executing tasks like **rails routes** or starting the rails console in **development** environment, run the following command:

```bash
docker compose exec rails bash
```

### Running tests

#### Open a test shell

Either, to run tests for the core:

```bash
bin/test_env_core
```

or, to run tests for a wagon:


```bash
export WAGON=MYWAGON # e.g. WAGON=pbs
bin/test_env_wagon
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
