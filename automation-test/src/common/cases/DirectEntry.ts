import CaseCreationForm from "pageObjects/caseCreationForm";
import Case from "./Case";
import * as faker from "faker";
import * as caseUtils from "utils/caseUtils";
import * as commonUtils from "utils/commonUtils";
import caseData from "data/caseData";

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

    // Intended Account BSB
    await caseCreationFormRoot.editText(6, 1, 1, caseData.bsb);

    // Intended Account Number
    await caseCreationFormRoot.editText(6, 2, 1, caseData.checkAccountNumber);

    // Intended Account Name
    await caseCreationFormRoot.editText(6, 3, 1, caseData.accountName);

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
    console.log("Skip assignNewOwner | This scenario does not need it.");
  }

  async updateRecord(): Promise<void> {
    console.log("Skip updateRecord |  This scenario does not need it.");
  }

  async closeRecord(): Promise<void> {
    const baseRecordForm = await caseUtils.getRecordForm();

    if (baseRecordForm) {
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
      await commonUtils.selectPicklistOnRecordLayout(
        recordLayout,
        [7, 1, 1],
        5
      );

      await baseRecordForm.clickFooterButton("Save");

      await browser.pause(3000);
    }
  }
}
