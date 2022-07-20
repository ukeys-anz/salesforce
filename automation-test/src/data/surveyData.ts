import { SObjectAPIName } from "./../constants/enums";
import { loginAsAPIUser, writeToEnv } from "./dataUtils";

export const createSurvey = async (): Promise<void> => {
  // use Qualtrics Automation Test user to query as it has Read All access
  const conn = await loginAsAPIUser("Qualtrics");

  // Get an Acount and its OCV Id
  const account = await conn
    .sobject(SObjectAPIName.Account)
    .find(
      {
        OCV_ID__c: { $ne: null }
      },
      ["Id, OCV_Id__c"]
    )
    .limit(1);

  const surveyResponse = {
    Name: "Test Survey Response",
    Alerting_Reason__c: "Detractor 0 -4",
    qualtrics__Net_Promoter_Score__c: 3,
    Create_Case__c: true,
    Additional_Feedback__c: "Some addtional feedback",
    Customer_Feedback__c: "Some customer feedback",
    Other_Feedback__c: "Some other feedback",
    OCV_ID__c: account[0].OCV_ID__c,
    qualtrics__Date_Responded__c: new Date().toISOString().split("T")[0]
  };

  // Create a Survey Response
  const optionHeader = { headers: { "SForce-Auto-Assign": "FALSE" } };
  const saveResult = await conn
    .sobject(SObjectAPIName.Survey_Response)
    .create(surveyResponse, optionHeader);

  if (!saveResult.success) {
    console.error(
      "Error in creating Survey Response through jsforce API call."
    );
    console.error("Error: ", JSON.stringify(saveResult.errors));
  } else {
    writeToEnv("SURVEY_ID", saveResult.id);

    // Get the case that was created for the above Survey Response
    const returnedCase = await conn.sobject(SObjectAPIName.Case).findOne(
      {
        Survey_Response__c: { $eq: saveResult.id }
      },
      ["Id"]
    );

    writeToEnv("SURVEY_CASE_ID", returnedCase!.Id);
  }

  await conn.logout();
};
