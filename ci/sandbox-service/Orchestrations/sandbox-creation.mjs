// Create a new sandbox using engineer username
// Engineers should raise a PAM and when it is approved and they have -
// System Admin as profile, they can run this

/// Import different function from services.
import { createSandbox } from "../Services/spin-sandbox.mjs";
///////////

/// Hardcoded username input
const SANDBOX_NAME = "";
const LICENCE_TYPE = "Developer";
const PROD_USER_NAME = "";
const CLONED_FROM = "Production";
////////

/// functions

// This function will:
//   - Validate the username should be prod username
//   - Validate the licence type should be "Developer" or "Developer_Pro"
//   - Creare the new sandbox
const sandboxCreation = () =>
  createSandbox(SANDBOX_NAME, LICENCE_TYPE, PROD_USER_NAME, CLONED_FROM);

// Run Orchestration

const runSandboxCreation = () => {
  return sandboxCreation();
};

runSandboxCreation();
