FROM resin/rpi-raspbian:wheezy

RUN apt-get update && apt-get upgrade -y

CMD ["/bin/bash", "-c"]