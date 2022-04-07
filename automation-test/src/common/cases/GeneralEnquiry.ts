import CaseCreationForm from "pageObjects/caseCreationForm";
import RecordPage from "pageObjects/recordPage";
import CaseCallsTab from "pageObjects/caseCallsTab";
import CaseNotesTab from "pageObjects/caseNotesTab";
import RecordLayoutItem from "pageObjects/recordLayoutItem";
import { CaseType, UserRole, Queue } from "constants/enums";
import { ownerType } from "types/record";
import Case from "./Case";
import IChatter from "interfaces/IChatter";
import caseData from "data/caseData";
import * as commonUtils from "utils/commonUtils";
import * as caseUtils from "utils/caseUtils";
import * as faker from "faker";

const generalComment = `Automation Test @ ${new Date().toLocaleString()}.`;

export default class GeneralEnquiry extends Case implements IChatter {
  async createRecord(): Promise<void> {
    const caseCreationFormRoot = await utam.load(CaseCreationForm);
    await caseCreationFormRoot.selectCaseRecordType(CaseType.GENERAL_ENQUIRY);

    // Account Name
    // search and select first account
    await caseCreationFormRoot.searchAndSelectLookup(
      1,
      1,
      1,
      caseData.accountName,
      caseData.accountName
    );

    // Issue Type
    await caseUtils.selectPicklistOnCreationForm(
      caseCreationFormRoot,
      [2, 3, 1],
      [2, 10],
      0
    );

    // Channel Received
    await caseUtils.selectPicklistOnCreationForm(
      caseCreationFormRoot,
      [2, 1, 2],
      [2, 8],
      1
    );

    // click save button
    await caseCreationFormRoot.saveNew();

    await browser.pause(5000);
  }

  async assignNewOwner(ownerType?: ownerType): Promise<void> {
    const baseRecordForm = await caseUtils.getRecordForm();

    if (baseRecordForm) {
      const recordLayout = await baseRecordForm.getRecordLayout();

      // Case Owner
      const caseOwnerField = await commonUtils.getFieldFromRecordLayout(
        recordLayout,
        [2, 1, 1]
      );

      switch (this.userRole) {
        case UserRole.COACH:
          await this.assignNewOwnerByCoach(caseOwnerField, ownerType);
          break;
        case UserRole.FRAUDX_AGENT:
          await this.assignNewOwnerByFraudXAgent(caseOwnerField);
          break;
        default:
          console.error(
            "Error: invalid user role when creating ANZx Complaint Case."
          );
          process.exit(-1);
      }
    }
  }

  async updateRecord(): Promise<void> {
    const baseRecordForm = await caseUtils.getRecordForm();

    if (baseRecordForm) {
      const recordLayout = await baseRecordForm.getRecordLayout();

      // Priority
      await commonUtils.selectPicklistOnRecordLayout(
        recordLayout,
        [2, 4, 2],
        [2, 5]
      );

      await baseRecordForm.clickFooterButton("Save");
    }
  }

  async updateCallDetails(): Promise<void> {
    const callsTab = await caseUtils.getTabContent("Calls");

    if (callsTab instanceof CaseCallsTab) {
      const randomCallSID = `CA${faker.finance.account(32)}`;
      const randomAuthMethodIndex = faker.datatype.number({ min: 2, max: 4 });

      const caseLogACall = await callsTab.getCaseLogACall();
      await caseLogACall.logACall(randomCallSID, randomAuthMethodIndex);
      await browser.pause(2000);
    }
  }

  async postChatterComment(): Promise<void> {
    const caseNotesTab = await caseUtils.getTabContent("Case Notes");

    if (caseNotesTab instanceof CaseNotesTab) {
      const chatterPanel = await caseNotesTab.getChatterPanel();
      await chatterPanel.postComment(generalComment);
    }
  }

  async verifyChatterComment(): Promise<void> {
    const caseNotesTab = await caseUtils.getTabContent("Case Notes");

    if (caseNotesTab instanceof CaseNotesTab) {
      const chatterPanel = await caseNotesTab.getChatterPanel();
      expect(
        await chatterPanel.latestPostContentEquals(generalComment)
      ).toEqual(true);
    }
  }

  async closeRecord(): Promise<void> {
    const baseRecordForm = await caseUtils.getRecordForm();

    if (baseRecordForm) {
      // get record layout
      const recordLayout = await baseRecordForm.getRecordLayout();

      // Status
      // select Closed status
      await commonUtils.selectPicklistOnRecordLayout(
        recordLayout,
        [2, 3, 2],
        6
      );
      await baseRecordForm.clickFooterButton("Save");
      await browser.pause(3000);
    }
  }

  async assignNewOwnerByCoach(
    caseOwnerField: RecordLayoutItem,
    ownerType?: ownerType
  ): Promise<void> {
    // click change owner button
    await caseOwnerField.clickChangeOwnerButton();

    if (ownerType === "Users") {
      await commonUtils.searchAndSelectNewOwner(
        "Users",
        caseData.newCoachOwnerName
      );
    } else if (ownerType === "Queues") {
      await commonUtils.searchAndSelectNewOwner(
        "Queues",
        Queue.SUPPORT_COACH_QUEUE
      );
    }
  }

  async assignNewOwnerByFraudXAgent(
    caseOwnerField: RecordLayoutItem
  ): Promise<void> {
    // click change owner button
    await caseOwnerField.clickChangeOwnerButton();
    await commonUtils.searchAndSelectNewOwner(
      "Users",
      caseData.newFraudXAgentOwnerName
    );
  }
}
