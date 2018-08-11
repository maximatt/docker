FROM maximatt/httpd-front:1.0

ARG GIT_PORT="5003"
ARG GIT_SERVER="git.maximatt.org"

ENV GIT_PORT=${GIT_PORT}
ENV GIT_SERVER=${GIT_SERVER}

WORKDIR /home/git

ADD ./config/git.conf /etc/httpd/conf.d/git.conf
ADD ./config/git.sh /usr/local/bin/git.sh

RUN chmod 755 /usr/local/bin/git.sh;
    yum -y update; \
    yum -y install git gitweb highlight; \
	yum clean all; rm -rf /var/cache/yum; 
   
#ln -sf /dev/stdout /var/log/httpd/access_log; \
#ln -sf /dev/stderr /var/log/httpd/error_log
#RUN useradd -M -d /home/git -G apache git; \
#    chown -R git:apache /home/git;
    
EXPOSE ${GIT_PORT}

VOLUME [ "/sys/fs/cgroup" ]

CMD ["git.sh","entrypoint"]
