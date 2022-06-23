import { UtamBasePageObject } from "utam";
import RecordPage from "pageObjects/recordPage";
import LeadDetailsTab from "pageObjects/leadDetailsTab";
import LeadNotesTab from "pageObjects/leadNotesTab";
import BaseRecordForm from "@salesforce-pageobjects/records/pageObjects/baseRecordForm";
import Tabset2 from "@salesforce-pageobjects/flexipage/pageObjects/tabset2";
import * as commonUtils from "../utils/commonUtils";

export const getRecordForm = async (): Promise<BaseRecordForm | undefined> => {
  const detailsTab = await getTabContent("Details");

  if (detailsTab instanceof LeadDetailsTab) {
    const detailPanel = await detailsTab.getDetailPanel();
    return detailPanel.getBaseRecordForm();
  }

  return;
};

export const getTabContent = async (
  tabName: string
): Promise<UtamBasePageObject | undefined> => {
  const recordPageRoot = await utam.load(RecordPage);
  const leadRecordPage = await recordPageRoot.getLeadRecordPage();

  await browser.pause(1000);

  let tabset: Tabset2;
  let tab: UtamBasePageObject | undefined;

  switch (tabName) {
    case "Lead Notes":
      tabset = await leadRecordPage.getLeadNotesTabset();
      tab = await commonUtils.clickTabByLabelAndGetContent(
        tabset,
        tabName,
        LeadNotesTab
      );
      break;
    case "Details":
      tabset = await leadRecordPage.getDetailsTabset();
      tab = await commonUtils.clickTabByLabelAndGetContent(
        tabset,
        tabName,
        LeadDetailsTab
      );
      break;
    default:
      tab = undefined;
  }

  return tab;
};
