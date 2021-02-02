#!/bin/bash

set -o errexit
set -o pipefail

QEMU_VERSION='5.2.0.balena1-arm'
QEMU_SHA256='2eb115f1b1626765108da1265b56444ffbfce86f194611d4367e1a06508857f8'
RESIN_XBUILD_VERSION='1.0.0'
RESIN_XBUILD_SHA256='1eb099bc3176ed078aa93bd5852dbab9219738d16434c87fc9af499368423437'
MIRROR='http://archive.raspbian.org/raspbian'

# Download QEMU
curl -SLO https://github.com/balena-io/qemu/releases/download/v5.2.0+balena1/qemu-v$QEMU_VERSION.tar.gz \
	&& echo "$QEMU_SHA256  qemu-v$QEMU_VERSION.tar.gz" > qemu-v$QEMU_VERSION.tar.gz.sha256sum \
	&& sha256sum -c qemu-v$QEMU_VERSION.tar.gz.sha256sum \
	&& tar -xz --strip-components=1 -f qemu-v$QEMU_VERSION.tar.gz
curl -SLO http://resin-packages.s3.amazonaws.com/resin-xbuild/v$RESIN_XBUILD_VERSION/resin-xbuild$RESIN_XBUILD_VERSION.tar.gz \
	&& echo "$RESIN_XBUILD_SHA256  resin-xbuild$RESIN_XBUILD_VERSION.tar.gz" | sha256sum -c - \
	&& tar -xzf resin-xbuild$RESIN_XBUILD_VERSION.tar.gz
chmod +x qemu-arm-static resin-xbuild

docker build -t raspbian-mkimage .

for suite in $SUITES; do

	rm -rf output
	mkdir -p output
	docker run --rm --privileged	-e REPO=$REPO \
									-e SUITE=$suite \
									-e MIRROR=$MIRROR \
									-e RESIN_QEMU_VERSION=$QEMU_VERSION \
									-v `pwd`/output:/output raspbian-mkimage

	docker build -t $REPO:$suite output/
done

rm -rf qemu* resin-xbuild
