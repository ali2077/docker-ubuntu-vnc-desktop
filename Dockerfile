FROM ubuntu:12.04
MAINTAINER Doro Wu <fcwu.tw@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

# setup our Ubuntu sources (ADD breaks caching)
RUN echo "deb http://us.archive.ubuntu.com/ubuntu/ precise main\n\
deb http://us.archive.ubuntu.com/ubuntu/ precise multiverse\n\
deb http://us.archive.ubuntu.com/ubuntu/ precise universe\n\
deb http://us.archive.ubuntu.com/ubuntu/ precise restricted\n\
"> /etc/apt/sources.list

# no Upstart or DBus
# https://github.com/dotcloud/docker/issues/1724#issuecomment-26294856
RUN apt-mark hold initscripts udev plymouth mountall
RUN dpkg-divert --local --rename --add /sbin/initctl && ln -s /bin/true /sbin/initctl

RUN HTTP_PROXY=http://172.17.42.1:3142 apt-get update

# install our "base" environment
RUN HTTP_PROXY=http://172.17.42.1:3142 apt-get install -y --no-install-recommends openssh-server pwgen sudo vim-tiny
RUN HTTP_PROXY=http://172.17.42.1:3142 apt-get install -y --no-install-recommends lxde
RUN HTTP_PROXY=http://172.17.42.1:3142 apt-get install -y --no-install-recommends x11vnc xvfb
RUN HTTP_PROXY=http://172.17.42.1:3142 apt-get install -y supervisor
RUN HTTP_PROXY=http://172.17.42.1:3142 apt-get install -y libreoffice firefox
# noVNC
RUN HTTP_PROXY=http://172.17.42.1:3142 apt-get install -y net-tools

ADD startup.sh /
ADD supervisord.conf /
ADD noVNC /noVNC/

# clean up after ourselves
RUN apt-get clean

EXPOSE 6080
EXPOSE 5900
EXPOSE 22
WORKDIR /
ENTRYPOINT ["/startup.sh"]
