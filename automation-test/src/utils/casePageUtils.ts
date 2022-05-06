import { UtamBasePageObject } from "utam";
import RecordPage from "pageObjects/recordPage";
import CaseDetailsTab from "pageObjects/caseDetailsTab";
import CaseCallsTab from "pageObjects/caseCallsTab";
import CaseNotesTab from "pageObjects/caseNotesTab";
import BaseRecordForm from "pageObjects/baseRecordForm";
import Tabset2 from "pageObjects/tabset2";
import * as commonUtils from "utils/commonUtils";

export const getCaseNumber = async (): Promise<string> => {
  const recordPageRoot = await utam.load(RecordPage);
  const caseRecordPage = await recordPageRoot.getCaseRecordPage();

  const highlightPanel = await caseRecordPage.getHighlights();
  const layout = await highlightPanel.getRecordLayout();
  const highlight = await layout.getHighlights2();
  const caseNumberFieldStr = await highlight.getSecondaryFieldText(3);
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
