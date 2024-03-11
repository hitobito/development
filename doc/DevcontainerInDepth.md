# Devcontainers & GitHub Codespaces in Depth

## How do devcontainers work?

Essentially, there is a `devcontainer.json` in the `.devcontainer` folder which defines the devcontainer setup.

This consist on a high level of the following:
- Define the docker compose file to use. In this repo, we also have a second `.devcontainer/docker-compose.yml`, which overrides some stuff form the main image.
- Define which service to user to run the IDE in
- Specify the workspace folder that gets opened by default inside the container
- Predefine some port mappings. They are supplemental to the docker compose ports…
- Some devcontainer setup commands
    1. initializeCommand: Runs outside of the container, before the container is being started.
    2. onCreateCommand: Runs inside the container after launching it, but before the IDE is available
    3. updateContentCommand: Runs inside the container after the onCreateCommant, but before the IDE is available. This is also rerun by github to update the prebuilt images.
- Some vscode extensions, that will get preinstalled.

## What to the Scripts do?

### initialize.sh

The initialize.sh script is run outside the container, before it is launched. It clones the app repositories given to it as parameters. This is used to allow for all the variant/wagon setups to use almost the same setup.

### create.sh

The create.sh script is run inside the container after launching it, but before the IDE is available. It installs the ruby "debug" gem, which is needed for the ruby debugger to work. It then also runs the rails-entrypoint.sh script, which installs the gems, runs the migrations, seeds the database etc.

### update.sh

The update.sh script is run inside the container after the onCreateCommant, but before the IDE is available. This is also rerun by github to update the prebuilt images. It tries to pull all the wagon repositories, if they are not modified/fast forward is possible. It the reruns the rails-entrypoint.sh script, but skipping seeding the database and copying the wagonfiles.

## Prebuilt Github Codespaces
Not gonna go into detail here. But the prebuilt github codespaces are a feature that allows to prebuild the devcontainer images, so that the first time a user opens a codespace, it is already prebuilt and ready to go. This is done by running all the scripts on a schedule and storing the resulting workspace as template.

## Docker Access

To access docker inside from the devcontainer:
- we mount the docker socket into the container
- we run the container as privileged
- we install docker-ce-cli inside the container

This is a security risk for production, but not really a problem for development.

The docker group is not available inside the container, so you always have to call docker as root, eg using sudo. If we would create it in the container, it's id would be different from the host, which would cause problems with the mounted socket.