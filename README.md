# Hitobito Development 👩🏽‍💻

We're glad you want to setup your machine for hitobito development 💃

## System Requirements

You need to have [Docker][docker] and _[docker-compose][doco]_ installed on your computer.
The free _Docker Community Edition (CE)_ works perfectly fine. Make sure your user is part of the docker group:
```bash
usermod -a -G docker $USER
```
You probably have to log out and log in back again or run `newgrp docker`.

[docker]: https://docs.docker.com/install/
[doco]: https://docs.docker.com/compose/install/

Additionally you need **git** to be installed and configured.
 
 🐧 This manual focuses on Linux/Ubuntu. Hitobito development also runs on other platforms with some adjustments. 
 Follow the prerequisites in section _[Windows preparation][windows_preparation]_ to set up a Windows platform for Hitobito development, before continuing below.

[windows_preparation]: #windows-preparation

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

⚡ If you want to contribute to an existing wagon/organisation please adapt this e.g. `(cd app && git clone https://github.com/hitobito/hitobito_youth.git && git clone https://github.com/hitobito/hitobito_pbs.git)`


The final structure in app/ should look something like this:

```bash
$ ls -lah app/
total 16K
drwxrwxr-x  4 ps ps 4.0K Jun 25 11:20 .
drwxrwxr-x 17 ps ps 4.0K Jun 25 10:00 ..
-rw-r--r-x  1 ps ps    2 Jun 25 10:00 .gitignore
drwxrwxr-x 18 ps ps 4.0K Jun 25 07:29 hitobito
drwxrwxr-x 11 ps ps 4.0K Jun 24 10:53 hitobito_generic
```

## Prepare storage space for dependencies

If you did not so before, create new docker volumes for storing bundled gems and yarn packages:

```bash
docker volume create hitobito_bundle
docker volume create hitobito_yarn_cache
```

⚡ If your user id is not 1000 (run id -u to check), you need to export this as env variable: **export RAILS_UID=$UID** before running any of the further commands. Maybe you want to add this to your bashrc.

## Start Development Containers

To start the Hitobito application, run the following command in your shell:

```bash
docker-compose up -d
```

⚡ This will also install all required gems and seed the database, which takes some time to complete if it's executed the first time. You can follow the progress using `docker-compose logs --follow rails` (exit with Ctrl+C).

After the startup has completed (once you see `Listening on tcp://0.0.0.0:3000` in the logs), make sure all services are up and running:

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
development_rails_1         rails-entrypoint rails ser ...   Up      0.0.0.0:3000->3000/tcp, 8080/tcp  
development_sphinx_1        sphinx-start                     Up      36307/tcp                         
development_worker_1        rails-entrypoint rails job ...   Up      8080/tcp
```

Access the web application by browser: http://localhost:3000 and log in using *hitobito@puzzle.ch* and password *hito42bito*. For some wagons, the e-mail address is different. Go to the file ```/config/settings.yml``` inside your wagon repository and look out for the field "root_email". Use this e-mail address to login.

## E-Mails

:email: All mails sent by your local development environment end up in **mailcatcher**. You can access these e-mails by visiting http://localhost:1080.

## Development

Start developing by editing files locally with your prefered editor in the app/hitobito* folders. Those directories are mounted inside the containers. So every saved file is instantly available inside the containers.

:bulb: If you don't know where to begin changing something, have a look at our hitobito cheatsheet in [English](./doc/hitobito-cheatsheet-en.pdf) and [German](./doc/hitobito-cheatsheet.pdf).

### Running rails tasks, console

For executing tasks like **rails routes** or starting the rails console in **development** environment, run the following command:

```bash
docker-compose exec rails bash
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
bin/test_env_wagon bundle exec rspec
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

🍺 finished work ? execute **docker-compose down** to shut down all running containers

### Updating Images

:calendar: If you have installed a previous development setup before 03.2021, please run the following command inside one project, and then update your images:
```bash
docker-compose down && docker volume rm hitobito_bundle && docker volume create hitobito_bundle
```

When the images of this project change, execute the following command to update them locally:

```bash
docker-compose build --no-cache
```

### Cloning wagons quickly  

:race_car: You go ahead and clone your hitobito dev setup by taking full advantage of the `hitobito_clone` script located within `bin/hitobito_clone.rb`

Make sure you execute the script in the folder you want to have your hitobito setup. Make sure you have the following things preinstalled on your device:

```text
# For script exec
- Ruby
# To retrieve the script
- wget
# Local development with docker
- docker + docker-compose
# Version control
- git
```

Then execute the following, which clones all hitobito repositories within a new or existing hitobito directory.

```bash
wget -O - https://raw.githubusercontent.com/hitobito/development/master/bin/hitobito_clone.rb | ruby
```

&ast;Note: by adding the -h option, you get some good information about what the script is able to do further.


## Windows preparation
The suggested approach for Hitobito development on Windows uses VSCode. VSCode provides extensions for integration of Docker and WSL 2. The next steps will prepare Windows for WSL 2, Docker and VSCode.

### WSL 2

Install WSL 2 with Ubuntu using PowerShell **running as administrator**.
```bash
wsl --install
```
Consider a look at _[Install Linux on Windows with WSL][wsl_install]_ for troubleshooting.

Next, you will have to reboot your computer, before you are able to use WSL 2.

Open another PowerShell as administrator, and install Ubuntu:
```bash
wsl --install -d Ubuntu
```

An Ubuntu terminal opens. If not, open _Ubuntu_ using the Start menu.

You will be prompted to specify user name and password. Then, update and upgrade packages.
```terminal
sudo apt update && sudo apt upgrade
```
⚡ Don't close the Ubuntu terminal yet.

[wsl_install]: https://learn.microsoft.com/en-us/windows/wsl/install

### Docker

Download and install [Docker Desktop][docker_desktop].
The installation will promt you to enable WSL 2.

Open _Docker Desktop_ using the Start menu. 
Select Settings > Generals and make sure the _Use the WSL 2 based engine_ option is activated. If necessary, click _Apply & restart_.

Return to the Ubuntu terminal and confirm the installation.
```terminal
docker --version
```
Version and build information should appear. That's it, terminate Ubuntu.
```terminal
exit
```

See _[Get started with Docker remote containers on WSL 2][docker_install]_ for a more detailed description.

[docker_desktop]: https://docs.docker.com/desktop/windows/wsl/#download
[docker_install]: https://learn.microsoft.com/en-us/windows/wsl/tutorials/wsl-containers

### VSCode

Download and install [VSCode][vs_code].

Open _VSCode_ using the Start menu.

Search for and install the following extensions:
- Remote Development (Microsoft)
- Dev Containers (Microsoft)
- Docker (Microsoft)

:bulb: You will find the _Extensions_ menu on the left.

Start a remote Ubuntu session by clicking on the buttom left corner which should be highlighted in green, and select _New WSL window_.

A new VSCode instance opens with remote Ubuntu enabled.
Confirm the button in the bottom left corner highlighted in green and indicating the Ubuntu session.

Start the terminal within VSCode, by clicking the _Toggle panel_ button in the top right.

:sparkles: Well donne! You are set to follow the instructions of section _[Preparation][preparation]_, using the Ubuntu session within the VSCode terminal.

[vs_code]: https://code.visualstudio.com/download
[preparation]: #preparation
