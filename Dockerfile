FROM hub.artifactory.gcp.anz/node:12.8.0-alpine
RUN apk add --update --no-cache git openssh ca-certificates openssl curl
RUN npm config set registry https://artifactory.gcp.anz/artifactory/api/npm/npmjs-org/
RUN npm install sfdx-cli --global
USER node
ENTRYPOINT [ "sfdx" ]
