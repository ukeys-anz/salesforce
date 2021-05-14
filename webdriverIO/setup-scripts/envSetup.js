const { exec } = require("child_process");
const fs = require("fs");

//Execute sfdx command to get default org as json format
exec("sfdx force:org:display --json", (err, stdout, stderr) => {
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

  //Get access token and instance url
  const accessToken = result.accessToken;
  const instanceUrl = result.instanceUrl;

  //Read .env file
  fs.readFile(`${process.cwd()}/.env`, "utf8", (err, data) => {
    if (err) {
      return console.log(err);
    }

    // Replace the values in the env
    var replacement = data.replace(
      /INSTANCE_URL.*/g,
      `INSTANCE_URL='${instanceUrl}'`
    );
    replacement = replacement.replace(
      /ACCESS_TOKEN.*/g,
      `ACCESS_TOKEN='${accessToken}'`
    );
    replacement = replacement.replace(
      /BASE_URL.*/g,
      `BASE_URL='${instanceUrl}/secur/frontdoor.jsp?sid=${accessToken}'`
    );

    //Write the new values to the env
    fs.writeFile(`${process.cwd()}/.env`, replacement, "utf8", (err) => {
      if (err) return console.log(err);
    });
  });
});
