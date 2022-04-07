import { UtamBasePageObject } from "utam";
import CaseCreationForm from "pageObjects/caseCreationForm";
import RecordPage from "pageObjects/recordPage";
import CaseDetailsTab from "pageObjects/caseDetailsTab";
import CaseCallsTab from "pageObjects/caseCallsTab";
import CaseNotesTab from "pageObjects/caseNotesTab";
import BaseRecordForm from "pageObjects/baseRecordForm";
import Tabset2 from "pageObjects/tabset2";
import { fieldSectionIndex, picklistItemIndexRange } from "types/layout";
import { clickTabByLabelAndGetContent } from "./commonUtils";
import * as faker from "faker";
import * as commonUtils from "utils/commonUtils";

export const selectPicklistOnCreationForm = async (
  caseCreationFormRoot: CaseCreationForm,
  fieldSectionIndex: fieldSectionIndex,
  picklistItemIndexRange: picklistItemIndexRange,
  picklistDOMIndex: number
): Promise<void> => {
  // get field from layout
  await caseCreationFormRoot.selectPicklist(
    fieldSectionIndex[0],
    fieldSectionIndex[1],
    fieldSectionIndex[2]
  );

  let itemIndex: picklistItemIndexRange;

  if (typeof picklistItemIndexRange === "number") {
    // use the specific item index
    itemIndex = picklistItemIndexRange;
  } else {
    // get a random picklist item index, usually min starts from 2, as 1 is index of --None--
    itemIndex = faker.datatype.number({
      min: picklistItemIndexRange[0],
      max: picklistItemIndexRange[1]
    });
  }

  // get picklist dropdown
  const picklist = (await caseCreationFormRoot.getPicklistItemsLists())[
    picklistDOMIndex
  ];

  // select an item from picklist
  await picklist.selectPicklistItem(itemIndex);
};

export const getTabContent = async (
  tabName: string
): Promise<UtamBasePageObject | undefined> => {
  const recordPageRoot = await utam.load(RecordPage);
  const caseRecordPage = await recordPageRoot.getCaseRecordPage();

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

export const getRecordForm = async (): Promise<BaseRecordForm | undefined> => {
  const detailsTab = await getTabContent("Details");

  if (detailsTab instanceof CaseDetailsTab) {
    const detailPanel = await detailsTab.getDetailPanel();
    return detailPanel.getBaseRecordForm();
  }

  return;
};
