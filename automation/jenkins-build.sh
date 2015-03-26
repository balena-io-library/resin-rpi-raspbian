#!/bin/bash

# Jenkins build steps
docker build -t raspbian-mkimage .
docker run --privileged -v /var/run/docker.sock:/var/run/docker.sock -v `pwd`/qemu-arm-static:/usr/src/mkimage/qemu-arm-static raspbian-mkimage
docker push resin/rpi-raspbian
