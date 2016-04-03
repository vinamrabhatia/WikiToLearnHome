#!/bin/bash
#WIP
[[  "$WTL_SCRIPT_DEBUG" == "1" ]] && set -x
set -e
if [[ $(basename $0) != "fix-hosts.sh" ]] ; then
    echo "Wrong way to execute fix-hosts.sh"
    exit 1
fi
cd $(dirname $(realpath $0))"/.."
if [[ ! -f "const.sh" ]] ; then
    echo "Error changing directory"
    exit 1
fi

. ./load-libs.sh
. $WTL_SCRIPTS/environments/${WTL_ENV}.sh


WEBSRV_IP=$(docker inspect -f "{{ .NetworkSettings.IPAddress }}" ${WTL_INSTANCE_NAME}-websrv)
PARSOID_IP=$(docker inspect -f "{{ .NetworkSettings.IPAddress }}" ${WTL_INSTANCE_NAME}-parsoid)

web_hosts=($(for subdom in $(cat $WTL_REPO_DIR/databases.conf | sed 's/wikitolearn//g' | grep -v shared); do
  echo "${subdom}.$WTL_DOMAIN_NAME "
done))

for d in ${WTL_INSTANCE_NAME}-{parsoid,ocg,restbase} ; do
    docker inspect $d &> /dev/null && {
        echo "In '$d' fixing '${web_hosts[@]}' to '$WEBSRV_IP'"
        {
            docker exec $d sed '/FIXHOSTWEBSRV/d' /etc/hosts | docker exec -i $d tee /tmp/tmp_hosts
            docker exec $d cat /tmp/tmp_hosts | docker exec -i $d tee /etc/hosts
            echo $WEBSRV_IP" FIXHOSTWEBSRV ${web_hosts[@]}" | docker exec -i $d tee -a /etc/hosts
        } &> /dev/null
        echo "In '$d' fixing 'parsoid.$WTL_DOMAIN_NAME' to '$PARSOID_IP'"
        {
            docker exec $d sed '/FIXHOSTPARSOID/d' /etc/hosts | docker exec -i $d tee /tmp/tmp_hosts
            docker exec $d cat /tmp/tmp_hosts | docker exec -i $d tee /etc/hosts
            echo $PARSOID_IP" FIXHOSTPARSOID parsoid.$WTL_DOMAIN_NAME" | docker exec -i $d tee -a /etc/hosts
        } &> /dev/null
    }
done
