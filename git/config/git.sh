#!/bin/bash
#
# Autor:
#   Maximiliano de Mattos (azamax@gmail.com)
#
# Description:
#   Script that runs as entry point for docker Git and provides basics tasks
#   to create and remove git repositories
#
# Preconditions:
#   The script assume that exists the following envars:
#       GIT_SERVER: server name for git
#       GIT_PORT: listening port
#       GIT_USER: git user
#       GIT_PASS: git password
#       GIT_NAME: git user name
#       GIT_EMAIL: git user email
#       
# Usage:
#   As entrypoint:
#       CMD ["/usr/local/bin/git.sh","entrypoint"]
#
#   To create a repository:       
#       $ sudo sh git.sh create <repository name>
#
#   To delete repository:       
#       $ sudo sh git.sh delete <repository name>
#
################################################################################

#set -e
nocolor='\e[0m'; red='\e[0;31m'; green='\e[0;32m'; bold='\e[1m'; cyan='\e[0;36m'; yellow='\e[0;33m'; blue='\e[0;34m'

HOME_GIT="/home/git"
CREDENTIAL_FILE="$HOME_GIT/.git.htpasswd"

entrypoint(){
    printf "$green Git entrypoint $nocolor\n"
    if [ ! -f $CREDENTIAL_FILE ]; then
        htpasswd -bc $CREDENTIAL_FILE $GIT_USER $GIT_PASS > /dev/null 2>&1
    fi

    git config --global user.name  $GIT_NAME
    git config --global user.email $GIT_EMAIL
    git config --global gitweb.owner $GIT_NAME

    sed -i "s/^\$projectroot = .*/\$projectroot = '\/home\/git';/g" /etc/gitweb.conf

    echo "\$feature{'blame'}{'default'} = [1];" >> /etc/gitweb.conf 
    echo "\$feature{'snapshot'}{'default'} = [];" >> /etc/gitweb.conf
    echo "\$feature{'grep'}{'default'} = [0];" >> /etc/gitweb.conf
    echo "\$feature{'highlight'}{'default'} = [1];" >>/etc/gitweb.conf;
    echo "\$git_temp = '/tmp';" >>/etc/gitweb.conf;
    echo "\$projects_list =  \$projectroot;" >>/etc/gitweb.conf;

    assignPermission $HOME_GIT

    exec /lib/systemd/systemd
}

assignPermission(){
    chown -R www-data:www-data $1
    chmod -R 775 $1
}

create_new_git_repo(){
    # $1= REPO_NAME
    printf "$green Creating $1 new git repository $nocolor\n"
    git init --bare --shared $1.git --quiet

    cd $1.git 
    mv hooks/post-update.sample hooks/post-update
    chmod +x $HOME_GIT/$1.git/hooks/post-update
    git update-server-info  

    assignPermission $HOME_GIT
}

populate_new_git_repo(){
    # $1= REPO_NAME
    printf "$green Populating $1 git repository $nocolor\n"

    mkdir -p $HOME_GIT/tmp
    cd $HOME_GIT/tmp
    git init  --quiet

    touch README.md 
    git add README.md
    git commit -m 'initial commit' 
    git remote add origin http://$GIT_USER:$GIT_PASS@$GIT_SERVER:$GIT_PORT/git/$1.git
    git push --set-upstream origin master --quiet
    cd $HOME_GIT
    rm -fr $HOME_GIT/tmp
}

delete_git_repo(){
    # $1= REPO_NAME
    rm -fr /home/git/$1.git
}

########
# MAIN #
########

case "$1" in
entrypoint)
    entrypoint
    ;;
create)
    create_new_git_repo $2
    populate_new_git_repo $2
    ;;
delete)
    delete_git_repo $2
    ;;
*)
    echo "Usage: git.sh { entrypoint | create <REPO_NAME> | delete <REPO_NAME> }"
    exit 1
    ;;
esac

exit 0
