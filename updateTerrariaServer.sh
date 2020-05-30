#!/bin/bash


#########################################
# CONFIG
#########################################
# --------------------------------------
# Config you will certainly need to change/update
# --------------------------------------

# !! Keep this version number updated !!
VERSION=1404

# !! Keep this url updated !!
#TERRARIA_URL=''
TERRARIA_URL='https://www.terraria.org/system/dedicated_servers/archives/000/000/038/original/terraria-server-1404.zip'


# --------------------------------------
# Config you probably won't need to change
# --------------------------------------

TERRARIA_HOME='/wd/terraria'
TERRARIA_SRV=$TERRARIA_HOME/srv
TERRARIA_STAGE=$TERRARIA_HOME/staging

TERRARIA_LATEST=$TERRARIA_SRV/latest
TERRARIA_ARCHIVE=$TERRARIA_SRV/archive


# --------------------------------------
# Style
# --------------------------------------

RED='\033[0;31m'
GREEN='\033[0;32m'
LTCYAN='\033[1;36m'
NC='\033[0m' # No Color


#########################################
# ENVIRONMENT
#########################################
# --------------------------------------
# Check our HOME. Our work branches from here.
# --------------------------------------

if [[ ! -d $TERRARIA_HOME || ! -r $TERRARIA_HOME || ! -w $TERRARIA_HOME ]]
then
    echo -e "${RED}ERROR${NC}: Permissions (rw) or existance missing for {$TERRARIA_HOME}"
    exit 1
else
    cd $TERRARIA_HOME
fi


# --------------------------------------
# Check secondary directories for EXISTANCE.
#   CWD is assumed TERRARIA_HOME by now
#   RW permissions for TERRARIA_HOME assumed by now
# --------------------------------------

[[ ! -d $TERRARIA_SRV ]] && mkdir $TERRARIA_SRV
[[ ! -d $TERRARIA_STAGE ]] && mkdir $TERRARIA_STAGE
[[ ! -d $TERRARIA_LATEST ]] && mkdir $TERRARIA_LATEST
[[ ! -d $TERRARIA_ARCHIVE ]] && mkdir $TERRARIA_ARCHIVE


# --------------------------------------
# Check secondary directories for PERMISSION.
# --------------------------------------

if [[ ! -r $TERRARIA_SRV || ! -w $TERRARIA_SRV || ! -x $TERRARIA_SRV ]]
then
    echo -e "${RED}ERROR${NC}: Permissions (rwx) missing for {$TERRARIA_SRV}"
    exit 1
fi

if [[ ! -r $TERRARIA_STAGE || ! -w $TERRARIA_STAGE || ! -x $TERRARIA_STAGE ]]
then
    echo -e "${RED}ERROR${NC}: Permissions (rwx) missing for {$TERRARIA_STAGE}"
    exit 1
fi

if [[ ! -r $TERRARIA_LATEST || ! -w $TERRARIA_LATEST || ! -x $TERRARIA_LATEST ]]
then
    echo -e "${RED}ERROR${NC}: Permissions (rwx) missing for {$TERRARIA_LATEST}"
    exit 1
fi

if [[ ! -r $TERRARIA_ARCHIVE || ! -w $TERRARIA_ARCHIVE || ! -x $TERRARIA_ARCHIVE ]]
then
    echo -e "${RED}ERROR${NC}: Permissions (rwx) missing for {$TERRARIA_ARCHIVE}"
    exit 1
fi


#########################################
# STAGING
#########################################

# Clean the stage

