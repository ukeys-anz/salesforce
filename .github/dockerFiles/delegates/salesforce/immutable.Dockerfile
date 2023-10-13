# Point at an artifactory instance. These ARGs are needed
# before the FROM line as they are used in the FROM line. To use them after
# the FROM line, you need to redeclare the ARGs. If you leave out the value
# then it will take it from the previous ARG.
ARG ARTIFACTORY=artifactory.gcp.anz
ARG BASE_IMAGE
ARG YQ_VERSION=4.21.1
ARG CONFTEST_VERSION=v0.26.0
ARG OPA_VERSION=0.27.1
ARG GOLANG_VERSION=1.19.3

FROM hub.${ARTIFACTORY}/openpolicyagent/conftest:${CONFTEST_VERSION} as conftest
FROM hub.${ARTIFACTORY}/openpolicyagent/opa:${OPA_VERSION} as opa

# hadolint ignore=DL3006
FROM ${BASE_IMAGE}

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

WORKDIR /opt/harness-delegate
COPY --from=conftest conftest .
COPY --from=opa opa .

ARG ARTIFACTORY
ENV NPM_CONFIG_REGISTRY=https://${ARTIFACTORY}/artifactory/api/npm/npmjs-org NODE_VERSION=18.7.0

USER root
# Install python
# hadolint ignore=DL3033
RUN yum install -y python27 python2-pip && \
    yum clean all

# Set Python and Pip default to Python 2, so that it is backward compatible
RUN alternatives --set python /usr/bin/python2 && ln -s /usr/bin/pip2 /usr/bin/pip

# Install yq
ARG YQ_VERSION
RUN curl -L "https://${ARTIFACTORY}/artifactory/github/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_amd64" --output /usr/local/bin/yq && \
  chmod u+x /usr/local/bin/yq

# Installing Go
ARG GOLANG_VERSION
RUN curl -fsSL https://$ARTIFACTORY/artifactory/anzx-binaries/go$GOLANG_VERSION.linux-amd64.tar.gz -O && \
    tar -C /usr/local -xzf go$GOLANG_VERSION.linux-amd64.tar.gz && \
    rm -f ./go$GOLANG_VERSION.linux-amd64.tar.gz

# Set env variables
ENV PATH=$PATH:/usr/local/go/bin NODE_EXTRA_CA_CERTS=/etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem PATH=$PATH:/opt/harness-delegate/bin

# Install node and Salesforce CLI deps: https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_install_cli.htm#sfdx_setup_install_cli_npm
RUN curl -o node.tar.gz https://${ARTIFACTORY}:443/artifactory/nodejs-dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.gz && \
  tar -zxf node.tar.gz --strip-components 1 && \
  rm node.tar.gz

# Install Salesforce CLI, ignore scripts to avoid binary downloads (e.g. ngrok)
RUN npm install sfdx-cli@7.205.6 -g --ignore-scripts && npm install @salesforce/cli@1.75.6 -g --ignore-scripts

# Label image to assist in grouping/filtering of scanning reports within the twistlock console
LABEL ci_group="ANZx-Salesforce" ci_name="ANZx-Platform"

RUN mkdir -p /opt/harness-delegate/.sf || true ; chown delegate:delegate /opt/harness-delegate/.sf && \
    mkdir -p /opt/harness-delegate/.terraform.d || true ; chown delegate:delegate /opt/harness-delegate/.terraform.d && \
    mkdir -p /opt/harness-delegate/.tfwrap || true ; chown delegate:delegate /opt/harness-delegate/.tfwrap && \
    mkdir -p /opt/harness-delegate/.local/share/sfdx || true ; chown delegate:delegate /opt/harness-delegate/.local/share/sfdx

RUN echo y | sfdx plugins:install https://${ARTIFACTORY}:443/artifactory/api/npm/npmjs-org/sfdx-git-delta/-/sfdx-git-delta-5.25.2.tgz && npm install sfdx-git-delta@latest --global

USER delegate