import CaseCreationForm from "pageObjects/coachesWorkbenchCaseCreationForm";
import CaseRecordHomeFlexipage from "pageObjects/coachesWorkbenchCaseRecordHomeFlexipage";
import { CaseType } from "constants/enums";
import Case from "./Case";
import caseData from "data/caseData";
import * as CommonUtils from "utils/commonUtils";
import * as faker from "faker";

export default class RecipientMule extends Case {
  async createRecord(): Promise<void> {
    const caseCreationFormRoot = await utam.load(CaseCreationForm);
    await caseCreationFormRoot.selectCaseRecordType(CaseType.RECIPIENT_MULE);

    // search and select first account
    await caseCreationFormRoot.searchAndSelectLookup(
      1,
      4,
      1,
      caseData.accountName,
      1
    );

    // Issue Type
    // get field from layout
    await caseCreationFormRoot.selectPicklist(1, 3, 1);
    // define a random value index, there are 8 items in picklist, skip none, which is 1
    const issueTypeIndex = faker.datatype.number({
      min: 2,
      max: 9
    });
    // get picklist dropdown
    const [
      issueTypePicklist
    ] = await caseCreationFormRoot.getPicklistItemsLists();
    // select a issue type
    await issueTypePicklist.selectPicklistItem(issueTypeIndex);

    // Channel Received
    // get field from layout
    await caseCreationFormRoot.selectPicklist(1, 2, 2);
    // define a random value index, there are 6 items in picklist, skip --None--, which is 1
    const channelReceivedIndex = faker.datatype.number({
      min: 2,
      max: 7
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

  async assignNewOwner(): Promise<void> {
    const consoleRecordFlexipageRoot = await utam.load(CaseRecordHomeFlexipage);
  }

  async updateRecord(): Promise<void> {
    // Coaches Workbench Case Record Page
    const CaseRecordHomeFlexipageRoot = await utam.load(
      CaseRecordHomeFlexipage
    );

    // get record layout
    const detailPanel = await CaseRecordHomeFlexipageRoot.getMainRegionActiveTabDetailPanel();
    const baseRecordForm = await detailPanel.getBaseRecordForm();
    const recordLayout = await baseRecordForm.getRecordLayout();

    // Priority
    const priorityField = await CommonUtils.getFieldFromLayout(
      recordLayout,
      1,
      1,
      2
    );
    // define a random value index, there are 8 items in picklist, skip --None--, which is 1
    const priorityIndex = faker.datatype.number({
      min: 2,
      max: 9
    });
    await CommonUtils.selectPicklist(priorityField, priorityIndex);
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
    const recordLayout = await baseRecordForm.getRecordLayout();

    // Status
    // select Closed status
    const statusField = await CommonUtils.getFieldFromLayout(
      recordLayout,
      1,
      4,
      2
    );
    await CommonUtils.selectPicklist(statusField, 4);
    await baseRecordForm.clickFooterButton("Save");

    await browser.pause(3000);
  }
}
