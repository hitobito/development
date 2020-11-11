# Hitobito Development 👩🏽‍💻

We're glad you want to setup your machine for Hitobito development 💃

## System Requirements

You need to have [Docker][docker] and _[docker-compose][doco]_ installed on your computer.
The free _Docker Community Edition (CE)_ works perfectly fine.

[docker]: https://docs.docker.com/install/
[doco]: https://docs.docker.com/compose/install/

Additionally you need **git** to be installed and configured.
 
 ⚡ This manual focuses on Linux/Ubuntu. Hitobito development also runs on other plattforms with some adjustments. 

## Preparation

First declare a instance name: (e.g. generic, pbs)

```bash
read -p "Enter hitobito instance name: " INSTANCE_NAME
```

Then you need to clone this repository:

```bash
mkdir -p ~/git/hitobito && cd ~/git/hitobito
git clone https://github.com/hitobito/development.git $INSTANCE_NAME && cd $INSTANCE_NAME
(cd app && git clone https://github.com/hitobito/hitobito.git)
```

Now you need to add at least one wagon project:

```bash
# wagon project(s)
(cd app && git clone https://github.com/hitobito/hitobito_generic.git)
```

The final structure in app/ should look something like this:

```bash
$ ls -lah app/
total 16K
drwxrwxr-x  4 ps ps 4.0K Jun 25 11:20 .
drwxrwxr-x 17 ps ps 4.0K Jun 25 10:00 ..
drwxrwxr-x 18 ps ps 4.0K Jun 25 07:29 hitobito
drwxrwxr-x 11 ps ps 4.0K Jun 24 10:53 hitobito_generic
```

## Install Gems / Setup Database

If you did not so before, create a new docker volume for storing bundled gems:

```bash
docker volume create hitobito_bundle
```

⚡ If your user id is not 1000 (run id -u to check), you need to export this as env variable: **export UID=$UID** before running any of the further commands. Maybe you want to add this to your bashrc. 

Now it's time to seed the database with development seeds:

```bash
docker-compose run rails 'rails db:seed wagon:seed'
```

⚡ This will also install all required gems which takes some time to complete if it's executed the first time.

## Start Development Containers

To start the Hitobito application, run the following command in your shell:

```bash
docker-compose up -d
```

After this command completed, make sure all services are up and running:

```bash
docker-compose ps
```

This should look something like this:

```
          Name                         Command               State                 Ports               
-------------------------------------------------------------------------------------------------------
development_cache_1         docker-entrypoint.sh memca ...   Up      11211/tcp                         
development_db_1            docker-entrypoint.sh --sor ...   Up      0.0.0.0:33066->3306/tcp, 33060/tcp
development_mailcatcher_1   container-entrypoint mailc ...   Up      0.0.0.0:1080->1080/tcp, 8080/tcp  
development_rails-test_1    rails-entrypoint tail -f / ...   Up      8080/tcp                          
development_rails_1         rails-entrypoint rails ser ...   Up      0.0.0.0:3000->3000/tcp, 8080/tcp  
development_sphinx_1        sphinx-start                     Up      36307/tcp                         
development_worker_1        rails-entrypoint rails job ...   Up      8080/tcp
```

Access webapplication by browser: http://localhost:3000 and log in using *hitobito@puzzle.ch* and password *hito42bito*. For some wagons, the e-mail address is different. Go to the file ```/config/settings.yml``` inside your wagon repository and look out for the field "root_email". Use this e-mail address to login.

## Development

Start developing by editing files locally with your prefered editor in the app/hitobito* folders. Those directories are mounted inside the containers. So every saved file is instantly available inside the containers. 

### Running rails tasks, console

For executing tasks like **rails routes** or starting the rails console in **development** environment, run the following command:

```bash
docker-compose exec rails bash
```

For executing tests or running other commands in **test** environment, do the same for the rails-test container:

```bash
docker-compose exec rails-test bash
```

### HTTP request debugging with pry

For debugging with pry during a HTTP request, you can attach to the running docker container:

```bash
docker attach $(docker-compose ps | grep _rails_1 | cut -d ' ' -f 1)
```

For detaching after debugging, you use CTRL+p followed by CTRL+q

### Shutdown

🍺 finished work ? execute **docker-compose down** to shut down all running containers

### Updating Images

When the images of this project change, execute the following command to update them locally:

```bash
docker-compose build --no-cache
```
