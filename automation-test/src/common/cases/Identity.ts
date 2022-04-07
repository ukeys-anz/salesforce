import CaseCreationForm from "pageObjects/caseCreationForm";
import { CaseType } from "constants/enums";
import Case from "./Case";
import caseData from "data/caseData";
import * as commonUtils from "utils/commonUtils";
import * as caseUtils from "utils/caseUtils";

export default class Identity extends Case {
  async createRecord(): Promise<void> {
    const caseCreationFormRoot = await utam.load(CaseCreationForm);
    await caseCreationFormRoot.selectCaseRecordType(CaseType.IDENTITY);

    // Account Name
    // search and select first account
    await caseCreationFormRoot.searchAndSelectLookup(
      1,
      5,
      1,
      caseData.accountName,
      caseData.accountName
    );

    // Issue Type
    await caseUtils.selectPicklistOnCreationForm(
      caseCreationFormRoot,
      [1, 4, 1],
      [2, 9],
      0
    );

    // Channel Received
    await caseUtils.selectPicklistOnCreationForm(
      caseCreationFormRoot,
      [1, 3, 2],
      [2, 3],
      1
    );

    // click save button
    await caseCreationFormRoot.saveNew();

    await browser.pause(5000);
  }

  async assignNewOwner(): Promise<void> {
    const baseRecordForm = await caseUtils.getRecordForm();

    if (baseRecordForm) {
      const recordLayout = await baseRecordForm.getRecordLayout();

      // Case Owner
      const caseOwnerField = await commonUtils.getFieldFromRecordLayout(
        recordLayout,
        [2, 6, 2]
      );

      // click change owner button
      await caseOwnerField.clickChangeOwnerButton();
      await commonUtils.searchAndSelectNewOwner(
        "Users",
        caseData.newFraudXAgentOwnerName
      );
    }
  }

  async updateRecord(): Promise<void> {
    const baseRecordForm = await caseUtils.getRecordForm();

    if (baseRecordForm) {
      const recordLayout = await baseRecordForm.getRecordLayout();

      // Priority
      await commonUtils.selectPicklistOnRecordLayout(
        recordLayout,
        [2, 1, 2],
        [2, 9]
      );
      await baseRecordForm.clickFooterButton("Save");
    }
  }

  async closeRecord(): Promise<void> {
    const baseRecordForm = await caseUtils.getRecordForm();

    if (baseRecordForm) {
      const recordLayout = await baseRecordForm.getRecordLayout();

      // Status
      await commonUtils.selectPicklistOnRecordLayout(
        recordLayout,
        [2, 4, 2],
        4
      );
      await baseRecordForm.clickFooterButton("Save");

      await browser.pause(3000);
    }
  }
}
