# CAMAGRU

## Description

[Subject](https://cdn.intra.42.fr/pdf/pdf/75146/en.subject.pdf)

Camagru is a 42 school project that consists in create an Instagram like app.
You can subscribe as user and connect to publish your own pictures or see the other users's publications.
Your pic are taken from webcam and can be added with emojis or images with alpha canal.
The goal of this project is to create a web app WITHOUT FRAMEWORKS !

## Launch

⚠️ The app works with Docker and docker-compose. Check if these are present on your machine.

```
make
```

then go to your browser at URL:
```
http://localhost:8000
```

## envfile

This project require an envfile .env  set at the root with following variables:

POSTGRES_HOST=postgres\
POSTGRES_USER=<db_user>\
POSTGRES_PASSWORD=<db_password>\
POSTGRES_DB=<db_name>\
HOST=<server_host_ip>

[these one are optional]\
SENDGRID_EMAIL_SENDER=<your_sendgrid_api_mail_adress>\
SENDGRID_API_KEY=<your_sendgrid_api_key>
