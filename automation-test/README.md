# Salesforce End-to-End Automation Testing

**Note: To install the NPM packages on the ANZ network, proxy settings need to be configured. The below articles can assist you with this. The top article also handles the setup of Salesforce.**

- [Salesforce Setup (Initial Proxy Setup)](https://confluence.service.anz/display/ABT/How+to+get+setup+your+laptop+for+Salesforce+development)

- [NPM Proxy setup](https://confluence.service.anz/display/~yero/NPM+Proxy+Setting)

## Project Structure

```txt
├── automation-test
    ├── all-logs
    ├── build
    ├── node_modules
    └── src
        ├── common
        ├── data
        ├── pageObjects
        ├── tests
        ├── utam
        |   ├── auth
        |   ├── base
        |   └── lwc
        └── utils

```

- `tests` folder contains the test spec files and test running will look for those files for testing

- `utils` folder groups reusable methods

- `common` folder contains specific interaction scnearios used in test spec files. Some of these scenario can be reused in different test spec files.

- `utam` folder will be the place to maintain \*.utam.json and utam compiler will compile these files into page objects in pageObjects folder (git ignored)

## Prerequisites

### chromedriver

- install chromedriver

  ```bash
  npm install -g chromedriver --detect_chromedriver_version
  ```

OR, if above command does not work, follow below:

- Download Mac chromedriver from this [website](https://sites.google.com/chromium.org/driver/downloads). Ensure that the driver you downloaded is for the chrome version you have installed on your computer. If the driver and chrome version does not match the automation will fail.

- Run below command to install the downloaded zip. Change the path in the command if needed.

  ```bash
  npm install -g chromedriver --chromedriver_filepath=/Path/Downloads/chromedriver_mac64.zip
  ```

### yarn

- install yarn if haven't done yet. See [here](https://classic.yarnpkg.com/lang/en/docs/install/#mac-stable)

  ```bash
  npm install --global yarn
  ```

### .env file

- The ANZ Salesforce End-to-End testing will test different business and feature scenarios with different user roles.

- Before running the test locally, create a .env file under journeytest folder with following entries so the test script can login into the test environment with correct credentials.

  ```txt
  SALESFORCE_LOGIN_URL=test.salesforce.com
  SALESFORCE_ENV_BASE=
  COACH_USERNAME=
  COACH_PASSWORD=
  COACH_LEAD_USERNAME=
  COACH_LEAD_PASSWORD=
  FRAUD_AGENT_USERNAME=
  FRAUD_AGENT_PASSWORD=
  TWILIO_USERNAME=
  TWILIO_PASSWORD=
  ```

- **`For now engineers need to get test users' credentials and store in .env file. Please be mindful and DO NOT commit these credentials. This practice will be replaced in the future once the security store integration for automation is ready`**

- In .env file, the `SALESFORCE_ENV_BASE` variable is used to control in which org the test will be running. For now the only supported value is `test` as we will run the automation in test sandbox first.

- The `SALESFORCE_ENV_BASE` also format the testing users' username. For exmaple: if `COACH_USERNAME` is `testusername@anzx.com`, `COACH_USERNAME` + `'.'` + `SALESFORCE_ENV_BASE` will format the username to `testusername@anzx.com.test` during automation auth process.

## Run in Local

1. Switch to jorneytest folder if you are not in

   ```bash
   cd journeytest
   ```

2. Turn off ANZ VPN

3. Install dependencies

   ```bash
   npm install
   ```

4. Change wdio.conf.js, “goog:chromeoptions” and comment headless from the argument list, leave other arguments as is

   ```txt
   "goog:chromeOptions": {
    args: [
      // "--headless"
    ]
   }
   ```

5. Build locally

   ```bash
   npm run build
   ```

6. (optional) ReBuild and update pageObjects files if any \*.utam.json files have been edited

   ```bash
   npm run build:utam
   ```

7. (optional) ReBuild and update test code files if any \*.ts files have been edited

   **note:** You can also use _watch_ mode of TS while coding

   ```bash
   npm run build:ts
   ```

8. run locally

   ```bash
   ./journeytest.sh
   ```
