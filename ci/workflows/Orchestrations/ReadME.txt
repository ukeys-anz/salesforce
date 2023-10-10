*** This will be updated until we test everything

** Validation workflow should be like below

name: Validation

on:
  pull_request:
    branches:
      - develop

jobs:
  validation:
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
      - name: Install npm packages
        run: |
          # git checkout origin/ar-98054-1
          # mv ci.npmrc .npmrc
          # rm -rf node_modules
          npm ci -f
      - name: Install SGD
        run: |
          echo "${{ github.base_ref }} ${{ github.head_ref }}"
          echo y | npx sfdx plugins:install https://artifactory.gcp.anz:443/artifactory/api/npm/npmjs-org/sfdx-git-delta/-/sfdx-git-delta-5.25.2.tgz

      - name: ENV vars
        run: |
          echo BASE_REF="${{ github.base_ref }}" >> $GITHUB_ENV
          echo BRANCH_NAME="${{ github.head_ref }}" >> $GITHUB_ENV
          echo DRAFT_PR="${{ github.event.pull_request.draft }}" >> $GITHUB_ENV
          echo SPECIFIED_TEST_PR="${{ contains( toJson(github.event.pull_request.labels), 'Run Specified Tests') }}" >> $GITHUB_ENV

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

      - name: Add secrets to ENV
        run: |
          echo SFDX_URL="${{ steps.secrets.outputs.sfdxurl }}" >> $GITHUB_ENV
          echo ARTIFACTORY_SECRET_VALUE="${{ steps.secrets.outputs.artifactory }}" >> $GITHUB_ENV

      - name: run Validation
        run: |
          echo WHICH_JOB="validation" >> $GITHUB_ENV
          node ci/workflows/Orchestrations/validation.mjs

      - name: code coverage and cleaning
        run: |
          echo WHICH_JOB="clean" >> $GITHUB_ENV
          node ci/workflows/Orchestrations/validation.mjs
