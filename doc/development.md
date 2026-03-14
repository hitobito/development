# Cloning wagons quickly

:race_car: You go ahead and clone your hitobito dev setup by taking full advantage of the `hitobito_clone` script located within `bin/hitobito_clone.rb`

Make sure you execute the script in the folder you want to have your hitobito setup. Make sure you have the following things preinstalled on your device:

```text
# For script exec
- Ruby
# To retrieve the script
- wget
# Local development with docker
- docker + docker compose
# Version control
- git
```

Then execute the following, which clones all hitobito repositories within a new or existing hitobito directory.

```bash
wget -O - https://raw.githubusercontent.com/hitobito/development/master/bin/hitobito_clone.rb | ruby
```

&ast;Note: by adding the -h option, you get some good information about what the script is able to do further.


# `hit` command

## Usage

To initialize the `hit` command, run the following in your console:

```bash
bin/dev-env.sh
```

To start the development environment, run:

```bash
# This command might take a very long time on the first run, as the database needs to be seeded…
hit up
```

Access hitobito via http://localhost:3000

Get a list of available commands with:

```bash
hit help
```

## Running tests

### Open a test shell

When using this for the first time, once daily or after assets changed run the prep command:

```bash
hit test prep
```

Get a shell to run core or wagon specs:

```bash
hit test
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
hit rails attach
```

## Access Development Database

```bash
hit db console
```

## Rerunning seeds

Useful when adding new seeds

```bash
hit rails seed
```

## Updating Images

When you have made changes to the images of this project, execute the following command to update them locally:

```bash
docker compose build --no-cache
```

Images are built and published with github actions.

## Shutdown

🍺 finished work ? execute `hit down` to shut down all running containers
