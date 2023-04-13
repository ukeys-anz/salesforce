const fs = require("fs");
const prettier = require("prettier");
const { exec, execSync } = require("child_process");
var endDir = "./data/ea/dataflows/";

function baseName(str) {
  var base = new String(str).substring(str.lastIndexOf("/") + 1);
  if (base.lastIndexOf(".") != -1)
    base = base.substring(0, base.lastIndexOf("."));
  return base;
}

// Find the Staged Files and only look for WDF files
exec(
  'git diff --staged --name-only | grep ".wdf" ',
  (error, stdout, stderr) => {
    if (stdout == "") {
      console.log("Nothing to EA Prettify");
      process.exit(0);
    }

    if (error) {
      throw "EA Prettier failed:" + error.message;
    }

    //Iterate all the staged files line by line.
    var lines = stdout.split("\n");

    for (var i = 0; i < lines.length; i++) {
      let line = lines[i];

      if (line) {
        let fileext = line.split(".").pop(); //Make sure the ext is WDF only.
        let basename = baseName(line); //Strip the filename
        if (fileext == "wdf") {
          //Get the JSON from the file
          var jsonData = JSON.parse(fs.readFileSync(`${line}`, "utf-8"));

          //Format it
          const v = prettier.format(jsonData[0].toString(), { parser: "json" });
          jsonData[0] = v;

          //Write it to the {endDir} directory
          fs.writeFileSync(`${endDir}${basename}.json`, v.toString());

          //Auto-Stage the newly created files
          execSync(`git add ${endDir}${basename}.json`);

          console.log(`Created: ${endDir}${basename}.json`);
        }
      }
    }
  }
);
