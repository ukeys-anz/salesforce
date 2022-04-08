import CaseCreationForm from "pageObjects/caseCreationForm";
import { CaseType } from "constants/enums";
import Case from "./Case";
import caseData from "data/caseData";
import * as faker from "faker";
import * as commonUtils from "utils/commonUtils";
import * as caseUtils from "utils/caseUtils";

export default class KYCQA extends Case {
  async createRecord(): Promise<void> {
    const caseCreationFormRoot = await utam.load(CaseCreationForm);
    await caseCreationFormRoot.selectCaseRecordType(CaseType.KYC_QA);

    // Account Name
    // search and select first account
    await caseCreationFormRoot.searchAndSelectLookup(
      1,
      4,
      1,
      caseData.accountName,
      caseData.accountName
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
        [1, 3, 1]
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

      // Chat Topic ID
      const chatTopicField = await commonUtils.getFieldFromRecordLayout(
        recordLayout,
        [1, 3, 2]
      );

      const chatTopicId = `CH${faker.datatype.string(32)}`;
      await commonUtils.inputText(chatTopicField, chatTopicId);

      // click save button
      await baseRecordForm.clickFooterButton("Save");
    }
  }

  async closeRecord(): Promise<void> {
    const baseRecordForm = await caseUtils.getRecordForm();

    if (baseRecordForm) {
      const recordLayout = await baseRecordForm.getRecordLayout();

      // select Yes for all below fields to close KYC QA Case
      // KYC Information is a Match & Complete
      await commonUtils.selectPicklistOnRecordLayout(
        recordLayout,
        [2, 1, 1],
        2
      );
      await baseRecordForm.clickFooterButton("Save");

      // Identity Document is Legible
      await commonUtils.selectPicklistOnRecordLayout(
        recordLayout,
        [2, 1, 2],
        2
      );
      await baseRecordForm.clickFooterButton("Save");

      // Middle Name Missing
      await commonUtils.selectPicklistOnRecordLayout(
        recordLayout,
        [2, 2, 1],
        2
      );
      await baseRecordForm.clickFooterButton("Save");

      // Image is not a Picture of ID Document
      await commonUtils.selectPicklistOnRecordLayout(
        recordLayout,
        [2, 2, 2],
        2
      );
      await baseRecordForm.clickFooterButton("Save");

      // Middle Name Initial
      await commonUtils.selectPicklistOnRecordLayout(
        recordLayout,
        [2, 3, 1],
        2
      );
      await baseRecordForm.clickFooterButton("Save");

      // Customer's Photo is Not Modified
      await commonUtils.selectPicklistOnRecordLayout(
        recordLayout,
        [2, 3, 2],
        2
      );
      await baseRecordForm.clickFooterButton("Save");

      // Selfie Comparison Match
      await commonUtils.selectPicklistOnRecordLayout(
        recordLayout,
        [2, 4, 1],
        2
      );
      await baseRecordForm.clickFooterButton("Save");

      // Security Features Visible
      await commonUtils.selectPicklistOnRecordLayout(
        recordLayout,
        [2, 4, 2],
        2
      );
      await baseRecordForm.clickFooterButton("Save");

      // Residential Address is Not a PO Box
      await commonUtils.selectPicklistOnRecordLayout(
        recordLayout,
        [2, 5, 1],
        2
      );
      await baseRecordForm.clickFooterButton("Save");

      // Residential address is valid
      await commonUtils.selectPicklistOnRecordLayout(
        recordLayout,
        [2, 6, 1],
        2
      );
      await baseRecordForm.clickFooterButton("Save");

      // Restraint Status
      // select N/A
      await commonUtils.selectPicklistOnRecordLayout(
        recordLayout,
        [2, 7, 1],
        2
      );
      await baseRecordForm.clickFooterButton("Save");

      // Have All Defects Been Rectified
      // select Not Applicable
      await commonUtils.selectPicklistOnRecordLayout(
        recordLayout,
        [3, 1, 1],
        3
      );
      await baseRecordForm.clickFooterButton("Save");

      // Status
      // select Closed status
      await commonUtils.selectPicklistOnRecordLayout(
        recordLayout,
        [1, 4, 2],
        3
      );
      await baseRecordForm.clickFooterButton("Save");

      await browser.pause(3000);
    }
  }
}
