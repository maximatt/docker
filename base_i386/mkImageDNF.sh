#!/bin/bash
#
# Autor:
#   Maximiliano de Mattos (azamax@gmail.com)
#
# Description:
#   Script to create a docker base image based on Centos 7 i386
#
# Usage:
#   $ sudo sh mkImageDNF.sh
#
# References:
#   https://github.com/moby/moby/blob/master/contrib/mkimage-yum.sh
#   https://github.com/CentOS/sig-cloud-instance-build/blob/master/docker/centos-7i386.ks
#
##########################################################################

CENTOS_REPO="http://mirror.centos.org/altarch/7/os/i386/"
CENTOS_REPO_UPD="http://mirror.centos.org/altarch/7/updates/i386/"
CENTOS_ROOT=$(mktemp -d --tmpdir CENTOS_ROOT.XXXXXXXXXXXX)

mkdir -p -m 755 $CENTOS_ROOT/etc/sysconfig
mkdir -m 755 $CENTOS_ROOT/dev
mknod -m 600 $CENTOS_ROOT/dev/console c 5 1
mknod -m 600 $CENTOS_ROOT/dev/initctl p
mknod -m 666 $CENTOS_ROOT/dev/full c 1 7
mknod -m 666 $CENTOS_ROOT/dev/null c 1 3
mknod -m 666 $CENTOS_ROOT/dev/ptmx c 5 2
mknod -m 666 $CENTOS_ROOT/dev/random c 1 8
mknod -m 666 $CENTOS_ROOT/dev/tty c 5 0
mknod -m 666 $CENTOS_ROOT/dev/tty0 c 4 0
mknod -m 666 $CENTOS_ROOT/dev/urandom c 1 9
mknod -m 666 $CENTOS_ROOT/dev/zero c 1 5

dnf --installroot=$CENTOS_ROOT --releasever=7 --setopt=tsflags=nodocs \
    --repofrompath=centos7,$CENTOS_REPO --repofrompath=centos7u,$CENTOS_REPO_UPD \
    --disablerepo=* --enablerepo={centos7,centos7u} -y install centos-release yum

dnf --installroot=$CENTOS_ROOT --releasever=7 --setopt=tsflags=nodocs \
    --repofrompath=centos7,$CENTOS_REPO --repofrompath=centos7u,$CENTOS_REPO_UPD \
    --disablerepo=* --enablerepo={centos7,centos7u} clean all

sed -i '/distroverpkg=centos-release/a tsflags=nodocs' /etc/yum.conf
echo 'container' > $CENTOS_ROOT/etc/yum/vars/infra
echo 'i386' > $CENTOS_ROOT/etc/yum/vars/basesearch

cat > "$target"/etc/sysconfig/network <<EOF
NETWORKING=yes
HOSTNAME=localhost.localdomain
EOF

rm -rf $CENTOS_ROOT/usr/{{lib,share}/locale,{lib,lib64}/gconv,bin/localedef,sbin/build-locale-archive}
rm -rf $CENTOS_ROOT/usr/share/{man,doc,info,gnome/help}
rm -rf $CENTOS_ROOT/usr/share/cracklib
rm -rf $CENTOS_ROOT/usr/share/i18n
rm -rf $CENTOS_ROOT/var/cache/yum
rm -rf $CENTOS_ROOT/sbin/sln
rm -rf $CENTOS_ROOT/etc/ld.so.cache
rm -fr $CENTOS_ROOT/var/cache/ldconfig/*
rm -rf $CENTOS_ROOT/var/log/*
rm -rf $CENTOS_ROOT/tmp/*
rm -rf $CENTOS_ROOT/boot
rm -rf $CENTOS_ROOT//etc/udev/hwdb.bin
rm -rf $CENTOS_ROOT//usr/lib/udev/hwdb.d/*

DOCKER_PIPE=$(mktemp -u --tmpdir pipe.XXXXXXXXXXXX)
XZ_PIPE=$(mktemp -u --tmpdir pipe.XXXXXXXXXXXX)
mkfifo $DOCKER_PIPE
mkfifo $XZ_PIPE
docker import - i386/centos7 < $DOCKER_PIPE &
xz -9e < $XZ_PIPE > centos7.tar.xz &
tar -C $CENTOS_ROOT/ -c . | tee $DOCKER_PIPE > $XZ_PIPE
