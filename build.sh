#!/bin/bash

# Version tag template: IMAGE_NAME-YYYY-MM-DD
DATE=$(date +'%F')
REPO=resin/rpi-raspbian:wheezy

# Create temp image before squashing
docker build --tag $REPO-temp .

docker run -t -i --name=temp $REPO-temp echo
docker export temp | docker import - $REPO

# Remove temp image
docker rmi -f $REPO-temp

docker tag $REPO $REPO-$DATE

# Push the images
docker push $REPO
docker push $REPO-$DATE