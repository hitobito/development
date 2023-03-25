# Keep ruby version in sync with the Hitobito S2I image.
# Some tests depend on the ruby version.
FROM ruby:2.7

USER root

ENV RAILS_ENV=development
ENV RAILS_DB_ADAPTER=mysql2
ENV BUNDLE_PATH=/opt/bundle
ARG USERNAME=hitobito
ARG USER_UID=1000
ARG USER_GID=$USER_UID

WORKDIR /usr/src/app/hitobito

RUN \
  curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
  apt update && \
  apt install -y \
    nodejs \
    python3-pip direnv \
    xvfb chromium chromium-driver \
    default-mysql-client pv \
    less \
    sudo &&  \
  curl -o- https://raw.githubusercontent.com/transifex/cli/master/install.sh | bash && \
  npm install -g yarn

# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME -s /bin/bash \
    #
    # [Optional] Add sudo support. Omit if you don't need to install software after connecting.
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

RUN bash -c 'gem install bundler -v 2.1.4'

COPY ./rails-entrypoint /usr/local/bin
COPY ./webpack-entrypoint /usr/local/bin
COPY ./waitfortcp /usr/local/bin

RUN mkdir /opt/bundle && chmod 777 /opt/bundle
RUN mkdir /seed && chmod 777 /seed
RUN mkdir /home/developer && chmod 777 /home/developer
ENV HOME=/home/developer
ENV NODE_PATH=/usr/lib/nodejs

# ********************************************************
# * Anything else you want to do like clean up goes here *
# ********************************************************

# [Optional] Set the default user. Omit if you want to keep the default as root.
USER $USERNAME

ENTRYPOINT ["rails-entrypoint"]
CMD [ "rails", "server", "-b", "0.0.0.0" ]
