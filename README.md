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
      bundler:1.12.5

  COPY Gemfile Gemfile
  COPY Gemfile.lock Gemfile.lock
  RUN bundle install

  COPY . /opt/app

  # Force user to overide CMD at run time
  CMD false
```

## Building, tagging, and pushing

Docker hub automatically builds new sets of the docker containers on every push to master. This is set up here: https://hub.docker.com/r/liaisonintl/ruby/~/settings/automated-builds/
When new Dockerfile(s) are added to this project we will need to update the automated build configurations through the website.

More information about the build process can be found here: https://docs.docker.com/docker-hub/builds/#create-an-automated-build

## Testing out a build locally.

A image can be run and tested out locally using the following commands:

```
$ docker build -t liaisonintl/ruby:debian-jessie-2.3.8 -f Dockerfile .
$ docker images | grep debian-jessie-2.3.8
liaisonintl/ruby    debian-jessie-2.3.8   3153c40c8a06        20 hours ago        986MB
$ docker run --name test-2.3.8 -it 3153c40c8a06 bash
root@6d0be9ab893f:/# ruby --version
ruby 2.3.8p459 (2018-10-18 revision 65136) [x86_64-linux]
```

NOTE:
This example shows someone building the container from the docker file, another option would be to `docker pull` the current tag in the repo.
