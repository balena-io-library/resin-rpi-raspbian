#!/bin/bash

QEMU_VERSION='2.5.0-resin-rc1'
QEMU_SHA256='8db1c7525848072974580b2e1c79797fc995fd299ee2e4214631574023589782'

# Jenkins build steps
docker build -t raspbian-mkimage .
docker run --privileged -e QEMU_SHA256=$QEMU_SHA256 -e QEMU_VERSION=$QEMU_VERSION -e REGION_NAME=$REGION_NAME -e ACCESS_KEY=$ACCESS_KEY -e SECRET_KEY=$SECRET_KEY -e BUCKET_NAME=$BUCKET_NAME -v /var/run/docker.sock:/var/run/docker.sock raspbian-mkimage
docker push resin/rpi-raspbian
