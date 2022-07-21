import { navigateToAppAndTab } from "../utils/navigationUtils";
import { App, AppTab } from "../constants/appsDefinition";
import * as commonUtils from "../utils/commonUtils";
import * as casePageUtils from "../utils/casePageUtils";
import ObjectHome from "pageObjects/objectHome";
import RecordPage from "pageObjects/recordPage";
import { Queue } from "../constants/enums";
// @ts-ignore below line has resolving issue, ignore for now
import Lookup from "salesforce-pageobjects/force/pageObjects/lookup";

export default class Survey {
  public id: string | undefined;
  public caseId: string | undefined; // auto created Case Id

  constructor(init?: Partial<Survey>) {
    Object.assign(this, init);
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
    await browser.pause(5000);
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

    //TODO: salesforce-pageobjects v1.2.0 has a bug in lookup po
    // comment for until bug fix
    // expect(await outputLookup.getlookupText()).toEqual(Queue.Coach_Queue);
  }

  async verifyAccount() {
    const baseRecordForm = await casePageUtils.getRecordForm();
    const recordLayout = await baseRecordForm!.getRecordLayout();

    const accountField = await commonUtils.getFieldFromRecordLayout(
      recordLayout,
      [1, 1, 1]
    );

    const accountLookupField = await accountField.getOutputField(Lookup);
    await accountField.waitForOutputField();

    const hoverLink = await (accountLookupField as Lookup).getHoverLink();
    await hoverLink!.clickLink();
    await browser.pause(5000);

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
    await hoverLink!.clickLink();

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
