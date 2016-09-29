FROM alpine:3.4

RUN set -ex && \
    # Ruby dependencies
    apk add --no-cache \
    autoconf \
    bison \
    bzip2 \
    bzip2-dev \
    ca-certificates \
    coreutils \
    curl \
    gcc \
    gdbm-dev \
    glib-dev \
    libc-dev \
    libffi-dev \
    libxml2-dev \
    libxslt-dev \
    linux-headers \
    make \
    ncurses-dev \
    openssl-dev \
    procps \
    readline-dev \
    yaml-dev \
    zlib-dev \
    # Added for convenience
    bash \
    # GEM dependencies
    freetds \
    freetds-dev \
    postgresql-client \
    postgresql-dev \
    libpq \
    g++ \
    libxml2-dev \
    libxml2-utils \
    libxslt-dev \
    unixodbc-dev \
    # For cas3-transformer ( Gemfile refer to remote git repos )
    git

# TODO: install phantomjs 1.8.2 and wkhtmltopdf >=0.12.2.1

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
    adduser -D -s /bin/bash app && \
    mkdir -p /usr/src && \
    curl -SL -o ruby.tar.gz "http://cache.ruby-lang.org/pub/ruby/$RUBY_MAJOR/ruby-$RUBY_VERSION.tar.gz" && \
    echo "$RUBY_DOWNLOAD_SHA256 ruby.tar.gz" | sha256sum -c - && \
    tar -xzf ruby.tar.gz -C /usr/src && \
    mv "/usr/src/ruby-$RUBY_VERSION" /usr/src/ruby && \
    rm -f ruby.tar.gz && \
    cd /usr/src/ruby && \
    sed -i '1i#include <asm/ioctl.h>' io.c && \
    # ^^ allow ruby 1.9.3 to compile with musl libc
    autoconf && \
    ./configure --disable-install-doc --sysconfdir=/etc/ && \
    make -j4 && \
    make install && \
    mkdir -p "$GEM_HOME" "$BUNDLE_BIN" && \
    echo 'gem: --no-rdoc --no-ri' >> /etc/gemrc && \
    gem update --system $RUBYGEMS_VERSION && \
    gem install bundler --version "$BUNDLER_VERSION" && \
    chown -R app: "$GEM_HOME" "$BUNDLE_BIN" && \
    rm -rf /usr/src/ruby && \
    mkdir -p /opt/app && \
    chown app: /opt/app

## Allow all users to use ping
#
RUN chmod +s /bin/ping

CMD [ "irb" ]
