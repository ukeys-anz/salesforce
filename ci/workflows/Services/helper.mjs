import { execSync } from "child_process";
import {
  readdirSync,
  readFileSync,
  statSync,
  existsSync,
  renameSync,
  rmSync,
  mkdirSync,
  writeFileSync
} from "fs";

import { checkIfTestWhiteListed } from "../Config/validateConfig.mjs";

const renameFile = (oldFilepath, newFilepath) => {
  renameSync(oldFilepath, newFilepath);
  console.log(`${oldFilepath} renamed to ${newFilepath}.`);
};

const runCommand = (command) => {
  try {
    return execSync(command, {
      stdio: "pipe",
      maxBuffer: 1024 * 1024 * 100
    }).toString("utf-8");
  } catch (e) {
    logger("ERROR: " + JSON.parse(e.stdout.toString("utf-8")).message);
  }
};

const runSfCommand = (command) => {
  try {
    return execSync(command, {
      stdio: "pipe",
      maxBuffer: 1024 * 1024 * 100
    }).toString("utf-8");
  } catch (e) {
    logger("ERROR: " + JSON.parse(e.stdout.toString("utf-8")).message);
    process.exit(1);
  }
};

const printContextFromFile = (jobIdFilePath, comment = "") => {
  if (!existsSync(jobIdFilePath)) {
    logger(`There is no jobId. ${comment}`);
    return "";
  }
  return readFileSync(jobIdFilePath).toString();
};

// This will find all files inside a directory.
// Case scenario to use this: Will go through all the changed classes -
// and will find all the specified tests on them, if we want to run specified tests
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

// This will check if a folder exist or not
// Suppose we have chosen run specified test label, -
// but there is no class folder inside artifact. This will check that
const folderExist = (folderPath) => {
  if (!existsSync(folderPath)) {
    logger(`ERROR: The ${folderPath} does not exist.`);
    return false;
  }
  return true;
};

const salesforceDestructiveChanges = (artifactPath) => {
  const destructivePath = "/destructiveChanges/destructiveChanges.xml";
  let allDestructiveChanges = findNamesAndMembersXML(
    artifactPath + destructivePath
  );
  allDestructiveChanges = printXMLNamesAndMembers(allDestructiveChanges);
  return allDestructiveChanges;
};

const salesforceIgnoredDestructiveChanges = (artifactPath) => {
  const destructivePath = "/destructiveChanges/destructiveChanges.xml";
  let allIgnoredDestructiveChanges = findDiffOnXMLs(
    artifactPath + "-all-files" + destructivePath,
    artifactPath + destructivePath
  );
  allIgnoredDestructiveChanges = printXMLNamesAndMembers(
    allIgnoredDestructiveChanges
  );
  return allIgnoredDestructiveChanges;
};

const salesforceFileChanges = (artifactPath) => {
  const packagePath = "/package/package.xml";
  let allChanges = findNamesAndMembersXML(artifactPath + packagePath);
  allChanges = printXMLNamesAndMembers(allChanges);
  return allChanges;
};

const salesforceIgnoredFileChanges = (artifactPath) => {
  const packagePath = "/package/package.xml";
  let allIgnoredChanges = findDiffOnXMLs(
    artifactPath + "-all-files" + packagePath,
    artifactPath + packagePath
  );
  allIgnoredChanges = printXMLNamesAndMembers(allIgnoredChanges);
  return allIgnoredChanges;
};

const canSkipTest = (artifactPath, baseRef) => {
  if (baseRef == "master") {
    return false;
  }
  const packagePath = "/package/package.xml";
  let allChanges = findNamesAndMembersXML(artifactPath + packagePath);
  let canSkipTest = Object.keys(allChanges).every((x) =>
    checkIfTestWhiteListed(x, allChanges[x])
  );

  if (canSkipTest) {
    loggerInStep(
      "All the metadata that is being changed does not require test, hence skipping..."
    );
  }
  return canSkipTest;
};

const salesforceForceAppChangesExist = (artifactPath) =>
  folderExist(artifactPath + "/force-app");

const destructivePackageChangesExist = (artifactPath) =>
  folderExist(artifactPath + "/unpackaged/unpackaged/package.xml");

const moveDestructiveFolderToForceApp = (destructiveFolderpath) => {
  console.log(`move ${destructiveFolderpath} to force-app`);
  execSync(`
    mv ${destructiveFolderpath} force-app
  `);
};

// This will check if there is any salesforce diff on artifact folder or not.
const salesforceDiffExist = (artifactPath) => {
  return (
    salesforceDestructiveChanges(artifactPath) ||
    salesforceForceAppChangesExist(artifactPath)
  );
};

// This will read a file and find all the lines of that.
// To find all the lines with `@runTests` to find all specified tests
const readFileLines = (file) => {
  const content = readFileSync(file).toString();
  return content.split("\n");
};

