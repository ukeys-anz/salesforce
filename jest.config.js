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
      "<rootDir>/force-app/tests/jest-mocks/lightning/actions",
    "^lightning/uiRelatedListApi$":
      "<rootDir>/force-app/tests/jest-mocks/lightning/uiRelatedListApi",
    "^lightning/modal$": "<rootDir>/force-app/tests/jest-mocks/lightning/modal",
    "^lightning/modalHeader$":
      "<rootDir>/force-app/tests/jest-mocks/lightning/modalHeader",
    "^lightning/modalBody$":
      "<rootDir>/force-app/tests/jest-mocks/lightning/modalBody",
    "^lightning/modalFooter$":
      "<rootDir>/force-app/tests/jest-mocks/lightning/modalFooter",
    "^lightning/platformWorkspaceApi$":
      "<rootDir>/force-app/tests/jest-mocks/lightning/platformWorkspaceApi",
    "^lightning/refresh$":
      "<rootDir>/force-app/tests/jest-mocks/lightning/refresh",
    "^c/customerAccountPageCssUtility$":
      "<rootDir>/force-app/main/default/lwc/customerAccountPageCssUtility/customerAccountPageCssUtility.css"
  }
};
