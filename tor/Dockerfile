FROM debian:10
LABEL maintainer="azamax@gmail.com"

ARG TOR_VERSION="0.4.8.9"
ARG HIDDEN_SERVICE_PORT="80"
ARG HIDDEN_SERVICE_VERSION="3"
ARG TOR_SITE_URI="tor-site:80"

ENV TERM=xterm-256color
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /home/tor

RUN apt update && apt upgrade --yes; \
    apt-get install --yes gcc make tar libevent-dev libssl-dev zlib1g zlib1g-dev pkg-config liblzma-dev libzstd-dev wget; \
    apt-get install --yes nyx apt-transport-https

RUN wget -c https://dist.torproject.org/tor-${TOR_VERSION}.tar.gz tor-${TOR_VERSION}.tar.gz; \
    tar -zxvf tor-${TOR_VERSION}.tar.gz && cd tor-${TOR_VERSION} && ./configure  && make && make install; \
    mkdir -p /etc/tor; \
    cp /usr/local/etc/tor/torrc.sample /usr/local/etc/tor/torrc

RUN rm -fr /home/tor/*; \
    useradd tor -M -d /home/tor; \
    chown -R tor:tor /home/tor; \
    # info: sed -n <install line number>p
    apt-get --purge --yes remove $(grep -i "Commandline" /var/log/apt/history.log | sed -n 1p |  sed -e 's|.*--yes\(\)|\1|'); \ 
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN sed -i 's|^#Log notice syslog|Log notice stdout|' /usr/local/etc/tor/torrc; \
    sed -i 's|^#ControlPort 9051|ControlPort 9051|' /usr/local/etc/tor/torrc; \
    sed -i 's|^#CookieAuthentication 1|CookieAuthentication 1|' /usr/local/etc/tor/torrc; \
    sed -i 's|^#HiddenServiceDir /usr/local/var/lib/tor/hidden_service|HiddenServiceDir /home/tor/hidden_service|' /usr/local/etc/tor/torrc; \
    sed -i '0,/^#HiddenServicePort 80 127.0.0.1:80/ s/^#HiddenServicePort 80 127.0.0.1:80/HiddenServicePort '"${HIDDEN_SERVICE_PORT} ${TOR_SITE_URI}"'/' /usr/local/etc/tor/torrc; \
    sed -i '/#HiddenServicePort 22 127.0.0.1:22/a \\nHiddenServiceVersion '"${HIDDEN_SERVICE_VERSION}"'' /usr/local/etc/tor/torrc; \
    pass=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1); \
    sed -i 's|^#HashedControlPassword 16:872860B76453A77D60CA2BB8C1A7042072093276A3D701AD684053EC4C|HashedControlPassword '"$(tor --hash-password "${pass}" | grep 16:)"'|' /usr/local/etc/tor/torrc; \
    echo ">>>\033[0;32m KEEP SAFE: \033[36m $pass \033[0m<<<"; \
    mkdir -p /home/tor/.nyx/ && touch /home/tor/.nyx/config; \
    chown tor:tor -R /home/tor/.nyx/

USER tor

VOLUME [ "/sys/fs/cgroup" ]

CMD ["tor"]
