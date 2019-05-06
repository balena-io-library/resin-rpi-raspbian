#!/bin/bash

set -o errexit
set -o pipefail

QEMU_VERSION='4.0.0-balena-arm'
QEMU_SHA256='0cfb91a6afd0a796e1391f2b7a459be2ef7f86da3e05d5da16e8e9546e496b29'
RESIN_XBUILD_VERSION='1.0.0'
RESIN_XBUILD_SHA256='1eb099bc3176ed078aa93bd5852dbab9219738d16434c87fc9af499368423437'
MIRROR='http://archive.raspbian.org/raspbian'

# Download QEMU
curl -SLO https://github.com/resin-io/qemu/releases/download/v3.0.0+resin/qemu-$QEMU_VERSION.tar.gz \
	&& echo "$QEMU_SHA256  qemu-$QEMU_VERSION.tar.gz" > qemu-$QEMU_VERSION.tar.gz.sha256sum \
	&& sha256sum -c qemu-$QEMU_VERSION.tar.gz.sha256sum \
	&& tar -xz --strip-components=1 -f qemu-$QEMU_VERSION.tar.gz
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
