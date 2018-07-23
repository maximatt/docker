#!/bin/bash

set -e

HOME_TRAC="/home/trac"
TRAC_CREDENTIAL_FILE="$HOME_TRAC/trac.htpasswd"

nocolor='\e[0m'; red='\e[0;31m'; green='\e[0;32m'; bold='\e[1m'; cyan='\e[0;36m'; yellow='\e[0;33m'; blue='\e[0;34m'

createTracCredentials(){
    if [ -f $TRAC_CREDENTIAL_FILEFILE ]; then
        htpasswd -bc $TRAC_CREDENTIAL_FILE $TRAC_USER $TRAC_PASSWORD > /dev/null 2>&1
    fi
}

configPython(){
    mkdir -p $HOME_TRAC/.python-eggs
}

configHTTP(){
    sed -i 's/^Listen .*/Listen 5002/g' /etc/httpd/conf/httpd.conf
    chown -R apache:apache $HOME_TRAC
    chmod -R 775 $HOME_TRAC
    chcon -R -t httpd_sys_content_t $HOME_TRAC
    chcon -R -t httpd_sys_content_rw_t $HOME_TRAC
}

configTrac(){
    createTracCredentials
    setupTracProjects
}

updateProjectTrac(){
    # $1 = trac project name
    printf "$green Updating $1 trac project $nocolor\n"
    trac-admin $HOME_TRAC/repository/$1 upgrade > /dev/null 2>&1
    trac-admin $HOME_TRAC/repository/$1 wiki upgrade > /dev/null 2>&1
}

createProjectTrac(){
    # $1 = trac project name
    printf "$green Creating $1 trac project $nocolor\n"
    trac-admin $HOME_TRAC/repository/$1 initenv $1 sqlite:db/trac.db > /dev/null 2>&1

    # [attachment]
    sed -i "/^max_size/s/=.*/= 26214400/" $HOME_TRAC/repository/$1/conf/trac.ini

    # [components]
    if grep -q components "$HOME_TRAC/repository/$1/conf/trac.ini"; ##note the space after the string you are searching for
    then
        sed -i "/^\[components\]/a tracwysiwyg.* = enabled" $HOME_TRAC/repository/$1/conf/trac.ini
        sed -i "/^\[components\]/a tracrpc.* = enabled" $HOME_TRAC/repository/$1/conf/trac.ini
    else
        echo "[components]" >> $HOME_TRAC/repository/$1/conf/trac.ini
        echo "tracwysiwyg.* = enabled" >> $HOME_TRAC/repository/$1/conf/trac.ini
        echo "tracrpc.* = enabled" >> $HOME_TRAC/repository/$1/conf/trac.ini
    fi
}

grantAccessTrac(){
    # $1 = trac project name
	trac-admin $HOME_TRAC/repository/$1 permission add $TRAC_USER TRAC_ADMIN XML_RPC WIKI_ADMIN > /dev/null 2>&1
}

setupTracProjects(){
    cd $HOME_TRAC/repository/
    repositories=(`ls -d */ | sed 's|/$||g'`)

    for i in "${repositories[@]}"; do
	    if [ "$(ls -A $i)" ]; then
            updateProjectTrac $i
	    else
            createProjectTrac $i
	    fi
	    grantAccessTrac $i
    done
}

#########
## MAIN #
#########

configPython
configTrac
configHTTP

exec /usr/sbin/init
