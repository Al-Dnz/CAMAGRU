FROM python:3

RUN mkdir -p /app

ADD . /app/

WORKDIR /app/

EXPOSE 80

ENTRYPOINT ["sh", "./entrypoint.sh"]
