#!/bin/bash

set -o errexit
set -o pipefail

export SUITES='jessie stretch buster'
export REPO='balenalib/rpi-raspbian'
LATEST='stretch'
dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
date=$(date +'%Y%m%d' -u)

bash "$dir/build-image.sh"
for suite in $SUITES; do

	docker tag $REPO:$suite $REPO:$suite-$date

	if [ $LATEST == $suite ]; then
		docker tag $REPO:$suite $REPO:latest
	fi
done

docker push $REPO

# Clean up unnecessarry docker images after pushing
if [ $? -eq 0 ]; then
	for suite in $SUITES; do
		docker rmi -f $REPO:$suite
		docker rmi -f $REPO:$suite-$date
		docker rmi -f $REPO:latest || true
	done
fi
