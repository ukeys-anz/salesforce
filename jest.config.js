const { jestConfig } = require("@salesforce/sfdx-lwc-jest/config");
const setupFilesAfterEnv = jestConfig.setupFilesAfterEnv || [];
setupFilesAfterEnv.push("<rootDir>/ci/jest-sa11y-setup.js");

module.exports = {
  ...jestConfig,
  setupFilesAfterEnv,
  moduleNameMapper: {
    "^lightning/messageService$":
      "<rootDir>/force-app/tests/jest-mocks/lightning/messageService",
    "^lightning/platformShowToastEvent$":
      "<rootDir>/force-app/tests/jest-mocks/lightning/platformShowToastEvent",
    "^lightning/navigation$":
      "<rootDir>/force-app/tests/jest-mocks/lightning/navigation",
    "^lightning/actions$":
      "<rootDir>/force-app/tests/jest-mocks/lightning/actions"
  }
};
