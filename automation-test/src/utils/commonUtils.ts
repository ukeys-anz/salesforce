import BaseRecordForm from "@salesforce-pageobjects/records/pageObjects/baseRecordForm";
import ObjectHome from "pageObjects/objectHome";
import RecordLayout from "@salesforce-pageobjects/records/pageObjects/lwcRecordLayout";
import RecordLayoutItem from "@salesforce-pageobjects/records/pageObjects/recordLayoutItem";
import ChangeOwnerModal from "pageObjects/changeOwnerModal";
import GlobalSearch from "pageObjects/globalSearch";
import Tabset2 from "@salesforce-pageobjects/flexipage/pageObjects/tabset2";
import { FieldSectionIndex, PicklistOptionIndexRange } from "../types/layout";
import * as faker from "faker";
import { SObject, OwnerType } from "../constants/enums";
import { UtamBasePageObject } from "utam";
import { ContainerCtor } from "@utam/core";
import * as casePageUtils from "./casePageUtils";
import * as qaPageUtils from "./qualityAssessmentPageUtils";

/**
 * @description get a field from record layout
 * @param recordLayout record layout
 * @param fieldSectionIndex index array to define a field position on layout
 * @returns a field on specific section and row
 */
export const getFieldFromRecordLayout = async (
  recordLayout: RecordLayout,
  fieldSectionIndex: FieldSectionIndex
): Promise<RecordLayoutItem> => {
  const section = await recordLayout.getSection(fieldSectionIndex[0]);
  const row = await section.getRow(fieldSectionIndex[1]);
  const field = await row.getItem(fieldSectionIndex[2]);
  return field;
};

/**
 * @description select picklist/combobox from
 * @param recordLayout record layout
 * @param fieldSectionIndex index array to define a field position on layout
 * @param picklistOptionIndexRange picklist item indexes range
 * @param currentLayoutMode if inlineEditButton has been clicked or not to trigger edit layout
 */
export const selectPicklistOnRecordLayout = async (
  recordLayout: RecordLayout,
  fieldSectionIndex: FieldSectionIndex,
  picklistOptionIndexRange: PicklistOptionIndexRange
): Promise<void> => {
  const field = await getFieldFromRecordLayout(recordLayout, fieldSectionIndex);

  // scroll current field to window (viewport) center
  const fieldRoot = await field.getRoot();
  await fieldRoot.scrollToCenter();

  // if is output field, click inline edit button
  // otherwise it's an input field, which is already in edit mode
  if (!(await field.isInputField())) {
    await field.edit();
    await browser.pause(5000);
  }

  // click picklist and get selection items list
  const recordPicklist = await field.getRecordPicklist();
  const formPicklist = await recordPicklist!.getFormPicklist();
  const picklist = await formPicklist.getPicklist();
  const combobox = await picklist.getComboBox();
  const baseCombobox = await combobox!.getBase();
  await baseCombobox.expandForDisabledInput();

  let itemIndex: PicklistOptionIndexRange;

  if (typeof picklistOptionIndexRange === "number") {
    // use the specific item index
    itemIndex = picklistOptionIndexRange;
  } else {
    // get a random picklist item index, usually min starts from 2, as 1 is index of --None--
    itemIndex = faker.datatype.number({
      min: picklistOptionIndexRange[0],
      max: picklistOptionIndexRange[1]
    });
  }

  // find item and click it to select
  const item = await baseCombobox?.getItem(itemIndex);
  await item?.clickItem();
  await browser.pause(1000);
};

export const clickFormFooterButtonByTitle = async (
  buttonTitle: string,
  baseRecordForm: BaseRecordForm
): Promise<void> => {
  await browser.pause(1000);
  const footer = await baseRecordForm.getFooter();
  const actionsRibbon = await footer.getActionsRibbon();
  const action = await actionsRibbon.getActionRendererWithTitle(buttonTitle);
  await action.clickButton();
  await browser.pause(3000);
};

/**
 * @description enter value to a input field
 * @param field field on the page
 * @param text text value to input
 */
export const inputText = async (
  field: RecordLayoutItem,
  text: string
): Promise<void> => {
  const fieldInlineEditButton = await field.getInlineEditButton();
  await fieldInlineEditButton!.click();

  // get input field and set new value
  const inputField = await field.getTextInput();
  await inputField.setText(text);
};

export const assignNewOwner = async (
  sobject: SObject,
  ownerFieldIndex: FieldSectionIndex,
  ownerType: OwnerType,
  newOwnerName: string
): Promise<void> => {
  let baseRecordForm: BaseRecordForm | undefined;

  if (sobject === SObject.Case) {
    baseRecordForm = await casePageUtils.getRecordForm();
  } else if (sobject === SObject.Quality_Assessment) {
    baseRecordForm = await qaPageUtils.getRecordForm();
  }

  if (baseRecordForm !== undefined) {
    const recordLayout = await baseRecordForm.getRecordLayout();

    const ownerField = await getFieldFromRecordLayout(
      recordLayout,
      ownerFieldIndex
    );

    const ownerLookup = await ownerField.getOwnerLookup();
    const changeOwnerIcon = await ownerLookup.getChangeOwnerIcon();
    await changeOwnerIcon.clickButton();
    await browser.pause(6000);
    await searchAndSelectNewOwner(ownerType, newOwnerName);
  }
};