// This will go through each class file, will find each line of that, and if -
// class contain @runTests, it will find it, and will find the names of the -
// specified classes
const findClassSpecifiedTest = (
  classLines,
  specifidTestSymbol = "runTests"
) => {
  for (let ind = 0; ind < classLines.length; ind++) {
    const line = classLines[ind];
    if (line.indexOf(specifidTestSymbol) > -1) {
      return line.split(specifidTestSymbol)[1].replace(" ", "") + ",";
    }
  }
  return "";
};

// This will find all the specified tests for all of the classes -
// and will add them all together.
// There might be some duplication on tests.
const findAllClassesSpecifiedTests = (classArray) => {
  let specifiedTests = "";
  classArray.forEach((file) => {
    const lines = readFileLines(file);
    const tests = findClassSpecifiedTest(lines);
    specifiedTests += tests;
  });

  return specifiedTests;
};

// This will remove the duplication on specified tests and will return it as an array of specified tests
const findAllSpecifiedTests = (
  classFolderPath = "artifact/force-app/main/default/classes"
) => {
  if (!folderExist(classFolderPath)) process.exit(1);

  const allClasses = findAllFiles(classFolderPath);
  const allSpecifiedTestsArray = [
    ...findAllClassesSpecifiedTests(allClasses).split(",")
  ];
  allSpecifiedTestsArray.pop();

  return [...new Set([...allSpecifiedTestsArray])];
};

const currentDate = () => {
  const dateTime = new Date();
  const day = dateTime.getDate("en-US", "Australia/Sydney");
  const month = dateTime.getMonth("en-US", "Australia/Sydney") + 1;
  const year = dateTime.getFullYear("en-US", "Australia/Sydney");
  return `${day}-${month}-${year}`;
};

const findJobIdFromCommand = (command) => {
  if (!command) return;
  return JSON.parse(command)["result"]["id"];
};

const deleteFolder = (folderPath) => {
  rmSync(folderPath, { recursive: true, force: true }, (err) => {
    if (err) {
      console.error(err);
      return;
    }
  });
};

const renameItem = (folderPath) => folderPath.replaceAll("/", "-");

const createFolder = (folderPath) => {
  mkdirSync(folderPath, (err) => {
    if (err) {
      console.error(err);
      return;
    }
  });
};

const logger = (log) => {
  console.log(
    "\n-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"
  );
  console.log(log);
  console.log("---------------------------------");
  console.log("\n");
};

const loggerInStep = (log) => {
  console.log("=================");
  console.log(log);
  console.log("\n");
};

const booleanMap = (stringBoolean) => stringBoolean === "true";

// This will find all the parent component changes on package/destructiveChange.xml ( eg: ApexClass )
const findNamesOnXML = (filePath) => {
  const destructiveFileLines = readFileLines(filePath);
  let destructiveChangeNames = {};
  let index = 0;

  for (let ind = 0; ind < destructiveFileLines.length; ind++) {
    const line = destructiveFileLines[ind];

    let name = line.split("<name>")[1];
    if (!name) continue;

    name = name.split("</name>")[0];
    destructiveChangeNames[index] = name;
    index++;
  }
  return destructiveChangeNames;
};

// This will find all the component changes on package/destructiveChange.xml ( eg: TSPCondition.cls )
const findMembersOnXML = (filePath) => {
  const destructiveFileLines = readFileLines(filePath);
  let destructiveChangesMembers = {};
  let index = 0;

  for (let ind = 0; ind < destructiveFileLines.length; ind++) {
    const line = destructiveFileLines[ind];

    let name = line.split("<name>")[1];
    if (name) {
      index++;
      continue;
    }

    let member = line.split("<members>")[1];
    if (!member) continue;

    if (!destructiveChangesMembers[index])
      destructiveChangesMembers[index] = [];
    member = member.split("</members>")[0];
    destructiveChangesMembers[index].push(member);
  }
  return destructiveChangesMembers;
};

// This will find all the changes on a parnet components and which components are changed (eg: { ApexClass : [ TSPCondition.cls ] } )
const findNamesAndMembersXML = (filePath) => {
  const names = findNamesOnXML(filePath);
  const members = findMembersOnXML(filePath);
  const result = {};

  for (const key in members) {
    result[names[key]] = members[key];
  }
  return result;
};

// This will find the ignored changed components
const findDiffOnXMLs = (fullChangesFilePath, changesWithIgnoredFilesPath) => {
  const fullXMLJson = findNamesAndMembersXML(fullChangesFilePath);
  const xmlWithIgnoredJson = findNamesAndMembersXML(
    changesWithIgnoredFilesPath
  );
  const diffResult = {};
  for (const key in fullXMLJson) {
    if (!xmlWithIgnoredJson[key]) {
      diffResult[key] = fullXMLJson[key];
      continue;
    }

    const name = fullXMLJson[key];
    const members = xmlWithIgnoredJson[key];

    const diff = name.filter((el) => !members.includes(el));
    if (diff.length) diffResult[key] = diff;
  }
  return diffResult;
};

