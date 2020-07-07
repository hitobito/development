WIP !!!!
 
# Hitobito Development 👩🏽‍💻

We're glad you want to setup your machine for Hitobito development 💃

## System Requirements

You need to have [Docker][docker] and _[docker-compose][doco]_ installed on your computer.
The free _Docker Community Edition (CE)_ works perfectly fine.

[docker]: https://docs.docker.com/install/
[doco]: https://docs.docker.com/compose/install/

Additionally you need **git** to be installed and configured.
 
   ⚡ This manual focuses on Linux/Ubuntu. Hitobito also runs on other plattforms and some command may vary. 

## Preparation

First, you need to clone this repository:

```bash
mkdir -p ~/git/hitobito && cd ~/git/hitobito
git clone https://github.com/hitobito/development.git
cd development/app
git clone https://github.com/hitobito/hitobito.git
```

Now you need to add at least one wagon project:

```bash
# wagon project(s)
git clone https://github.com/hitobito/hitobito_generic.git 
```

The final structure should look something like this:

```bash
$ ls -lah
total 16K
drwxrwxr-x  4 ps ps 4.0K Jun 25 11:20 .
drwxrwxr-x 17 ps ps 4.0K Jun 25 10:00 ..
drwxrwxr-x 18 ps ps 4.0K Jun 25 07:29 hitobito
drwxrwxr-x 11 ps ps 4.0K Jun 24 10:53 hitobito_generic
```

## Starting Development Containers

To start the Hitobito application, run the following command in your shell:

```bash
docker-compose up -d
```

It will initially take a while to prepare the initial Docker images, to prepare the database and to start the application.
The process will be shorter on subsequent starts. After this command completed, make sure all services are up and running:

```bash
docker-compose ps
```

EXAMPLE OUTPUT è

Now it's time to seed the database:

```bash
docker-compose exec rails bash -c 'bundle exec rails db:seed wagon:seed'
```

Access webapplication by browser: http://localhost:3000
