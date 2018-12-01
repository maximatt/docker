FROM maximatt/httpd-front
LABEL maintainer="azamax@gmail.com"

ARG GIT_PORT="5003"
ARG GIT_SERVER="git.maximatt.org"

ENV GIT_PORT=${GIT_PORT}
ENV GIT_SERVER=${GIT_SERVER}

WORKDIR /home/git

ADD ./config/git.conf /etc/httpd/conf.d/git.conf
ADD ./config/git.sh /usr/local/bin/git.sh

RUN chmod 755 /usr/local/bin/git.sh; \
    yum -y install git gitweb highlight; \
	yum clean all; rm -rf /var/cache/yum; 

EXPOSE ${GIT_PORT}

VOLUME [ "/sys/fs/cgroup" ]

CMD ["git.sh","entrypoint"]
