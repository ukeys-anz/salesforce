const faker = require("faker");
const { exec } = require("child_process");

const email1 = faker.internet.email();
// const email2 = faker.internet.email();
// const email3 = faker.internet.email();
// const email4 = faker.internet.email();

// const users = [
//   {
//     "Username": email1,
//     "LastName": faker.name.lastName(),
//     "Email": email1,
//     "Alias": "Coach",
//     "profileName": "ANZx Standard User",
//     "permsets": ["Coach"],
//     "TimeZoneSidKey": "Australia/Sydney",
//     "LocaleSidKey": "en_US",
//     "EmailEncodingKey": "UTF-8",
//     "LanguageLocaleKey": "en_US"
//   },
//   {
//     "Username": email2,
//     "LastName": faker.name.lastName(),
//     "Email": email2,
//     "Alias": "Content Author",
//     "profileName": "ANZx Standard User",
//     "permsets": ["Content_Author_PSG"],
//     "TimeZoneSidKey": "Australia/Sydney",
//     "LocaleSidKey": "en_US",
//     "EmailEncodingKey": "UTF-8",
//     "LanguageLocaleKey": "en_US"
//   },
//   {
//     "Username": email2,
//     "LastName": faker.name.lastName(),
//     "Email": email2,
//     "Alias": "IDR Level 1",
//     "profileName": "ANZ Standard User",
//     "permsets": ["IDR_Level_1"],
//     "TimeZoneSidKey": "Australia/Sydney",
//     "LocaleSidKey": "en_US",
//     "EmailEncodingKey": "UTF-8",
//     "LanguageLocaleKey": "en_US"
//   },
//   {
//     "Username": email3,
//     "LastName": faker.name.lastName(),
//     "Email": email3,
//     "Alias": "IDR Level 2",
//     "profileName": "ANZ Standard User",
//     "permsets": ["IDR_Level_2"],
//     "TimeZoneSidKey": "Australia/Sydney",
//     "LocaleSidKey": "en_US",
//     "EmailEncodingKey": "UTF-8",
//     "LanguageLocaleKey": "en_US"
//   },
//   {
//     "Username": email4,
//     "LastName": faker.name.lastName(),
//     "Email": email4,
//     "Alias": "IDR Level 3",
//     "profileName": "ANZ Standard User",
//     "permsets": ["IDR_Level_3"],
//     "TimeZoneSidKey": "Australia/Sydney",
//     "LocaleSidKey": "en_US",
//     "EmailEncodingKey": "UTF-8",
//     "LanguageLocaleKey": "en_US"
//   }
// ];

exec(
  `sfdx force:user:create --setalias qa-user --definitionfile config/user-def.json permsets="Coach" Username=${email1} Email=${email1} LastName=${faker.name.lastName()}`,
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