// This will print the changes from package/destructiveChanges.xml ( eg: ApexClass: TSPCondition )
const printXMLNamesAndMembers = (xmlJsonFile) => {
  let result = "";
  for (const key in xmlJsonFile) {
    result += key + ":\n" + xmlJsonFile[key].join("\n") + "\n";
  }
  return result;
};

const createFile = (context, fileName, whatFile) => {
  console.log(`Create ${whatFile} File`);
  execSync(`
    touch ${fileName}
    printf "${context}" > ${fileName}
  `);
};

// This will update the sf cache json
// For @salesforce/cli, they are using a new logic for each run. There is -
// - a json file which will contain all the jobIds and informations about it.
// Using container will remove this file whenever we raise a new commit. Thus -
// If we want to cancel a job, or check the progress of the running job with more than 33 mins -
// - we should create and update this json file
const updateSfCacheJsonFile = (
  jsonFile,
  jobId,
  anzxCIPackage,
  anzxCIDestructivePackage,
  targetOrg
) => {
  const deployCacheFile = "/github/home/.sf/deploy-cache.json";
  jsonFile[jobId] = {
    manifest: anzxCIPackage,
    "post-destructive-changes": anzxCIDestructivePackage,
    "target-org": `${targetOrg}`,
    wait: 120
  };
  writeFileSync(deployCacheFile, JSON.stringify(jsonFile));
};

// This will update the sf cache json
// For @salesforce/cli, they are using a new logic for each run. There is -
// - a json file which will contain all the jobIds and informations about it.
// Using container will remove this file whenever we raise a new commit. Thus -
// If we want to cancel a job, or check the progress of the running job with more than 33 mins -
// - we should create and update this json file
const createDeployCacheFile = (
  jobId,
  targetOrg,
  anzxCIPackage,
  anzxCIDestructivePackage
) => {
  const deployCacheFile = "/github/home/.sf/deploy-cache.json";
  const deployCacheFileExist = existsSync(deployCacheFile);
  let jsonFile = {};
  if (deployCacheFileExist) {
    const data = readFileSync(deployCacheFile);
    jsonFile = JSON.parse(data);
  }
  updateSfCacheJsonFile(
    jsonFile,
    jobId,
    anzxCIPackage,
    anzxCIDestructivePackage,
    targetOrg
  );
};

const copyFile = (copySourcePath, pasteSourcePath) => {
  logger(`Copy ${copySourcePath} to ${pasteSourcePath}`);
  execSync(`cp "${copySourcePath}" "${pasteSourcePath}"`);
};

const uploadFile = (
  fileName,
  artifactorySecret,
  artifactoryRepoName,
  whatFile
) => {
  if (!folderExist(fileName)) {
    console.log(`Could not find ${fileName} file`);
    process.exit(1);
  }
  console.log(`Upload ${whatFile} File`);
  console.log(
    execSync(
      `curl -H "Authorization: Bearer ${artifactorySecret}" -X PUT -T "${fileName}" "https://artifactory.gcp.anz/artifactory/${artifactoryRepoName}/${fileName}"`
    ).toString("utf8")
  );
};

const downloadFile = (
  fileName,
  artifactorySecret,
  artifactoryRepoName,
  whatFile
) => {
  console.log(`Download ${whatFile} File.`);
  console.log(
    execSync(
      `curl -H "Authorization: Bearer ${artifactorySecret}" -O "https://artifactory.gcp.anz/artifactory/${artifactoryRepoName}/${fileName}"`
    ).toString("utf8")
  );
};

const downloadZipFile = (
  fileName,
  artifactorySecret,
  artifactoryRepoName,
  whatFile
) => {
  console.log(`Download ${whatFile} File.`);
  console.log(
    execSync(
      `curl -H "Authorization: Bearer ${artifactorySecret}" -O "https://artifactory.gcp.anz/artifactory/${artifactoryRepoName}/${fileName}.zip"`
    ).toString("utf8")
  );
};

const unzipFile = (filename) => {
  console.log(`Unzip Zip File`);
  console.log(execSync(`unzip "${filename}.zip"`).toString("utf-8"));
};

const deleteFile = (fileName) => {
  execSync(`rm -f ${fileName}`).toString("utf-8");
};

const findAllArgvs = () => {
  const argvs = process.argv;
  return argvs.slice(2);
};

export {
  runCommand,
  runSfCommand,
  printContextFromFile,
  salesforceDiffExist,
  salesforceForceAppChangesExist,
  destructivePackageChangesExist,
  moveDestructiveFolderToForceApp,
  findAllSpecifiedTests,
  currentDate,
  renameFile,
  findJobIdFromCommand,
  findAllFiles,
  deleteFolder,
  createFolder,
  logger,
  loggerInStep,
  booleanMap,
  createFile,
  uploadFile,
  downloadFile,
  deleteFile,
  folderExist,
  copyFile,
  createDeployCacheFile,
  renameItem,
  downloadZipFile,
  unzipFile,
  salesforceIgnoredDestructiveChanges,
  salesforceDestructiveChanges,
  salesforceFileChanges,
  salesforceIgnoredFileChanges,
  findAllArgvs,
  readFileLines,
  canSkipTest
};
