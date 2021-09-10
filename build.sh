#!/bin/bash

set -o errexit

dir=$(mktemp --tmpdir=/var/tmp -d)
date=$(date +'%Y%m%d' -u)
	
mkdir -p $dir/rootfs/usr/bin
cp qemu-arm-static resin-xbuild $dir/rootfs/usr/bin
chmod +x $dir/rootfs/usr/bin/qemu-arm-static
	
./mkimage.sh -t $REPO:$SUITE --dir=$dir debootstrap --foreign --variant=minbase --keyring=/root/.gnupg/pubring.kbx --arch=armhf --include=sudo,ca-certificates,dirmngr,netbase,curl,procps $SUITE $MIRROR
