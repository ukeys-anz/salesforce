import CaseCreationForm from "pageObjects/coachesWorkbenchCaseCreationForm";
import CaseRecordHomeFlexipage from "pageObjects/coachesWorkbenchCaseRecordHomeFlexipage";
import Case from "./Case";
import * as faker from "faker";
import * as caseUtils from "utils/caseUtils";
import * as commonUtils from "utils/commonUtils";

export default class DirectEntry extends Case {
  async createRecord(): Promise<void> {
    const caseCreationFormRoot = await utam.load(CaseCreationForm);

    // Dispute Reason
    await caseUtils.selectPicklistOnCreationForm(
      caseCreationFormRoot,
      [3, 1, 1],
      [2, 6],
      0
    );

    // Description of Issue
    // get field from layout and set text
    const descriptionOfIssue = faker.datatype.string(100);
    await caseCreationFormRoot.editTextarea(3, 2, 1, descriptionOfIssue);

    // Is this a Business Customer?
    await caseUtils.selectPicklistOnCreationForm(
      caseCreationFormRoot,
      [4, 1, 1],
      [2, 3],
      1
    );

    // Channel Received
    await caseUtils.selectPicklistOnCreationForm(
      caseCreationFormRoot,
      [7, 3, 1],
      [2, 25],
      2
    );

    // External System
    await caseUtils.selectPicklistOnCreationForm(
      caseCreationFormRoot,
      [7, 6, 1],
      [2, 4],
      3
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
      [7, 7, 1]
    );
    const externalCaseId = `${faker.datatype.string(10)}`;
    await commonUtils.inputText(externalCaseIdField, externalCaseId);

    // click button twice to get across page stuck
    await baseRecordForm.clickFooterButton("Save");
    await baseRecordForm.clickFooterButton("Save");

    // Status
    // select Closed status
    await commonUtils.selectPicklistOnRecordLayout(recordLayout, [7, 1, 1], 5);

    await baseRecordForm.clickFooterButton("Save");

    await browser.pause(3000);
  }
}
