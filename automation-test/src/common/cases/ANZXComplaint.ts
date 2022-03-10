import CaseCreationForm from "pageObjects/coachesWorkbenchCaseCreationForm";
import CaseRecordHomeFlexipage from "pageObjects/coachesWorkbenchCaseRecordHomeFlexipage";
import LwcRecordLayout from "pageObjects/lwcRecordLayout";
import BaseRecordForm from "pageObjects/baseRecordForm";
import { CaseType, UserRole } from "constants/enums";
import Case from "./Case";
import caseData from "data/caseData";
import * as CommonUtils from "utils/commonUtils";
import * as faker from "faker";

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

  async assignNewOwner(): Promise<void> {}

  async updateRecord(): Promise<void> {
    // Coaches Workbench Case Record Page
    const CaseRecordHomeFlexipageRoot = await utam.load(
      CaseRecordHomeFlexipage
    );

    // get record layout
    const detailPanel = await CaseRecordHomeFlexipageRoot.getMainRegionActiveTabDetailPanel();
    const baseRecordForm = await detailPanel.getBaseRecordForm();
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

  async closeRecord(): Promise<void> {
    // Coaches Workbench Case Record Page
    const CaseRecordHomeFlexipageRoot = await utam.load(
      CaseRecordHomeFlexipage
    );

    // get record layout
    const detailPanel = await CaseRecordHomeFlexipageRoot.getMainRegionActiveTabDetailPanel();
    const baseRecordForm = await detailPanel.getBaseRecordForm();

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

  async createRecordByCoach(
    caseCreationFormRoot: CaseCreationForm
  ): Promise<void> {
    // search and select first account
    await caseCreationFormRoot.searchAndSelectLookup(
      1,
      1,
      1,
      caseData.accountName,
      1
    );

    // sequence of selecting fields must be followed due to limitation of page behavior
    await this.selectChannelReceived(caseCreationFormRoot, 2, 3, 1);
    await this.selectPriority(caseCreationFormRoot, 2, 3, 2);
    await this.selectIssueType(caseCreationFormRoot, 2, 5, 1);
    await this.selectSubsequentIssueType(caseCreationFormRoot, 2, 5, 2);
    await this.selectWrittenResponse(caseCreationFormRoot, 5, 3, 1);

    // Product or Service Name
    // search ANZ and select first result
    await caseCreationFormRoot.searchAndSelectLookup(2, 6, 1, "ANZ ", 1);

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
    // search and select first account
    await caseCreationFormRoot.searchAndSelectLookup(
      1,
      1,
      1,
      caseData.accountName,
      1
    );

    // sequence of selecting fields must be followed due to limitation of page behavior
    await this.selectChannelReceived(caseCreationFormRoot, 2, 3, 1);
    await this.selectPriority(caseCreationFormRoot, 2, 2, 2);
    await this.selectIssueType(caseCreationFormRoot, 2, 5, 1);
    await this.selectSubsequentIssueType(caseCreationFormRoot, 2, 4, 2);
    await this.selectWrittenResponse(caseCreationFormRoot, 5, 3, 1);

    // Product or Service Name
    // search ANZ and select first result
    await caseCreationFormRoot.searchAndSelectLookup(2, 6, 1, "ANZ ", 1);

    // Description of Issue
    // get field from layout and set text
    const descriptionOfIssue = faker.datatype.string(100);
    await caseCreationFormRoot.editTextarea(2, 9, 1, descriptionOfIssue);

    // Customer Desired Outcome
    // get field from layout and set text
    const customerDesiredOutcome = faker.datatype.string(100);
    await caseCreationFormRoot.editTextarea(2, 10, 1, customerDesiredOutcome);
  }

  async updateRecordByCoach(recordLayout: LwcRecordLayout): Promise<void> {
    await this.updatePriority(recordLayout, 2, 3, 2);
  }

  async updateRecordByFraudXAgent(
    recordLayout: LwcRecordLayout
  ): Promise<void> {
    await this.updatePriority(recordLayout, 2, 2, 2);
  }

  async closeRecordByCoach(baseRecordForm: BaseRecordForm): Promise<void> {
    // get record layout
    const recordLayout = await baseRecordForm.getRecordLayout();

    // Status
    // select Closed status
    const statusField = await CommonUtils.getFieldFromLayout(
      recordLayout,
      2,
      2,
      2
    );
    await CommonUtils.selectPicklist(statusField, 7);
    await baseRecordForm.clickFooterButton("Save");
  }

  async closeRecordByFraudXAgent(
    baseRecordForm: BaseRecordForm
  ): Promise<void> {
    // get record layout
    const recordLayout = await baseRecordForm.getRecordLayout();

    // Status
    // select Closed status
    const statusField = await CommonUtils.getFieldFromLayout(
      recordLayout,
      2,
      1,
      2
    );
    await CommonUtils.selectPicklist(statusField, 7);
    await baseRecordForm.clickFooterButton("Save");
  }

  // Channel Received
  async selectChannelReceived(
    caseCreationFormRoot: CaseCreationForm,
    sectionIndex: number,
    sectionRowIndex: number,
    sectionRowItemIndex: number
  ): Promise<void> {
    // get field from layout
    await caseCreationFormRoot.selectPicklist(
      sectionIndex,
      sectionRowIndex,
      sectionRowItemIndex
    );
    // define a random value index, there are 13 items in picklist, skip --None--, which is 1
    const channelReceivedIndex = faker.datatype.number({
      min: 2,
      max: 14
    });
    // get picklist dropdown
    const [
      channelReceivedPicklist
    ] = await caseCreationFormRoot.getPicklistItemsLists();
    // select a recevied channel
    await channelReceivedPicklist.selectPicklistItem(channelReceivedIndex);
  }

  // Priority
  async selectPriority(
    caseCreationFormRoot: CaseCreationForm,
    sectionIndex: number,
    sectionRowIndex: number,
    sectionRowItemIndex: number
  ): Promise<void> {
    // get field from layout
    await caseCreationFormRoot.selectPicklist(
      sectionIndex,
      sectionRowIndex,
      sectionRowItemIndex
    );
    // define a random value index, there are 4 items in picklist, skip --None--, which is 1
    const priorityIndex = faker.datatype.number({
      min: 2,
      max: 4
    });
    // get picklist dropdown
    // get 2nd list from the returned lists and skip first one, which is Channel Received list above
    const [
      ,
      priorityPicklist
    ] = await caseCreationFormRoot.getPicklistItemsLists();
    // select a priority
    await priorityPicklist.selectPicklistItem(priorityIndex);
  }

  // Issue Type
  async selectIssueType(
    caseCreationFormRoot: CaseCreationForm,
    sectionIndex: number,
    sectionRowIndex: number,
    sectionRowItemIndex: number
  ): Promise<void> {
    // get field from layout
    await caseCreationFormRoot.selectPicklist(
      sectionIndex,
      sectionRowIndex,
      sectionRowItemIndex
    );
    // define a random value index, there are 9 items in picklist, skip --None--, which is 1
    const issueTypeIndex = faker.datatype.number({
      min: 2,
      max: 10
    });
    // get picklist dropdown
    // get 3rd list from the returned lists and skip first one, which is Priority list above
    const [
      ,
      ,
      issueTypePicklist
    ] = await caseCreationFormRoot.getPicklistItemsLists();
    // select a issue type
    await issueTypePicklist.selectPicklistItem(issueTypeIndex);
  }

  // Subsequent Issue Type
  async selectSubsequentIssueType(
    caseCreationFormRoot: CaseCreationForm,
    sectionIndex: number,
    sectionRowIndex: number,
    sectionRowItemIndex: number
  ): Promise<void> {
    // get field from layout
    await caseCreationFormRoot.selectPicklist(
      sectionIndex,
      sectionRowIndex,
      sectionRowItemIndex
    );
    // get picklist dropdown
    // get 4th list from the returned lists and skip first one, which is Issue Type list above
    const [
      ,
      ,
      ,
      subsequentIssueTypePicklist
    ] = await caseCreationFormRoot.getPicklistItemsLists();
    // select second dependent picklist value to avoid test breaking
    // this one might fail randomly as there are some sub issue type has 0 item
    await subsequentIssueTypePicklist.selectPicklistItem(2);
  }

  // Is a Written Response Requested?
  async selectWrittenResponse(
    caseCreationFormRoot: CaseCreationForm,
    sectionIndex: number,
    sectionRowIndex: number,
    sectionRowItemIndex: number
  ): Promise<void> {
    // get field from layout
    await caseCreationFormRoot.selectPicklist(
      sectionIndex,
      sectionRowIndex,
      sectionRowItemIndex
    );
    // define a random value index, there are 2 items in picklist, skip --None--, which is 1
    const writtenResponseIndex = faker.datatype.number({
      min: 2,
      max: 3
    });
    // get picklist dropdown
    // get 5th list from the returned lists and skip first one, which is Subsequent Issue Type list above
    const [
      ,
      ,
      ,
      ,
      writtenReponsePicklist
    ] = await caseCreationFormRoot.getPicklistItemsLists();
    // select a value
    await writtenReponsePicklist.selectPicklistItem(writtenResponseIndex);
  }

  // Priority (used on Record Page, not on Creation Form)
  async updatePriority(
    recordLayout: LwcRecordLayout,
    sectionIndex: number,
    rowIndex: number,
    fieldIndex: number
  ) {
    const priorityField = await CommonUtils.getFieldFromLayout(
      recordLayout,
      sectionIndex,
      rowIndex,
      fieldIndex
    );
    // define a random value index, there are 4 items in picklist, skip --None--, which is 1
    const priorityIndex = faker.datatype.number({
      min: 2,
      max: 5
    });
    await CommonUtils.selectPicklist(priorityField, priorityIndex);
  }
}
