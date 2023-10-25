import { execSync } from "child_process";
import {
  readdirSync,
  readFileSync,
  statSync,
  existsSync,
  rename,
  rmSync,
  mkdirSync,
  writeFileSync
} from "fs";

const renameFile = (oldFilepath, newFilepath) => {
  rename(oldFilepath, newFilepath, (err) => {
    if (err) {
      console.error(err);
    }
    console.log(`${oldFilepath} renamed to ${newFilepath}.`);
  });
};

const runSfCommand = (command) =>
  execSync(command, { stdio: "pipe", maxBuffer: 1024 * 1024 * 10 }).toString(
    "utf-8"
  );

const printContextFromFile = (jobIdFilePath, comment = "") => {
  if (!existsSync(jobIdFilePath)) {
    logger(`ERROR: There is no jobId. ${comment}`);
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

// This will check if there is any salesforce diff on artifact folder or not.
const salesforceDiffExist = (artifactPath) =>
  folderExist(artifactPath + "/force-app");

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

// This will remove the duplication on specified tests and will return it as a class of specified tests
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
  logger(`Delete Folder: ${folderPath}`);
  rmSync(folderPath, { recursive: true, force: true }, (err) => {
    if (err) {
      console.error(err);
      return;
    }
  });
  console.log(`${folderPath} folder is deleted!`);
};

const renameItem = (folderPath) => folderPath.replaceAll("/", "-");

const createFolder = (folderPath) => {
  logger(`Create Folder: ${folderPath}`);
  mkdirSync(folderPath, (err) => {
    if (err) {
      console.error(err);
      return;
    }
  });
  console.log(`${folderPath} folder is created!`);
};

const logger = (log) => {
  console.log("\n-=-=-=-=-=-=-=-=-");
  console.log(log);
  console.log("-----------------");
  console.log("\n");
};

const booleanMap = (stringBoolean) => stringBoolean === "true";

const ignoredFiles = (folderName) => {
  const allChangedFiles = findAllFiles(folderName + "-all-files");
  const notIgnoredFilesChanges = findAllFiles(folderName);
  const ignoredFilesChanges = [];

  allChangedFiles.forEach((file) => {
    const f = file.replace(folderName + "-all-files", folderName);
    if (!notIgnoredFilesChanges.includes(f)) ignoredFilesChanges.push(f);
  });
  logger(`All Changed files:\n${notIgnoredFilesChanges.join("\n")}`);
  logger(
    `All Ignored files:\n${
      ignoredFilesChanges.length ? ignoredFilesChanges.join("\n") : "None"
    }`
  );
};

const createFile = (context, fileName, whatFile) => {
  console.log(`Create ${whatFile} File`);
  execSync(`
    touch ${fileName}
    printf "${context}" > ${fileName}
  `);
};

const updateSfCacheJsonFile = (jsonFile, jobId, anzxCIPackage, targetOrg) => {
  const deployCacheFile = "/github/home/.sf/deploy-cache.json";
  jsonFile[jobId] = {
    manifest: anzxCIPackage,
    "post-destructive-changes": anzxCIPackage,
    "target-org": `${targetOrg}`,
    wait: 120
  };
  writeFileSync(deployCacheFile, JSON.stringify(jsonFile));
};

const createDeployCacheFile = (jobId, targetOrg, anzxCIPackage) => {
  const deployCacheFile = "/github/home/.sf/deploy-cache.json";
  const deployCacheFileExist = existsSync(deployCacheFile);
  let jsonFile = {};
  if (deployCacheFileExist) {
    const data = readFileSync(deployCacheFile);
    jsonFile = JSON.parse(data);
  }
  updateSfCacheJsonFile(jsonFile, jobId, anzxCIPackage, targetOrg);
};

const copyFile = (copySourcePath, pasteSourcePath) => {
  logger(`Copy ${copySourcePath} to ${pasteSourcePath}`);
  execSync(`cp "${copySourcePath}" "${pasteSourcePath}"`);
};

const uploadFile = (fileName, artifactorySecret, whatFile) => {
  if (!folderExist(fileName)) {
    console.log(`Could not find ${fileName} file`);
    process.exit(1);
  }
  console.log(`Upload ${whatFile} File`);
  console.log(
    execSync(
      `curl -H "X-JFrog-Art-Api:${artifactorySecret}" -X PUT -T "${fileName}" "https://artifactory.gcp.anz/artifactory/anzx-salesforce-releases-np/${fileName}"`
    ).toString("utf8")
  );
};

const downloadFile = (fileName, artifactorySecret, whatFile) => {
  console.log(`Download ${whatFile} File.`);
  console.log(
    execSync(
      `curl -H "X-JFrog-Art-Api:${artifactorySecret}" -O "https://artifactory.gcp.anz/artifactory/anzx-salesforce-releases-np/${fileName}"`
    ).toString("utf8")
  );
};

const downloadZipFile = (fileName, artifactorySecret, whatFile) => {
  console.log(`Download ${whatFile} File.`);
  console.log(
    execSync(
      `curl -H "X-JFrog-Art-Api:${artifactorySecret}" -O "https://artifactory.gcp.anz/artifactory/anzx-salesforce-releases-np/${fileName}.zip"`
    ).toString("utf8")
  );
};

const unzipFile = (filename) => {
  console.log(`Unzip Zip File`);
  console.log(execSync(`unzip "${filename}.zip"`).toString("utf-8"));
};

const deleteFile = (fileName) => {
  logger(`Delete File: ${fileName}`);
  execSync(`rm -f ${fileName}`).toString("utf-8");
};

export {
  runSfCommand,
  printContextFromFile,
  salesforceDiffExist,
  findAllSpecifiedTests,
  currentDate,
  renameFile,
  findJobIdFromCommand,
  findAllFiles,
  deleteFolder,
  createFolder,
  logger,
  booleanMap,
  ignoredFiles,
  createFile,
  uploadFile,
  downloadFile,
  deleteFile,
  folderExist,
  copyFile,
  createDeployCacheFile,
  renameItem,
  downloadZipFile,
  unzipFile
};
