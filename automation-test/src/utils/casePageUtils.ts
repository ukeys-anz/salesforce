import { UtamBasePageObject } from "utam";
import RecordPage from "pageObjects/recordPage";
import CaseDetailsTab from "pageObjects/caseDetailsTab";
import CaseCallsTab from "pageObjects/caseCallsTab";
import CaseNotesTab from "pageObjects/caseNotesTab";
import BaseRecordForm from "@salesforce-pageobjects/records/pageObjects/baseRecordForm";
import Tabset2 from "@salesforce-pageobjects/flexipage/pageObjects/tabset2";
import LwcHighlightsPanel from "@salesforce-pageobjects/records/pageObjects/lwcHighlightsPanel";
import * as commonUtils from "../utils/commonUtils";
import { FieldSectionIndex, PicklistOptionIndexRange } from "../types/layout";

export const getCaseNumber = async (): Promise<string> => {
  const highlightsPanel = await getHighlightsPanel();
  const recordLayout = await highlightsPanel.getRecordLayout();
  const highlights = await recordLayout.waitForHighlights2();
  const caseNumberFieldStr = await highlights.getSecondaryFieldText(3);
  const caseNumber = caseNumberFieldStr
    .trim()
    .substring("Case Number".length)
    .replace(/\s/g, "");
  return caseNumber;
};

export const getRecordForm = async (): Promise<BaseRecordForm | undefined> => {
  const detailsTab = await getTabContent("Details");

  if (detailsTab instanceof CaseDetailsTab) {
    const detailPanel = await detailsTab.getDetailPanel();
    return detailPanel.getBaseRecordForm();
  }

  return;
};

export const getTabContent = async (
  tabName: string
): Promise<UtamBasePageObject | undefined> => {
  const recordPageRoot = await utam.load(RecordPage);
  const caseRecordPage = await recordPageRoot.getCaseRecordPage();

  await browser.pause(1000);

  let tabset: Tabset2;
  let tab: UtamBasePageObject | undefined;

  switch (tabName) {
    case "Case Notes":
      tabset = await caseRecordPage.getCaseNotesTabset();
      tab = await commonUtils.clickTabByLabelAndGetContent(
        tabset,
        tabName,
        CaseNotesTab
      );
      break;
    case "Calls":
      tabset = await caseRecordPage.getChatsTabset();
      tab = await commonUtils.clickTabByLabelAndGetContent(
        tabset,
        tabName,
        CaseCallsTab
      );
      break;
    case "Details":
      tabset = await caseRecordPage.getDetailsTabset();
      tab = await commonUtils.clickTabByLabelAndGetContent(
        tabset,
        tabName,
        CaseDetailsTab
      );
      break;
    default:
      tab = undefined;
  }

  return tab;
};

export const getHighlightsPanel = async (): Promise<LwcHighlightsPanel> => {
  const recordPageRoot = await utam.load(RecordPage);
  const caseRecordPage = await recordPageRoot.getCaseRecordPage();
  const highlightsPanel = await caseRecordPage.getHighlightsPanel();
  return highlightsPanel;
};

export const closeCase = async (
  statusFieldIndex: FieldSectionIndex,
  closedOptionIndex: PicklistOptionIndexRange
): Promise<void> => {
  const baseRecordForm = (await getRecordForm())!;
  const recordLayout = await baseRecordForm.getRecordLayout();

  await commonUtils.selectPicklistOnRecordLayout(
    recordLayout,
    statusFieldIndex,
    closedOptionIndex
  );
  await commonUtils.clickFormFooterButtonByTitle("Save", baseRecordForm);
  await browser.pause(4000);

  const statusField = await commonUtils.getFieldFromRecordLayout(
    recordLayout,
    statusFieldIndex
  );
  expect(await (await statusField.getFormattedText()).getInnerText()).toEqual(
    "Closed"
  );
};
