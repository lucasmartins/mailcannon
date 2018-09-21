FROM ruby:2.3.7

RUN mkdir /var/app

ENV APP_HOME /var/app
ADD . $APP_HOME
WORKDIR $APP_HOME
RUN bundle install
