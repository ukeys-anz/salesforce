import {
  runCommand,
  prodChangeValidation,
  licenceTypeValidation
} from "./helper.mjs";

const createSandbox = (
  sandboxName,
  licenceType,
  username,
  cloneFrom = "Production"
) => {
  prodChangeValidation(username);
  licenceTypeValidation(licenceType);
  const queryMap = {
    Production: `npx sf org create sandbox --name ${sandboxName} --license-type=${licenceType} --target-org ${username} --alias ${sandboxName} --wait 300 --no-prompt --json`,
    "Non-Production": `npx sf org create sandbox --clone ${cloneFrom} --name ${sandboxName} --target-org ${username} --alias ${sandboxName} --wait 300 --no-prompt --json`
  };
  const chosenQuery =
    queryMap[cloneFrom === "Production" ? "Production" : "Non-Production"];

  return runCommand(chosenQuery);
};

export { createSandbox };
