const { exec } = require("child_process");
const fs = require("fs");

const numberOfScratchOrgs = (command, whichInfo, whatproperty) => {
  exec(command, (err, stdout, stderr) => {
    if (err) {
      console.log(`error: ${err.message}`);
    }
    if (stderr) {
      console.log(`stderr: ${stderr}`);
    }
    if (stdout) {
      let j = JSON.parse(stdout);
      let output = j[whichInfo][whatproperty];
      console.log(output);
    }
  });
};
numberOfScratchOrgs("sfdx force:org:snapshot:list --json", "result", "length");
