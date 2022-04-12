import CaseCreationForm from "pageObjects/coachesWorkbenchCaseCreationForm";
import CaseRecordHomeFlexipage from "pageObjects/coachesWorkbenchCaseRecordHomeFlexipage";
import Case from "./Case";
import * as faker from "faker";
import * as caseUtils from "utils/caseUtils";
import * as commonUtils from "utils/commonUtils";

export default class ATM extends Case {
  async createRecord(): Promise<void> {
    const caseCreationFormRoot = await utam.load(CaseCreationForm);

    // Dispute Reason
    await caseUtils.selectPicklistOnCreationForm(
      caseCreationFormRoot,
      [3, 1, 1],
      [2, 4],
      0
    );

    // Description of Issue
    // get field from layout and set text
    const descriptionOfIssue = faker.datatype.string(100);
    await caseCreationFormRoot.editTextarea(3, 2, 1, descriptionOfIssue);

    // Is The Card Lost
    await caseUtils.selectPicklistOnCreationForm(
      caseCreationFormRoot,
      [3, 5, 1],
      [2, 4],
      1
    );

    // Card In Possession During Transaction
    await caseUtils.selectPicklistOnCreationForm(
      caseCreationFormRoot,
      [3, 6, 1],
      [2, 3],
      2
    );

    // Has The Card Been Stopped
    await caseUtils.selectPicklistOnCreationForm(
      caseCreationFormRoot,
      [3, 7, 1],
      [2, 3],
      3
    );

    // Received Amount
    // get field from layout and set number
    const receivedAmount = faker.datatype.number({ min: 1, max: 100 });
    await caseCreationFormRoot.editNumber(3, 9, 1, receivedAmount.toString());

    // Channel Received
    await caseUtils.selectPicklistOnCreationForm(
      caseCreationFormRoot,
      [4, 3, 1],
      [2, 22],
      4
    );

    // External System
    await caseUtils.selectPicklistOnCreationForm(
      caseCreationFormRoot,
      [4, 6, 1],
      [2, 4],
      5
    );

    // click save button
    await caseCreationFormRoot.saveNew();

    await browser.pause(5000);
  }

  async assignNewOwner(): Promise<void> {
    console.log("Skip Assign a new owner | This scenario does not need it.");
  }

  async updateRecord(): Promise<void> {
    console.log("Update a record |  This scenario does not need it.");
  }

  async closeRecord(): Promise<void> {
    // Coaches Workbench Case Record Page
    const CaseRecordHomeFlexipageRoot = await utam.load(
      CaseRecordHomeFlexipage
    );

    // get record layout
    const detailPanel = await CaseRecordHomeFlexipageRoot.getMainRegionActiveTabDetailPanel();
    const baseRecordForm = await detailPanel.getBaseRecordForm();
    const recordLayout = await baseRecordForm.getRecordLayout();

    // External Case ID
    const externalCaseIdField = await commonUtils.getFieldFromRecordLayout(
      recordLayout,
      [4, 7, 1]
    );
    const externalCaseId = `${faker.datatype.string(10)}`;
    await commonUtils.inputText(externalCaseIdField, externalCaseId);

    // click button twice to get across page stuck
    await baseRecordForm.clickFooterButton("Save");
    await baseRecordForm.clickFooterButton("Save");

    // Status
    // select Closed status
    await commonUtils.selectPicklistOnRecordLayout(recordLayout, [4, 1, 1], 5);

    await baseRecordForm.clickFooterButton("Save");

    await browser.pause(3000);
  }
}
