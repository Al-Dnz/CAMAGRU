FROM ruby:2.5.5

RUN mkdir -p /app 

ADD server.rb /app/

WORKDIR /app/

# RUN gem install 

EXPOSE 1337

CMD [ "ruby", "server.rb" ]