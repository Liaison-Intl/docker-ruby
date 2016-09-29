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
    postgresql-client-9.5 \
    postgresql-common \
    libpq-dev \
    unixodbc-dev \
    freetds-dev \
    freetds-bin \
    libpcre3-dev \
    # Dependancy for wkhtmltopdf
    xfonts-75dpi \
    fontconfig \
    libfontenc1 \
    libxfont1 \
    libxrender1 \
    xfonts-base \
    xfonts-encodings \
    xfonts-utils \
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
    # Dependancy for phantomjs
    flex \
    gperf \
    perl \
    libfontconfig1-dev \
    libicu-dev \
    libfreetype6 \
    libpng-dev \
    libjpeg-dev \
    # For common app ( with Gemfile refering to git repos )
    git && \
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

## Install wkhtmltox ( SECURITY: select latest stable from http://wkhtmltopdf.org/downloads.html )
#
RUN curl -SL -o wkhtmltox.deb http://download.gna.org/wkhtmltopdf/0.12/0.12.2.1/wkhtmltox-0.12.2.1_linux-jessie-amd64.deb && \
    dpkg -i wkhtmltox.deb && \
    rm wkhtmltox.deb

# Install phantomjs 1.8.2
#
RUN curl -SL -o /usr/bin/phantomjs https://www.dropbox.com/s/b7mgkdgsygjweux/phantomjs-1.8.2?dl=1 && \
    chmod +x /usr/bin/phantomjs

## Install ruby
#
ENV RUBY_MAJOR=1.9 \
    RUBY_VERSION=1.9.3-p551 \
    RUBY_DOWNLOAD_SHA256=bb5be55cd1f49c95bb05b6f587701376b53d310eb1bb7c76fbd445a1c75b51e8 \
    RUBYGEMS_VERSION=2.6.6 \
    BUNDLER_VERSION=1.12.5 \
    GEM_HOME=/usr/local/bundle \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_APP_CONFIG=/usr/local/bundle \
    BUNDLE_BIN=/usr/local/bundle/bin \
    BUNDLE_SILENCE_ROOT_WARNING=1 \
    PATH=/usr/local/bundle/bin:$PATH
RUN set -ex && \
    useradd -m -s /bin/bash app && \
    mkdir -p /usr/src/ruby && \
    curl -SL -o ruby.tar.gz "http://cache.ruby-lang.org/pub/ruby/$RUBY_MAJOR/ruby-$RUBY_VERSION.tar.gz" && \
    echo "$RUBY_DOWNLOAD_SHA256 ruby.tar.gz" | sha256sum -c - && \
    tar -xzf ruby.tar.gz -C /usr/src/ruby --strip-components=1 && \
    rm -f ruby.tar.gz && \
    cd /usr/src/ruby && \
    autoconf && \
    ./configure --disable-install-doc --sysconfdir=/etc/ && \
    make && \
    make install && \
    mkdir -p "$GEM_HOME" "$BUNDLE_BIN" && \
    chmod 777 "$GEM_HOME" "$BUNDLE_BIN" && \
    echo 'gem: --no-rdoc --no-ri' >> /etc/gemrc && \
    gem update --system $RUBYGEMS_VERSION && \
    gem install bundler --version "$BUNDLER_VERSION" && \
    chown -R app: $GEM_HOME && \
    mkdir /opt/app && \
    chown app: /opt/app && \
    rm -rf /usr/src/ruby

## Allow all user to use ping
#
RUN chmod +s /bin/ping

## Mitigate CVE-2016–3714
##
COPY  policy.yml /etc/ImageMagick-6/

## Force user to redefine CMD
#
CMD false
