# Leveraging this image

## Dockerfile example

```
  FROM liaisonintl/ruby-1.9.3:jessie

  RUN echo 'gem: --no-rdoc --no-ri' >> /etc/gemrc

  RUN mkdir -p /opt/app && \
      chown app: /opt/app

  USER app
  WORKDIR /opt/app/
  ENV GEM_HOME=/home/app/bundle
  ENV BUNDLE_PATH=${GEM_HOME} \
      BUNDLE_APP_CONFIG=${GEM_HOME} \
      BUNDLE_BIN=${GEM_HOME}/bin \
      PATH=${GEM_HOME}/bin:${PATH}

  RUN gem install \
      bundler:1.12.5 \
      io-console:0.4.6

  COPY Gemfile Gemfile
  COPY Gemfile.lock Gemfile.lock
  RUN bundle install

  COPY . /opt/app

  # Force user to overide CMD at run time
  CMD false
  ```
