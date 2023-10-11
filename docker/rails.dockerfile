# Keep ruby version in sync with the Hitobito S2I image.
# Some tests depend on the ruby version.
FROM ruby:3.0

USER root

ENV RAILS_ENV=development
ENV RAILS_DB_ADAPTER=mysql2
ENV BUNDLE_PATH=/opt/bundle

WORKDIR /usr/src/app/hitobito

RUN \
  curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
  apt update && \
  apt install -y \
    nodejs \
    python3-pip direnv \
    xvfb chromium chromium-driver \
    default-mysql-client pv \
    less && \
  curl -o- https://raw.githubusercontent.com/transifex/cli/master/install.sh | bash && \
  npm install -g yarn

RUN bash -c 'gem install bundler -v 2.4.19'

COPY ./rails-entrypoint /usr/local/bin
COPY ./webpack-entrypoint /usr/local/bin
COPY ./waitfortcp /usr/local/bin

RUN mkdir /opt/bundle && chmod 777 /opt/bundle
RUN mkdir /seed && chmod 777 /seed
RUN mkdir /home/developer && chmod 777 /home/developer
ENV HOME=/home/developer
ENV NODE_PATH=/usr/lib/nodejs

ENTRYPOINT ["rails-entrypoint"]
CMD [ "rails", "server", "-b", "0.0.0.0" ]
