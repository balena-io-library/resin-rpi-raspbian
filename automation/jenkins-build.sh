#!/bin/bash

set -o errexit
set -o pipefail

export SUITES='stretch buster bullseye bookworm'
export REPO='balenalib/rpi-raspbian'
LATEST='bullseye'
dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
date=$(date +'%Y%m%d' -u)

bash "$dir/build-image.sh"
for suite in $SUITES; do

	docker tag $REPO:$suite $REPO:$suite-$date
	docker push $REPO:$suite
	docker push $REPO:$suite-$date

	if [ $LATEST == $suite ]; then
		docker tag $REPO:$suite $REPO:latest
		docker push $REPO:latest
	fi
done

# Clean up unnecessarry docker images after pushing
if [ $? -eq 0 ]; then
	for suite in $SUITES; do
		docker rmi -f $REPO:$suite
		docker rmi -f $REPO:$suite-$date
		docker rmi -f $REPO:latest || true
	done
fi
