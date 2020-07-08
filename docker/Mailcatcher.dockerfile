FROM centos/ruby-26-centos7

USER root

RUN bash -c 'gem install mailcatcher'

CMD [ "mailcatcher", "-f", "--ip", "0.0.0.0" ]