echo -e "${LTCYAN}INFO${NC}: Removing any old files from the staging directory"
rm -r $TERRARIA_STAGE/*

# Get latest server from web source

echo -e "${LTCYAN}INFO${NC}: Extracting new server zip file from web"

# Web location subject to change w/o notice

wget $TERRARIA_URL --directory-prefix=$TERRARIA_STAGE

if [[ `ls $TERRARIA_STAGE | wc -l` != 1 ]]
then
    echo -e "${RED}ERROR${NC}: Exactly 1 file expected staged after pulling down new server and this is not the case"
    exit 1
fi

if [[ ! `unzip $TERRARIA_STAGE/terraria-server* -d $TERRARIA_STAGE` ]]
then
    echo -e "${RED}ERROR${NC}: Failed to unzip server"
    exit 1
fi

# Terraria server dir structure subject to change w/o notice

if [ -f $TERRARIA_STAGE/$VERSION/Linux/TerrariaServer.bin.x86_64 ]
then
    chmod +x $TERRARIA_STAGE/$VERSION/Linux/TerrariaServer.bin.x86_64
else
    echo -e "${RED}ERROR${NC}: Directory structure of Terraria package is unexpected"
    exit 1
fi

echo -e "${LTCYAN}INFO${NC}: Staging complete"
echo -e "${LTCYAN}INFO${NC}: Begin archive of previous server files"


#########################################
# ARCHIVING
#########################################

# If any previous existing files are found, create an archive of them.

TIMESTAMP=`date +%s`
TERRARIA_ARCHIVE_FILE=$TIMESTAMP.tar.gz

if [[ `ls $TERRARIA_LATEST | wc -l` -gt 0 ]]
then
    cp -r $TERRARIA_LATEST /tmp/$TIMESTAMP
    [[ `tar czf $TERRARIA_ARCHIVE/$TERRARIA_ARCHIVE_FILE /tmp/$TIMESTAMP` ]] && rm -r /tmp/$TIMESTAMP

    # Check that an archive file was made.

    if [[ -s $TERRARIA_ARCHIVE/$TERRARIA_ARCHIVE_FILE && -f $TERRARIA_ARCHIVE/$TERRARIA_ARCHIVE_FILE ]]
    then
        echo -e "${LTCYAN}INFO${NC}: Previous server directory archived."
        echo -e "`stat -c "%y    %n:    %s(bytes)" $TERRARIA_ARCHIVE/$TERRARIA_ARCHIVE_FILE`"
    else
        echo -e "${RED}ERROR${NC}: Archive file is empty or does not exist"
        exit 1
    fi
fi

# Archive rotation

if [[ `ls $TERRARIA_ARCHIVE | wc -l` -gt 2 ]]
then
    rm `ls -dt $TERRARIA_ARCHIVE/* | awk 'NR>2'`
fi

#########################################
# UPDATE
#########################################

echo -e "${LTCYAN}INFO${NC}: Hey User. Time to delete the old server files at $TERRARIA_LATEST and replace the contents of that directory with the new files in $TERRARIA_STAGE. If these server files are still executing we might see some funky behaivour."

echo -e "${LTCYAN}INFO${NC}: Please ensure files are not executing and we'll auto replace them right here and now."

read -p "Replace those file automatically [y/N]? " USER_INPUT
if [[ ! ${USER_INPUT:0:1} =~ ^[yY]$ ]]
then
    echo -e "Leaving it to you."
    echo -e "Have a great day!"
    exit 0
fi

# Permission to proceed has been granted.

echo -e "${LTCYAN}INFO${NC}: Removing all files inside $TERRARIA_LATEST"

# Delete any old files in TERRARIA_LATEST if there are any

if [[ `ls $TERRARIA_LATEST | wc -l` -gt 0 ]]
then
    rm -r $TERRARIA_LATEST/*

    if [[ `ls $TERRARIA_LATEST | wc -l` -gt 0 ]]
    then
        echo -e "${RED}ERROR${NC}: Failed to delete old files from $TERRARIA_LATEST."
    fi

fi

# Move our new staged files to their rightful place in TERRARIA_LATEST

mv $TERRARIA_STAGE/$VERSION/Linux/* $TERRARIA_LATEST

if [[ `ls $TERRARIA_STAGE/$VERSION/Linux/ | wc -l` != 0 || `ls $TERRARIA_LATEST | wc -l` == 0 ]]
then
    echo -e "${RED}ERROR${NC}: Migrating files from $TERRARIA_STAGE/$VERSION/Linux to $TERRARIA_LATEST failed."
    exit 1
fi

# Cleanup

echo -e "${LTCYAN}INFO${NC}: Removing old files from the staging directory"
rm -r $TERRARIA_STAGE/*
