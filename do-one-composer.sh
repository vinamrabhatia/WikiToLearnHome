#!/bin/bash
# Install composer dependencies from composer.json in the $1 folder 

#check if $1 is null
if [ -z "$1" ]; then
  echo "do-one-composer Error: required parameter 'path of composer.json'" 
  exit 1
fi

echo "do-one-composer Composing '$1'"


#call ./load-wikitolearn.sh script: load environment variables from const and config file
. ./load-wikitolearn.sh

#check if auth.json is in the composer folder
if [[ ! -f "$WTL_DIR/configs/composer/auth.json" ]] ; then
  echo "do-one-composer Composer config missing, please run create-config.sh"
  exit 1
fi

mkdir -p $WTL_CACHE/composer

echo "do-one-composer USER_ID:$WTL_USER_UID USER_GID:$WTL_USER_GID"
docker run --rm -u $WTL_USER_UID:$WTL_USER_GID -v $1:/app -e COMPOSER_CACHE_DIR=/cache -e COMPOSER_HOME=/composer -v $WTL_CACHE/composer:/cache -v $WTL_CONFIGS_DIR/composer:/composer composer/composer install