/**
 * @description search and select new record owner
 * @param ownerType value should be either Users or Queues
 * @param newOwnerName
 */
export const searchAndSelectNewOwner = async (
  ownerType: OwnerType,
  newOwnerName: string
): Promise<void> => {
  // load change owner modal
  const changeOwnerModalRoot = await utam.load(ChangeOwnerModal);

  await changeOwnerModalRoot.clickOwnerTypeDropDown();
  await browser.pause(1500);
  await changeOwnerModalRoot.selectOwnerType(ownerType);
  await browser.pause(1500);
  await changeOwnerModalRoot.clickSearchBox();
  await browser.pause(1500);
  await changeOwnerModalRoot.search(newOwnerName);
  await browser.pause(1500);
  await changeOwnerModalRoot.selectUser(newOwnerName);
  await browser.pause(1500);
  await changeOwnerModalRoot.save();

  // wait for page reload
  await browser.pause(5000);
};

/**
 * @description search record in Global Search bar with key words, select 1st result and redirect to record home
 * @param searchTerm
 */
export const searchRecordInGlobalSearchAndRedirect = async (
  searchTerm: string
): Promise<void> => {
  const globalSearchRoot = await utam.load(GlobalSearch);
  const resultList = await globalSearchRoot.search(searchTerm);
  await browser.pause(2000);
  await resultList.selectFirstResult();
  await browser.pause(5000);
};

/**
 * @description generate a random future date formatted string: DD/MM/YYYY
 * @returns a formatted date string: DD/MM/YYYY
 */
export const getRandomFutureDateFormattedString = (): string => {
  const today = new Date();
  const futureDay = new Date();
  futureDay.setDate(today.getDate() + 7);

  const futureDate = faker.date.between(today, futureDay);

  // format date and return
  return `${futureDate.getDate()}/${
    futureDate.getMonth() + 1
  }/${futureDate.getFullYear()}`;
};

/**
 * @description generate a random credit card string with 1111-1111-1111-1111 format
 * @returns credit card number string
 */
export const getCreditCardNumberString = (): string => {
  let ccNumStr: string;

  //https://stackoverflow.com/questions/59650010/regularexpression-for-16-digits-virtual-visa-cards-with-dash
  const reg = new RegExp("^4[0-9]{3}(?:-[0-9]{4}){3}$");

  do {
    // faker.finance.creditCardNumber randomly returns cc number for all format.
    // we only need visa or master card, which has 16 digital
    ccNumStr = faker.finance.creditCardNumber();
  } while (!ccNumStr.match(reg));

  return ccNumStr;
};

export const clickTabByLable = async (
  tabset2: Tabset2,
  tabLabel: string
): Promise<void> => {
  const tabset = await tabset2.getTabset();
  const tabBar = await tabset.getTabBar();
  await tabBar.clickTab(tabLabel);
};

export const clickTabByLabelAndGetContent = async (
  tabset2: Tabset2,
  tabLabel: string,
  content: ContainerCtor<UtamBasePageObject>
) => {
  await clickTabByLable(tabset2, tabLabel);

  const tabset = await tabset2.getTabset();
  return tabset.getActiveTabContent(content);
};

export const searchAndOpenListViewByName = async (listViewName: string) => {
  const objectHomeRoot = await utam.load(ObjectHome);
  await objectHomeRoot.searchListView(listViewName);
  // wait for the result to filter, move filter logic from utam file to code
  await browser.pause(1000);
  await objectHomeRoot.openListView();
  await browser.pause(1000);
};

export const openListViewByIndex = async (index: number) => {
  const objectHomeRoot = await utam.load(ObjectHome);
  const listViewSelector = await objectHomeRoot.getListViewSelector();
  await listViewSelector.click();
  await browser.pause(2000);
  const allListViews = await objectHomeRoot.getListViews();
  await allListViews[index].click();
};

export const openFirstRecordInListView = async () => {
  const objectHomeRoot = await utam.load(ObjectHome);
  await objectHomeRoot.openFirstRow();
  await browser.pause(5000);
};

export const editButtonIsNotVisible = async (
  recordLayout: RecordLayout,
  fieldIndex: FieldSectionIndex
) => {
  const fieldToCheck = await getFieldFromRecordLayout(recordLayout, fieldIndex);
  const fieldIsEditable = await fieldToCheck.getInlineEditButton();
  expect(await fieldIsEditable?.isVisible()).toBeUndefined();
};
