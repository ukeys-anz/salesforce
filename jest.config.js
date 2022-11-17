const { jestConfig } = require("@salesforce/sfdx-lwc-jest/config");
module.exports = {
  ...jestConfig,
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
