import CaseCreationForm from "pageObjects/coachesWorkbenchCaseCreationForm";
import CaseRecordHomeFlexipage from "pageObjects/coachesWorkbenchCaseRecordHomeFlexipage";
import LwcDetailPanel from "pageObjects/lwcDetailPanel";
import { CaseType } from "constants/enums";
import Case from "./Case";
import caseData from "data/caseData";
import * as CommonUtils from "utils/commonUtils";
import * as faker from "faker";

export default class GeneralEnquiry extends Case {
  async createRecord(): Promise<void> {
    const caseCreationFormRoot = await utam.load(CaseCreationForm);
    await caseCreationFormRoot.selectCaseRecordType(CaseType.GENERAL_ENQUIRY);

    // search and select first account
    await caseCreationFormRoot.searchAndSelectLookup(
      1,
      1,
      1,
      caseData.accountName,
      1
    );

    // Issue Type
    // get field from layout
    await caseCreationFormRoot.selectPicklist(2, 3, 1);
    // define a random value index, there are 9 items in picklist, skip --None--, which is 1
    const issueTypeIndex = faker.datatype.number({
      min: 2,
      max: 10
    });
    // get picklist dropdown
    const [
      issueTypePicklist
    ] = await caseCreationFormRoot.getPicklistItemsLists();
    // select a issue type
    await issueTypePicklist.selectPicklistItem(issueTypeIndex);

    // Channel Received
    // get field from layout
    await caseCreationFormRoot.selectPicklist(2, 1, 2);
    // define a random value index, there are 7 items in picklist, skip --None--, which is 1
    const channelReceivedIndex = faker.datatype.number({
      min: 2,
      max: 8
    });
    // get picklist dropdown
    // get 2nd list from the returned lists and skip first one, which is Issue Type list above
    const [
      ,
      channelReceivedPicklist
    ] = await caseCreationFormRoot.getPicklistItemsLists();
    // select a recevied channel
    await channelReceivedPicklist.selectPicklistItem(channelReceivedIndex);

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
      4,
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
      3,
      2
    );
    await CommonUtils.selectPicklist(statusField, 6);
    await baseRecordForm.clickFooterButton("Save");
  }
}
