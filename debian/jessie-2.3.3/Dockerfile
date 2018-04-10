FROM debian:jessie

ENV DEBIAN_FRONTEND noninteractive

## Add official postgres apt repos key
#
COPY postgres_apt.gpg /opt/
RUN cat /opt/postgres_apt.gpg | apt-key add - && \
    rm -f /opt/postgres_apt.gpg

## Install base package
#
COPY sources.list /etc/apt/sources.list
COPY apt.conf /etc/apt/apt.conf.d/70debconf
RUN mkdir -p /var/cache/apt/archives && \
    apt-get clean && apt-get update && apt-get install -y \
    # For ruby compile
    debian-keyring \
    sharutils \
    locales \
    zlib1g-dev \
    ca-certificates \
    gzip \
    unzip \
    curl \
    wget \
    openssl \
    patch \
    g++ \
    gcc \
    make \
    libc6-dev \
    patch \
    libreadline6-dev \
    zlib1g-dev \
    libssl-dev \
    libyaml-dev \
    autoconf \
    libncurses5-dev \
    automake \
    bison \
    libffi-dev \
    postgresql-client-9.6 \
    postgresql-common \
    libpq-dev \
    unixodbc-dev \
    freetds-dev \
    freetds-bin \
    libpcre3-dev \
    # For minimum debug purpose
    gdb \
    telnet \
    redis-tools \
    dnsutils \
    net-tools \
    netcat-openbsd \
    less \
    htop \
    strace \
    tmux \
    # Dependancy for wkhtmltopdf
    xz-utils \
    xfonts-75dpi \
    fontconfig \
    libfontenc1 \
    libxfont1 \
    libxrender1 \
    xfonts-base \
    xfonts-encodings \
    xfonts-utils \
    # Dependancy for phantomjs
    bzip2 \
    flex \
    gperf \
    perl \
    libfontconfig1-dev \
    libicu-dev \
    libfreetype6 \
    libpng-dev \
    libjpeg-dev \
    # For common ruby app
    libtcmalloc-minimal4 \
    imagemagick \
    libmagick++-dev \
    libtool \
    libjpeg-dev \
    libpng12-dev \
    libpng++-dev \
    libpng3 \
    libfreetype6-dev \
    cron \
    vim \
    ssh \
    # For common app ( with Gemfile refering to git repos )
    git && \
    # Tidy up and reduce space
    apt-get clean && \
    rm -rf /usr/share/doc && \
    rm -rf /usr/share/man && \
    rm -rf /var/log/*

## Install dumb-init
#
RUN wget -O /bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64
RUN chmod +x /bin/dumb-init

## Install tini
#
ENV TINI_VERSION v0.15.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini.asc /tini.asc
RUN chmod +x /tini

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

## Install wkhtmltox ( SECURITY: select latest stable from http://wkhtmltopdf.org/downloads.html )
#
RUN curl -sSL https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.4/wkhtmltox-0.12.4_linux-generic-amd64.tar.xz \
      | tar -C /usr/ --strip-components=1 -xJf -

# Install phantomjs ( SECURITY: select latest 1.9.x from https://bitbucket.org/ariya/phantomjs/downloads )
#
RUN curl -sSL https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-1.9.8-linux-x86_64.tar.bz2 \
      | tar -C /usr/bin/ --strip-component=2 -xjf - phantomjs-1.9.8-linux-x86_64/bin/phantomjs

## Install ruby
#
ENV RUBY_MAJOR=2.3 \
    RUBY_VERSION=2.3.3 \
    RUBY_DOWNLOAD_SHA256=241408c8c555b258846368830a06146e4849a1d58dcaf6b14a3b6a73058115b7 \
    RUBYGEMS_VERSION=2.6.6 \
    PATH=/usr/local/bundle/bin:$PATH
RUN set -ex && \
    useradd -m -s /bin/bash app && \
    curl -SL -o ruby.tar.gz "http://cache.ruby-lang.org/pub/ruby/$RUBY_MAJOR/ruby-$RUBY_VERSION.tar.gz" && \
    echo "$RUBY_DOWNLOAD_SHA256 ruby.tar.gz" | sha256sum -c - && \
    mkdir -p /usr/src/ruby && \
    tar -xzf ruby.tar.gz -C /usr/src/ruby --strip-components=1 && \
    rm -f ruby.tar.gz && \
    cd /usr/src/ruby && \
    autoconf && \
    ./configure --disable-install-doc --sysconfdir=/etc/ && \
    make && \
    make install && \
    gem update --system $RUBYGEMS_VERSION && \
    rm -rf /usr/src/ruby

## Allow all user to use ping
#
RUN chmod +s /bin/ping

## Mitigate CVE-2016–3714
##
COPY  policy.yml /etc/ImageMagick-6/

## Simplify sourcing of config-map ENV from Kubernetes ( prior to 1.6 )
#
RUN mkdir /etc/bashrc.d && \
    echo '[[ -d /etc/bashrc.d ]] && for i in $(find /etc/bashrc.d/ -type f | sort -n) ; do . $i ; done' \
    >> /etc/profile && \
    echo '[[ -d /etc/bashrc.d ]] && for i in $(find /etc/bashrc.d/ -type f | sort -n) ; do . $i ; done' \
    >> /etc/bash.bashrc
RUN echo 'export PATH=/home/app/bundle/bin:/usr/local/bundle/bin:$PATH' \
      >> /etc/bashrc.d/0-env

## Forcing terminal to xterm ( fix issue with kubectl exec )
#
RUN echo "export TERM=xterm" >> /etc/bash.bashrc && \
    echo "alias tmux='script /dev/null -qc tmux'" >> /etc/bash.bashrc

## Save a few line of history from ruby console to improve the developer experience
#
RUN echo "IRB.conf[:SAVE_HISTORY] = 200" >> /home/app/.irbrc && \
    echo "IRB.conf[:HISTORY_FILE] = '~/.irb-history'" >> /home/app/.irbrc && \
    chown app:app /home/app/.irbrc

## Force user to redefine CMD
#
CMD false
