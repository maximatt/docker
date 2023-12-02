#!/bin/bash
#
# Autor:
#   Maximiliano de Mattos (azamax@gmail.com)
#
# Description:
#   Script that runs as entry point for docker Trac. 
#   Create new Trac projects on empty directories at /home/trac
#   Update Trac projects on non empty directories at /home/trac
#

set -e
nocolor='\e[0m'; red='\e[0;31m'; green='\e[0;32m'; bold='\e[1m'; cyan='\e[0;36m'; yellow='\e[0;33m'; blue='\e[0;34m'

HOME_TRAC="/home/trac"
TRAC_CREDENTIAL_FILE="$HOME_TRAC/.trac.htpasswd"

createTracCredentials(){
    if [ ! -f $TRAC_CREDENTIAL_FILE ]; then
        htpasswd -bc $TRAC_CREDENTIAL_FILE $TRAC_USER $TRAC_PASS > /dev/null 2>&1
    fi
}

configTrac(){
    printf "$green Configuring trac $nocolor\n"   
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
	configureProjectTrac $i
    done
}

#########
## MAIN #
#########

configTrac

exec /lib/systemd/systemd
