# use small node image
FROM node:alpine

# install zip, unzip and jq
RUN apk add --update zip unzip jq bash git openjdk8-jre wget curl python make g++

# setup java
ENV JAVA_HOME="/usr/lib/jvm/java-1.8-openjdk"
ENV PATH="$JAVA_HOME/bin:${PATH}"
RUN java -version

# install latest sfdx and typescript from npm
RUN npm install sfdx-cli typescript --global
RUN sfdx --version
RUN sfdx plugins --core

# install pmd
ENV PMD_VERSION 6.29.0

RUN mkdir -p /opt

RUN cd /opt && \
      wget -nc -O pmd.zip https://github.com/pmd/pmd/releases/download/pmd_releases/${PMD_VERSION}/pmd-bin-${PMD_VERSION}.zip && \
      unzip pmd.zip && \
      rm -f pmd.zip && \
      mv pmd-bin-${PMD_VERSION} pmd


COPY pmdscripts/pmd /usr/bin/pmd
COPY pmdscripts/cpd /usr/bin/cpd
RUN chmod +x /usr/bin/pmd /usr/bin/cpd

RUN apk add --update tar
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories
RUN apk add hub

RUN mkdir /src
VOLUME /src
WORKDIR /src
