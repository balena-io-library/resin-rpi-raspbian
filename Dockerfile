FROM debian:jessie

RUN apt-get -q update \
	&& apt-get -qy install \
		curl \
		docker.io \
		debootstrap

RUN gpg --recv-keys --keyserver pgp.mit.edu 0x9165938D90FDDD2E

COPY . /usr/src/mkimage

WORKDIR /usr/src/mkimage

CMD ./build.sh

