WIP !!!!
 
# Hitobito Development 👩🏽‍💻

We're glad you want to setup your machine for Hitobito development 💃

## System Requirements

You need to have [Docker][docker] and _[docker-compose][doco]_ installed on your computer.
The free _Docker Community Edition (CE)_ works perfectly fine.

[docker]: https://docs.docker.com/install/
[doco]: https://docs.docker.com/compose/install/

Additionally you need **git** to be installed and configured.
 
   ⚡ This manual focuses on Linux/Ubuntu. Hitobito development also runs on other plattforms with some adjustions. 

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

This should look something like this:

```
          Name                         Command               State                  Ports               
--------------------------------------------------------------------------------------------------------
development_cache_1         docker-entrypoint.sh memca ...   Up       11211/tcp                         
development_db_1            docker-entrypoint.sh --sor ...   Up       0.0.0.0:33066->3306/tcp, 33060/tcp
development_indexer_1       indexer --config /opt/sphi ...   Exit 0                                     
development_mailcatcher_1   container-entrypoint mailc ...   Up       0.0.0.0:1080->1080/tcp, 8080/tcp  
development_rails-test_1    rails-entrypoint tail -f / ...   Up       8080/tcp                          
development_rails_1         rails-entrypoint rails ser ...   Up       0.0.0.0:3000->3000/tcp, 8080/tcp  
development_sphinx_1        /bin/sh -c searchd --nodet ...   Up       36307/tcp                         
development_worker_1        rails-entrypoint rails job ...   Up       8080/tcp     
```

Now it's time to seed the database:

```bash
docker-compose run rails 'rails db:seed wagon:seed'
```

Access webapplication by browser: http://localhost:3000
