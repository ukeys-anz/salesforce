# Salesforce Cypress Automation

_Salesforce automation test capability_

Primary NPM packages used (installed as dev dependencies):

```
cypress
typescript
faker
```

You may also need to install typescript globally to build and run your tests locally.

**Note: To install the NPM packages on the ANZ network, proxy settings need to be configured. The below articles can assist you with this. The top article also handles the setup of Salesforce.**

- [Salesforce Setup (Initial Proxy Setup)](https://confluence.service.anz/display/ABT/How+to+get+setup+your+laptop+for+Salesforce+development)
- [NPM Proxy setup](https://confluence.service.anz/display/~yero/NPM+Proxy+Setting)

Once you have configured your proxy settings. Simply clone this repo and run `npm install` and the process should work without any issues.

**These tests rely on having a scratch org set up locally and set as the default org in order to work correctly.**

The `cypress.json` file will need to be created in the root of the project to contain the configuration information. You can use the configuration that currently exists in the `cypress.example.json` file which is also located in the root of the project. The `cypress.json` file is ignored as it contains the configuration information for the Cypress project and could potentially contain sensitive data we do not want visible.

All tests are run from a `cypress-build` folder, which is not included. After successfully cloning and installing typescript globally, you can build by running `tsc`/`tsc --build` or use `tsc --watch`.

The build folder will be created and Cypress will use that folder to run all tests. This folder is ignored by git so you don't have to worry about committing it.

**Please ensure that you are modifying the files in the `/cypress` folder and not the `/cypress-build` folder as any changes you make in the build folder wont be committed and will be overwritten next time typescript compiles that folder**

An example test can look like:

```
// Use this as an example of how tests should be laid out.

import { createAccountList } from '../objectStore/account';

before(() => {
    cy.login();
    cy.connect().then((response:any) => {
        cy.log('Creating accounts...')
        createAccountList(response, 1);
        console.log(response)
    })
})
describe('Search', () => {
    it('Searches for account', () => {
        cy.wait(1000);
    });
})
```
