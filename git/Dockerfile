FROM debian10-base:latest
LABEL maintainer="azamax@gmail.com"

ARG SERVER_ADMIN=azamax@gmail.com
ARG GIT_PORT="5000"
ARG GIT_SERVER="git.maximatt.org"

ENV GIT_PORT=${GIT_PORT}
ENV GIT_SERVER=${GIT_SERVER}
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /home/git

RUN apt update && apt upgrade --yes; \
    apt-get install --yes apache2 git gitweb highlight; \
    a2enmod cgi; \
    systemctl enable apache2; \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD ./config/git.conf /etc/apache2/conf-available/git.conf
ADD ./config/git.sh /usr/local/bin/git.sh

RUN chmod 755 /usr/local/bin/git.sh; \
    sed -i 's/^Listen .*/Listen '"${GIT_PORT}"'/g' /etc/apache2/ports.conf; \
    touch /etc/apache2/conf-available/http_front.conf; \
    echo "ServerAdmin ${SERVER_ADMIN}" >> /etc/apache2/conf-available/http_front.conf; \
    echo "EnableSendfile off" >> /etc/apache2/conf-available/http_front.conf; \
    a2enconf http_front; \
    sed -i 's/^<VirtualHost .*/<VirtualHost *:'"${GIT_PORT}"'>/g' /etc/apache2/conf-available/git.conf; \
    sed -i 's/ServerName .*/ServerName '"${GIT_SERVER}"'/g' /etc/apache2/conf-available/git.conf; \
    sed -i 's/ServerAdmin .*/ServerAdmin '"${GIT_EMAIL}"'/g' /etc/apache2/conf-available/git.conf; \
    a2enconf git

EXPOSE ${GIT_PORT}

VOLUME [ "/sys/fs/cgroup" ]

CMD ["git.sh","entrypoint"]
