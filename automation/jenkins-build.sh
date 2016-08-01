#!/bin/bash

set -o errexit
set -o pipefail

export SUITES='wheezy jessie'
export REPO='resin/rpi-raspbian'
ALIAS_REPO='resin/raspberrypi-debian'
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

	docker tag -f $REPO:$suite $ALIAS_REPO:$suite
	docker tag -f $REPO:$suite $REPO:$suite-$date
	docker tag -f $ALIAS_REPO:$suite $ALIAS_REPO:$suite-$date
	if [ $LATEST == $suite ]; then
		docker tag -f $REPO:$suite $REPO:latest
		docker tag -f $ALIAS_REPO:$suite $ALIAS_REPO:latest
	fi
done

docker push $REPO
docker push $ALIAS_REPO

# Clean up unnecessarry docker images after pushing
if [ $? -eq 0 ]; then
	for suite in $SUITES; do
		docker rmi -f $REPO:$suite
		docker rmi -f $REPO:$suite-$date
		docker rmi -f $ALIAS_REPO:$suite
		docker rmi -f $ALIAS_REPO:$suite-$date
	done
fi
