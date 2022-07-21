import jsforce, { Connection, StandardSchema } from "jsforce";
import fs from "fs";
import path from "path";

type ApiUser = "OCV" | "Qualtrics";

const assertUnreachable = (x: never): never => {
  throw new Error(`Didn't expect to get here with x ${x}`);
};

export const loginAsAPIUser = async (apiUser: ApiUser) => {
  let username = "";
  let password = "";

  switch (apiUser) {
    case "OCV":
      username = process.env.OCV_AUTOMATION_USERNAME!;
      password = process.env.OCV_AUTOMATION_PASSWORD!;
      break;
    case "Qualtrics":
      username = process.env.QUALTRICS_AUTOMATION_USERNAME!;
      password = process.env.QUALTRICS_AUTOMATION_PASSWORD!;
      break;
    default:
      assertUnreachable(apiUser);
  }

  const conn = new Connection<StandardSchema>({
    loginUrl: process.env.SALESFORCE_LOGIN_URL
  });

  await conn.login(username, password);
  return conn;
};

export const allTestUserIdsByProfile = async (): Promise<string[]> => {
  // use Qualtrics Automation Test user to query as it has Read All access
  const conn = await loginAsAPIUser("Qualtrics");

  // get ANZx Standard Automation User profile
  const automationProfile = await conn
    .sobject("Profile")
    .findOne({ Name: { $eq: "ANZx Standard Automation User" } }, ["Id"]);

  const allTestUsers = await conn
    .sobject("User")
    .find({ ProfileId: { $eq: automationProfile!.Id } }, ["Id"]);

  await conn.logout();

  return allTestUsers.map((user) => user.Id).filter((id) => id != undefined);
};

export const deleteTestData = async (
  sobjectsToDelete: string[],
  testUserIds: string[]
): Promise<void> => {
  // use Qualtrics Automation Test user to query as it has Modify All access
  const conn = await loginAsAPIUser("Qualtrics");

  for (const so of sobjectsToDelete) {
    // only delete today's test data in case of unexpected accident
    await conn
      .sobject(so)
      .find({
        CreatedById: { $in: testUserIds },
        CreatedDate: { $eq: jsforce.Date.TODAY }
      })
      .destroy();
  }

  await conn.logout();
};

/**
 * @description write new value to .env used in runtime(container or local)
 * @param envKey
 * @param envVal
 */
export const writeToEnv = (envKey: string, envVal: string) => {
  fs.appendFileSync(
    path.join(__dirname, "/../../.env"),
    `${envKey}=${envVal}\n`
  );
};
