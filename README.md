# docker
docker images definitions

## Base

Base image for other projects.

## HTTP-Front

Frontend for other projects based on HTTP Apache server.

Proxy definitions on `httpd/config/proxy.conf`.

## Trac

[Trac](https://trac.edgewall.org/) is a wiki and issue tracking system for software development projects.

This projetc enable the posibility to manage multiprojects.

All projects are under `/home/trac/repository`. Each folder under this directory is considerated as an Trac project.

A exisiting project is updated to the installed version of trac.

Empty folders, are considerated as Trac project to create ant they are created when the container stars.

All projects are setted to be authenticated with `TRAC_USER` and `TRAC_PASSWORD` (environment variables).

### Environment variables

 - TRAC_USER: user to trac projects.
 - TRAC_PASSWORD: password to trac projects.
