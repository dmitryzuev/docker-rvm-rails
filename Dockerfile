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

# Define mountable directories
VOLUME ["/home/rails/app"]


# Expose ports
EXPOSE 8080


CMD /bin/bash -c -l unicorn_rails
