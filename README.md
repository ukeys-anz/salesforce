![Deploy](https://github.com/anzx/salesforce/workflows/Deploy/badge.svg)
<a href="#badge"><img alt="code style: prettier" src="https://img.shields.io/badge/code_style-prettier-ff69b4.svg?style=flat-square"></a>

# Salesforce

Repository for the Salesforce Customer Relationship Management platform

## Setting up locally

<details>
  <summary>Click to see setup steps</summary>

### 1. Cloning the repository

To clone this repository locally, you need to ensure you add your username into the HTTPS URL. So instead of getting the HTTPS link and entering

```bash
git clone https://github.com/org/repo.git
```

you will need to add your username

```bash
git clone https://USERNAME@github.com/org/repo.git
```

### 2. Setting up tooling

It is not recommended to run Salesforce on WLAN, as most features do not work. You are better off switching to MOBILITY to run Salesforce CLI. To setup local tooling:

1. Download and install Node.js (and NPM)
2. Setup Salesforce CLI, Typescript (used for WebdriverIO) & Prettier by running

```bash
npm i -g sfdx-cli prettier prettier-plugin-apex typescript
```

#### Pre-commit tooling

(Recommended) To ensure that your npm tools are installed, please run

```bash
npm install -- force
```

This will install all the dev dependacies on your local machines, and it will also install a pre-commit hook which runs a script found in `.git-hooks/pre-commit`.
This script runs:

- Prettier on all parsable staged files
- Runs a custom code designed to help with reviewing Einstein Analytics Dataflow JSON
- Runs XML Linting to ensure that any XMLs commited is formatted nicely and ordered alphabetically

If you are experiencing linting errors on your commits, consider looking into the `.git/pre-commit' bash file.

You will see prettier notices in your terminal everytime you run `git-commit`
![Prettier and Git Hooks](https://user-images.githubusercontent.com/73924151/115315255-45aeba80-a1ba-11eb-8633-18aae634eab6.png)

3. Download and install [PMD](https://pmd.github.io/) (use the Quickstart section on the home page)
4. You can use any Text Editor or IDE you choose so long as they run locally. VS Code is recommended by Salesforce and there are several handy plugins found in the VS Code marketplace for syntax highlighter and SFDX CLI integration
5. We use Production as our DevHub, and a DevHub is required in Salesforce CLI to generate scratch orgs. First you need to get your Production credentials setup, then execute

```bash
sfdx force:auth:web:login -r https://anz.my.salesforce.com -a DevHub -d
```

### 3. Creating a scrarch org

There is a pre-written shell script, so to create a scratch org run:

```bash
./setup.sh
```

</details>

## Development Expectations

During the development phase, there are several things to keep in mind:

1. All code that is committed should be _production read_.
2. All code must comply to the Prettier styling standards.
3. All cost must comply to the PMD Quickstart ruleset.
4. Any changes that are critical path must have WebdriverIO integration tests written for them **before** merging.
5. Any broken WebdriverIO test cases as a result of any changes must be resolved by updating the test cases.
6. All features must have unit tests written before merging.

## Release Process

We use GitHub Actions to enable our CICD workflow. The complete CICD solution is documented [here](https://github.com/anzx/documents/blob/design-docs/github-actions-salesforce.md).

To summarise the workflows there are two events:

### Pull Request

When you raise a PR against develop or master, the following three jobs run:

1. **Package and Verify**
   This will build a package that only contains your changes and runs a deployment to systest (develop) or staging (master) with the _check only_ flag set to `TRUE`. This ensures your changes will deploy successfully, and it runs all local tests to ensure we remain compliant in regards to minimum required test coverage.
2. **Lint**
   This step lints all of the files within our project and ensures they are compliant to the Prettier styling convention & ESLint coding rules. For Prettier this includes LWC, Aura and through the Apex Plugin it also lints apex files and for ESLint it is LWC and TypScript files. This ensures consistency and best practise in the way we write code, makes PRs easier to read and extinguishes disagreements over coding styles and formats.
3. **Scan**
   PMD is used to run a code scan to detect poorly written or vulnerable code, as well as ensuring our code conforms to the ApexDoc code documentation specs.

### Merge

When you merge to develop or master, the following runs:

1. **Package and Deploy**
   This will build a package that only contains your changes and runs a deployment to systest (develop) or staging (master) with the _check only_ flag set to `FALSE`. This deploys the changes merged as well as running all tests.

### Other Controls

As part of the PR process, we use CODEOWNERS to enforce that each PR must be reviewed by a CODEOWNER.

Any changes to the org can be reviewed by any member of the team, with a few exceptions. The following changes must be approved by a Lead Engineer or the Chapter Lead:

- Any changes/additions/deletions in the flows and workflows directories
- Changes to the GitHub workflows, including:
  - YAML files
  - Dockerfile
  - Any of the shell scripts within `ci/`

## Feature Traceability

All cards must be linked to the relevant JIRA card number. Following the convention required by the PR Title Checked, starting with ABT-#### or IDR-#### followed by a descriptive title. Example: `ABT-12345 Updates to the Admin Profile`.

We use an internal github action to enforce this format, see https://github.com/anzx/pr-title-action.

## Branch Naming Convention

Please follow the naming convention for all branches:

| Branch type    | Description                                                | Branched off | Merged to | Naming Convention      |
| -------------- | ---------------------------------------------------------- | ------------ | --------- | ---------------------- |
| Feature Branch | Used to create an initial feature                          | `develop`    | `develop` | `feature/feature-name` |
| Develop Branch | Persistent Branch, represents systest                      | N/A          | N/A       | `develop`              |
| Release Branch | Created at the start of each sprint. Represents a release. | `master`     | `master`  | `release/release-name` |
| Master Branch  | Persistent Branch, represents Staging & Production         | N/A          | N/A       | `master`               |

##### Integration

- Please use the following [readme](./force-app/main/default/certs/README.md) to configure certificates on salesforce in scratchorgs for integration with Mulesoft **Dev** environment to work.
