import CaseCreationForm from "pageObjects/coachesWorkbenchCaseCreationForm";
import CaseRecordHomeFlexipage from "pageObjects/coachesWorkbenchCaseRecordHomeFlexipage";
import { CaseType } from "constants/enums";
import Case from "./Case";
import caseData from "data/caseData";
import * as faker from "faker";
import * as commonUtils from "utils/commonUtils";
import * as caseUtils from "utils/caseUtils";

export default class Scam extends Case {
  async createRecord(): Promise<void> {
    const caseCreationFormRoot = await utam.load(CaseCreationForm);
    await caseCreationFormRoot.selectCaseRecordType(CaseType.SCAM);

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
      [2, 8],
      0
    );

    // Channel Received
    await caseUtils.selectPicklistOnCreationForm(
      caseCreationFormRoot,
      [1, 3, 2],
      [2, 7],
      1
    );

    // click save button
    await caseCreationFormRoot.saveNew();

    await browser.pause(5000);
  }

  async assignNewOwner(): Promise<void> {
    const CaseRecordHomeFlexipageRoot = await utam.load(
      CaseRecordHomeFlexipage
    );

    // get record layout
    const detailPanel =
      await CaseRecordHomeFlexipageRoot.getMainRegionActiveTabDetailPanel();
    const baseRecordForm = await detailPanel.getBaseRecordForm();
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

  async updateRecord(): Promise<void> {
    const CaseRecordHomeFlexipageRoot = await utam.load(
      CaseRecordHomeFlexipage
    );

    // get record layout
    const detailPanel =
      await CaseRecordHomeFlexipageRoot.getMainRegionActiveTabDetailPanel();
    const baseRecordForm = await detailPanel.getBaseRecordForm();
    const recordLayout = await baseRecordForm.getRecordLayout();

    // Chat Topic ID
    const chatTopicField = await commonUtils.getFieldFromRecordLayout(
      recordLayout,
      [2, 3, 2]
    );

    const chatTopicId = `CH${faker.datatype.string(32)}`;
    await commonUtils.inputText(chatTopicField, chatTopicId);

    // click save button
    await baseRecordForm.clickFooterButton("Save");
  }

  async closeRecord(): Promise<void> {
    const CaseRecordHomeFlexipageRoot = await utam.load(
      CaseRecordHomeFlexipage
    );

    // get record layout
    const detailPanel =
      await CaseRecordHomeFlexipageRoot.getMainRegionActiveTabDetailPanel();
    const baseRecordForm = await detailPanel.getBaseRecordForm();
    const recordLayout = await baseRecordForm.getRecordLayout();

    // Status
    // select Closed status
    await commonUtils.selectPicklistOnRecordLayout(recordLayout, [2, 4, 2], 4);

    await baseRecordForm.clickFooterButton("Save");
  }
}
