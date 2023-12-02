#!/bin/bash

DEBIAN_ROOT=$(mktemp -d --tmpdir DEBIAN_ROOT.XXXXXXXXXXXX)

sudo apt update
sudo apt-get install --yes multistrap

if [ -f multistrap.conf ]; then
	rm -fr multistrap.conf
fi

cat >multistrap.conf<<EOF
[General]
#arch=amd64
arch=i386
cleanup=true
noauth=true
unpack=true
aptsources=Buster
debootstrap=Buster
addimportant=true

[Buster]
packages=
source=http://deb.debian.org/debian/
keyring=debian-archive-keyring
suite=buster
EOF

mkdir -p -m 755 $DEBIAN_ROOT/etc/sysconfig
mkdir -m 755 $DEBIAN_ROOT/dev
mknod -m 600 $DEBIAN_ROOT/dev/console c 5 1
mknod -m 600 $DEBIAN_ROOT/dev/initctl p
mknod -m 666 $DEBIAN_ROOT/dev/full c 1 7
mknod -m 666 $DEBIAN_ROOT/dev/null c 1 3
mknod -m 666 $DEBIAN_ROOT/dev/ptmx c 5 2
mknod -m 666 $DEBIAN_ROOT/dev/random c 1 8
mknod -m 666 $DEBIAN_ROOT/dev/tty c 5 0
mknod -m 666 $DEBIAN_ROOT/dev/tty0 c 4 0
mknod -m 666 $DEBIAN_ROOT/dev/urandom c 1 9
mknod -m 666 $DEBIAN_ROOT/dev/zero c 1 5

sudo sed -i 's|apt_get update|apt_get update --allow-insecure-repositories|g' /usr/sbin/multistrap
sudo multistrap -d $DEBIAN_ROOT -f multistrap.conf

cat > $DEBIAN_ROOT/etc/sysconfig/network <<EOF
NETWORKING=yes
HOSTNAME=localhost.localdomain
EOF

rm -rf $DEBIAN_ROOT/usr/{{lib,share}/locale,{lib,lib64}/gconv,bin/localedef,sbin/build-locale-archive}
rm -rf $DEBIAN_ROOT/usr/share/{man,doc,info,gnome/help}
rm -rf $DEBIAN_ROOT/usr/share/{cracklib,i18n}
rm -rf $DEBIAN_ROOT/usr/lib/udev/hwdb.d/*
rm -rf $DEBIAN_ROOT/var/lib/apt/lists/*
rm -rf $DEBIAN_ROOT/sbin/sln
rm -rf $DEBIAN_ROOT/etc/ld.so.cache
rm -rf $DEBIAN_ROOT/tmp/*
rm -rf $DEBIAN_ROOT/boot
rm -rf $DEBIAN_ROOT/etc/udev/hwdb.bin
rm -rf $DEBIAN_ROOT/var/{tmp,log}/*
rm -fr $DEBIAN_ROOT/var/cache/ldconfig/*

DOCKER_PIPE=$(mktemp -u --tmpdir pipe.XXXXXXXXXXXX)
XZ_PIPE=$(mktemp -u --tmpdir pipe.XXXXXXXXXXXX)
mkfifo $DOCKER_PIPE
mkfifo $XZ_PIPE
docker import - i386/debian10 < $DOCKER_PIPE &
xz -9e < $XZ_PIPE > debian10.tar.xz &
tar -C $DEBIAN_ROOT/ -c . | tee $DOCKER_PIPE > $XZ_PIPE
