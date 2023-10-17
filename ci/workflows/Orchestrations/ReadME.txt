*** This will be updated until we test everything

** Validation workflow should be like below

name: validationTEST

on:
  pull_request:
    branches:
      - develop

jobs:
  validationTEST:
    runs-on: [self-hosted, salesforce-prod]
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Setup Node.js
        uses: actions/setup-node@v2
        with:
          node-version: 18

      - name: ENV vars
        run: |
          echo BASE_REF="${{ github.base_ref }}" >> $GITHUB_ENV
          echo BRANCH_NAME="${{ github.head_ref }}" >> $GITHUB_ENV
          echo DRAFT_PR="${{ github.event.pull_request.draft }}" >> $GITHUB_ENV
          echo SPECIFIED_TEST_PR="${{ contains( toJson(github.event.pull_request.labels), 'Run Specified Tests') }}" >> $GITHUB_ENV

      - name: Find Secret Names
        run: |
          # sfdxURL=$( node --no-warnings ci/workflows/Orchestrations/findSecret.mjs )
          # echo "$sfdxURL"

          echo SECRET_NAME="ghr-salesforce-prod-salesforce-sysl-np" >> $GITHUB_ENV
          echo ARTIFACTORY_SECRET_NAME="h-salesforce-np-artifactory" >> $GITHUB_ENV

      - name: Retrieve GSM Credentials
        id: secrets
        uses: google-github-actions/get-secretmanager-secrets@main
        with:
          secrets: |-
            sfdxurl:projects/36540621485/secrets/${{ env.SECRET_NAME }}/versions/latest

      - name: Add secrets to ENV
        run: |
          echo SFDX_URL="${{ steps.secrets.outputs.sfdxurl }}" >> $GITHUB_ENV
          # echo ARTIFACTORY_SECRET_VALUE="${{ steps.secrets.outputs.artifactory }}" >> $GITHUB_ENV

      - name: cleaning
        run: |
          pwd
          mv ci.npmrc .npmrc
          # npm uninstall sfdx-cli -f
          rm -rf node_modules
          npm ci -f

      - name: Install SGD
        run: |
          echo "${{ github.base_ref }} ${{ github.head_ref }}"
          echo y | npx sfdx plugins:install https://artifactory.gcp.anz:443/artifactory/api/npm/npmjs-org/sfdx-git-delta/-/sfdx-git-delta-5.25.2.tgz

      - name: run Validation
        run: |
          node --no-warnings ci/workflows/Orchestrations/validation.mjs
          echo WHICH_JOB="clean" >> $GITHUB_ENV

      - name: code coverage and cleaning
        run: |
          node --no-warnings ci/workflows/Orchestrations/validation.mjs


---------------------------------------------------

** Deployment workflow should be like below

name: DeploymentTest

on:
  pull_request:
    branches:
      - develop

jobs:
  deploymentTest:
    runs-on: [self-hosted, salesforce-prod]
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0
          ref: ${{ github.ref }}

      - name: Setup Node.js
        uses: actions/setup-node@v2
        with:
          node-version: 18

      - name: ENV vars
        run: |
          #baseRef="$(echo ${GITHUB_REF#refs/heads/})"
          baseRef="${{ github.base_ref }}"
          echo BASE_REF="${baseRef}" >> $GITHUB_ENV
          echo RUN_ID="${GITHUB_RUN_ID}" >> $GITHUB_ENV

          lastTag="$( git describe --abbrev=0 --tags --match $baseRef* )"
          echo BASE_REF_LAST_TAG="$lastTag" >> $GITHUB_ENV

      - name: Find Secret Names
        run: |
          # sfdxURL=$( node --no-warnings ci/workflows/Orchestrations/findSecret.mjs )
          # echo "$sfdxURL"

          echo SECRET_NAME="ghr-salesforce-prod-salesforce-sysl-np" >> $GITHUB_ENV
          echo ARTIFACTORY_SECRET_NAME="h-salesforce-np-artifactory" >> $GITHUB_ENV

      - name: Retrieve GSM Credentials
        id: secrets
        uses: google-github-actions/get-secretmanager-secrets@main
        with:
          secrets: |-
            sfdxurl:projects/36540621485/secrets/${{ env.SECRET_NAME }}/versions/latest
        #sfdxurl:projects/448406129405/secrets/${{ env.SECRET_NAME }}/versions/latest
      - name: Add secrets to ENV
        run: |
          echo SFDX_URL="${{ steps.secrets.outputs.sfdxurl }}" >> $GITHUB_ENV
          # echo ARTIFACTORY_SECRET_VALUE="${{ steps.secrets.outputs.artifactory }}" >> $GITHUB_ENV

      - name: cleaning
        run: |
          pwd
          mv ci.npmrc .npmrc
          # npm uninstall sfdx-cli -f
          rm -rf node_modules
          npm ci -f

      - name: Install SGD
        run: |
          echo y | npx sfdx plugins:install https://artifactory.gcp.anz:443/artifactory/api/npm/npmjs-org/sfdx-git-delta/-/sfdx-git-delta-5.25.2.tgz

      - name: run Deployment
        run: |
          node --no-warnings ci/workflows/Orchestrations/deployment.mjs
          echo WHICH_JOB="clean" >> $GITHUB_ENV

      - name: show me the file changed
        run: |
          cat artifact-"${{ github.base_ref }}"-"${GITHUB_RUN_ID}"/force-app/main/default/classes/transactionSecurity/TSPCondition.cls
      - name: create tag and cleaning
        run: |
          node --no-warnings ci/workflows/Orchestrations/validation.mjs


---------------------------------------------------

** Run All Tests workflow should be like below

name: Run All Tests

on:
  pull_request:
    branches:
      - master

jobs:
  run-all-tests:
    runs-on: [self-hosted, salesforce-prod]
    steps:
      - name: Checkout
        uses: actions/checkout@v2
        with:
          fetch-depth: 0

      - name: Setup Node.js
        uses: actions/setup-node@v2
        with:
          node-version: 18

      - name: cleaning
        run: |
          mv ci.npmrc .npmrc
          # npm uninstall sfdx-cli -f
          rm -rf node_modules
          npm ci -f

      - name: ENV vars
        run: |
          echo BASE_REF="${{ github.base_ref }}" >> $GITHUB_ENV

      - name: Find Secret Names
        run: |
          sfdxURL=$( node ci/workflows/Orchestrations/findSecret.mjs )
          echo "$sfdxURL"
          echo SECRET_NAME="$sfdxURL" >> $GITHUB_ENV

      - name: Find GSM credential
        id: secrets
        uses: google-github-actions/get-secretmanager-secrets@main
        with:
          secrets: |-
            sfdxurl:projects/448406129405/secrets/${{ env.SECRET_NAME }}/versions/latest

      - name: Add secrets to ENV
        run: |
          echo SFDX_URL="${{ steps.secrets.outputs.sfdxurl }}" >> $GITHUB_ENV

      - name: run all tests
        run: |
          echo WHICH_JOB="runAllTests" >> $GITHUB_ENV
          node ci/workflows/Orchestrations/runAllTests.mjs

      - name: cleaning
        run: |
          echo WHICH_JOB="clean" >> $GITHUB_ENV
          node ci/workflows/Orchestrations/runAllTests.mjs
