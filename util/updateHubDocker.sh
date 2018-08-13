#!/bin/bash
#
# Autor:
#   Maximiliano de Mattos (azamax@gmail.com)
#
# Description:
#   Script to update images at hub.docker
#
# Usage:
#   updateHubDocker.sh { update | add <NEW_IMAGE> }"
#
################################################################################
tabs 4
set -e
nocolor='\e[0m'; cyan='\e[0;36m'

HUB_DOCKER_USER="maximatt"
HUB_IMAGES=(`docker search $HUB_DOCKER_USER | grep $HUB_DOCKER_USER | cut -d' ' -f1`)
HUB_IMAGES_REV=(`tac -s" " <<< "${HUB_IMAGES[@]} "`)

declare -A DOCKER_FILES=(
    [default]="../docker-compose-dev.yml"
    [tor-service]="../tor/docker-compose-dev.yml"
)

deleteLocally(){
    # $1: hub_image
    image_id=$(docker images | grep $1 | awk "{print \$3}")
    if [ ! -z "$image_id" ]; then
        printf "$cyan image deleted locally $nocolor\n"
        docker rmi -f $image_id
    fi
}

pullImage(){
    # $1: hub_image
    # $2: tag
    image_id=$(docker images | grep $1 | awk "{print \$3}")
    if [ -z "$image_id" ]; then
        printf "$cyan \tpull image $nocolor\n"
        docker pull $1:$2
    fi
}

buildImage(){
    # $1: hub_image
    image=${hub_image/maximatt\//}
    if [ -z "${image##*tor-service*}" ]; then
        docker_compose_file=${DOCKER_FILES[$image]}
    else
        docker_compose_file=${DOCKER_FILES['default']}
    fi
    
    printf "$cyan building $image $nocolor\n"
    docker-compose -f $docker_compose_file build $image
}

pushImage(){
    # $1: image
    # $2: tag
    image=${1/maximatt\//}
    printf "$cyan push $image:latest -> $HUB_DOCKER_USER/$image:$2 $nocolor\n"
    docker tag $image:latest $HUB_DOCKER_USER/$image:$2
    docker push $HUB_DOCKER_USER/$image:$2
}

update(){
    for hub_image in "${HUB_IMAGES_REV[@]}"; do
        deleteLocally $hub_image
    done

    for hub_image in "${HUB_IMAGES[@]}"; do
        if [ -z "${hub_image##*centos7_i386*}" ]; then
            continue # centos7_i386 is built from scratch
        fi
        buildImage $hub_image
        pushImage $hub_image "1.0"
        pushImage $hub_image "latest"
        docker rmi "$hub_image:1.0"
        docker rmi "${hub_image/maximatt\//}:latest"
    done
}

add(){
    # $1: new_image
    docker-compose -f ${DOCKER_FILES['default']} build $1
    pushImage $1 "1.0"
    pushImage $1 "latest"
    docker rmi "$HUB_DOCKER_USER/$1:1.0"
    docker rmi "$1:latest"
}

########
# MAIN #
########

case "$1" in
update)
    update
    ;;
add)
    add $2
    ;;
*)
    echo "Usage: updateHubDocker.sh { update | add <IMAGE_NAME> }"
    exit 1
    ;;
esac

exit 0
