#
# Node.js from source Dockerfile
#
# https://github.com/foreveroceans/docker-node
#
FROM ubuntu:14.04

MAINTAINER Forever Oceans

# Update system
RUN apt-get -y update && apt-get -y dist-upgrade

# Install dependencies
RUN apt-get -y install build-essential \
                       git \
                       python-dev \
                       supervisor \
                       wget

# Install node and npm from source (https://github.com/dockerfile/nodejs/blob/master/Dockerfile)
RUN wget https://nodejs.org/dist/v0.10.40/node-v0.10.40.tar.gz && \
    tar xvzf node-v0.10.40.tar.gz && \
    cd node-v0.10.40 && \
    ./configure && \
    CXX="g++ -Wno-unused-local-typedefs" make && \
    CXX="g++ -Wno-unused-local-typedefs" make install && \
    npm install -g npm && \
    printf '\n# Node.js\nexport PATH="node_modules/.bin:$PATH"' >> /root/.bashrc && \
    cd .. && \
    rm -rf node-v0.10.40.tar.gz node-v0.10.40
