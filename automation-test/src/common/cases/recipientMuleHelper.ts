import CaseCreationForm from "pageObjects/caseCreationForm";
import ConsoleRecordHomeFlexipage from "pageObjects/consoleRecordHomeFlexipage";
import LwcDetailPanel from "pageObjects/lwcDetailPanel";
import { recipientMuleCase } from "data/cases";
import * as CommonUtils from "utils/commonUtils";

export const createRecord = async (): Promise<void> => {
  const caseCreationFormRoot = await utam.load(CaseCreationForm);
  await caseCreationFormRoot.selectCaseRecordType("Recipient/Mule");

  // enter, search and select first account
  await caseCreationFormRoot.selectAccount(recipientMuleCase.accountName, 1);

  // Issue Type
  await caseCreationFormRoot.selectIssueType(2);

  // Channel Received
  await caseCreationFormRoot.selectChannelReceived(2);

  // click save button
  await caseCreationFormRoot.saveNew();

  await browser.pause(5000);
};

export const assignNewOwner = async (): Promise<void> => {};

export const updateRecord = async (): Promise<void> => {
  const consoleRecordHomeFlexipageRoot = await utam.load(
    ConsoleRecordHomeFlexipage
  );

  // load Detail Panel container
  const detailComponent = await consoleRecordHomeFlexipageRoot.getDetailComponent();

  // load Detail Panel into container
  const detailPanel = await detailComponent.getContent(LwcDetailPanel);
  const baseRecordForm = await detailPanel.getBaseRecordForm();
  const recordLayout = await baseRecordForm.getRecordLayout();

  // Priority
  const priorityField = await CommonUtils.getFieldFromLayout(
    recordLayout,
    1,
    1,
    2
  );
  await CommonUtils.selectPicklist(priorityField, 2);
  await baseRecordForm.clickFooterButton("Save");

  // click save button
  await baseRecordForm.clickFooterButton("Save");
};

export const closeRecord = async (): Promise<void> => {
  const consoleRecordHomeFlexipageRoot = await utam.load(
    ConsoleRecordHomeFlexipage
  );

  // load Detail Panel container
  const detailComponent = await consoleRecordHomeFlexipageRoot.getDetailComponent();

  // load Detail Panel into container
  const detailPanel = await detailComponent.getContent(LwcDetailPanel);
  const baseRecordForm = await detailPanel.getBaseRecordForm();
  const recordLayout = await baseRecordForm.getRecordLayout();

  // Status
  // select Close status
  const statusField = await CommonUtils.getFieldFromLayout(
    recordLayout,
    1,
    4,
    2
  );
  await CommonUtils.selectPicklist(statusField, 4);
  await baseRecordForm.clickFooterButton("Save");
};
