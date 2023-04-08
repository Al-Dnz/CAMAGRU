FROM ruby:latest

RUN mkdir -p /app 
RUN mkdir -p /app/upload

ADD server.rb request_util.rb server_util.rb data_parsing.rb mailer.rb routing/ /app/

WORKDIR /app/

COPY Gemfile .

RUN gem install bundler

RUN bundle install 

EXPOSE 1337

CMD [ "ruby", "server.rb", "PROD" ]