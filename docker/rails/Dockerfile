#################################
#          Variables            #
#################################

# The toolchain (ruby, node, yarn, bundler, build packages) is inherited
# from the `base` stage of the hitobito core Dockerfile. The base image is
# built directly from GitHub – no local checkout of the core repository
# is needed:
#
#   docker build --target base https://github.com/hitobito/hitobito.git
#
# or via docker compose (see the `hitobito-base` service):
#
#   docker compose --profile manual build hitobito-base
#
# It is also rebuilt nightly and published to ghcr.io by the
# docker-publish workflow, so a simple `docker compose build` resolves
# it from the registry.

ARG BASE_IMAGE="ghcr.io/hitobito/development/hitobito-base:latest"
ARG TRANSIFEX_VERSION="1.6.4"
ARG CLAUDE_CODE_VERSION="stable"
ARG OPENCODE_VERSION=""

# Packages needed on top of the ones the core Dockerfile installs
ARG DEV_PACKAGES="direnv xvfb chromium chromium-driver pv vim curl less sudo docker-ce-cli sqlite3 libsqlite3-dev imagemagick libvips42 postgresql-client"

#################################
#       Development Stage       #
#################################

FROM ${BASE_IMAGE} AS dev

USER root

ENV RAILS_ENV=development
ENV RAILS_DB_ADAPTER=postgresql
ENV BUNDLE_PATH=/opt/bundle
ARG USERNAME=hitobito
ARG USER_UID=1000
ARG USER_GID=$USER_UID

WORKDIR /usr/src/app/hitobito

# Prepare Docker cli install to be able to use it in the devcontainer
RUN export DEBIAN_FRONTEND=noninteractive \
 && apt-get update \
 && apt-get install -y ca-certificates curl gnupg lsb-release \
 && install -m 0755 -d /etc/apt/keyrings \
 && curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc \
 && chmod a+r /etc/apt/keyrings/docker.asc \
 && echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" > /etc/apt/sources.list.d/docker.list

ARG DEV_PACKAGES
RUN export DEBIAN_FRONTEND=noninteractive \
 && apt-get update \
 && apt-get install -y --no-install-recommends ${DEV_PACKAGES}

ARG TRANSIFEX_VERSION
RUN curl -L "https://github.com/transifex/cli/releases/download/v${TRANSIFEX_VERSION}/tx-linux-amd64.tar.gz" | tar xz -C /usr/local/bin/

ARG CLAUDE_CODE_VERSION
ARG OPENCODE_VERSION
RUN export HOME=/opt/agent-install \
 && mkdir -p $HOME \
 && curl -fsSL https://claude.ai/install.sh | bash -s -- "${CLAUDE_CODE_VERSION}" \
 && curl -fsSL https://opencode.ai/install | VERSION="${OPENCODE_VERSION}" bash \
 && cp "$(readlink -f $HOME/.local/bin/claude)" /usr/local/bin/claude \
 && cp $HOME/.opencode/bin/opencode /usr/local/bin/opencode \
 && chmod 755 /usr/local/bin/claude /usr/local/bin/opencode \
 && rm -rf $HOME

# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
&& useradd --uid $USER_UID --gid $USER_GID -m $USERNAME -s /bin/bash -d /home/developer \
&& echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
&& chmod 0440 /etc/sudoers.d/$USERNAME

# Preinstall github.com ssh host keys
# This needs to be in /home/developer, since we have a non-standard home directory for the user $USERNAME
# You can find the keys at https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints
RUN mkdir -p /home/developer/.ssh \
    && echo "github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl" >> /home/developer/.ssh/known_hosts \
    && echo "github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=" >> /home/developer/.ssh/known_hosts \
    && echo "github.com ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk=" >> /home/developer/.ssh/known_hosts \
    && chmod 600 /home/developer/.ssh/known_hosts \
    && /usr/bin/ssh-keygen -H -f /home/developer/.ssh/known_hosts \
    && chown -R $USERNAME:$USERNAME /home/developer/.ssh

# for release and version-scripts
RUN bash -vxc 'gem install cmdparse pastel'

COPY ./rails-entrypoint.sh /usr/local/bin
COPY ./assets-entrypoint.sh /usr/local/bin

RUN mkdir /opt/bundle && chmod 777 /opt/bundle
RUN mkdir /seed && chmod 777 /seed

USER $USERNAME

ENV HOME=/home/developer
ENV NODE_PATH=/usr/lib/nodejs

ENTRYPOINT ["rails-entrypoint.sh"]
CMD [ "rails", "server", "-b", "0.0.0.0" ]
