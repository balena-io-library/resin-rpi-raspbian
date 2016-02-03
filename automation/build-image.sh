#!/bin/bash

set -o errexit
set -o pipefail

QEMU_VERSION='2.5.0-resin-rc1'
QEMU_SHA256='8db1c7525848072974580b2e1c79797fc995fd299ee2e4214631574023589782'
MIRROR='http://archive.raspbian.org/raspbian'

# Download QEMU
curl -SLO https://github.com/resin-io/qemu/releases/download/$QEMU_VERSION/qemu-$QEMU_VERSION.tar.gz \
	&& echo "$QEMU_SHA256  qemu-$QEMU_VERSION.tar.gz" > qemu-$QEMU_VERSION.tar.gz.sha256sum \
	&& sha256sum -c qemu-$QEMU_VERSION.tar.gz.sha256sum \
	&& tar -xz --strip-components=1 -f qemu-$QEMU_VERSION.tar.gz

docker build -t raspbian-mkimage .

for suite in $SUITES; do

	rm -rf output
	mkdir -p output
	docker run --rm --privileged	-e REPO=$REPO \
									-e SUITE=$suite \
									-e MIRROR=$MIRROR \
									-v `pwd`/output:/output raspbian-mkimage

	docker build -t $REPO:$suite output/
done

rm -rf qemu*
