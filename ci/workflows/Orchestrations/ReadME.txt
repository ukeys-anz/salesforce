*** This will be updated until we test everything

** Validation workflow should be like below

name: Salesforce Validation

on:
  pull_request:
    branches:
      - x
      # This should be changed
      # pull_request:
      # branches:
      #   - "master"
      #   - "develop"
      #   - "release"
      #   - "epic/*"
      # types:
      #   - opened
      #   - reopened
      #   - ready_for_review
      #   - synchronize

permissions:
  contents: "read"
  id-token: "write"

jobs:
  validation:
    container:
      image: "salesforce-docker.artifactory.gcp.anz/salesforce-delegate:1.2.1"
      options: --user root
    runs-on: [self-hosted, cd-ubuntu-s-np]
    steps:
      - name: Link SGD plugin
        run: |
          cd /opt/harness-delegate/.local/share/sf
          sf plugins:link node_modules/sfdx-git-delta/bin

      - name: NPM package Version | node, sfdx, sf, sgd version
        run: |
          echo "node version: $(node -v)"
          echo "sf version: $(sf -v)"
          echo "sf plugins: $(sf plugins)"

      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: OIDC Authentication (Salesforce Harness Delegate Service Account)
        id: "authenticate-harness-delegate"
        uses: "anzx/github-reusable-actions/authenticate-gcp@main"
        with:
          service_account: "h-sf-primary-np@anz-x-bootstrap-np-487e09.iam.gserviceaccount.com"

      - name: ENV vars
        run: |
          baseRef="${{ github.base_ref }}"
          echo BASE_REF="$baseRef" >> $GITHUB_ENV
          echo BRANCH_NAME="${{ github.head_ref }}" >> $GITHUB_ENV
          echo PR_NUMBER="${{ github.event.number }}" >> $GITHUB_ENV
          echo DRAFT_PR="${{ github.event.pull_request.draft }}" >> $GITHUB_ENV
          echo SPECIFIED_TEST_PR="${{ contains( toJson(github.event.pull_request.labels), 'Run Specified Tests') }}" >> $GITHUB_ENV
          echo WORKING_DIR="$(pwd)" >> $GITHUB_ENV

          lastTag="$( git describe --abbrev=0 --tags --match $baseRef* )"
          echo BASE_REF_LAST_TAG="$lastTag" >> $GITHUB_ENV

      - name: Find Secret Names
        run: |
          sfdxURL=$( node ci/workflows/Orchestrations/findSecret.mjs )
          echo "$sfdxURL"
          echo SECRET_NAME="$sfdxURL" >> $GITHUB_ENV
          echo ARTIFACTORY_SECRET_NAME="h-salesforce-np-artifact" >> $GITHUB_ENV

      - name: Retrieve GSM Credentials
        id: secrets
        uses: google-github-actions/get-secretmanager-secrets@main
        with:
          secrets: |-
            sfdxurl:projects/448406129405/secrets/${{ env.SECRET_NAME }}/versions/latest
            artifactory:projects/448406129405/secrets/${{ env.ARTIFACTORY_SECRET_NAME }}/versions/latest
            proxypass:projects/anz-x-bootstrap-np-487e09/secrets/h-salesforce-np-proxy-password/versions/3

      - name: Add secrets to ENV
        run: |
          echo SFDX_URL="${{ steps.secrets.outputs.sfdxurl }}" >> $GITHUB_ENV
          echo ARTIFACTORY_SECRET_VALUE="${{ steps.secrets.outputs.artifactory }}" >> $GITHUB_ENV

      - name: Setup HTTP Proxy
        id: "proxy-harness-delegate"
        uses: "anzx/github-reusable-actions/setup-http-proxy@main"
        with:
          production: false
          proxy-username: "sf-harness-delegate-np"
          proxy-password: "${{ steps.secrets.outputs.proxypass }}"

      - name: Run Validation
        run: |
          node --no-warnings ci/workflows/Orchestrations/validation.mjs
          echo WHICH_JOB="clean" >> $GITHUB_ENV

      - name: Code coverage and cleaning
        run: |
          node --no-warnings ci/workflows/Orchestrations/validation.mjs



---------------------------------------------------

** Deployment workflow should be like below

name: Salesforce Deployment

on:
  push:
    branches:
      - x
      # - "release"
      # - "develop"
      # - "epic/*"

permissions:
  contents: "write"
  id-token: "write"

