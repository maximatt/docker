#!/bin/bash
#
# Autor:
#   Maximiliano de Mattos (azamax@gmail.com)
#
# Description:
#   Script that runs as entry point for docker Git and provides basics tasks
#   to create and remove svn repositories
#
# Preconditions:
#   The script assume that exists the following envars:
#       SVN_SERVER: server name for svn
#       SVN_PORT: listening port
#       SVN_USER: svn user
#       SVN_PASS: svn password
#       
# Usage:
#   svn.sh { entrypoint | create <REPO_NAME> | delete <REPO_NAME> }"
#
################################################################################

#set -e
nocolor='\e[0m'; red='\e[0;31m'; green='\e[0;32m'; bold='\e[1m'; cyan='\e[0;36m'; yellow='\e[0;33m'; blue='\e[0;34m'

HOME_SVN="/home/svn"
CREDENTIAL_FILE="$HOME_SVN/.svn.htpasswd"

entrypoint(){
    if [ ! -f $CREDENTIAL_FILE ]; then
        htpasswd -bc $CREDENTIAL_FILE $SVN_USER $SVN_PASS > /dev/null 2>&1
    fi

    sed -i 's/^Listen .*/Listen '"${SVN_PORT}"'/g' /etc/httpd/conf/httpd.conf; \
    assignPermission $HOME_SVN
    
    exec /usr/sbin/init
}

assignPermission(){
    chown -R apache:apache $1
    chmod -R 775 $1
    chcon -R -t httpd_sys_content_t $1
    chcon -R -t httpd_sys_content_rw_t $1
}

create_new_svn_repo(){
    # $1= REPO_NAME
    printf "$green Creating $1 new svn repository $nocolor\n"
    cd $HOME_SVN
    svnadmin create $1 
    echo "#! /bin/sh" >$1/hooks/pre-revprop-change; 
    chmod +x $1/hooks/pre-revprop-change
    assignPermission $HOME_SVN
}

populate_new_svn_repo(){
    # $1= REPO_NAME
    printf "$green Populating $1 svn repository $nocolor\n"
    
    mkdir -p $HOME_SVN/tmp
    cd $HOME_SVN/tmp
    svn co http://$SVN_SERVER:$SVN_PORT/svn/$1 $1 --username $SVN_USER --password $SVN_PASS --no-auth-cache
    cd $1
    touch README.md
    svn add README.md
    svn commit -m 'initial commit' --username $SVN_USER --password $SVN_PASS --no-auth-cache
    
    cd $HOME_SVN
    rm -fr $HOME_SVN/tmp
}

delete_svn_repo(){
    # $1= REPO_NAME
    rm -fr /home/svn/$1.svn
}

########
# MAIN #
########

case "$1" in
entrypoint)
    entrypoint
    ;;
create)
    create_new_svn_repo $2
    populate_new_svn_repo $2
    ;;
delete)
    delete_svn_repo $2
    ;;
*)
    echo "Usage: svn.sh { entrypoint | create <REPO_NAME> | delete <REPO_NAME> }"
    exit 1
    ;;
esac

exit 0
