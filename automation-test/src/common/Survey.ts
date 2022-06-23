import { loginJSForce } from "../utils/apiUtils";
import { navigateToAppAndTab } from "../utils/navigationUtils";
import { App, AppTab } from "../constants/appsDefinition";
import * as commonUtils from "../utils/commonUtils";
import * as casePageUtils from "../utils/casePageUtils";
import ObjectHome from "pageObjects/objectHome";
import { CaseRecord, APIResult } from "../types/survey";
import RecordPage from "pageObjects/recordPage";
import { searchRecordInGlobalSearchAndRedirect } from "../utils/commonUtils";

export default class Survey {
  private ocvId: string | null;

  constructor() {
    this.ocvId = null;
  }

  async createSurveyResponse(): Promise<APIResult | void> {
    const apiResult: APIResult = {
      CaseId: "",
      CaseNumber: "",
      SurveyResId: ""
    };
    // Log in as Qualtrics Integration User
    const conn = await loginJSForce(
      process.env.QUALTRICS_AUTOMATION_USERNAME!,
      process.env.QUALTRICS_AUTOMATION_PASSWORD!
    );

    if (conn) {
      // Get an Acount and its OCV Id
      const account = await conn
        .sobject("Account")
        .find(
          {
            OCV_ID__c: { $ne: null }
          },
          ["Id, OCV_Id__c"]
        )
        .limit(1);

      this.ocvId = account[0].OCV_ID__c;

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

      // Create a survey response
      const optionHeader = { headers: { "SForce-Auto-Assign": "FALSE" } };
      const sr = await conn
        .sobject("qualtrics__Survey_Response__c")
        .create(surveyResponse, optionHeader);
      apiResult.SurveyResId = sr.id!;

      // Get the case that was created for the above survey response
      const returnedCases = await conn
        .sobject("Case")
        .find<CaseRecord>(
          {
            Survey_Response__c: { $eq: sr.id }
          },
          ["Id, CaseNumber"]
        )
        .limit(1);
      apiResult.CaseId = returnedCases[0].Id;
      apiResult.CaseNumber = returnedCases[0].CaseNumber;

      return apiResult;
    }
  }

  async openCase(recordId: string) {
    // Go to Coaches Workbench and Cases tab
    await navigateToAppAndTab(App.Coaches_Workbench, AppTab.Cases);

    // Go to "All Customer Feedback Cases" list view
    await commonUtils.searchAndOpenListViewByName(
      "All Customer Feedback Cases"
    );

    // Search for the created case and click on it
    const objectHomeRoot = await utam.load(ObjectHome);
    await objectHomeRoot.openRecordById(recordId);
  }

  async verifyCase() {
    const baseRecordForm = await casePageUtils.getRecordForm();
    const recordLayout = await baseRecordForm!.getRecordLayout();

    // Assert Priority field
    const priorityField = await commonUtils.getFieldFromRecordLayout(
      recordLayout,
      [2, 4, 2]
    );
    const priority = await (
      await priorityField.getFormattedText()
    ).getInnerText();

    expect(priority).toEqual("Medium");

    // Assert Subject field
    const subjectField = await commonUtils.getFieldFromRecordLayout(
      recordLayout,
      [2, 6, 1]
    );
    const subject = await (
      await subjectField.getFormattedText()
    ).getInnerText();

    expect(subject).toEqual("Detractor 0 -4 - Survey");

    // Assert Case Owner field
    const ownerField = await commonUtils.getFieldFromRecordLayout(
      recordLayout,
      [2, 1, 1]
    );

    const ownerLookup = await ownerField.getOwnerLookup();
    const outputLookup = await ownerLookup.getOutputLookup();
    //TODO: salesforce-pageobjects v1.1.0 force-lookup element does not have method to get Queue text.
    // comment below method out until bug fix.
    // expect(await outputLookup.getText()).toEqual(Queue.Coach_Queue);
  }

  async verifyAccount() {
    const baseRecordForm = await casePageUtils.getRecordForm();
    const recordLayout = await baseRecordForm!.getRecordLayout();

    const accountField = await commonUtils.getFieldFromRecordLayout(
      recordLayout,
      [1, 1, 1]
    );

    //TODO: salesforce-pageobjects v1.1.0 RecordLayoutItem does not have force-lookup element.
    // comment below method out until bug fix.
    // const accountLookupField = await accountField.getOutputField(ForceLookup);
    // await accountLookupField.openLookupLink();

    // search by Account OCV Id from global search as a temp solution for Account redirection.
    // remove after above bug fix
    await searchRecordInGlobalSearchAndRedirect(this.ocvId!);

    const recordPageRoot = await utam.load(RecordPage);
    const accountRecordPage = await recordPageRoot.getAccountRecordPage();
    const advocacyRatingWrapper =
      await accountRecordPage.getAdvocacyRatingWrapper();
    expect(await advocacyRatingWrapper.isVisible()).toBeTruthy();
  }

  async verifySurveyResponse(surveyResponseId: string) {
    const recordPageRoot = await utam.load(RecordPage);
    const accountRecordPage = await recordPageRoot.getAccountRecordPage();

    const financialDetails =
      await accountRecordPage.getPersonAccountFinancialDetails();
    const financialGoals = await financialDetails.getFinancialGoals();
    const financialGoalsRoot = await financialGoals.getRoot();
    await financialGoalsRoot.scrollToTop();

    const surveyResRelatedList =
      await accountRecordPage.getSurveyResponsesRelatedList();
    const firstSurveyRes = await surveyResRelatedList.getItemByIndex(1);
    const rowHeaderLookup = await firstSurveyRes.getRowHeaderLookup();
    const hoverLink = await rowHeaderLookup.getHoverLink();
    await hoverLink.clickLink();

    const domDocument = utam.getCurrentDocument();
    await domDocument.waitFor(async () =>
      (await domDocument.getUrl()).includes("qualtrics__Survey_Response__c")
    );
    expect(
      (await domDocument.getUrl()).includes("qualtrics__Survey_Response__c")
    ).toBeTruthy;
    expect((await domDocument.getUrl()).includes(surveyResponseId)).toBeTruthy;
  }
}
