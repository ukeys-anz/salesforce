import { UtamBasePageObject } from "utam";
import RecordPage from "pageObjects/recordPage";
import QualityAssessmentDetailsTab from "pageObjects/qualityAssessmentDetailsTab";
import BaseRecordForm from "pageObjects/baseRecordForm";
import * as commonUtils from "utils/commonUtils";

export const getRecordForm = async (): Promise<BaseRecordForm | undefined> => {
  const detailsTab = await getTabContent("Details");

  if (detailsTab instanceof QualityAssessmentDetailsTab) {
    const detailPanel = await detailsTab.getDetailPanel();
    return detailPanel.getBaseRecordForm();
  }

  return;
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
