FROM ruby:2.6

USER root

RUN bash -c 'gem install mailcatcher'

CMD [ "mailcatcher", "-f", "--ip", "0.0.0.0" ]
