import { UtamBasePageObject } from "utam";
import RecordPage from "pageObjects/recordPage";
import QualityAssessmentDetailsTab from "pageObjects/qualityAssessmentDetailsTab";
import BaseRecordForm from "@salesforce-pageobjects/records/pageObjects/baseRecordForm";
import * as commonUtils from "../utils/commonUtils";

export const getRecordForm = async (): Promise<BaseRecordForm> => {
  const detailsTab = await getTabContent("Details");
  const detailPanel = await (
    detailsTab as QualityAssessmentDetailsTab
  ).getDetailPanel();
  return detailPanel.getBaseRecordForm();
};

export const getTabContent = async (
  tabName: string
): Promise<UtamBasePageObject | undefined> => {
  const recordPageRoot = await utam.load(RecordPage);
  const qaRecordPage = await recordPageRoot.getQualityAssessmentRecordPage();

  const tabset = await qaRecordPage.getDetailsTabset();
  const tab = await commonUtils.clickTabByLabelAndGetContent(
    tabset,
    tabName,
    QualityAssessmentDetailsTab
  );
  return tab;
};
