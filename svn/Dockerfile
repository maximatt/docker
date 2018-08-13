FROM maximatt/httpd-front
LABEL maintainer="azamax@gmail.com"

ARG SVN_PORT="5004"
ARG SVN_SERVER="svn.maximatt.org"

ENV SVN_PORT=${SVN_PORT}
ENV SVN_SERVER=${SVN_SERVER}

WORKDIR /home/svn

ADD ./config/svn.conf /etc/httpd/conf.d/svn.conf
ADD ./config/svn.sh /usr/local/bin/svn.sh

RUN chmod 755 /usr/local/bin/svn.sh; \
    yum -y update; \
    yum -y install mod_dav_svn subversion; \
    yum clean all; rm -rf /var/cache/yum; 

EXPOSE ${SVN_PORT}
VOLUME [ "/sys/fs/cgroup" ]

CMD ["svn.sh","entrypoint"]
