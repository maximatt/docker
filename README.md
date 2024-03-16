# Docker
Docker definitions for some projects to learn and research.

## Base

Base image for other projects based on Debian 10.

```bash
docker build --rm -t debian10:1.0 -f $(pwd -P)/Dockerfile .
```

## Base i386

Build a docker base image from scratch (based on Debian 10 i386)

```bash
$ sh mkImage.sh
$ docker build --rm -t i386/debian10 -f $(pwd -P)/Dockerfile .
$ docker run --name debian10_i386  --rm -ti  -v /tmp -v /run i386/debian10
```
