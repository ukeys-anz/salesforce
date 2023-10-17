#!/usr/bin/env bash

set -euo pipefail

if [[ -z ${ACCOUNT_SECRET+x} ]]; then
    # If ACCOUNT_SECRET environment variable does not exist try to get it from Secret Manager Secret.
    # NOTE: if ACCOUNT_SECRET is empty but does exist this will not run.

    REGEXP_SECRET_MANAGER_SECRET_VERSION='^projects/([^/]+)/secrets/([^/]+)/versions/([^/]+)$'
    readonly REGEXP_SECRET_MANAGER_SECRET_VERSION

    if [[ -z ${1+x} ]]; then
        1>&2 echo "If environment variable ACCOUNT_SECRET does not exist then the first argument must be set (to a value that matches regular expression ${REGEXP_SECRET_MANAGER_SECRET_VERSION})"
        exit 1
    elif [[ ! ${1} =~ ${REGEXP_SECRET_MANAGER_SECRET_VERSION} ]]; then
        1>&2 echo "First argument must match regular expression ${REGEXP_SECRET_MANAGER_SECRET_VERSION} but got $1"
        exit 1
    fi

    echo "Trying to get Account Secret from Secret Manager Secret $1 because environment variable ACCOUNT_SECRET does not exist"
    GOOGLE_OAUTH2_TOKEN=$(curl \
        --fail \
        -sS \
        --retry 30 \
        --retry-connrefused \
        --retry-max-time 30 \
        -H 'Metadata-Flavor: Google' \
        'http://169.254.169.254/computeMetadata/v1/instance/service-accounts/default/token' \
        | jq -r '.access_token')
    ACCOUNT_SECRET=$(curl \
        --fail \
        -sS \
        --connect-timeout 1 \
        --max-time 5 \
        --retry 5 \
        --retry-max-time 25 \
        -H 'Authorization: Bearer '"${GOOGLE_OAUTH2_TOKEN}" \
        'https://secretmanager.googleapis.com/v1/'"$1"':access' \
        | jq -r '.payload.data' \
        | base64 -d)
    export ACCOUNT_SECRET
    echo "Got Account Secret successfully. Account Secret has length ${#ACCOUNT_SECRET}"
fi

set -x
# Configure credential helper for accessing github.com repositories.
git config --global credential.helper /opt/delegate-git-credential-helper
git config --global credential.useHttpPath true

# SSH is not supported at all on Harness delegates.
# In case people accidentally refer to remotes using ssh://git@github.com/ or git@github.com:,
# rewrite those URLs.
git config --global url.'https://github.com/'.insteadOf 'ssh://git@github.com/'

# If gcloud SDK is installed (and is on the PATH) then configure the gcloud credential helper.
if command -v git-credential-gcloud.sh 2>/dev/null 1>&1; then
    git config --global --add credential.helper gcloud.sh
fi
set +x

./start.sh
