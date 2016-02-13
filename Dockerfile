#
# Base image.
#
# https://github.com/foreveroceans/docker-node
#
FROM ubuntu:14.04

MAINTAINER Forever Oceans

# Update system and install dependencies
RUN apt-get -y update && \
    apt-get -y install \
        autoconf \
        automake \
        build-essential \
        curl \
        git \
        libtool \
        pkg-config \
        python-dev \
        supervisor \
        uuid-dev \
        wget

##
# NODE INSTALLATION
##

# gpg keys listed at https://github.com/nodejs/node
RUN set -ex \
  && for key in \
    9554F04D7259F04124DE6B476D5A82AC7E37093B \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    0034A06D9D9B0064CE8ADF6BF1747F4AD2306D93 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    B9AE9905FFD7803F25714661B63B535A4C206CA9 \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
  ; do \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
  done

ENV NPM_CONFIG_LOGLEVEL info
ENV NODE_VERSION 5.6.0

RUN curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" && \
    curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" && \
    gpg --verify SHASUMS256.txt.asc && \
    grep " node-v$NODE_VERSION-linux-x64.tar.xz\$" SHASUMS256.txt.asc | sha256sum -c - && \
    tar -xJf "node-v$NODE_VERSION-linux-x64.tar.xz" -C /usr/local --strip-components=1 && \
    rm "node-v$NODE_VERSION-linux-x64.tar.xz" SHASUMS256.txt.asc

##
# ZMQ INSTALLATION
##

ENV ZEROMQ_VERSION 4.1.4
ENV LIBSODIUM_VERSION 1.0.8

WORKDIR /tmp

RUN curl -SLO https://download.libsodium.org/libsodium/releases/libsodium-$LIBSODIUM_VERSION.tar.gz && \
    tar -xvf libsodium-$LIBSODIUM_VERSION.tar.gz && \
    cd libsodium-* && \
    ./configure && \
    make && \
    make check && \
    make install && \
    cd .. && \
    rm -rf libsodium*

RUN curl -SLO http://download.zeromq.org/zeromq-$ZEROMQ_VERSION.tar.gz && \
    tar -xvf zeromq-$ZEROMQ_VERSION.tar.gz && \
    cd zeromq-* && \
    ./configure && \
    make install && \
    ldconfig && \
    cd .. && \
    rm -rf zeromq*

# Remove pacakges we only needed for libsodium/zeromq
RUN apt-get purge -y \
        autoconf \
        automake \
        libtool \
        pkg-config \
        uuid-dev

RUN npm install -g zmq && \
    npm link zmq

CMD [ "node" ]
