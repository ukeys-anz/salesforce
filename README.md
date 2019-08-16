# salesforce

Repository for the Salesforce Customer Relationship Management platform

## Dev, Build and Test

### Prerequisites

- Install SFDX CLI
- Strongly recommended:
  - Install Visual Studio Code (VSC) and use it :)
  - Install "Salesforce Extension Pack" VSC extension
  - Install "gitflow" VSC extension

### How-to

- Clone the project
- Open in VSC. At some point it'll recognize it as a Salesforce project...
- Authorize a dev hub and set an org
- Open VSC's terminal pane and type ./setup.sh

## Resources

- Git workflows basics
  - <https://www.atlassian.com/git/tutorials/comparing-workflows/feature-branch-workflow>
  - <https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow>
- <https://developer.salesforce.com/tools/sfdxcli>
  - Do *NOT* miss the links in the Getting Started section!
- Salesforce have an extensive online training platform with lots of content particularly around ALM and Salesforce DX (stands for Developer eXperience). Some recommendations:
  - Trailhead modules for Developers and Business Admins:
    - <https://trailhead.salesforce.com/en/content/learn/projects/quickstart-vscode-salesforce> 25 mins
    - <https://trailhead.salesforce.com/en/content/learn/projects/quick-start-salesforce-dx> 40 mins >> this is a good investment of your time
    - <https://trailhead.salesforce.com/en/content/learn/modules/sfdx_app_dev> 3h 15 mins
    - <https://trailhead.salesforce.com/en/content/learn/modules/git-and-git-hub-basics> 1h 50 mins
    - <https://trailhead.salesforce.com/en/content/learn/modules/sfdx_dev_model> 50 mins
  - Trailhead modules for DevOps Engineer: all trailheads above + the ones below
    - <https://trailhead.salesforce.com/content/learn/modules/package-development-readiness> 40 mins
    - <https://trailhead.salesforce.com/en/content/learn/modules/unlocked-packages-for-customers> 55 mins
    - <https://trailhead.salesforce.com/en/content/learn/projects/quick-start-unlocked-packages> 60 mins
    - <https://trailhead.salesforce.com/en/content/learn/modules/sfdx_travis_ci> 1h 40 mins (Travis + Git) >> this would give you a feel for how to build a pipeline with the Salesforce CLI (Command Line Interface)
    - <https://trailhead.salesforce.com/en/content/learn/projects/automate-cicd-with-gitlab> 1h 40 mins (GitLab)

## Description of Files and Directories

TODO

## Issues

- Creating or opening scratch orgs will take long
  - Successfully created org with ID: 00D5P0000008d78UAA and name: test-gi7dcuukd39u@example.com. However, the My Domain URL <https://saas-momentum-9000.cs152.my.salesforce.com/> has not finished propagating. Some commands may not work as expected until the My Domain DNS propagation is complete.
  - Waiting to resolve the Lightning Experience-enabled custom domain......
