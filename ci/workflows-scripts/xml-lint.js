const { exec, execSync } = require("child_process");
const { exit } = require("process");
const { readFileSync } = require("fs");
const SaxonJS = require("saxon-js");

//This is the main linting function, it also tests to see if this is the Check Only flag is active
const xmlLinter = (changedFile) => {
  const file = decodeURIComponent(changedFile);
  const lintedFile = SaxonJS.transform({
    sourceLocation: file,
    stylesheetFileName: "ci/xml_lint.sef.json",
    destination: "serialized"
  });

  try {
    const data = readFileSync(file);

    // File needs to end with \n to match salesforce format.
    if (lintedFile.principalResult + "\n" != data) {
      return false;
    }
  } catch (err) {
    return false;
  }
  return true;
};

const checkXMLLint = (files) => {
  const failedFiles = [];
  files.forEach((file) => {
    if (!xmlLinter(file)) {
      failedFiles.push(file);
    }
  });

  return failedFiles.join("\n");
};

const args = process.argv;
const filePath = args[2];
const fileContent = readFileSync(filePath, "utf8");
const changedFiles = JSON.parse(fileContent);
console.log(checkXMLLint(changedFiles));
