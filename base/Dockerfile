FROM debian:10
LABEL maintainer="azamax@gmail.com"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt upgrade --yes; \
    apt-get install --yes apt-utils systemd; \
    rm -f /lib/systemd/system/multi-user.target.wants/*; \
    rm -f /etc/systemd/system/*.wants/*; \
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/sysinit.target.wants/systemd-tmpfiles-setup*; \
    rm -f /lib/systemd/system/systemd-update-utmp*; \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

VOLUME [ "/sys/fs/cgroup" ]

CMD ["/lib/systemd/systemd"]
