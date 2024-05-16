# Point at an artifactory instance. These ARGs are needed
# before the FROM line as they are used in the FROM line. To use them after
# the FROM line, you need to redeclare the ARGs. If you leave out the value
# then it will take it from the previous ARG.
ARG BASE_IMAGE

# hadolint ignore=DL3006
FROM ${BASE_IMAGE} as base
FROM anzx-docker.artifactory.gcp.anz/library/certificates:latest as certificates

FROM anzx-docker.artifactory.gcp.anz/library/zulu-openjdk:11-jdk-ubi8-minimal
COPY --from=base /opt/harness-delegate/delegate.jar /tmp
RUN jarsigner -verify -verbose /tmp/delegate.jar > output && \
  grep "jar verified" output && \
  grep "Signed by \"CN=\*.harness.io" output

# hadolint ignore=DL3006
FROM ${BASE_IMAGE}

ARG ARTIFACTORY_URL="https://artifactory.gcp.anz/artifactory"
ARG PIP_INDEX_URL="https://artifactory.gcp.anz/artifactory/api/pypi/pypi/simple"

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

# The following operations need root
USER root
# From https://github.com/anzx/dockerfiles/tree/master/certificates
# DO NOT run update-ca-trust it will remove the ANZ certificates
# hadolint ignore=DL3021
COPY --from=certificates /etc/ssl/certs/ca-certificates.crt /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem
# hadolint ignore=DL3041
RUN set -euxo pipefail && \
    sed -i "s%https://cdn-ubi.redhat.com/content/public/ubi/%${ARTIFACTORY_URL}/redhat-ubi-rpm/%g" /etc/yum.repos.d/ubi.repo && \
    microdnf -y install git jq tar tzdata yum zip && \
    microdnf clean all

# Configure localtime and timezone
ENV TZ='Australia/Melbourne'
RUN ln -snf /usr/share/zoneinfo/"${TZ}" /etc/localtime && \
    echo "${TZ}" > /etc/timezone

# Override java.security file
COPY java.security /tmp
COPY java.security.11 /tmp

# Setup Java.
# JAVA_HOME has already been set in immutable delegates
RUN cd /opt/harness-delegate && \
    KEYTOOL="${JAVA_HOME}"/bin/keytool && \
    [[ -e "${JAVA_HOME}"/lib/security/java.security ]] && cp /tmp/java.security "${JAVA_HOME}"/lib/security/java.security; \
    [[ -e "${JAVA_HOME}"/conf/security/java.security ]] && cp /tmp/java.security.11 "${JAVA_HOME}"/conf/security/java.security; \
    "${KEYTOOL}" -import -keystore "${JAVA_HOME}"/lib/security/cacerts -storepass \
        changeit -noprompt -trustcacerts -file "/etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem" -alias "$(basename -- "${X}")" || exit 1

# Setup delegate user.
RUN useradd -m -u 2001 delegate && \
  # Add the user delegate to the group 412 so that the user can access /var/run/docker.sock on the Delegate container.
  # The group id 412 is used by Harness GCE instances.
  groupadd -g 412 delegategroup && \
  usermod -aG 412 delegate && \
  usermod -aG 0 delegate

# Label image to assist in grouping/filtering of scanning reports within the twistlock console, and
# to align with https://confluence.service.anz/pages/viewpage.action?pageId=683272131
LABEL ci_group="ANZx-PlatformDevEx" ci_name="ANZx-Platform" confidentiality="confidential" trustlevel="veryhigh" integrity="trusted"

# Install required tools: helm, kubectl, kustomize, tfwrap, go-template, Docker,
# delegate-git-credential-helper, Python, gcloud

ARG CLIENT_TOOLS_DIR=/opt/harness-delegate/client-tools

