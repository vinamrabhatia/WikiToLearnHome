#!/bin/bash

docker start ${WTL_INSTANCE_NAME}-websrv
if [[ $? -ne 0 ]] ; then
    echo "[start/single-node] FATAL ERROR: MISSING WEBSRV"
    exit 1
fi

if [[ ! -f $WTL_CONFIGS_DIR/LocalSettings.d/wgSecretKey.php ]] ; then
    echo "[start/single-node] Creating new '$WTL_CONFIGS_DIR/LocalSettings.d/wgSecretKey.php' file"
    WG_SECRET_KEY=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 64 | head -n 1)
    {
        echo "<?php"
        echo "\$wgSecretKey = '$WG_SECRET_KEY';"
    } > $WTL_CONFIGS_DIR/LocalSettings.d/wgSecretKey.php
else
    echo "[start/single-node] Using the existent '$WTL_CONFIGS_DIR/LocalSettings.d/wgSecretKey.php' file"
fi

rsync -av --delete --exclude .placeholder $WTL_CONFIGS_DIR/LocalSettings.d/ $WTL_WORKING_DIR/LocalSettings.d/

if [[ "$WTL_MAIL_RELAY_HOST" != "" ]] ; then
    echo "[start/single-node] Setup the relay host to "${WTL_MAIL_RELAY_HOST}
    {
        docker exec ${WTL_INSTANCE_NAME}-websrv sed '/^mailhub/d' /etc/ssmtp/ssmtp.conf
        echo "mailhub=${WTL_MAIL_RELAY_HOST}" | docker exec -i ${WTL_INSTANCE_NAME}-websrv tee -a /etc/ssmtp/ssmtp.conf
    } &> /dev/null

    if [[ "$WTL_MAIL_RELAY_USERNAME" != "" ]] ; then
        {
            docker exec ${WTL_INSTANCE_NAME}-websrv sed '/^AuthUser/d' /etc/ssmtp/ssmtp.conf
            echo "AuthUser=${WTL_MAIL_RELAY_USERNAME}" | docker exec -i ${WTL_INSTANCE_NAME}-websrv tee -a /etc/ssmtp/ssmtp.conf
        } &> /dev/null
    fi
    if [[ "$WTL_MAIL_RELAY_PASSWORD" != "" ]] ; then
        {
            docker exec ${WTL_INSTANCE_NAME}-websrv sed '/^AuthPass/d' /etc/ssmtp/ssmtp.conf
            echo "AuthPass=${WTL_MAIL_RELAY_PASSWORD}" | docker exec -i ${WTL_INSTANCE_NAME}-websrv tee -a /etc/ssmtp/ssmtp.conf
        } &> /dev/null
    fi
fi

docker exec -ti ${WTL_INSTANCE_NAME}-websrv su -s /var/www/WikiToLearn/fix-symlinks.sh www-data
docker exec -ti ${WTL_INSTANCE_NAME}-websrv su -s /var/www/WikiToLearn/fix-configs.sh www-data

