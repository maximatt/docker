FROM maximatt/centos7-base:1.0

ENV container docker

RUN yum -y install mod_proxy_html mod_proxy_uwsgi; \
    yum clean all; \
    systemctl enable httpd;

VOLUME [ "/sys/fs/cgroup" ]
