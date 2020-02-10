#!/bin/bash
set -ex

# Update /etc/hosts
sed -i "s/rsyslog-dest/${SYSLOG_HOST}/g" /etc/rsyslog.conf

# chown to syslog user
chown -R syslog:syslog /var/spool/rsyslog

rsyslogd -n
