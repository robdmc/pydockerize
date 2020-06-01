# Pull from the base image
FROM ubuntu:20.04

# Add files
ADD ./files/.bash_profile /root/.bash_profile
ADD ./files/.bashrc /root/.bashrc
ADD ./files/.inputrc /root/.inputrc
ADD ./files/.vimrc /root/.vimrc


ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm-256color

# set utf8 default locale lang
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Set the working directory
WORKDIR /root

# Install required linux packages
RUN apt-get update && \
  apt-get install -y python3-dev python3-pip && \
  apt-get install -y locales && \
  ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime && \
  apt-get install -y tzdata && \
  dpkg-reconfigure --frontend noninteractive tzdata && \
  apt-get install -y vim curl tree wget bzip2 ca-certificates git nano ssh && \
  locale-gen en_US.UTF-8 && \
  apt-get install -y postgresql-client


# This directory will get overridden by volume mount
# But this sets up simlink for gitconfig
RUN mkdir -p /docker/container_files/root && \ 
touch /docker/container_files/root/.gitconfig && \
touch /docker/container_files/root/.bash_history && \
ln -s /docker/container_files/root/.gitconfig /root && \
ln -s /docker/container_files/root/.bash_history /root


# Build node for jupyter-lab
RUN curl -sL https://deb.nodesource.com/setup_14.x -o nodesource_setup.sh && \
bash nodesource_setup.sh && \
apt install -y nodejs


# Set timezone to eastern
RUN echo "America/New_York" > /etc/timezone && \
dpkg-reconfigure -f noninteractive tzdata