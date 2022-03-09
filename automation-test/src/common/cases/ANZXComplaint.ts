import CaseCreationForm from "pageObjects/coachesWorkbenchCaseCreationForm";
import CaseRecordHomeFlexipage from "pageObjects/coachesWorkbenchCaseRecordHomeFlexipage";
import LwcDetailPanel from "pageObjects/lwcDetailPanel";
import { CaseType } from "constants/enums";
import Case from "./Case";
import caseData from "data/caseData";
import * as CommonUtils from "utils/commonUtils";
import * as faker from "faker";

export default class ANZXComplaint extends Case {
  async createRecord(): Promise<void> {
    const caseCreationFormRoot = await utam.load(CaseCreationForm);
    await caseCreationFormRoot.selectCaseRecordType(CaseType.ANZX_COMPLAINT);

    // search and select first account
    await caseCreationFormRoot.searchAndSelectLookup(
      1,
      1,
      1,
      caseData.accountName,
      1
    );

    // Channel Received
    // get field from layout
    await caseCreationFormRoot.selectPicklist(2, 3, 1);
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

    // Priority
    // get field from layout
    await caseCreationFormRoot.selectPicklist(2, 3, 2);
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
    await channelReceivedPicklist.selectPicklistItem(priorityIndex);

    // Issue Type
    // get field from layout
    await caseCreationFormRoot.selectPicklist(2, 5, 1);
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

    // Subsequent Issue Type
    // get field from layout
    await caseCreationFormRoot.selectPicklist(2, 5, 2);
    // get picklist dropdown
    // get 4th list from the returned lists and skip first one, which is Issue Type list above
    const [
      ,
      ,
      ,
      subIssueTypePicklist
    ] = await caseCreationFormRoot.getPicklistItemsLists();
    // select second dependent picklist value to avoid test breaking
    await subIssueTypePicklist.selectPicklistItem(2);

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

    // Is a Written Response Requested?
    // get field from layout
    await caseCreationFormRoot.selectPicklist(5, 3, 1);
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

    // click save button
    await caseCreationFormRoot.saveNew();

    await browser.pause(5000);
  }

  async assignNewOwner(): Promise<void> {}

  async updateRecord(): Promise<void> {
    const CaseRecordHomeFlexipageRoot = await utam.load(
      CaseRecordHomeFlexipage
    );

    // load Detail Panel container
    const detailComponent = await CaseRecordHomeFlexipageRoot.getCaseDetailComponent();

    // load Detail Panel into container
    const detailPanel = await detailComponent.getContent(LwcDetailPanel);
    const baseRecordForm = await detailPanel.getBaseRecordForm();
    const recordLayout = await baseRecordForm.getRecordLayout();

    // Priority
    const priorityField = await CommonUtils.getFieldFromLayout(
      recordLayout,
      2,
      3,
      2
    );
    // define a random value index, there are 4 items in picklist, skip --None--, which is 1
    const priorityIndex = faker.datatype.number({
      min: 2,
      max: 5
    });
    await CommonUtils.selectPicklist(priorityField, priorityIndex);
    await baseRecordForm.clickFooterButton("Save");
  }

  async closeRecord(): Promise<void> {
    const CaseRecordHomeFlexipageRoot = await utam.load(
      CaseRecordHomeFlexipage
    );

    // load Detail Panel container
    const detailComponent = await CaseRecordHomeFlexipageRoot.getCaseDetailComponent();

    // load Detail Panel into container
    const detailPanel = await detailComponent.getContent(LwcDetailPanel);
    const baseRecordForm = await detailPanel.getBaseRecordForm();
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
}
