// This js file will run the "sfdx force:org:snapshot:list --json" command
// This will execute the number of existed snapshots
// In snapshotScratch.sh, we have a step that will check the number of snapshots and if --
// -- it we have 5 snapshots, then it will ask the engineer to delete one of them.

const { exec } = require("child_process");
const fs = require("fs");

const executeInfoFromACommand = (command, whichInfo, whatproperty) => {
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
executeInfoFromACommand(
  "sfdx force:org:snapshot:list --json",
  "result",
  "length"
);