ARG HELM_VERSION
ARG HELM_SHA256
ARG KUBECTL_VERSION
ARG KUBECLT_SHA256
ARG KUSTOMIZE_VERSION
ARG KUSTOMISE_SHA256
ARG GO_TEMPLATE_VERSION
ARG GO_TEMPLATE_SHA256
ARG GCLOUD_VERSION
ARG GCLOUD_SHA256SUM

ARG PYTHON_VERSION="3.9.16"

RUN mkdir -p ${CLIENT_TOOLS_DIR}/helm && \
    cd ${CLIENT_TOOLS_DIR}/helm && \
    HELM_FILE=helm-${HELM_VERSION}-linux-amd64.tar.gz && \
    curl -fLO "${ARTIFACTORY_URL}/helmcli/${HELM_FILE}" && \
    echo "${HELM_SHA256} ${HELM_FILE}" | sha256sum -c && \
    mkdir -p ${HELM_VERSION} && \
    tar zxvf ${HELM_FILE} --strip-components=1 -C ${HELM_VERSION} && \
    rm -f ${HELM_FILE} && \
    ln -s ${CLIENT_TOOLS_DIR}/helm/${HELM_VERSION}/helm /usr/local/bin/helm3 && \
    ln -s ${CLIENT_TOOLS_DIR}/helm/${HELM_VERSION}/helm /usr/local/bin/helm && \
    mkdir -p ${CLIENT_TOOLS_DIR}/kubectl/${KUBECTL_VERSION} && \
    cd ${CLIENT_TOOLS_DIR}/kubectl/${KUBECTL_VERSION} && \
    curl -fLO "${ARTIFACTORY_URL}/storage-googleapis/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" && \
    echo "${KUBECLT_SHA256} kubectl" | sha256sum -c && \
    chmod +x kubectl && \
    ln -s ${CLIENT_TOOLS_DIR}/kubectl/${KUBECTL_VERSION}/kubectl /usr/local/bin/ && \
    mkdir -p ${CLIENT_TOOLS_DIR}/kustomize/${KUSTOMIZE_VERSION} && \
    cd ${CLIENT_TOOLS_DIR}/kustomize/${KUSTOMIZE_VERSION} && \
    KUSTOMIZE_FILE="kustomize_${KUSTOMIZE_VERSION}_linux_amd64.tar.gz" && \
    curl -fLO "${ARTIFACTORY_URL}/git-github/kubernetes-sigs/kustomize/releases/download/kustomize/${KUSTOMIZE_VERSION}/${KUSTOMIZE_FILE}" && \
    echo "${KUSTOMISE_SHA256} ${KUSTOMIZE_FILE}" | sha256sum -c && \
    tar zxvf ${KUSTOMIZE_FILE} && \
    rm -f ${KUSTOMIZE_FILE} && \
    ln -s ${CLIENT_TOOLS_DIR}/kustomize/${KUSTOMIZE_VERSION}/kustomize /usr/local/bin/ && \
    TFWRAP_FILE="/usr/local/bin/tfwrap" && \
    curl -fsSL --output ${TFWRAP_FILE} "${ARTIFACTORY_URL}/anzx-binaries/tfwrap/tfwrap-latest-linux-amd64" && \
    chmod +x ${TFWRAP_FILE} && \
    tfwrap -h

# Install harness go template
RUN mkdir -p ${CLIENT_TOOLS_DIR}/go-template/${GO_TEMPLATE_VERSION} && \
    cd ${CLIENT_TOOLS_DIR}/go-template/${GO_TEMPLATE_VERSION} && \
    curl -fLO "${ARTIFACTORY_URL}/anzx-binaries/harness/go-template" && \
    echo "${GO_TEMPLATE_SHA256} go-template" | sha256sum -c && \
    chmod +x go-template && \
    ln -s ${CLIENT_TOOLS_DIR}/go-template/${GO_TEMPLATE_VERSION}/go-template /usr/local/bin/

