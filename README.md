## RVM and Ruby on Rails Dockerfile


This repository contains **Dockerfile** of [RVM](http://rvm.io/) with [Ruby on Rails](http://rubyonrails.org/) for [Docker](https://www.docker.com/)'s [automated build](https://registry.hub.docker.com/u/dmitryzuev/rvm-rails/) published to the public [Docker Hub Registry](https://registry.hub.docker.com/).


### Base Docker Image

* [ubuntu:14.04](https://registry.hub.docker.com/u/library/ubuntu/)


### Installation

1. Install [Docker](https://www.docker.com/).

2. Download [automated build](https://registry.hub.docker.com/u/dmitryzuev/rvm-rails/) from public [Docker Hub Registry](https://registry.hub.docker.com/): `docker pull dmitryzuev/rvm-rails`

   (alternatively, you can build an image from Dockerfile: `docker build -t="dmitryzuev/rvm-rails" github.com/dmitryzuev/docker-rvm-rails`)


### Usage

    docker run -d -p 8080:8080 dmitryzuev/rvm-rails

#### Attach persistent/shared directories

    docker run -d -p 8080:8080 -v <app-dir>:/home/rails/app dmitryzuev/rvm-rails

After few seconds, open `http://<host>:8080` to see the welcome page.
