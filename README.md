# docker
Docker images definitions.

## Base

Base image for other projects based on CentOS 7.

## i386 Base

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

 - TRAC_USER: user to trac projects.
 - TRAC_PASSWORD: password to trac projects.

## Pendings
 - Parametrize Trac config values 
 - Add SVN and Git as repositories
 - Email configuration
 - Add tools to backup trac, export wiki content as PDF, and others
