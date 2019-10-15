FROM nginx:latest

LABEL maintainer="selecticon@googlemail.com"
LABEL description="docker image for a default-reply nginx webserver"

COPY ./files/default.conf /etc/nginx/conf.d/
COPY ./files/404.html /usr/share/nginx/html
COPY ./files/404_sorry.png /usr/share/nginx/html

RUN echo "Nothing here..." > /usr/share/nginx/html/index.html