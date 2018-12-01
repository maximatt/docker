FROM maximatt/centos7-base
LABEL maintainer="azamax@gmail.com"

RUN yum -y install mod_proxy_html mod_proxy_uwsgi; \  
    yum clean all; rm -rf /var/cache/yum; \
    systemctl enable httpd

VOLUME [ "/sys/fs/cgroup" ]
