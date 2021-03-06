#!/bin/bash
#Set the global ENV variables

#cd to current script folder
if [[ ! -f "const.sh" ]] ; then
    echo "[const] : The parent script is not running inside the directory that contains const.sh"
    echo -e "\e[31mFATAL ERROR \e[0m"
    exit 1
fi

#define environment variables
export WTL_DIR=$(pwd)
export WTL_REPO_DIR=$WTL_DIR"/WikiToLearn"
export WTL_CONFIGS_DIR=$WTL_DIR'/configs/'
export WTL_RUNNING=$WTL_DIR"/running/"
export WTL_CERTS=$WTL_DIR"/certs/"
export WTL_CACHE=$WTL_DIR"/cache/"
export WTL_LOCK_FILE=$WTL_CACHE"/wtlhome-lock"
export WTL_BACKUPS=$WTL_DIR"/backups/"
export WTL_MW_DUMPS=$WTL_DIR"/mw-dumps/"
export WTL_MW_DUMPS_DOWNLOAD=$WTL_DIR"/mw-dumps-download/"
export WTL_SCRIPTS=$WTL_DIR"/scripts/"
export WTL_TRUSTED_KEYS_REPO=$WTL_CONFIGS_DIR"/trusted_keys/"

export WTL_HOOKS=$WTL_DIR"/hooks/"

export WTL_CONFIG_FILE=$WTL_CONFIGS_DIR"wtl.conf"
