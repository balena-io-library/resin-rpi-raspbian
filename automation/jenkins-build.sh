#!/bin/bash

set -o errexit
set -o pipefail

function push_to_aliases(){
	# $1: suite

	for alias in $ALIASES; do
		docker tag $REPO:$1 $alias:$1
		docker tag $alias:$1 $alias:$1-$date

		if [ $LATEST == $1 ]; then
			docker tag $alias:$1 $alias:latest
		fi

		docker push $alias
		docker rmi -f $alias:$1
		docker rmi -f $alias:$1-$date
		docker rmi -f $alias:latest || true
	done
}

export SUITES='wheezy jessie stretch buster'
export REPO='resin/rpi-raspbian'
ALIASES='resin/raspberry-pi-debian resin/rpi-debian'
LATEST='jessie'
dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
date=$(date +'%Y%m%d' -u)

bash "$dir/build-image.sh"
for suite in $SUITES; do
	
	docker run --rm $REPO:$suite dpkg-query -l > $suite

	# Upload to S3 (using AWS CLI)
	printf "$ACCESS_KEY\n$SECRET_KEY\n$REGION_NAME\n\n" | aws configure
	aws s3 cp $suite s3://$BUCKET_NAME/image_info/rpi-raspbian/$suite/
	aws s3 cp $suite s3://$BUCKET_NAME/image_info/rpi-raspbian/$suite/$suite_$date
	rm -f $suite 

	docker tag $REPO:$suite $REPO:$suite-$date

	if [ $LATEST == $suite ]; then
		docker tag $REPO:$suite $REPO:latest
	fi

	push_to_aliases $suite
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
