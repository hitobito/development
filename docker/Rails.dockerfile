FROM centos/ruby-26-centos7

USER root

ENV RAILS_ENV=development
ENV BUNDLE_PATH=/opt/bundle

WORKDIR /opt/app-root/src/hitobito

COPY ./docker/rails-entrypoint /usr/local/bin
COPY ./docker/waitfortcp /usr/local/bin
COPY ./app/hitobito/images/s2i/root/opt/bin/install-transifex /usr/local/bin
COPY ./app/hitobito/images/s2i/root/opt/bin/install-nodejs /usr/local/bin

RUN yum remove -y ${RUBY_SCL}-rubygem-bundler
RUN bash -c 'gem install bundler -v 1.17.3'

RUN \
    bash -c 'install-nodejs' && \
    yum install -y python-setuptools && \
    bash -c 'install-transifex' && \
    yum install ImageMagick ImageMagick-devel -y && \
    yum clean all -y

ENTRYPOINT ["rails-entrypoint"]
CMD [ "rails", "server", "-b", "0.0.0.0" ]
