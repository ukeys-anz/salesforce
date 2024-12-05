import { exec, execSync } from "child_process";
import {
  readFileSync,
  writeFileSync,
  appendFileSync,
  readdirSync,
  statSync
} from "fs";

const runCommand = (command) =>
  execSync(command, { stdio: "pipe", maxBuffer: 1024 * 1024 * 10 }).toString(
    "utf-8"
  );

const changeForceIgnoreFile = (changeOrRevert) => {
  if (changeOrRevert === "Change") {
    execSync(`
      mv .forceignore ci.forceignore
      touch .forceignore
    `);
  } else {
    execSync(`
      rm -rf .forceignore
      mv ci.forceignore .forceignore
    `);
  }
};

const readFileLines = (file) => {
  const content = readFileSync(file).toString();
  return content.split("\n");
};

const retrieveComponent = (filepath, username) => {
  runCommand(
    `sf project retrieve start -o ${username} --manifest "${filepath}" --ignore-conflicts`
  );
};

const findAllFiles = (dir, files = []) => {
  // Get an array of all files and directories in the passed directory using fs.readdirSync
  const fileList = readdirSync(dir);
  // Create the full path of the file/directory by concatenating the passed directory and file/directory name
  for (const file of fileList) {
    const name = `${dir}/${file}`;
    // Check if the current file/directory is a directory using statSync
    if (statSync(name).isDirectory()) {
      // If it is a directory, recursively call the getFiles function with the directory path and the files array
      findAllFiles(name, files);
    } else {
      // If it is a file, push the full path to the files array
      files.push(name);
    }
  }
  return files;
};

const changeMetadata = (line, newMetadata) => {
  if (!line) return;
  const changeMetadataMapping = {};
  changeMetadataMapping[line.includes("<certificate>")] =
    `<certificate>${newMetadata}</certificate>`;
  changeMetadataMapping[
    line.includes("username") && !line.includes("consumerId")
  ] = `<username>consumerId</username>`;
  changeMetadataMapping[
    line.includes("password") && !line.includes("consumerKey")
  ] = `<password>consumerKey</password>`;
  changeMetadataMapping[
    line.includes("<callbackUrl>") &&
      !line.includes("http://localhost:1717/OauthRedirect")
  ] = `<callbackUrl>http://localhost:1717/OauthRedirect</callbackUrl>`;
  changeMetadataMapping[
    line.includes("jwtSigningCertificate") &&
      !line.includes("DummyCertificate_ToBechanged")
  ] = `<jwtSigningCertificate>${newMetadata}</jwtSigningCertificate>`;
  changeMetadataMapping[
    (!line.includes(">") && !line.includes("</")) ||
      (line.includes("</callbackUrl>") && !line.includes("<callbackUrl>"))
  ] = "";
  changeMetadataMapping[
    line.includes("<url>https://anz--") &&
      line.includes("omnistudio") &&
      line.includes(".visual.force.com</url>") &&
      !line.includes(
        `<url>https://anz--${newMetadata}--omnistudio.sandbox.vf.force.com</url>`
      )
  ] = `<url>https://anz--${newMetadata}--omnistudio.sandbox.vf.force.com</url>`;
  changeMetadataMapping[
    line.includes("<url>https://anz") &&
      line.includes(".lightning.force.com</url>") &&
      !line.includes(
        `<url>https://anz--${newMetadata}.sandbox.lightning.force.com</url>`
      )
  ] = `<url>https://anz--${newMetadata}.sandbox.lightning.force.com</url>`;
  return changeMetadataMapping["true"];
};

const updateMetadataOnComponent = (filePath, newMetadata) => {
  const lines = readFileLines(filePath);
  let flag = false;
  writeFileSync(filePath, "");
  for (let line of lines) {
    const changedMetadata = changeMetadata(line, newMetadata);
    if (changedMetadata || changedMetadata === "") {
      line = changedMetadata;
      flag = true;
    }
    if (line !== "") appendFileSync(filePath, line + "\n");
  }
  return flag;
};