jobs:
  Deployment:
    container:
      image: "salesforce-docker.artifactory.gcp.anz/salesforce-delegate:1.2.1"
      options: --user root
    runs-on: [self-hosted, cd-ubuntu-s-np]
    steps:
      - name: Link SGD plugin
        run: |
          cd /opt/harness-delegate/.local/share/sf
          sf plugins:link node_modules/sfdx-git-delta/bin

      - name: NPM package Version | node, sfdx, sf, sgd version
        run: |
          echo "node version: $(node -v)"
          echo "sf version: $(sf -v)"
          echo "sf plugins: $(sf plugins)"

      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: OIDC Authentication (Salesforce Harness Delegate Service Account)
        id: "authenticate-harness-delegate"
        uses: "anzx/github-reusable-actions/authenticate-gcp@main"
        with:
          service_account: "h-sf-primary-np@anz-x-bootstrap-np-487e09.iam.gserviceaccount.com"

      - name: ENV vars
        run: |
          baseRef="$(echo ${GITHUB_REF#refs/heads/})"
          echo BASE_REF="$baseRef" >> $GITHUB_ENV
          echo RUN_ID="${GITHUB_RUN_ID}" >> $GITHUB_ENV
          echo WORKING_DIR="$(pwd)" >> $GITHUB_ENV
          lastTag="$( git describe --abbrev=0 --tags --match $baseRef* )"
          echo BASE_REF_LAST_TAG="$lastTag" >> $GITHUB_ENV

      - name: Find Secret Names
        run: |
          sfdxURL=$( node ci/workflows/Orchestrations/findSecret.mjs )
          echo "$sfdxURL"
          echo SECRET_NAME="$sfdxURL" >> $GITHUB_ENV
          echo ARTIFACTORY_SECRET_NAME="h-salesforce-np-artifact" >> $GITHUB_ENV

      - name: Retrieve GSM Credentials
        id: secrets
        uses: google-github-actions/get-secretmanager-secrets@main
        with:
          secrets: |-
            sfdxurl:projects/448406129405/secrets/${{ env.SECRET_NAME }}/versions/latest
            artifactory:projects/448406129405/secrets/${{ env.ARTIFACTORY_SECRET_NAME }}/versions/latest
            proxypass:projects/anz-x-bootstrap-np-487e09/secrets/h-salesforce-np-proxy-password/versions/3

      - name: Add secrets to ENV
        run: |
          echo SFDX_URL="${{ steps.secrets.outputs.sfdxurl }}" >> $GITHUB_ENV
          echo ARTIFACTORY_SECRET_VALUE="${{ steps.secrets.outputs.artifactory }}" >> $GITHUB_ENV

      - name: Setup HTTP Proxy
        id: "proxy-harness-delegate"
        uses: "anzx/github-reusable-actions/setup-http-proxy@main"
        with:
          production: false
          proxy-username: "sf-harness-delegate-np"
          proxy-password: "${{ steps.secrets.outputs.proxypass }}"

      - name: Run Deployment
        run: |
          node --no-warnings ci/workflows/Orchestrations/deployment.mjs
          echo WHICH_JOB="clean" >> $GITHUB_ENV

      - name: Creating new tag and cleaning
        run: |
          node --no-warnings ci/workflows/Orchestrations/deployment.mjs



---------------------------------------------------

** Quick Deployment workflow should be like below

name: Salesforce Quick Deployment

on:
  pull_request:
    branches:
      - x
      # - "develop"
      # - "release"
      # - "epic/*"

    types:
      - closed

permissions:
  contents: "write"
  id-token: "write"

