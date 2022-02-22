# Salesforce End-to-End Automation Testing

**Note: To install the NPM packages on the ANZ network, proxy settings need to be configured. The below articles can assist you with this. The top article also handles the setup of Salesforce.**

- [Salesforce Setup (Initial Proxy Setup)](https://confluence.service.anz/display/ABT/How+to+get+setup+your+laptop+for+Salesforce+development)
- [NPM Proxy setup](https://confluence.service.anz/display/~yero/NPM+Proxy+Setting)

## Project Structure

```txt
├── journeytest
    ├── all-logs
    ├── build
    ├── node_modules
    └── src
        ├── common
        ├── data
        ├── journey
        ├── pageObjects
        ├── scenarios
        └── utam
            ├── auth
            ├── base
            └── lwc

```

## .env file

- The ANZ Salesforce End-to-End testing will test different business and feature scenarios with different user roles.

- Before running the test locally, create a .env file under journeytest folder with following entries so the test script can login into the test environment with correct credentials.

```txt
SALESFORCE_LOGIN_URL=
SALESFORCE_ENV_TEST=test
SALESFORCE_ENV_BAU=anzxbau
COACH_USERNAME=
COACH_PASSWORD=
COACH_LEAD_USERNAME=
COACH_LEAD_PASSWORD=
FRAUD_AGENT_USERNAME=
FRAUD_AGENT_PASSWORD=
```

## Run in Local

1. Switch to jorneytest folder

   ```bash
   cd journeytest
   ```

2. Install dependencies

   ```bash
   npm install
   ```