const deployFile = (path, username) => {
  runCommand(`
    sf project deploy start -o ${username} --source-dir "${path}" --ignore-conflicts
  `);
};

const deployFiles = (files, username) => {
  files.forEach((f) => deployFile(f, username));
};

const removeCert = (files, username) => {
  files.forEach((f) => {
    if (
      !f.includes("DummyCertificate_ToBechanged") &&
      !f.toLowerCase().includes("readme") &&
      f.includes("-meta.xml")
    ) {
      console.log(`try to remove: ${f}`);
      runCommand(`
        echo "y" | sf project delete source -o ${username} --source-dir "${f}"
      `);
    }
  });
};

const changeCertsOnFiles = (files) => {
  files.forEach((f) => {
    const flag = updateMetadataOnComponent(f, "DummyCertificate_ToBechanged");
    if (flag) {
      console.log(`change on: ${f}`);
    }
  });
};

const discardGitChanges = () => runCommand(`git checkout .`);

const findAllUsernamesFromAlias = (usernameOrAlias) => {
  if (usernameOrAlias.includes("@anzx.com")) return usernameOrAlias;
  let aliasJsonFile = runCommand(`sf alias list --json`);
  aliasJsonFile = JSON.parse(aliasJsonFile);
  if (aliasJsonFile.result.length === 0) {
    console.error("No authenticated org found.");
    process.exit(1);
  }

  return aliasJsonFile.result.find((re) => re.alias === usernameOrAlias)?.value;
};

const isNPUsernameValid = (usernameOrAlias) => {
  const username = findAllUsernamesFromAlias(usernameOrAlias);
  if (!username) {
    console.error(
      `No authenticated org with ${usernameOrAlias} username/alias is found.`
    );
    process.exit(1);
  }

  const lowerCaseUsername = username.toLowerCase();
  console.log(`The username is: ${lowerCaseUsername}`);
  return (
    lowerCaseUsername.includes("@anzx.com") &&
    lowerCaseUsername.includes("@anzx.com.")
  );
};

const isNPInstanceUrlValid = (usernameOrAlias) => {
  let orgDisplayUserJson = runCommand(
    `sf org display user -o ${usernameOrAlias} --json`
  );
  orgDisplayUserJson = JSON.parse(orgDisplayUserJson);
  if (orgDisplayUserJson.result.length === 0) {
    console.error("No authenticated org found.");
    process.exit(1);
  }

  const instanceURL = orgDisplayUserJson.result.instanceUrl;
  console.log(`The instance url is: ${instanceURL}`);
  return instanceURL.includes("sandbox");
};

const nonProdChangeValidation = (usernameOrAlias) => {
  if (
    !isNPUsernameValid(usernameOrAlias) ||
    !isNPInstanceUrlValid(usernameOrAlias)
  ) {
    console.error(`ERROR: ${usernameOrAlias} is a Production username/alias`);
    process.exit(1);
  }
};

const prodChangeValidation = (usernameOrAlias) => {
  if (
    isNPUsernameValid(usernameOrAlias) ||
    isNPInstanceUrlValid(usernameOrAlias)
  ) {
    console.error(
      `ERROR: ${usernameOrAlias} is not a Production username/alias`
    );
    process.exit(1);
  }
};

const licenceTypeValidation = (licenceType) => {
  const validLicences = ["Developer", "Developer_Pro"];
  if (!validLicences.includes(licenceType)) {
    console.error(`Licence Type is not valid: ${licenceType}`);
    console.error(
      'Licence Type should be either "Developer" or "Developer_Pro"'
    );
    process.exit(1);
  }
};

const setAlias = (username, alias) =>
  runCommand(`
  sf alias set "${alias}" "${username}"
`);

export {
  findAllFiles,
  deployFile,
  deployFiles,
  changeForceIgnoreFile,
  retrieveComponent,
  changeCertsOnFiles,
  removeCert,
  discardGitChanges,
  runCommand,
  nonProdChangeValidation,
  prodChangeValidation,
  licenceTypeValidation,
  updateMetadataOnComponent,
  setAlias
};
