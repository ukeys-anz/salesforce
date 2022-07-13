import { Connection, StandardSchema } from "jsforce";
import { RecordTypeAPIName, SObjectAPIName } from "./../constants/enums";
import { loginAsAPIUser, writeToEnv } from "./dataUtils";
import * as faker from "faker";

export const createANZXLead = async (): Promise<void> => {
  // use Qualtrics Automation Test user to query as it has Read All access
  const conn = await loginAsAPIUser("Qualtrics");

  const envVarMap = new Map<string, string>([
    ["firstName", "ANZX_LEAD_FIRST_NAME"],
    ["lastName", "ANZX_LEAD_LAST_NAME"],
    ["mobilePhone", "ANZX_LEAD_MOBILE_PHONE"],
    ["email", "ANZX_LEAD_EMAIL"],
    ["id", "ANZX_LEAD_ID"]
  ]);

  await createLead(conn, envVarMap);
  await conn.logout();
};

export const convertAccountFromLead = async (): Promise<void> => {
  // use Qualtrics Automation Test user to query as it has Lead Read access
  const qualtricsConn = await loginAsAPIUser("Qualtrics");

  const envVarMap = new Map<string, string>([
    ["firstName", "ANZX_LEAD_TO_CONVERT_FIRST_NAME"],
    ["lastName", "ANZX_LEAD_TO_CONVERT_LAST_NAME"],
    ["mobilePhone", "ANZX_LEAD_TO_CONVERT_MOBILE_PHONE"],
    ["email", "ANZX_LEAD_TO_CONVERT_EMAIL"],
    ["id", "ANZX_LEAD_TO_CONVERT_ID"],
    ["accountId", "ANZX_LEAD_TO_CONVERT_ACCOUNT_ID"]
  ]);

  // create Lead
  const leadId = await createLead(qualtricsConn, envVarMap);

  if (leadId) {
    // query above lead data
    const leadToConvert = await qualtricsConn
      .sobject(SObjectAPIName.Lead)
      .findOne(
        {
          Id: { $eq: leadId }
        },
        ["FirstName, LastName, MobilePhone, Email"]
      );

    await qualtricsConn.logout();

    // use OCV Automation Test user to query as it has Account Create access
    const ocvConn = await loginAsAPIUser("OCV");

    // query Person Account record type and id
    const personAccountRT = await ocvConn
      .sobject(SObjectAPIName.Record_Type)
      .findOne(
        {
          DeveloperName: { $eq: RecordTypeAPIName.Person_Account }
        },
        ["Id"]
      );

    const ocvId = faker.datatype
      .number({ min: 1000000000, max: 9999999999 })
      .toString();

    // Construct Account payload
    const accountPayload = {
      FirstName: leadToConvert?.FirstName,
      LastName: leadToConvert?.LastName,
      PersonMobilePhone: leadToConvert?.MobilePhone,
      PersonEmail: leadToConvert?.Email,
      RecordTypeId: personAccountRT?.Id,
      OCV_ID__c: ocvId
    };

    // create Account with same data with above lead
    const saveResult = await ocvConn
      .sobject(SObjectAPIName.Account)
      .create(accountPayload);

    if (!saveResult.success) {
      console.error("Error in creating Account through jsforce API call.");
      console.error("Error: ", JSON.stringify(saveResult.errors));
    } else {
      writeToEnv(envVarMap.get("accountId")!, saveResult.id);
    }

    await ocvConn.logout();
  }
};

const createLead = async (
  conn: Connection<StandardSchema>,
  envVarMap: any
): Promise<string | undefined> => {
  // query ANZX_Leads record type and id
  const anzxLeadsRT = await conn.sobject(SObjectAPIName.Record_Type).findOne(
    {
      DeveloperName: { $eq: RecordTypeAPIName.ANZX_Leads }
    },
    ["Id"]
  );

  const firstName = faker.name.firstName();
  writeToEnv(envVarMap.get("firstName"), firstName);

  const lastName = faker.name.lastName();
  writeToEnv(envVarMap.get("lastName"), lastName);

  const mobilePhone = faker.phone.phoneNumber("04########");
  writeToEnv(envVarMap.get("mobilePhone"), mobilePhone);

  const email = faker.internet.exampleEmail(firstName, lastName);
  writeToEnv(envVarMap.get("email"), email);

  // Construct lead payload
  const leadPayload = {
    FirstName: firstName,
    LastName: lastName,
    MobilePhone: mobilePhone,
    Email: email,
    Marketing_Consent__c: true,
    Privacy_Consent__c: true,
    LeadSource: "Marketing",
    RecordTypeId: anzxLeadsRT?.Id
  };

  const optionHeader = { headers: { "SForce-Auto-Assign": "FALSE" } };

  const saveResult = await conn
    .sobject(SObjectAPIName.Lead)
    .create(leadPayload, optionHeader);

  if (!saveResult.success) {
    console.error("Error in creating Lead through jsforce API call.");
    console.error("Error: ", JSON.stringify(saveResult.errors));
    return;
  } else {
    writeToEnv(envVarMap.get("id"), saveResult.id);

    return saveResult.id;
  }
};
