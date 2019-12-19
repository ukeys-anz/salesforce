[![Status](https://ghe-statuses-from-cloud-build.apps.omni.service.test/api/v1/repos/github.service.anz/anzx/salesforce/badges/status/svg?branch=develop)](https://ghe-statuses-from-cloud-build.apps.omni.service.test/api/v1/repos/github.service.anz/anzx/salesforce/badges/status/redirect?branch=develop)

# Salesforce

Repository for the Salesforce Customer Relationship Management platform

## Dev, Build and Test

### Prerequisites

- Setup macBook for ANZ corporate network <https://confluence.service.anz/display/ABT/How+to+get+setup+your+laptop+for+Salesforce+development>
- Install SFDX CLI
- Strongly recommended:
  - Install Visual Studio Code (VSC) and use it :)
  - Install "Salesforce Extension Pack" VSC extension
  - Install "gitflow" VSC extension

### How-to

- Clone the project
- Open in VSC. At some point it'll recognize it as a Salesforce project...
- Authorize a dev hub and set an org
- Open VSC's terminal pane and type ./setup.sh create a Scratch Org to start developing
  - Note this script currently only works OFF the ANZ network because it does a DNS Lookup which fails.

### Git Practices

- We are currently using gitflow with pull requests to merge into develop and master.
- Develop and test in your own Scratch orgs and then commit the changes into a feature branch
- Create your feature branches in `feature` e.g `feature/ABT-71-Add-git-documentation`
- Branch naming conventions: Structure your branch names with a JiraID prefix followed by a short hyphenated description
- The `develop` will be deployed to an integration test environment (CI/CD Pending)
- The `master` branch will be deployed to production (CI/CD Pending)
- More details here <https://confluence.service.anz/display/ABT/How+to+get+started+with+git%2C+Github%2C+and+SFDX>

## Resources

- Refer to the [Technical Knowledge Base](https://confluence.service.anz/display/ABT/Technical+Knowledge+Base)
- Refer to [Issues] for help <https://confluence.service.anz/display/ABT/Salesforce+CLI+%28SFDX%29+Help>

## Description of Files and Directories

TODO

## Issues

- Creating or opening scratch orgs will take a long time
  - Successfully created org with ID: 00D5P0000008d78UAA and name: test-gi7dcuukd39u@example.com. However, the My Domain URL <https://saas-momentum-9000.cs152.my.salesforce.com/> has not finished propagating. Some commands may not work as expected until the My Domain DNS propagation is complete.
  - Waiting to resolve the Lightning Experience-enabled custom domain......

## Updating/recycling secrets
### Non-prod
Ensure you have gcloud SDK installed and that you have encrypt permissions on the key `salesforce-cli-authentication-key` (keyring `cloudbuild-keyring`, location `global`, GCP project `anz-anzx-build-np-f11b9e`).
In an interactive bash session do the following:
1. Change the working directory to the root of this repository.
1. Set the variable `ENV` to either `systest` or `staging`, identifying the systest and staging environments, respectively. `ENV` identifies the environment for which the secret is to be updated.
1. Generate a sfdx auth URL for the environment identified by `ENV`. It should look something like this:
    ```bash
    force://PlatformCLI::********@anz--staging.my.salesforce.com
    ```
1. Run the following commands, making sure to use the sfdx auth URL in place of `********`:
    ```bash
    gcloud config set core/project 'anz-anzx-build-np-f11b9e'
    gcloud kms encrypt \
      --plaintext-file=<(echo -n ‘********’) \
      --ciphertext-file=keys/sfdx-auth-url-"$ENV".encrypted.txt \
      --keyring='cloudbuild-keyring' \
      --key='salesforce-cli-authentication-key' \
      --location='global'
    ```

### Prod
The process is the same as non-prod, but requires access to a different keyring that is yet to be defined.