jobs:
  Quick-Deployment:
    if: ${{ github.event.pull_request.merged == true }}
    container:
      image: "salesforce-docker.artifactory.gcp.anz/salesforce-delegate:1.2.1"
      options: --user root
    runs-on: [self-hosted, cd-ubuntu-s-np]
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: OIDC Authentication (Salesforce Harness Delegate Service Account)
        id: "authenticate-harness-delegate"
        uses: "anzx/github-reusable-actions/authenticate-gcp@main"
        with:
          service_account: "h-sf-primary-np@anz-x-bootstrap-np-487e09.iam.gserviceaccount.com"

      - name: ENV vars
        run: |
          echo BASE_REF="${{ github.base_ref }}" >> $GITHUB_ENV
          echo BRANCH_NAME="${{ github.head_ref }}" >> $GITHUB_ENV
          echo RUN_ID="${GITHUB_RUN_ID}" >> $GITHUB_ENV
          echo WORKING_DIR="$(pwd)" >> $GITHUB_ENV

      - name: Find Secret Names
        run: |
          sfdxURL=$( node ci/workflows/Orchestrations/findSecret.mjs )
          echo "$sfdxURL"
          echo SECRET_NAME="$sfdxURL" >> $GITHUB_ENV
          echo ARTIFACTORY_SECRET_NAME="h-salesforce-np-artifact" >> $GITHUB_ENV

      - name: Retrieve GSM Credentials
        id: secrets
        uses: google-github-actions/get-secretmanager-secrets@main
        with:
          secrets: |-
            sfdxurl:projects/448406129405/secrets/${{ env.SECRET_NAME }}/versions/latest
            artifactory:projects/448406129405/secrets/${{ env.ARTIFACTORY_SECRET_NAME }}/versions/latest
            proxypass:projects/anz-x-bootstrap-np-487e09/secrets/h-salesforce-np-proxy-password/versions/3

      - name: Add secrets to ENV
        run: |
          echo SFDX_URL="${{ steps.secrets.outputs.sfdxurl }}" >> $GITHUB_ENV
          echo ARTIFACTORY_SECRET_VALUE="${{ steps.secrets.outputs.artifactory }}" >> $GITHUB_ENV
          echo WHICH_JOB="quickDeployment" >> $GITHUB_ENV

      - name: Setup HTTP Proxy
        id: "proxy-harness-delegate"
        uses: "anzx/github-reusable-actions/setup-http-proxy@main"
        with:
          production: false
          proxy-username: "sf-harness-delegate-np"
          proxy-password: "${{ steps.secrets.outputs.proxypass }}"

      - name: Run Quick Deployment
        run: |
          node --no-warnings ci/workflows/Orchestrations/quickDeployment.mjs
          echo WHICH_JOB="quickClean" >> $GITHUB_ENV

      - name: Creating new tag and cleaning
        run: |
          node --no-warnings ci/workflows/Orchestrations/quickDeployment.mjs


---------------------------------------------------

** Run All Tests workflow should be like below

name: Run All Local Tests

on:
  pull_request:
    branches:
      - x
    #   - "master"
    # types:
    #   - opened
    #   - reopened
    #   - ready_for_review
    #   - synchronize

permissions:
  contents: "read"
  id-token: "write"

jobs:
  run-all-tests:
    container:
      image: "salesforce-docker.artifactory.gcp.anz/salesforce-delegate:1.2.1"
      options: --user root
    runs-on: [self-hosted, cd-ubuntu-s-np]
    steps:
      - name: NPM package Version | node, sfdx, sf, sgd version
        run: |
          echo "node version: $(node -v)"
          echo "sf version: $(sf -v)"

      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: OIDC Authentication (Salesforce Harness Delegate Service Account)
        id: "authenticate-harness-delegate"
        uses: "anzx/github-reusable-actions/authenticate-gcp@main"
        with:
          service_account: "h-sf-primary-np@anz-x-bootstrap-np-487e09.iam.gserviceaccount.com"

      - name: ENV vars
        run: |
          echo BASE_REF="${{ github.base_ref }}" >> $GITHUB_ENV
          echo PR_NUMBER="${{ github.event.number }}" >> $GITHUB_ENV
          echo WORKING_DIR="$(pwd)" >> $GITHUB_ENV

      - name: Find Proper TargetOrg
        run: |
          echo TARGET_BASE_REF="$( node ci/workflows/Orchestrations/runAllTests.mjs )" >> $GITHUB_ENV
          echo WHICH_JOB="runAllTests" >> $GITHUB_ENV

      - name: Find Secret Names
        run: |
          sfdxURL=$( node ci/workflows/Orchestrations/findSecret.mjs )
          echo "$sfdxURL"
          echo SECRET_NAME="$sfdxURL" >> $GITHUB_ENV
          echo ARTIFACTORY_SECRET_NAME="h-salesforce-np-artifact" >> $GITHUB_ENV

      - name: Find GSM credential
        id: secrets
        uses: google-github-actions/get-secretmanager-secrets@main
        with:
          secrets: |-
            sfdxurl:projects/448406129405/secrets/${{ env.SECRET_NAME }}/versions/latest
            artifactory:projects/448406129405/secrets/${{ env.ARTIFACTORY_SECRET_NAME }}/versions/latest
            proxypass:projects/anz-x-bootstrap-np-487e09/secrets/h-salesforce-np-proxy-password/versions/3

      - name: Add secrets to ENV
        run: |
          echo SFDX_URL="${{ steps.secrets.outputs.sfdxurl }}" >> $GITHUB_ENV
          echo ARTIFACTORY_SECRET_VALUE="${{ steps.secrets.outputs.artifactory }}" >> $GITHUB_ENV

      - name: Setup HTTP Proxy
        id: "proxy-harness-delegate"
        uses: "anzx/github-reusable-actions/setup-http-proxy@main"
        with:
          production: false
          proxy-username: "sf-harness-delegate-np"
          proxy-password: "${{ steps.secrets.outputs.proxypass }}"

      - name: run all tests
        run: |
          node ci/workflows/Orchestrations/runAllTests.mjs
          echo WHICH_JOB="clean" >> $GITHUB_ENV

      - name: cleaning
        run: |
          node ci/workflows/Orchestrations/runAllTests.mjs


