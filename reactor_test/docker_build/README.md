### Fiona7 Dockerfile

This repository contains **Dockerfile** of [Fiona7](https://kb.infopark.com/infopark-cms-fiona-0b333744b53e505f) for [Docker](https://www.docker.com/)'s.

### Installation

1. Install [Docker](https://www.docker.com/).

2. Download [Fiona7](https://kb.infopark.com/infopark-cms-fiona-701-downloads-dc1abab22d308a1b/) and place zip file into this directory. (/reactor_test/docker_build)

3. Install MySQL version -> 5.6.

4. Put your license file into this directory under name `infopark-internal-restricted-license-fiona7.xml`

### Usage

Run to build the image

    docker build -t fiona7_reactor .

For starting CM, SES and Trifork.

    docker-compose up

For access to container bash.

    docker run -i -t fiona7_reactor

Display all containers:

    docker ps



### First run

After first run of `docker-compose up` we have to create mysql db. Run script `create_db.sh`
for it. `sh create_db.sh`
Than

docker exec -it <ID_OF_MYSQL_CONTAINER> /bin/bash


After first `docker-compose up` run you have to execute following lines in mysql container with:

    docker exec -it fiona7_reactor /bin/bash

Release object root in TCL single mode `CMS-Fiona-7.0.1/instance/default/bin/CM  -single`:

  setupGroups
  objClass create objType publication name Root
  obj root set objClass Root
  foreach obj [obj list] {catch {removeSubtree $obj}}
  foreach objClass [objClass list] {catch {objClass withName $objClass delete}}
  foreach attr [attribute list] {catch {attribute withName $attr delete}}

  `CMS-Fiona-7.0.1/instance/default/bin/CM -unrailsify`
  `CMS-Fiona-7.0.1/instance/default/bin/CM -railsify`

Or use empty dump of cms

  cd CMS-Fiona-7.0.1/instance/default/bin
  ./CM -restore ~/empty_cms
  ./CM -unrailsify
  ./CM -railsify
  
