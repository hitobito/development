# Keep ruby version in sync with the Hitobito S2I image.
# Some tests depend on the ruby version.
FROM ruby:2.5

USER root

ENV RAILS_ENV=development
ENV RAILS_DB_ADAPTER=mysql2
ENV BUNDLE_PATH=/opt/bundle

WORKDIR /usr/src/app/hitobito

RUN bash -c 'gem install bundler -v 1.17.3'

RUN \
  curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
  apt update && \
  apt install -y \
    nodejs yarnpkg \
    python3-pip direnv \
    xvfb chromium chromium-driver \
    default-mysql-client pv \
    less &&  \
  pip3 install transifex-client && \
  ln -s /usr/bin/yarnpkg /usr/bin/yarn

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