---------------------------------------------------

** Release pipeline should be like below

name: Release Pipeline

on:
  workflow_dispatch:
    inputs:
      NAME:
        description: "Release Name"
        required: true
        type: string

permissions:
  contents: "write"
  id-token: "write"

jobs:
  Release:
    container:
      image: "anzx-docker-dev.artifactory.gcp.anz/cd/salesforce-delegate:latest"
      options: --user root
      volumes:
        - ${{ github.workspace }}/release:/opt/harness-delegate/release
    runs-on: [self-hosted, cd-ubuntu-s-prod]
    concurrency:
      group: "salesforce-release"
      cancel-in-progress: true
    strategy:
      max-parallel: 1
      fail-fast: true
      matrix:
        config:
          - DEPLOYMENT_ENVIRONMENT: "prod-release-start"
            DEPLOYMENT_TITLE: "Stage 1: Preprod Deployment Approval"

          - DEPLOYMENT_ENVIRONMENT: "preprod-deployment"
            DEPLOYMENT_TITLE: "Stage 2: Preprod Deployment"

          - DEPLOYMENT_ENVIRONMENT: "prod-validation"
            DEPLOYMENT_TITLE: "Stage 3: Prod Validation Approval"

          - DEPLOYMENT_ENVIRONMENT: "production-validation"
            DEPLOYMENT_TITLE: "Stage 4: Preprod Validation"

          - DEPLOYMENT_ENVIRONMENT: "prod-deployment"
            DEPLOYMENT_TITLE: "Stage 5: Prod Deployment Approval"

          - DEPLOYMENT_ENVIRONMENT: "production-deployment"
            DEPLOYMENT_TITLE: "Stage 6: Prod Deployment"

    environment: "${{ matrix.config.DEPLOYMENT_ENVIRONMENT }}"
    env:
      RELEASE_NAME: "${{ github.event.inputs.NAME }}"
      ARTIFACTORY_SECRET_NAME: "h-salesforce-prod-artifactory"
      PREPROD_SECRET_NAME: "h-salesforce-prod-preprod"
      PROD_CONSUMER_KEY_SECRET_NAME: "h-salesforce-prod-ca-consumerkey"
      PROD_CERT_SECRET_NAME: "h-salesforce-prod-cert"
      APPROVAL_STEP: ${{ matrix.config.DEPLOYMENT_ENVIRONMENT == 'prod-release-start' || matrix.config.DEPLOYMENT_ENVIRONMENT == 'prod-validation' || matrix.config.DEPLOYMENT_ENVIRONMENT == 'prod-deployment' }}
      NOT_APPROVAL_STEP: ${{ matrix.config.DEPLOYMENT_ENVIRONMENT == 'preprod-deployment' || matrix.config.DEPLOYMENT_ENVIRONMENT == 'production-validation' || matrix.config.DEPLOYMENT_ENVIRONMENT == 'production-deployment' }}
      PREPROD_DEPLOYMENT_STEP: ${{ matrix.config.DEPLOYMENT_ENVIRONMENT == 'preprod-deployment' }}
      PROD_VALIDATION_STEP: ${{ matrix.config.DEPLOYMENT_ENVIRONMENT == 'production-validation' }}
      PROD_DEPLOYMENT_STEP: ${{ matrix.config.DEPLOYMENT_ENVIRONMENT == 'production-deployment' }}
      STAGE_NAME: ${{ matrix.config.DEPLOYMENT_ENVIRONMENT }}
    steps:
      - name: Environment Varibales Debug
        run: |
          echo "DEBUG: APPROVAL_STEP=${{ env.APPROVAL_STEP }}"
          echo "DEBUG: NOT_APPROVAL_STEP=${{ env.NOT_APPROVAL_STEP }}"
          echo "DEBUG: PREPROD_DEPLOYMENT_STEP=${{ env.PREPROD_DEPLOYMENT_STEP }}"
          echo "DEBUG: PROD_VALIDATION_STEP=${{ env.PROD_VALIDATION_STEP }}"
          echo "DEBUG: PROD_DEPLOYMENT_STEP=${{ env.PROD_DEPLOYMENT_STEP }}"
          echo "DEBUG: STAGE_NAME=${{ env.STAGE_NAME }}"

      - name: Link SGD plugin
        if: ${{ env.PREPROD_DEPLOYMENT_STEP }}
        run: |
          cd /opt/harness-delegate/.local/share/sf
          sf plugins:link node_modules/sfdx-git-delta/bin

      - name: NPM package Version | node, sfdx, sf, sgd version
        if: ${{ env.PREPROD_DEPLOYMENT_STEP }}
        run: |
          echo "node version: $(node -v)"
          echo "sf version: $(sf -v)"
          echo "sf plugins: $(sf plugins)"

      - name: Checkout
        if: ${{ env.NOT_APPROVAL_STEP }}
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: "OIDC Authentication (Salesforce Harness Delegate Service Account)"
        id: "authenticate-harness-delegate"
        uses: "anzx/github-reusable-actions/authenticate-gcp@main"
        with:
          service_account: "h-sf-primary-prod@anz-x-bootstrap-prod-3b7a6d.iam.gserviceaccount.com"

      - name: "Retrieve GSM Credentials"
        id: secrets
        uses: "google-github-actions/get-secretmanager-secrets@v1"
        with:
          secrets: |-
            preprod:projects/810679854929/secrets/${{ env.PREPROD_SECRET_NAME }}/versions/latest
            prod-consumer-key:projects/810679854929/secrets/${{ env.PROD_CONSUMER_KEY_SECRET_NAME }}/versions/latest
            prod-cert:projects/810679854929/secrets/${{ env.PROD_CERT_SECRET_NAME }}/versions/latest
            artifactory:projects/810679854929/secrets/${{ env.ARTIFACTORY_SECRET_NAME }}/versions/latest
            proxypass:projects/anz-x-bootstrap-prod-3b7a6d/secrets/h-salesforce-prod-proxy-password/versions/1

      - name: "Setup HTTP Proxy (sf-harness-delegate-prod)"
        id: "proxy-harness-delegate"
        uses: "anzx/github-reusable-actions/setup-http-proxy@main"
        with:
          production: true
          proxy-username: "sf-harness-delegate-prod"
          proxy-password: "${{ steps.secrets.outputs.proxypass }}"

      - name: Add genral Secrets to ENV
        if: ${{ env.NOT_APPROVAL_STEP }}
        run: |
          echo SFDX_URL="${{ steps.secrets.outputs.preprod }}" >> $GITHUB_ENV
          echo CONSUMER_KEY_SECRET_VALUE="${{ steps.secrets.outputs.prod-consumer-key }}" >> $GITHUB_ENV
          echo CERT_SECRET_VALUE="${{ steps.secrets.outputs.prod-cert }}" >> $GITHUB_ENV
          echo ARTIFACTORY_SECRET_VALUE="${{ steps.secrets.outputs.artifactory }}" >> $GITHUB_ENV
          echo CLEANING_JOB="false" >> $GITHUB_ENV
          echo WORKING_DIR="$(pwd)" >> $GITHUB_ENV
          lastTag="$( git describe --abbrev=0 --tags --match master* )"
          echo BASE_REF_LAST_TAG="$lastTag" >> $GITHUB_ENV

      - name: Run ${{ matrix.config.DEPLOYMENT_ENVIRONMENT }}
        if: ${{ env.NOT_APPROVAL_STEP }}
        run: |
          node --no-warnings ci/workflows/Orchestrations/release.mjs
          echo CLEANING_JOB="true" >> $GITHUB_ENV

      - name: Cleaning | Create Tag
        if: ${{ env.NOT_APPROVAL_STEP }}
        run: |
          node --no-warnings ci/workflows/Orchestrations/release.mjs

  cleanup:
    name: "cleanup"
    runs-on: [self-hosted, cd-ubuntu-s-prod]
    needs: [Release]
    if: failure() || always()
    steps:
      - name: Cleanup build artifacts
        id: cleanup
        run: |
          if [ -d "${{ github.workspace }}/release" ]; then
            rm -rf "${{ github.workspace }}/release"
          fi
