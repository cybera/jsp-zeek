FROM ubuntu:18.04
LABEL maintainer="security@cybera.ca"

LABEL build_date="2020-02-10"

RUN apt update \
    && apt install -y software-properties-common \
    && add-apt-repository ppa:adiscon/v8-stable \
    && apt update \
    && apt install -y \
     rsyslog \
    # Cleanup
    && apt remove -y software-properties-common \
    && apt autoremove -y \
    && rm -rf /tmp/* \
    && rm -rf /var/lib/apt/lists/*

COPY rsyslog.conf /etc/rsyslog.conf
COPY init.sh /init.sh

VOLUME /var/spool/rsyslog

CMD ["/init.sh"]
