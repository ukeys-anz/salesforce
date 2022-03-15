import RecordLayout from "pageObjects/lwcRecordLayout";
import RecordLayoutItem from "pageObjects/recordLayoutItem";
import ChangeOwnerModal from "pageObjects/changeOwnerModal";
import { ownerType } from "types/record";
import { fieldSectionIndex, picklistItemIndexRange } from "types/layout";
import * as faker from "faker";

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
