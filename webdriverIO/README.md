# Salesforce WebdriverIO Automation

_Salesforce automation test capability_

Primary NPM packages used (installed as dev dependencies):

```
@wdio/cli
typescript
faker
```

You may also need to install typescript globally to build and run your tests locally.

**Note: To install the NPM packages on the ANZ network, proxy settings need to be configured. The below articles can assist you with this. The top article also handles the setup of Salesforce.**

- [Salesforce Setup (Initial Proxy Setup)](https://confluence.service.anz/display/ABT/How+to+get+setup+your+laptop+for+Salesforce+development)
- [NPM Proxy setup](https://confluence.service.anz/display/~yero/NPM+Proxy+Setting)

Once you have configured your proxy settings. Simply clone this repo and run `npm install` and the process should work without any issues.

**These tests rely on having a scratch org set up locally and set as the default org in order to work correctly.**

```bash
npm install

tsc --build

mv .env.example .env
```

To correctly set the values in the `.env` file, run `node webdriverURLsetup.js`. This will overwrite the current values in the `.env` to get the most recent session details for your salesforce org.

All tests are run from a `webdriverIO-build` folder, which is not included. After successfully cloning and installing TypeScript globally, the folder is built by running `tsc`/`tsc --build` or alternatively you can use `tsc --watch` if you are making changes to the TypeScript files.

The build folder will be created and WebdriverIO will use that folder to run all tests. This folder is ignored by git so you don't have to worry about committing it.

The tests can be run using `npm test`. This will setup the `.env` and also build everything before the tests run.

If you would like to run a single test, you can use `npx wdio webdriverIO-build/wdio.conf.js --spec webdriverIO-build/test/specs/{path to test}`.

The tests by default are run headless, however this can be changed by modifying the `wdio.conf.js` file. Under the _browser capabilities_ section, you can find the following line of config: `args: ["--headless", "--disable-gpu"]`. If you comment this out, the tests won't be run headless.

**Please ensure that you are modifying the files in the `/webdriverIO` folder and not the `/webdriverIO-build` folder as any changes you make in the build folder wont be committed and will be overwritten next time typescript compiles that folder**

An example test can look like:

```
// Use this as an example of how tests should be laid out.

/*** BASE IMPORTS ***/
import CoachesWorkbench from "../../../../pages/getHelp/coachesWorkbench";
import GeneralInquiry from "../../../../pages/getHelp/edit/generalInquiry";

/*** OBJECT STORE IMPORTS ***/
import { createCaseList } from "../../../../objectStore/case";

/*** DECLARATIONS ***/
let caseNumber: String;
let recordType: String = "General_Inquiry";

describe("General Inquiry Record Resolved", () => {
  before(() => {
    createCaseList(1, recordType).then((cases: any) => {
      caseNumber = cases[0].CaseNumber;
    });
  });

  it("should resolve a general inquiry case record", () => {
    CoachesWorkbench.login();
    CoachesWorkbench.loadApp("Coaches Workbench");
    CoachesWorkbench.navCases.click();
    $(`.forceOutputLookup[title="${caseNumber}"]`).click();
    $('=Edit').click();

    GeneralInquiry.status.click();
    $('a[role="menuitemradio"]=Closed').click();

    GeneralInquiry.save.click();

    const toastMessage = $(".forceToastMessage");
    expect(toastMessage).toBeVisible();
  });
});
```
