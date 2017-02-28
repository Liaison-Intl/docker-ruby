FROM debian:jessie

ENV DEBIAN_FRONTEND noninteractive

## Add official gcloud apt repos key
#
COPY gcloud_apt.gpg /opt/
RUN cat /opt/gcloud_apt.gpg | apt-key add - && \
    rm -f /opt/postgres_apt.gpg

## Install base package
#
COPY sources.list /etc/apt/sources.list
COPY apt.conf /etc/apt/apt.conf.d/70debconf
RUN apt-get clean && apt-get update && apt-get install -y \
    # For ruby compile
    debian-keyring \
    sharutils \
    locales \
    zlib1g-dev \
    ca-certificates \
    gzip \
    unzip \
    curl \
    openssl \
    # For minimum debug purpose
    telnet \
    redis-tools \
    dnsutils \
    net-tools \
    netcat-openbsd \
    less \
    htop \
    # For GCE and GKE access
    google-cloud-sdk \
    kubectl && \
    # Install haproxy from backports
    apt-get install -t jessie-backports -y haproxy && \
    # Tidy up and reduce space
    apt-get clean && \
    rm -rf /usr/share/doc && \
    rm -rf /usr/share/man && \
    rm -rf /var/log/*

## Set LOCALE to UTF8
#
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen en_US.UTF-8 && \
    dpkg-reconfigure locales && \
    /usr/sbin/update-locale LANG=en_US.UTF-8
ENV LC_ALL en_US.UTF-8

## Set timezone
#
RUN echo "America/New_York" > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata

## Allow all user to use ping
#
RUN chmod +s /bin/ping

## Install confd
#
RUN curl -sSL https://github.com/kelseyhightower/confd/releases/download/v0.11.0/confd-0.11.0-linux-amd64 > /usr/bin/confd && \
    chmod +X /usr/bin/confd

## Force user to redefine CMD
#
CMD false
