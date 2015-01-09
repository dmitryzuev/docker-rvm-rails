#
# RVM + Rails Dockerfile
#
# https://github.com/dmitryzuev/docker-rvm-rails
#

# Pull base image.
FROM ubuntu:14.04

# rvm, ruby and rails versions
#  RvmVersion=stable
#  RubyVersion=2.2.0
#  RailsVersion=4.2.0

# Initial configuration
RUN \
  apt-get update && \
  apt-get upgrade -y && \
  apt-get install curl -y


# Add user `rails`
RUN \
  adduser --gecos 'Rails app user' --disabled-password rails && \
  echo "rails ALL = NOPASSWD: /usr/bin/apt-get" >> /etc/sudoers

USER rails
WORKDIR /home/rails

# Install RVM
RUN /bin/bash -l -c "\
  gpg --homedir /home/rails/.gnupg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3 && \
  curl -sSL https://get.rvm.io | bash -s stable && \
  source /home/rails/.rvm/scripts/rvm && \
  rvm requirements "

# Install ruby and rails
RUN /bin/bash -l -c "\
  source /etc/profile && \
  echo 'gem: --no-ri --no-rdoc' >> /home/rails/.gemrc && \
  rvm install 2.2.0 && \
  gem install rails:4.2.0 "


# Install web server (unicorn)
RUN /bin/bash -l -c "\
  gem install therubyracer && \
  gem install unicorn "


# Create blank rails app
RUN /bin/bash -l -c "\
  rails new app "

WORKDIR /home/rails/app

# Add unicorn and rubyracer gems to Gemfile. I'm not sure, add them now or after VOLUME
RUN /bin/bash -l -c "\
  echo \"gem 'therubyracer'\" >> Gemfile && \
  echo \"gem 'unicorn'\" >> Gemfile && \
  bundle install "

# And I think about some unicorn configuration files, but later.

COPY config/unicorn.rb /home/rails/app/config/unicorn.rb

# forward request and error logs to docker log collector
USER root
RUN \
  ln -sf /dev/stdout /home/rails/app/log/unicorn-stdout.log && \
  ln -sf /dev/stderr /home/rails/app/log/unicorn-stderr.log
USER rails

# Define mountable directories
VOLUME ["/home/rails/app"]

# Expose ports
EXPOSE 8080

ENV SECRET_KEY_BASE=41c5c6f724c5d764b3439e4f59ae6530c2ce39e91c412370e8dc4ddfa4f763e8e966ea21cf437abfb32b31fad88a54df97978869174ee2d54f6e38c881cd10f5

CMD /bin/bash -c -l "SECRET_KEY_BASE=$SECRET_KEY_BASE unicorn_rails -c config/unicorn.rb -E production"
