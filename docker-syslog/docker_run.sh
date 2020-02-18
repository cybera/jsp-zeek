#!/bin/bash
set -ex
CONTAINER_NAME=rsyslog-shipper
IMAGE_NAME=rsyslog-shipper
SYSLOG_HOST=${1}

if [ -z "${SYSLOG_HOST}" ]
then
  echo "Please specify a syslog host"
  exit 1
fi

docker rm -f ${CONTAINER_NAME} || true
docker run -d --restart unless-stopped --cpuset-cpus=0 --env SYSLOG_HOST=${SYSLOG_HOST} -v rsyslog-spool:/var/spool/rsyslog -v zeek-spool:/opt/zeek/spool:ro --name ${CONTAINER_NAME} -it ${IMAGE_NAME}
