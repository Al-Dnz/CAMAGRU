FROM ruby:latest

RUN mkdir -p /app 

ADD server.rb /app/

WORKDIR /app/

COPY Gemfile .

RUN gem install bundler

RUN bundle install 

EXPOSE 1337

CMD [ "ruby", "server.rb" ]