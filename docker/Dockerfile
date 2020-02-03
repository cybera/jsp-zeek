FROM ubuntu:18.04
LABEL maintainer="security@cybera.ca"

LABEL build_date="2020-02-03"
ENV ZEEK_VERSION 3.0.1

WORKDIR /tmp

RUN apt update \
    && apt install -y \
     curl \
     net-tools \
     gnupg \
     build-essential \
     git \
     bison \
     flex \
     cmake \
     python3 \
     python3-dev \
     python3-pip \
     libssl-dev \
     zlib1g-dev \
     libmaxminddb-dev \
     geoip-database \
     swig \
     libpcap-dev \
     linux-headers-$(uname -r) \
    && curl -sL https://www.zeek.org/downloads/zeek-${ZEEK_VERSION}.tar.gz \
      | tar zxvf - \
    && pip3 --no-cache-dir install zkg \
    # Compile Zeek
    && cd zeek-${ZEEK_VERSION} \
    && ./configure --prefix=/opt/zeek \
    && make -j8 \
    && make install \
    # Cleanup
    && rm -rf /tmp/* \
    && rm -rf /var/lib/apt/lists/*

ENV PATH $PATH:/opt/zeek/bin

RUN zkg autoconfig \
    && zkg install --force \
       bro-af_packet-plugin \
       zeek-sniffpass \
       zeek-httpattacks

COPY files/etc/* /opt/zeek/etc/
COPY files/init.sh /init.sh
COPY files/local.zeek /opt/zeek/share/zeek/site/local.zeek

VOLUME /opt/zeek/logs
VOLUME /opt/zeek/spool


CMD ["/init.sh"]
