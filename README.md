# Docker
Docker definitions for some projects to learn and research.

## Base

Base image for other projects based on CentOS 7.

## Base i386

Build a docker base image from scratch (based on Centos 7 i386)

There are two scripts:
 - `mkImageYum.sh`: to be used under hosts with Yum package manager.
 - `mkImageDNF.sh`: to be used under hosts with DNF package manager.
 
## HTTP-Front

Frontend based on HTTP Apache server.

Proxy definitions on `httpd/config/proxy.conf`.

## Trac

[Trac](https://trac.edgewall.org/) is a wiki and issue tracking system for software development projects.

This project enable the possibility to manage multiprojects.

All projects are under `/home/trac/repository`; each folder under this directory is considerated as a Trac project; and all of them are updated to the installed version of Trac.

Empty folders, are considerated as Trac project to create and they are created when the container starts.

All projects are setted to be authenticated with `TRAC_USER` and `TRAC_PASSWORD` (environment variables).

### Environment variables

 - `TRAC_USER`: user to trac projects.
 - `TRAC_PASSWORD`: password to trac projects.

### Pendings

 - Parametrize Trac config values. 
 - Add SVN and Git as repositories to Trac.
 - Email configuration on Trac.
 - Add scripts to backup/restore, export wiki content as PDF/HTML, and others.
 
## Tor

[Tor](www.torproject.org) is a piece of software that enable to us an anonymous communication.

This project enable the possibility to create a Tor service (.onion site).
To retrieve onion address: 
```bash
$ docker-compose exec tor-service /bin/bash -c 'cat ./hidden_service/hostname'
```  

### Arguments

- Tor service
  - `TOR_VERSION`: Tor version to use (default `0.3.3.9`).
  - `HIDDEN_SERVICE_PORT` Tor service port (default `80`).
  - `HIDDEN_SERVICE_VERSION`: Onion address version to be generated (default `3`).
  - `TOR_SITE_URI`: URI where Tor service content is located (default `tor-site:80`)
  
### Pendings

 - Improve security, isolation, anonymity, availability and limit available resources.
