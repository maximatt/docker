FROM maximatt/debian10-base:latest
LABEL maintainer="azamax@gmail.com"

ARG SERVER_ADMIN=azamax@gmail.com
ARG TRAC_PORT=5002

ENV TERM xterm-256color
ENV DEBIAN_FRONTEND noninteractive
ENV SHEL /bin/bash
ENV HOME /home/trac
ENV TRAC_PORT=${TRAC_PORT}
ENV SERVER_ADMIN=${SERVER_ADMIN}
ENV PYTHON_EGG_CACHE=/tmp/python-eggs

WORKDIR /home/trac

RUN apt update && apt upgrade --yes; \
    apt-get install --yes git subversion apache2 libapache2-mod-wsgi-py3 python3-pip build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev ; \
    a2enmod wsgi; \
    systemctl enable apache2; \ 
    python3 -m pip install --upgrade pip; \
    pip install trac svn+https://trac-hacks.org/svn/xmlrpcplugin/trunk svn+https://trac-hacks.org/svn/tracwikiprintplugin/trunk svn+https://trac-hacks.org/svn/tracwysiwygplugin/0.12/; \
    mkdir -p /tmp/python-eggs

ADD ./config/trac.wsgi /home/trac/trac.wsgi
ADD ./config/trac.conf /etc/apache2/conf-available/trac.conf
ADD ./config/tracEntrypoint.sh /usr/local/bin/entrypoint.sh
ADD ./config/space_invaders.png /home/trac/space_invaders.png

RUN chmod 755 /usr/local/bin/entrypoint.sh; \
    a2enconf trac; \
    sed -i 's/^Listen .*/Listen '"$TRAC_PORT"'/g' /etc/apache2/ports.conf; \
    chown -R www-data:www-data $HOME_TRAC/repository/; \
    chmod -R 775 $HOME_TRAC; \
    touch /etc/apache2/conf-available/http_front.conf; \
    echo "ServerAdmin ${SERVER_ADMIN}" >> /etc/apache2/conf-available/http_front.conf; \
    echo "EnableSendfile off" >> /etc/apache2/conf-available/http_front.conf; \
    a2enconf http_front

EXPOSE ${TRAC_PORT}

VOLUME [ "/sys/fs/cgroup" ]

CMD ["entrypoint.sh"]
