const { exec } = require("child_process");
const fs = require("fs");

//Execute sfdx command to get default org as json format
exec("sfdx force:user:list --json", (err, stdout, stderr) => {
  if (err) {
    console.log(`error: ${err.message}`);
    return;
  }
  if (stderr) {
    console.log(`stderr: ${stderr}`);
    return;
  }

  //Parse result
  let result = JSON.parse(stdout).result;

  var users = [];

  result.forEach(el => {
    if (el.alias) {
      exec(
        `sfdx force:org:open -u "${el.alias}" -r --json`,
        (err, stdout, stderr) => {
          if (err) {
            console.log(`error: ${err.message}`);
            return;
          }
          if (stderr) {
            console.log(`stderr: ${stderr}`);
            return;
          }
          let user = JSON.parse(stdout).result;
          let userDetails = {
            alias: el.alias,
            url: user.url
          };
          users.push(userDetails);
          fs.writeFile(
            "webdriverIO/utilities/userList.json",
            JSON.stringify(users),
            err => {
              if (err) {
                throw err;
              }
            }
          );
        }
      );
    }
  });
});
