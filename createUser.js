const faker = require("faker");
const { exec } = require("child_process");
const argv = require("minimist")(process.argv.slice(2));

let permSets, alias, profileName, email, lastName;
lastName = faker.name.lastName();

if (argv.help) {
  console.log(
    "This script creates a user based on the profile you would like."
  );
  console.log("You can use 'node createUser.js --profile <profile>'");
  console.log("The supported profiles are listed below:");
  console.log(
    "Coach\n",
    "Content Author\n",
    "IDR Level 1\n",
    "IDR Level 2\n",
    "IDR Level 3"
  );
  process.exit();
}

switch (argv.profile.toLowerCase()) {
  case "coach":
    permSets = ["Coach"];
    alias = "Coach";
    profileName = "ANZx Standard User";
    email = faker.name.firstName() + lastName + "@anzxtesting.com";
    break;

  case "content author":
    permSets = ["Content_Author_PSG"];
    alias = "ContAuth";
    profileName = "ANZx Standard User";
    email = faker.name.firstName() + lastName + "@anzxtesting.com";
    break;

  case "idr level 1":
    permSets = ["IDR_Level_1"];
    alias = "IDRLvl1";
    profileName = "ANZ Standard User";
    email = faker.name.firstName() + lastName + "@anzxtesting.com";
    break;

  case "idr level 2":
    permSets = ["IDR_Level_2"];
    alias = "IDRLvl 2";
    profileName = "ANZ Standard User";
    email = faker.name.firstName() + lastName + "@anzxtesting.com";
    break;

  case "idr level 3":
    permSets = ["IDR_Level_3"];
    alias = "IDRLvl3";
    profileName = "ANZ Standard User";
    email = faker.name.firstName() + lastName + "@anzxtesting.com";
    break;
  default:
    console.error(
      "Invalid profile provided. Please enter one of the following:"
    );
    console.error(
      "Coach\n",
      "Content Author\n",
      "IDR Level 1\n",
      "IDR Level 2\n",
      "IDR Level 3"
    );
    process.exit();
}

console.log("Assigning permset:", permSets);
console.log("Assigning alias:", alias);
console.log("Assigning profile name:", profileName);
console.log("Assigning email:", email);
console.log("Assigning last name:", lastName);

//Assigning a username for some reason prevents the alias from being set. So we use a auto generated username from SF
exec(
  `sfdx force:user:create --setalias "${alias.toLowerCase()}" --definitionfile config/user-def.json permsets=${permSets} Alias="${alias}" profileName="${profileName}" Email=${email} LastName=${lastName}`,
  (err, stdout, stderr) => {
    if (err) {
      console.log(`error: ${err.message}`);
      return;
    }
    if (stderr) {
      console.log(`stderr: ${stderr}`);
      return;
    }

    console.log(stdout);
  }
);
