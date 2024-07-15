#################################
#          Variables            #
#################################

# Keep ruby version in sync with the Hitobito Dockerfile
# Some tests depend on the ruby version.

# Versioning
ARG RUBY_VERSION="3.2"
ARG BUNDLER_VERSION="2.5.11"
ARG NODEJS_VERSION="16"
ARG YARN_VERSION="1.22.19"
ARG TRANSIFEX_VERSION="1.6.4"

# Packages
ARG BUILD_PACKAGES="nodejs git sqlite3 libsqlite3-dev imagemagick build-essential default-libmysqlclient-dev"
ARG DEV_PACKAGES="direnv xvfb chromium chromium-driver default-mysql-client pv vim curl less sudo docker-ce-cli"

#################################
#          Build Stage          #
#################################

FROM ruby:${RUBY_VERSION} AS build

USER root

ENV RAILS_ENV=development
ENV RAILS_DB_ADAPTER=mysql2
ENV BUNDLE_PATH=/opt/bundle
ARG USERNAME=hitobito
ARG USER_UID=1000
ARG USER_GID=$USER_UID

WORKDIR /usr/src/app/hitobito

ARG NODEJS_VERSION
RUN export DEBIAN_FRONTEND=noninteractive \
 && apt-get update \
 && apt-get install -y ca-certificates curl gnupg lsb-release \
 && mkdir -p /etc/apt/keyrings \
 && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
 && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODEJS_VERSION}.x nodistro main" > /etc/apt/sources.list.d/nodesource.list \
 && echo "Package: nodejs" >> /etc/apt/preferences.d/preferences \
 && echo "Pin: origin deb.nodesource.com" >> /etc/apt/preferences.d/preferences \
 && echo "Pin-Priority: 1001" >> /etc/apt/preferences.d/preferences \
 # Prepare Docker cli install to be able to use it in the devcontainer
 && install -m 0755 -d /etc/apt/keyrings \
 && curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc \
 && chmod a+r /etc/apt/keyrings/docker.asc \
 && echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" > /etc/apt/sources.list.d/docker.list

ARG BUILD_PACKAGES
ARG DEV_PACKAGES
RUN export DEBIAN_FRONTEND=noninteractive \
 && apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y --no-install-recommends ${BUILD_PACKAGES} \
 && apt-get install -y --no-install-recommends ${DEV_PACKAGES}

ARG YARN_VERSION
RUN node -v && npm -v && npm install -g yarn && yarn set version "${YARN_VERSION}"

ARG TRANSIFEX_VERSION
RUN curl -L "https://github.com/transifex/cli/releases/download/v${TRANSIFEX_VERSION}/tx-linux-amd64.tar.gz" | tar xz -C /usr/local/bin/

ARG BUNDLER_VERSION
RUN bash -vxc "gem install bundler -v ${BUNDLER_VERSION}"


# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME -s /bin/bash -d /home/developer \
    #
    # [Optional] Add sudo support. Omit if you don't need to install software after connecting.
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Preinstall github.com ssh host keys
# This needs to be in /home/developer, since we have a non-standard home directory for the user $USERNAME
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
COPY ./webpack-entrypoint.sh /usr/local/bin

RUN mkdir /opt/bundle && chmod 777 /opt/bundle
RUN mkdir /seed && chmod 777 /seed

USER $USERNAME

ENV HOME=/home/developer
ENV NODE_PATH=/usr/lib/nodejs

ENTRYPOINT ["rails-entrypoint.sh"]
CMD [ "rails", "server", "-b", "0.0.0.0" ]
