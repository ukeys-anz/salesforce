// This js file will execute some sfdx command --json to check some info out of that
// The `executeInfoFromACommand` function will give us the output that we need.
// The `executeOutput` function will give us the output according to the command that we want
// There are two place in `createSnapshot.sh` that we use this js file: 
//     1- to check how many snapshots do we have | command: sfdx force:org:snapshot:list --json
//     2- to chech if the installation of manage packages has been finished or not | command: sfdx force:mdapi:deploy:report --json


const { exec } = require("child_process");

function executeFunctionArgs(actionName) {
  let command, property;
  if (actionName === "snapshot"){
    command = "sfdx force:org:snapshot:list --json"
    property = "length"
    return executeInfoFromACommand(command,"result", property)
  }else{
    command = "sfdx force:mdapi:deploy:report --json"
    property = "done"
    return executeInfoFromACommand(command, "result", property)
  };
}

function executeInfoFromACommand(command, whichInfo, whatproperty) {
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
