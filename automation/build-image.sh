#!/bin/bash

set -o errexit
set -o pipefail

QEMU_RELEASE='5.2.0+balena4'
QEMU_ASSET="qemu-${QEMU_RELEASE/+/.}-arm.tar.gz"
QEMU_SHA256='8b410eabfb8417b6d8dcb7008fafa91c5f0496ab5db0b93a1b5b88cc7d86391e'
RESIN_XBUILD_VERSION='1.0.0'
RESIN_XBUILD_SHA256='1eb099bc3176ed078aa93bd5852dbab9219738d16434c87fc9af499368423437'
MIRROR='http://archive.raspbian.org/raspbian'

# Download QEMU
curl -SLO https://github.com/balena-io/qemu/releases/download/v$QEMU_RELEASE/$QEMU_ASSET \
	&& echo "$QEMU_SHA256 $QEMU_ASSET" > $QEMU_ASSET.sha256sum \
	&& sha256sum -c $QEMU_ASSET.sha256sum \
	&& tar -xz --strip-components=1 -f $QEMU_ASSET
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