# Install Docker
# config.json needs to be writable by the delegate user
COPY --chown=delegate:delegate docker-config.json /opt/harness-delegate/.docker/config.json
ARG DOCKER_TEMP_DIR=/opt/harness-delegate/docker
RUN yum install -y yum-utils && \
  mkdir -p ${DOCKER_TEMP_DIR} && \
  cd ${DOCKER_TEMP_DIR} && \
  # Use Centos Docker repo https://serverfault.com/questions/1076075/how-to-officially-install-latest-docker-into-offline-rhel-8-x86-64-machine
  curl -fLO "${ARTIFACTORY_URL}/docker-download/linux/centos/docker-ce.repo" && \
  # Need this in order to build in GHA Runner workflow.
  sed -i "s%download.docker.com/%artifactory.gcp.anz/artifactory/docker-download/%g" docker-ce.repo && \
  yum-config-manager --add-repo docker-ce.repo && \
  yum install -y docker-ce-cli && \
  yum clean all && \
  rm -f docker-ce.repo && \
  # Fix open /opt/harness-delegate/.docker/.token_seed: permission denied
  install -m 0775 -d /opt/harness-delegate/.docker && \
  # Smoke test
  docker --help

RUN DELEGATE_GIT_CREDENTIAL_HELPER_FILE="/opt/delegate-git-credential-helper" && \
    curl -fsSL --output ${DELEGATE_GIT_CREDENTIAL_HELPER_FILE} "${ARTIFACTORY_URL}/anzx-binaries/delegate-git-credential-helper/delegate-git-credential-helper-latest" && \
    chmod +x ${DELEGATE_GIT_CREDENTIAL_HELPER_FILE}

RUN curl -fsSL --output /usr/local/bin/devexcli "${ARTIFACTORY_URL}/anzx-binaries/delegateutil-cli/delegateutil-cli-latest" && \
    chmod +x /usr/local/bin/devexcli

# Install Python
RUN yum update -y && \
  yum install -y python3 python3-pip && \
  yum clean all

# Ensure that a non-root owned folder exists for gcloud installation
RUN install -o delegate -g delegate -d /opt/harness-delegate/gcloud && \
    install -o delegate -g delegate -d /opt/harness-delegate/.config/gcloud/logs && \
    chmod -R g+w /opt/harness-delegate/.config

# Switch to the delegate user
USER delegate

# Install gcloud SDK: https://cloud.google.com/sdk/docs/downloads-versioned-archives
# Install kubectl, kustomize from gcloud for GKE
RUN cd /opt/harness-delegate/gcloud && \
  curl -fsSL --output /tmp/gcloud.tar.gz "${ARTIFACTORY_URL}/dl-google/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz" && \
  echo "${GCLOUD_SHA256SUM} /tmp/gcloud.tar.gz" | sha256sum -c && \
  tar -xf /tmp/gcloud.tar.gz && \
  rm -rf /tmp/gcloud.tar.gz && \
  # required for component update
  sed -i "s|default='https://dl.google.com/dl/cloudsdk/channels/rapid/components-2.json'|default='https://artifactory.gcp.anz/artifactory/dl-google/dl/cloudsdk/channels/rapid/components-2.json'|"  /opt/harness-delegate/gcloud/google-cloud-sdk/lib/googlecloudsdk/core/properties.py && \
  # Install and update .bashrc to install on PATH
  # Additional components kubectl installs gke-gcloud-auth-plugin
  ./google-cloud-sdk/install.sh \
    --additional-components beta kubectl kustomize \
    --usage-reporting false \
    --command-completion false \
    --path-update true \
    --quiet && \
  # Disable auto-update
  jq '. * {"disable_updater":true}' < ./google-cloud-sdk/lib/googlecloudsdk/core/config.json > /tmp/config.json && \
  cp /tmp/config.json ./google-cloud-sdk/lib/googlecloudsdk/core/config.json && \
  rm -rf  /tmp/config.json
ENV CLOUDSDK_PYTHON=python3
ENV PATH=/opt/harness-delegate/gcloud/google-cloud-sdk/bin:$PATH

