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
RUN bash -c 'gem install spring'

RUN yum localinstall -y \
      "https://github.com/sphinxsearch/sphinx/releases/download/2.2.11-release/sphinx-2.2.11-1.rhel7.x86_64.rpm" && \
    scl enable rh-ruby26 install-nodejs && \
    yum install -y python-setuptools && \
    scl enable rh-ruby26 install-transifex && \
    yum install ImageMagick ImageMagick-devel -y

# reduce image size
RUN yum clean all -y && rm -rf /var/cache/yum

RUN wget -O /usr/local/bin/direnv https://github.com/direnv/direnv/releases/download/v2.21.3/direnv.linux-amd64 && \
    chmod +x /usr/local/bin/direnv

RUN mkdir /opt/bundle && chmod 777 /opt/bundle

ENTRYPOINT ["rails-entrypoint"]
CMD [ "rails", "server", "-b", "0.0.0.0" ]
