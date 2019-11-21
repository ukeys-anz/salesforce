# This is the Dockerfile of anzx-docker.artifactory.gcp.anz/salesforce/salesforce-builder:new
FROM hub.artifactory.gcp.anz/node:12.8.0-alpine

RUN sed -i -e 's|http://dl-cdn.alpinelinux.org|https://artifactory.gcp.anz/artifactory/alpinelinux|g' /etc/apk/repositories && \
  apk add --no-cache ca-certificates bash git zip

RUN npm config set registry https://artifactory.gcp.anz/artifactory/api/npm/npmjs-org/ && \
  npm install sfdx-cli --global

