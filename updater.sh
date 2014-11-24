#!/bin/bash

docker pull resin/rpi-raspbian:wheezy
docker run -d -i -t --name img-updater resin/rpi-raspbian:wheezy /bin/bash
docker exec img-updater apt-get update
docker exec img-updater apt-get upgrade -y
 # Generate version tag for docker image: resin/rpi-raspbian:wheezy-YYYY-MM-DD
 # Default OS_NAME=resin/rpi-raspbian:wheezy
VERSIONTAG="resin/rpi-raspbian:wheezy-$(date +'%F')"
docker export img-updater | docker import - $VERSIONTAG