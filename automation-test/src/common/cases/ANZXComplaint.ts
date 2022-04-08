import CaseCreationForm from "pageObjects/caseCreationForm";
import RecordLayout from "pageObjects/lwcRecordLayout";
import BaseRecordForm from "pageObjects/baseRecordForm";
import RecordLayoutItem from "pageObjects/recordLayoutItem";
import { CaseType, UserRole, Queue } from "constants/enums";
import { ownerType } from "types/record";
import { fieldSectionIndex } from "types/layout";
import Case from "./Case";
import caseData from "data/caseData";
import * as faker from "faker";
import * as commonUtils from "utils/commonUtils";
import * as caseUtils from "utils/caseUtils";

export default class ANZXComplaint extends Case {
  async createRecord(): Promise<void> {
    const caseCreationFormRoot = await utam.load(CaseCreationForm);
    await caseCreationFormRoot.selectCaseRecordType(CaseType.ANZX_COMPLAINT);

    switch (this.userRole) {
      case UserRole.COACH:
        await this.createRecordByCoach(caseCreationFormRoot);
        break;
      case UserRole.FRAUDX_AGENT:
        await this.createRecordByFraudXAgent(caseCreationFormRoot);
        break;
      default:
        console.error(
          "Error: invalid user role when creating ANZx Complaint Case."
        );
        process.exit(-1);
    }

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

      switch (this.userRole) {
        case UserRole.COACH:
          await this.updateRecordByCoach(recordLayout);
          break;
        case UserRole.FRAUDX_AGENT:
          await this.updateRecordByFraudXAgent(recordLayout);
          break;
        default:
          console.error(
            "Error: invalid user role when updating ANZx Complaint Case."
          );
          process.exit(-1);
      }

      await baseRecordForm.clickFooterButton("Save");
    }
  }

  async closeRecord(): Promise<void> {
    const baseRecordForm = await caseUtils.getRecordForm();

    if (baseRecordForm) {
      switch (this.userRole) {
        case UserRole.COACH:
          await this.closeRecordByCoach(baseRecordForm);
          break;
        case UserRole.FRAUDX_AGENT:
          await this.closeRecordByFraudXAgent(baseRecordForm);
          break;
        default:
          console.error(
            "Error: invalid user role when closing ANZx Complaint Case."
          );
          process.exit(-1);
      }

      await browser.pause(3000);
    }
  }

  async createRecordByCoach(
    caseCreationFormRoot: CaseCreationForm
  ): Promise<void> {
    // Account Name
    // search and select first account
    await caseCreationFormRoot.searchAndSelectLookup(
      1,
      1,
      1,
      caseData.accountName,
      caseData.accountName
    );

    // sequence of selecting fields must be followed due to limitation of page behavior
    await this.selectChannelReceived(caseCreationFormRoot, [2, 3, 1]);
    await this.selectPriority(caseCreationFormRoot, [2, 3, 2]);
    await this.selectIssueType(caseCreationFormRoot, [2, 5, 1]);
    await this.selectSubsequentIssueType(caseCreationFormRoot, [2, 5, 2]);
    await this.selectWrittenResponse(caseCreationFormRoot, [5, 3, 1]);

    // Product or Service Name
    // search ANZ and select first result
    await caseCreationFormRoot.searchAndSelectLookup(
      2,
      6,
      1,
      caseData.productName,
      caseData.productName
    );

    // Description of Issue
    // get field from layout and set text
    const descriptionOfIssue = faker.datatype.string(100);
    await caseCreationFormRoot.editTextarea(2, 10, 1, descriptionOfIssue);

    // Customer Desired Outcome
    // get field from layout and set text
    const customerDesiredOutcome = faker.datatype.string(100);
    await caseCreationFormRoot.editTextarea(2, 11, 1, customerDesiredOutcome);
  }

  async createRecordByFraudXAgent(
    caseCreationFormRoot: CaseCreationForm
  ): Promise<void> {
    // Account Name
    // search and select first account
    await caseCreationFormRoot.searchAndSelectLookup(
      1,
      1,
      1,
      caseData.accountName,
      caseData.accountName
    );

    // sequence of selecting fields must be followed due to limitation of page behavior
    await this.selectChannelReceived(caseCreationFormRoot, [2, 3, 1]);
    await this.selectPriority(caseCreationFormRoot, [2, 2, 2]);
    await this.selectIssueType(caseCreationFormRoot, [2, 5, 1]);
    await this.selectSubsequentIssueType(caseCreationFormRoot, [2, 4, 2]);
    await this.selectWrittenResponse(caseCreationFormRoot, [5, 3, 1]);

    // Product or Service Name
    // search ANZ and select first result
    await caseCreationFormRoot.searchAndSelectLookup(
      2,
      6,
      1,
      caseData.productName,
      caseData.productName
    );

    // Description of Issue
    // get field from layout and set text
    const descriptionOfIssue = faker.datatype.string(100);
    await caseCreationFormRoot.editTextarea(2, 9, 1, descriptionOfIssue);

    // Customer Desired Outcome
    // get field from layout and set text
    const customerDesiredOutcome = faker.datatype.string(100);
    await caseCreationFormRoot.editTextarea(2, 10, 1, customerDesiredOutcome);
  }

  async updateRecordByCoach(recordLayout: RecordLayout): Promise<void> {
    await this.updatePriority(recordLayout, [2, 3, 2]);
  }

  async updateRecordByFraudXAgent(recordLayout: RecordLayout): Promise<void> {
    await this.updatePriority(recordLayout, [2, 2, 2]);
  }

  async closeRecordByCoach(baseRecordForm: BaseRecordForm): Promise<void> {
    // get record layout
    const recordLayout = await baseRecordForm.getRecordLayout();

    // Status
    // select Closed status
    await commonUtils.selectPicklistOnRecordLayout(recordLayout, [2, 2, 2], 7);
    await baseRecordForm.clickFooterButton("Save");
  }

  async closeRecordByFraudXAgent(
    baseRecordForm: BaseRecordForm
  ): Promise<void> {
    // get record layout
    const recordLayout = await baseRecordForm.getRecordLayout();

    // Status
    // select Closed status
    await commonUtils.selectPicklistOnRecordLayout(recordLayout, [2, 1, 2], 7);
    await baseRecordForm.clickFooterButton("Save");
  }

  // Channel Received
  async selectChannelReceived(
    caseCreationFormRoot: CaseCreationForm,
    fieldSectionIndex: fieldSectionIndex
  ): Promise<void> {
    await caseUtils.selectPicklistOnCreationForm(
      caseCreationFormRoot,
      fieldSectionIndex,
      [2, 14],
      0
    );
  }

  // Priority
  async selectPriority(
    caseCreationFormRoot: CaseCreationForm,
    fieldSectionIndex: fieldSectionIndex
  ): Promise<void> {
    await caseUtils.selectPicklistOnCreationForm(
      caseCreationFormRoot,
      fieldSectionIndex,
      [2, 5],
      1
    );
  }

  // Issue Type
  async selectIssueType(
    caseCreationFormRoot: CaseCreationForm,
    fieldSectionIndex: fieldSectionIndex
  ): Promise<void> {
    await caseUtils.selectPicklistOnCreationForm(
      caseCreationFormRoot,
      fieldSectionIndex,
      [2, 10],
      2
    );
  }

  // Subsequent Issue Type
  async selectSubsequentIssueType(
    caseCreationFormRoot: CaseCreationForm,
    fieldSectionIndex: fieldSectionIndex
  ): Promise<void> {
    await caseUtils.selectPicklistOnCreationForm(
      caseCreationFormRoot,
      fieldSectionIndex,
      [2, 2],
      3
    );
  }

  // Is a Written Response Requested?
  async selectWrittenResponse(
    caseCreationFormRoot: CaseCreationForm,
    fieldSectionIndex: fieldSectionIndex
  ): Promise<void> {
    await caseUtils.selectPicklistOnCreationForm(
      caseCreationFormRoot,
      fieldSectionIndex,
      [2, 3],
      4
    );
  }

  // Priority (used on Record Page, not on Creation Form)
  async updatePriority(
    recordLayout: RecordLayout,
    fieldSectionIndex: fieldSectionIndex
  ) {
    await commonUtils.selectPicklistOnRecordLayout(
      recordLayout,
      fieldSectionIndex,
      [2, 5]
    );
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
        caseData.newFraudXAgentOwnerName
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
