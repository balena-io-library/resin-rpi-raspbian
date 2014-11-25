#!/bin/bash

set -o errexit
set -o pipefail

# Version tag template: IMAGE_NAME-YYYY-MM-DD
DATE=$(date +'%F')
REPO=resin/rpi-raspbian:wheezy

# Create temp image before squashing
docker build --tag $REPO-temp .

CONTAINER=$(docker run -d $REPO-temp echo)
docker export $CONTAINER | docker import - $REPO

# Remove temp image and container
docker rm -f $CONTAINER
docker rmi -f $REPO-temp

docker tag $REPO $REPO-$DATE

# Push the images
docker push $REPO
docker push $REPO-$DATE