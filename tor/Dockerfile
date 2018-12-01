FROM maximatt/centos7-base
LABEL maintainer="azamax@gmail.com"

ARG TOR_VERSION="0.3.3.10"
ARG HIDDEN_SERVICE_PORT="80"
ARG HIDDEN_SERVICE_VERSION="3"
ARG TOR_SITE_URI="tor-site:80"

WORKDIR /home/tor
ADD https://www.torproject.org/dist/tor-${TOR_VERSION}.tar.gz tor-${TOR_VERSION}.tar.gz
ADD https://bootstrap.pypa.io/get-pip.py get-pip.py

RUN yum install -y libevent-devel openssl-devel zlib-devel; \
    python get-pip.py; pip install nyx; \
    yum install -y gcc make

RUN tar -zxvf tor-${TOR_VERSION}.tar.gz && cd tor-${TOR_VERSION} && ./configure  && make && make install; \
    mkdir -p /etc/tor && cp /usr/local/etc/tor/torrc.sample /usr/local/etc/tor/torrc

RUN rm -fr /home/tor/*; \
    useradd tor -M -d /home/tor; \
    chown -R tor:tor /home/tor; \
    yum -y history undo $(yum history addon-info last | grep 'Transaction ID:' | tr -dc '0-9'); \
    yum clean all; rm -rf /var/cache/yum

RUN sed -i 's|^#Log notice syslog|Log notice stdout|' /usr/local/etc/tor/torrc; \
    sed -i 's|^#ControlPort 9051|ControlPort 9051|' /usr/local/etc/tor/torrc; \
    sed -i 's|^#CookieAuthentication 1|CookieAuthentication 1|' /usr/local/etc/tor/torrc; \
    sed -i 's|^#HiddenServiceDir /usr/local/var/lib/tor/hidden_service|HiddenServiceDir /home/tor/hidden_service|' /usr/local/etc/tor/torrc; \
    sed -i '0,/^#HiddenServicePort 80 127.0.0.1:80/ s/^#HiddenServicePort 80 127.0.0.1:80/HiddenServicePort '"${HIDDEN_SERVICE_PORT} ${TOR_SITE_URI}"'/' /usr/local/etc/tor/torrc; \
    sed -i '/#HiddenServicePort 22 127.0.0.1:22/a \\nHiddenServiceVersion '"${HIDDEN_SERVICE_VERSION}"'' /usr/local/etc/tor/torrc;

USER tor
VOLUME [ "/sys/fs/cgroup" ]

CMD ["tor"]
