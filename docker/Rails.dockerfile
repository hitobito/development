FROM centos/ruby-26-centos7

USER root

ENV RAILS_ENV=development
ENV BUNDLE_PATH=/opt/bundle
WORKDIR /opt/app-root/src/hitobito
RUN yum remove -y ${RUBY_SCL}-rubygem-bundler
RUN bash -c 'gem install bundler -v 1.17.3'
COPY ./docker/rails-entrypoint /usr/local/bin
COPY ./docker/waitfortcp /usr/local/bin

ENTRYPOINT ["rails-entrypoint"]
CMD [ "rails", "server", "-b", "0.0.0.0" ]
