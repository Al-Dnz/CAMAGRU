FROM postgres:13.3-alpine

RUN apk update && apk add --no-cache tzdata
ENV TZ Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

COPY init.sql /docker-entrypoint-initdb.d/

CMD ["postgres"]