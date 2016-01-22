FROM debian:jessie

RUN echo "deb http://http.debian.net/debian jessie-backports main"  >> /etc/apt/sources.list

RUN apt-get -q update \
	&& apt-get -qy install \
		curl \
		docker.io \
		debootstrap \
		python \
		python-pip \
		ca-certificates \
	&& rm -rf /var/lib/apt/lists/*

RUN pip install awscli

RUN gpg --recv-keys --keyserver pgp.mit.edu 0x9165938D90FDDD2E

COPY . /usr/src/mkimage

WORKDIR /usr/src/mkimage

CMD ./build.sh
