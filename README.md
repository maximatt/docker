# Docker
Docker definitions for some projects to learn and research.

## Base

Base image for other projects based on Debian 10.
```bash
$ docker compose build debian10-base
$ docker compose start debian10-base
```

## Base i386

Build a docker base image from scratch (based on Debian 10 i386)
```bash
$ sh mkImage.sh
$ docker build --rm -t i386/debian10:1.0 -f $(pwd -P)/Dockerfile .
$ docker run --name debian10_i386  --rm -ti  -v /tmp -v /run i386/debian10:1.0
```
## Git

Project to setup a Git server
```bash
$ docker compose build git
$ docker compose start git
```

### Create and access to repositories
- [GitWeb](http://172.72.0.101:5001/gitweb/)
- Create repository
```bash
$ docker exec -it $(docker ps | grep "git " | awk "{print \$1}") /bin/bash -c "git.sh create test"
```  
- Clone repository
```bash
$ git clone http://guser:gpass@172.72.0.101:5001/git/test.git
```
- Delete repository
```bash
$ docker exec -it $(docker ps | grep "git " | awk "{print \$1}") /bin/bash -c "git.sh delete test"
```

## Trac

[Trac](https://trac.edgewall.org/) is a wiki and issue tracking system for software development projects.

This project enable the possibility to manage multiprojects, and all projects are setted to be authenticated with `TRAC_USER` and `TRAC_PASSWORD` (environment variables).

To setup a Trac server:
```bash
$ docker compose build trac
$ docker compose start trac
```

### Create and access to repositories
- [Trac](http://172.72.0.102:5002/trac)
- Create repository
```bash
$ docker exec -it $(docker ps | grep "trac " | awk "{print \$1}") /bin/bash -c "trac.sh setup_project test"
```

### Pendings
 - Add Git as repositorys to Trac.
 - Email configuration on Trac.
 - Add scripts to backup/restore, export wiki content as PDF/HTML.
