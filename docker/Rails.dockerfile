FROM ruby:2.6

USER root

ENV RAILS_ENV=development
ENV RAILS_DB_ADAPTER=mysql2
ENV BUNDLE_PATH=/opt/bundle

WORKDIR /usr/src/app/hitobito

RUN bash -c 'gem install bundler -v 1.17.3'

COPY ./docker/rails-entrypoint /usr/local/bin
COPY ./docker/webpack-entrypoint /usr/local/bin
COPY ./docker/waitfortcp /usr/local/bin
COPY ./app/hitobito/images/s2i/root/opt/bin/install-transifex /usr/local/bin

RUN apt update
RUN apt-get install nodejs yarnpkg -y && ln -s /usr/bin/yarnpkg /usr/bin/yarn
RUN apt-get install python-setuptools -y && install-transifex
RUN apt-get install direnv -y
RUN apt-get install -y xvfb chromium chromium-driver

RUN mkdir /opt/bundle && chmod 777 /opt/bundle
RUN mkdir /seed && chmod 777 /seed
RUN mkdir /home/developer && chmod 777 /home/developer
ENV HOME=/home/developer

ENTRYPOINT ["rails-entrypoint"]
CMD [ "rails", "server", "-b", "0.0.0.0" ]
