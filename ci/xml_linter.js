/**
 * @author Mouhamed "Mo" Assafiri
 * @date Sept 2022
 *
 * @description Without any arguments, the linter will do a git diff --staged compare, take all the staged XML files and Lint them automatically.
 * The process will also git add them to your staged files so you don't have to do anything else but commit.
 *
 * @usage  node ./ci/xml_linter.js [--check] [--fix] [--gitbase=HEAD] [--compare=HEAD^1]
 *
 * @param --check: Runs a cofmpare based on the previous commit on the banch (HEAD^) to see if the XML Linting has been run correctly
 * @param --fix: Finds any files which are not linted when compairing the gitbase and will lint them automatically
 * @param --gitbase: Choose the Gitbase to compare for linting
 * @param --compare: (Works with --gitbase) Choose the branch to compare with the base
 */

const { exec, execSync } = require("child_process");
const { exit } = require("process");
const fs = require("fs");
const SaxonJS = require("saxon-js");
const { isError } = require("util");
const { check } = require("prettier");

var checkOnly = false;
var checkAndFix = false;
var gitbase = "HEAD";
var compare = "HEAD^";
var fileCheck = false;
var filename;

// Add to Exclutions to skip over certain files
const EXCLUDES = [
  ".js", //LWC JS Meta as it fails
  ".entitlementProcess",
  ".md-meta", //Remove Custom Meta,
  "quickstart.xml" //Ignore quickstart cause it's non compliant
];

//Usage
process.argv.forEach(function (val, index, array) {
  if (val == "--check") {
    checkOnly = true;
    return;
  }

  if (val == "--fix") {
    checkAndFix = true;
  }

  let args = val.split("=");

  if (args[0] == "--gitbase") {
    gitbase = args[1];
  }

  if (args[0] == "--compare") {
    compare = args[1];
  }

  if (args[0] == "--file") {
    fileCheck = true;
    filename = args[1];
  }
});

var errorHandler = function (error) {
  console.error(error);
  exit(1);
};

//This is the main linting function, it also tests to see if this is the Check Only flag is active
function linter(file, check) {
  if (!check) {
    try {
      var lintedFile = SaxonJS.transform({
        sourceLocation: file,
        stylesheetFileName: "ci/xml_lint.sef.json",
        destination: "serialized"
      });

      // setting indent-spaces in xml_lint.xsl to 4 seems to have no effect. Manually fixing that here.
      // Also file needs to end with \n to match sfdx format.
      fs.writeFileSync(file, lintedFile.principalResult + "\n");

      execSync(`git add "${file}"`);
      console.log(`Linted: ${file}`);
    } catch (err) {
      console.error(`Failed XML Linting ${file}`);
      console.error(err);

      return false;
    }
  } else {
    var lintedFile = SaxonJS.transform({
      sourceLocation: file,
      stylesheetFileName: "ci/xml_lint.sef.json",
      destination: "serialized"
    });

    try {
      let data = fs.readFileSync(file);

      // setting indent-spaces in xml_lint.xsl to 4 seems to have no effect. Manually fixing that here.
      // Also file needs to end with \n to match sfdx format.
      if (lintedFile.principalResult.replace(/   /g, "    ") + "\n" != data) {
        console.error(`${file} is not linted correctly, check your XML Linter`);
        return false;
      }
    } catch (err) {
      console.error(`Failed XML Lint checking: ${file}`);
      console.error(err);

      return false;
    }
  }

  return true;
}

var execCmd = 'git diff --staged --name-only | grep ".xml$"';

if (checkOnly || checkAndFix) {
  execCmd = `git diff ${gitbase} ${compare} --name-only| grep ".xml$"`;
}
if (fileCheck) {
  execCmd = `echo ${filename} | grep ".xml$"`;
}

// Find the Staged Files and only look for WDF files
exec(execCmd, (error, stdout, stderr) => {
  if (stdout == "") {
    console.info("Nothing to XML Lint");
    process.exit(0);
  }

  if (error) {
    throw "XML Linter failed:" + error.message;
  }

  //Iterate all the staged files line by line.
  var lines = stdout.split("\n");

  //If there is one or more error, this bool will flip
  var isError = false;

  for (var i = 0; i < lines.length; i++) {
    let line = lines[i];
    line = decodeURIComponent(line);
    if (line) {
      let fileext = line.split(".").pop(); //Make sure the ext is XML only.

      //Skip any LWC JS Meta as it fails
      if (EXCLUDES.some((ext) => line.includes(ext))) {
        console.log(`Skipping ${line}`);
        continue;
      }

      if (fileext == "xml" && fs.existsSync(line)) {
        if (!linter(line, checkOnly)) {
          isError = true;
        }
      }
    }
  }

  //If isError == true then exit with 1 to fail gracefully
  if (true === isError) {
    console.error(
      `Exiting with error. You can try running 'npm run xml:lint -- --fix --gitbase=${gitbase} --compare=${compare}' to try and lint all the files out of sync`
    );
    process.exit(1);
  }
});
