import RecordLayout from "pageObjects/lwcRecordLayout";
import RecordLayoutItem from "pageObjects/recordLayoutItem";
import ChangeOwnerModal from "pageObjects/changeOwnerModal";
import GlobalSearch from "pageObjects/globalSearch";
import Tabset2 from "pageObjects/tabset2";
import { ownerType } from "types/record";
import { fieldSectionIndex, picklistItemIndexRange } from "types/layout";
import * as faker from "faker";
import { UtamBasePageObject } from "utam";
import { ContainerCtor } from "@utam/core";

/**
 * @description get a field from record layout
 * @param recordLayout record layout
 * @param fieldSectionIndex index array to define a field position on layout
 * @returns a field on specific section and row
 */
export const getFieldFromRecordLayout = async (
  recordLayout: RecordLayout,
  fieldSectionIndex: fieldSectionIndex
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
 * @param picklistItemIndexRange picklist item indexes range
 */
export const selectPicklistOnRecordLayout = async (
  recordLayout: RecordLayout,
  fieldSectionIndex: fieldSectionIndex,
  picklistItemIndexRange: picklistItemIndexRange
): Promise<void> => {
  // get field and click inline edit button
  const field = await getFieldFromRecordLayout(recordLayout, fieldSectionIndex);
  const fieldInlineEditButton = await field.getInlineEditButton();
  await fieldInlineEditButton.click();
  await browser.pause(2000);

  // click picklist and get selection items list
  const picklist = await field.getPicklist();
  const combobox = await picklist.getComboBox();
  const baseCombobox = await combobox?.getBase();
  await baseCombobox?.expandForDisabledInput();

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

  // find item and click it to select
  const item = await baseCombobox?.getItem(itemIndex);
  await item?.clickItem();
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
  await fieldInlineEditButton.click();

  // get input field and set new value
  const inputField = await field.getTextInput();
  await inputField.setText(text);
};

/**
 * @description search and select new record owner
 * @param ownerType value should be either Users or Queues
 * @param newOwnerName
 */
export const searchAndSelectNewOwner = async (
  ownerType: ownerType,
  newOwnerName: string
): Promise<void> => {
  // load change owner modal
  const ChangeOwnerModalRoot = await utam.load(ChangeOwnerModal);

  // click either Users or Queues and search and select first result
  ChangeOwnerModalRoot.searchAndSelectNewOwner(
    ownerType,
    newOwnerName,
    newOwnerName
  );

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
  await globalSearchRoot.searchAndRedirectToRecord(searchTerm, 1);
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
