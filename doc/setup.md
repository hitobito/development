# Hitobito Development Setup 👩🏽‍💻

We're glad you want to setup your machine for hitobito development 💃

## System Requirements

You need to have [Docker][docker] and _[docker compose][doco]_ installed on your computer.
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

## Gemfile.lock

See more in the main [README.md](../README.md) but to prevent issues with the Gemfile.lock, you should run the following command:

```bash
touch docker/rails/Gemfile.lock
```

## Start Development Containers

To start the Hitobito application, run the following command in your shell:

```bash
docker compose up -d
```

After the startup has completed (once you see `Listening on tcp://0.0.0.0:3000` in the logs), make sure all services are up and running:

```bash
docker compose ps
```

This should look something like this:

```
NAME                            IMAGE                                      COMMAND                  SERVICE           CREATED        STATUS              PORTS
development-cache-1             memcached:1.6-alpine                       "docker-entrypoint.s…"   cache             3 hours ago    Up 3 hours          11211/tcp
development-postgres-1          postgres:16                                "docker-entrypoint.s…"   postgres          23 hours ago   Up 3 hours          5432/tcp, 0.0.0.0:5432->5432/tcp, :::5432->5432/tcp
development-mailcatcher-1       ghcr.io/hitobito/development/mailcatcher   "mailcatcher -f --ip…"   mailcatcher       3 hours ago    Up 3 hours          0.0.0.0:1080->1080/tcp, :::1080->1080/tcp
development-rails-1             ghcr.io/hitobito/development/rails         "rails-entrypoint.sh…"   rails             3 hours ago    Up 3 hours          0.0.0.0:3000->3000/tcp, :::3000->3000/tcp
development-rails_test_core-1   ghcr.io/hitobito/development/rails         "rails-entrypoint.sh…"   rails_test_core   21 hours ago   Up About a minute
development-webpack-1           ghcr.io/hitobito/development/rails         "webpack-entrypoint.…"   webpack           3 hours ago    Up About a minute   0.0.0.0:3035->3035/tcp, :::3035->3035/tcp
development-worker-1            ghcr.io/hitobito/development/rails         "rails-entrypoint.sh…"   worker            3 hours ago    Up About a minute
```

Access the web application by browser: http://localhost:3000 and log in using *hitobito@puzzle.ch* and password *hito42bito*. For some wagons, the e-mail address is different. Go to the file ```/config/settings.yml``` inside your wagon repository and look out for the field "root_email". Use this e-mail address to login.

## E-Mails

:email: All mails sent by your local development environment end up in **mailcatcher**. You can access these e-mails by visiting http://localhost:1080.


### Updating Images

When you have made changes to the images of this project, execute the following command to update them locally:

```bash
docker compose build --no-cache
```

Images are built and published with github actions

### Cloning wagons quickly  

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

:sparkles: Well done! You are set to follow the instructions of section _[Preparation][preparation]_, using the Ubuntu session within the VSCode terminal.

[vs_code]: https://code.visualstudio.com/download
[preparation]: #preparation

## Nextcloud

Hitobito has official support for nextcloud. You can start a nextcloud instance ready and set up for OIDC authentication via hitobito as follows:
```bash
docker compose -f docker-compose.yml -f nextcloud.yml up
```

You can then access your local nextcloud instance at http://localhost.
To test the hitobito Login part, you can then click on "Login with hitobito".
Alternatively, to manage the local nextcloud, you can use the credentials `admin` / `hito42bito`.

In case you get the following error:
> Client-Autorisierung MKIM ist fehlgeschlagen: Unbekannter Client, keine Autorisierung mitgeliefert oder Autorisierungsmethode nicht unterstützt.

The reason is that the connection between hitobito and nextcloud is set up during hitobito's seeding process, and you probably already had a seeded database before, so no re-seed was done.
To fix it, you first have to clear your database and then start again:
```bash
# Clear the database
docker compose -f docker-compose.yml -f nextcloud.yml down --volumes
# Start again
docker compose -f docker-compose.yml -f nextcloud.yml up
# Now it should work
```
