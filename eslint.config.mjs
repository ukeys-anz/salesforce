import lwcConfig from "@salesforce/eslint-config-lwc/recommended.js";
import lockerConfig from "@locker/eslint-config-locker/recommended.js";

export default [
  {
    ignores: ["**/node_modules/**", "**/dist/**", "**/build/**"]
  },
  ...lwcConfig,
  ...lockerConfig,
  {
    rules: {
      "no-undef": "off"
    }
  }
];
