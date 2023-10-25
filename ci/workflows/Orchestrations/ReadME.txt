*** This will be updated until we test everything

** Validation workflow should be like below

name: Salesforce Validation

on:
  pull_request:
    branches:
      - develop

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
          echo BASE_REF="${{ github.base_ref }}" >> $GITHUB_ENV
          echo BRANCH_NAME="${{ github.head_ref }}" >> $GITHUB_ENV
          echo PR_NUMBER="${{ github.event.number }}" >> $GITHUB_ENV
          echo DRAFT_PR="${{ github.event.pull_request.draft }}" >> $GITHUB_ENV
          echo SPECIFIED_TEST_PR="${{ contains( toJson(github.event.pull_request.labels), 'Run Specified Tests') }}" >> $GITHUB_ENV
          echo WORKING_DIR="$(pwd)" >> $GITHUB_ENV

      - name: Find Secret Names
        run: |
          sfdxURL=$( node ci/workflows/Orchestrations/findSecret.mjs )
          echo "$sfdxURL"
          echo SECRET_NAME="$sfdxURL" >> $GITHUB_ENV
          echo ARTIFACTORY_SECRET_NAME="h-salesforce-np-artifactory" >> $GITHUB_ENV

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

          lastTag="$( git describe --abbrev=0 --tags --match $baseRef* )"
          echo BASE_REF_LAST_TAG="$lastTag" >> $GITHUB_ENV

      - name: Find Secret Names
        run: |
          sfdxURL=$( node ci/workflows/Orchestrations/findSecret.mjs )
          echo "$sfdxURL"
          echo SECRET_NAME="$sfdxURL" >> $GITHUB_ENV
          echo ARTIFACTORY_SECRET_NAME="h-salesforce-np-artifactory" >> $GITHUB_ENV

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

      - name: Find Secret Names
        run: |
          sfdxURL=$( node ci/workflows/Orchestrations/findSecret.mjs )
          echo "$sfdxURL"
          echo SECRET_NAME="$sfdxURL" >> $GITHUB_ENV
          echo ARTIFACTORY_SECRET_NAME="h-salesforce-np-artifactory" >> $GITHUB_ENV

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
          echo ARTIFACTORY_SECRET_NAME="h-salesforce-np-artifactory" >> $GITHUB_ENV

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
