# Docker
Docker definitions for some projects to learn and research.

## Base

Base image for other projects based on CentOS 7.

## Base i386

Build a docker base image from scratch (based on CentOS 7 i386)

There are two scripts:
 - [mkImageYum.sh](https://github.com/maximatt/docker/blob/master/base_i386/mkImageYum.sh): to be used under hosts with Yum package manager.
 - [mkImageDNF.sh](https://github.com/maximatt/docker/blob/master/base_i386/mkImageDNF.sh): to be used under hosts with DNF package manager.
 
Build and run using [Dockerfile](https://github.com/maximatt/docker/blob/master/base_i386/Dockerfile) 
```bash
$ docker build --rm -t centos7/i386:1.0 -f $(pwd -P)/Dockerfile .
$ docker run --name centos7_i386  --rm -ti  -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v /tmp -v /run centos7/i386:1.0
```
 
## HTTP-Front

Frontend based on HTTP Apache server.

Proxy definitions on [proxy.conf](https://github.com/maximatt/docker/blob/master/httpd/config/proxy.conf).

## Trac

[Trac](https://trac.edgewall.org/) is a wiki and issue tracking system for software development projects.

This project enable the possibility to manage multiprojects.

All projects are under `/home/trac/repository`; each folder under this directory is considerated as a Trac project; and all of them are updated to the installed version of Trac.

Empty folders, are considerated as Trac project to create and they are created when the container starts.

All projects are setted to be authenticated with `TRAC_USER` and `TRAC_PASSWORD` (environment variables).

### Access Trac repositories
 - [Trac](http://172.30.0.101/trac/)

### Parameters
  - `TRAC_USER`: user to trac projects.
  - `TRAC_PASSWORD`: password to trac projects.

### Pendings
 - Add SVN and Git as repositories to Trac.
 - Email configuration on Trac.
 - Add scripts to backup/restore, export wiki content as PDF/HTML, and others.

## Git

Project to setup a Git server

### Create and access to repositories
 - [GitWeb](http://172.30.0.101/gitweb/)
 - Create repository
   ```bash
   $ docker exec -it $(docker ps | grep git | awk "{print \$1}") /bin/bash -c "git.sh create test"
   ```  
 - Clone repository
   ```bash
   $ git clone http://guser:gpass@172.30.0.101/git/test.git
   ```
 - Delete repository
   ```bash
   $ docker exec -it $(docker ps | grep git | awk "{print \$1}") /bin/bash -c "git.sh delete test"
   ```

## SVN

Project to setup a SVN server

### Create and access to repositories
 - [SVN](http://172.30.0.101/svn/)
 - Create repository
   ```bash
   $ docker exec -it $(docker ps | grep svn | awk "{print \$1}") /bin/bash -c "svn.sh create test"
   ```  
 - Checkout repository
   ```bash
   $ svn co http://172.30.0.101/svn/test test
   ```
 - Delete repository
   ```bash
   $ docker exec -it $(docker ps | grep svn | awk "{print \$1}") /bin/bash -c "svn.sh delete test"
   ```

### Parameters
  - `SVN_USER`: svn user used to authenticate against repositories under the server
  - `SVN_PASS`: password for the svn user name
  
## Tor

[Tor](www.torproject.org) is a piece of software that enable to us an anonymous communication.

This project enable the possibility to create a Tor service (.onion site).
To retrieve onion address: 
```bash
$ docker exec $(docker ps | grep tor-service | awk "{print \$1}") /bin/bash -c 'cat ./hidden_service/hostname'
```

### Parameters
- Arguments
  - `TOR_VERSION`: Tor version to use (default `0.3.3.10`).
  - `HIDDEN_SERVICE_PORT` Tor service port (default `80`).
  - `HIDDEN_SERVICE_VERSION`: Onion address version to be generated (default `3`).
  - `TOR_SITE_URI`: URI where Tor service content is located (default `tor-site:80`)

### Pendings

 - Improve security, isolation, anonymity, availability and limit available resources.

## Registry

  - Certificate configuration
    ```bash
    $ sudo mkdir -p /etc/docker/certs.d/172.28.0.107:443
    $ sudo cp ./certs/cert.crt /etc/docker/certs.d/172.28.0.107:443/ca.crt
    ```
  - Setting user and password
    ```bash
    $ mkdir auth
    $ docker run --entrypoint htpasswd registry -Bbn testuser testpassword > auth/htpasswd
    ```
  - Test
    ```bash
    $ docker login -u testuser 172.28.0.107:443
    $ docker image tag centos:7 172.28.0.107:443/centos:7
    $ docker push 172.28.0.107:443/centos:7
    $ docker pull 172.28.0.107:443/centos:7
    $ curl -u testuser:testpassword -X GET --insecure https://172.28.0.107/v2/centos/tags/list | jq .
    ```
