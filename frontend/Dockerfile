FROM python:3

RUN mkdir -p /app

ADD . /app/

WORKDIR /app/

EXPOSE 8000

CMD [ "python3", "-m", "http.server", "8000" ]