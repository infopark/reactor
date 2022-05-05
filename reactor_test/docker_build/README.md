### Fiona7 Dockerfile

This repository contains **Dockerfile** of [Fiona7](https://kb.infopark.com/infopark-cms-fiona-0b333744b53e505f) for [Docker](https://www.docker.com/)'s.

### Installation

1. Install [Docker](https://www.docker.com/).

2. Download [Fiona7](https://kb.justrelate.com/cms-fiona-702-downloads-63cf9f3741c8e4b4) and place unzipped file into this directory. (/reactor_test/docker_build)

3. Put your license file into this directory under name `infopark-internal-restricted-license-fiona7.xml`

### Usage

Run to build the image

    docker build -t fiona7_reactor_test .

IF necessary (i.e. expired license-key or new Fiona-Version) push build to aws

    docker image tag fiona7_reactor_test 721039963787.dkr.ecr.eu-central-1.amazonaws.com/mpg-reactor-test
    docker push 721039963787.dkr.ecr.eu-central-1.amazonaws.com/mpg-reactor-test

For starting CM

    docker-compose up

### First run

First start of docker containers will fail coused by mysql container.

Wait until mysql container is up and stop [Ctrl-C] docker-compose execution.

Start docker compose one more time.

  docker-compose up

Now you DB-Server and CMS should be up and running.

### Run reactor tests

In directory `~/reactor_test` run `bundle exec rake db:create` to create database
for user generated content.

For tests run `bundle exec rake spec`
