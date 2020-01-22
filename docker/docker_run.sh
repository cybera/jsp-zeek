#!/bin/bash
set -ex
CONTAINER_NAME=zeek
INTERFACE=br0
docker rm -f ${CONTAINER_NAME} || true
docker run -d --restart unless-stopped -v zeek-logs:/opt/zeek/logs -v zeek-spool:/opt/zeek/spool --network host --name ${CONTAINER_NAME} -it zeek /init.sh ${INTERFACE}
