FROM maximatt/debian10-base:latest
LABEL maintainer="azamax@gmail.com"

ARG SERVER_ADMIN=azamax@gmail.com
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt upgrade --yes; \
    apt-get install --yes apache2 libapache2-mod-proxy-uwsgi; \
    a2enmod proxy_http; \
    a2enmod proxy_uwsgi; \
    systemctl enable apache2; \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD ./config/proxy.conf /etc/apache2/conf-available/proxy.conf

RUN touch /etc/apache2/conf-available/http_front.conf; \
    echo "ServerAdmin ${SERVER_ADMIN}" >> /etc/apache2/conf-available/http_front.conf; \
    echo "EnableSendfile off" >> /etc/apache2/conf-available/http_front.conf; \
    a2enconf proxy; \
    a2enconf http_front
