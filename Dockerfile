FROM debian:bullseye

RUN apt-get -q update \
	&& apt-get -qy install \
		curl \
		debootstrap \
		python3 \
		python3-pip \
		ca-certificates \
	&& rm -rf /var/lib/apt/lists/*

RUN pip install awscli

RUN gpg --recv-keys --keyserver keyserver.ubuntu.com 0x9165938D90FDDD2E

COPY . /usr/src/mkimage

WORKDIR /usr/src/mkimage

CMD ./build.sh
