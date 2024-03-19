#!/bin/bash

set -e
nocolor='\e[0m'; red='\e[0;31m'; green='\e[0;32m'; bold='\e[1m'; cyan='\e[0;36m'; yellow='\e[0;33m'; blue='\e[0;34m'

HOME_TRAC="/home/trac"
TRAC_CREDENTIAL_FILE="$HOME_TRAC/.trac.htpasswd"

createTracCredentials(){
    if [ ! -f $TRAC_CREDENTIAL_FILE ]; then
        htpasswd -bc $TRAC_CREDENTIAL_FILE $TRAC_USER $TRAC_PASS > /dev/null 2>&1
    fi
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
}

configureProjectTrac(){
    printf "$green Configuring $1 trac project $nocolor\n"
    
    # [header_logo]
    cp /home/trac/space_invaders.png $HOME_TRAC/repository/$1/htdocs
    sed -i "/^alt /s/=.*/= maximatt/" $HOME_TRAC/repository/$1/conf/trac.ini
    sed -i "/^src /s/=.*/= site\/space_invaders.png/" $HOME_TRAC/repository/$1/conf/trac.ini
    sed -i "/^height /s/=.*/= 50/" $HOME_TRAC/repository/$1/conf/trac.ini
    sed -i "/^width /s/=.*/= 50/" $HOME_TRAC/repository/$1/conf/trac.ini
    
    # [attachment]
    sed -i "/^max_size/s/=.*/= 26214400/" $HOME_TRAC/repository/$1/conf/trac.ini
    
    # [components]
    trac-admin $HOME_TRAC/repository/$1 config set components tracrpc.* enabled
    trac-admin $HOME_TRAC/repository/$1 config set components wikiprint.* enabled
    trac-admin $HOME_TRAC/repository/$1 config set components tracpdf.admin.* enabled
    trac-admin $HOME_TRAC/repository/$1 config set components tracpdf.pdfbook.* enabled
    trac-admin $HOME_TRAC/repository/$1 config set components tracpdf.wikiprint.* enabled
    trac-admin $HOME_TRAC/repository/$1 config set components tracwysiwyg.* enabled
}

grantAccessTrac(){
    # $1 = trac project name
    printf "$green Grant Access $1 trac project $nocolor\n"
    trac-admin $HOME_TRAC/repository/$1 permission add $TRAC_USER TRAC_ADMIN XML_RPC WIKI_ADMIN > /dev/null 2>&1
}

setupTracProject(){
    createProjectTrac $1
    configureProjectTrac $1
    grantAccessTrac $1
    chown -R www-data:www-data $HOME_TRAC/repository/$1
}

entrypoint(){
    printf "$green Configuring trac $nocolor\n"   
    createTracCredentials
    exec /lib/systemd/systemd
}

########
# MAIN #
########

case "$1" in
entrypoint)
    entrypoint
    ;;
setup_project)
    setupTracProject $2
    ;;
*)
    echo "Usage: trac.sh { entrypoint | setup_projects <TRAC_PROJECT_NAME>}"
    exit 1
    ;;
esac

exit 0
