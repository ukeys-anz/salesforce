import RecordLayout from "pageObjects/lwcRecordLayout";
import RecordLayoutItem from "pageObjects/recordLayoutItem";

/**
 * @description get a field from record layout
 * @param layout record layout
 * @param sectionIndex index starts from 1, not 0
 * @param rowIndex index starts from 1, not 0
 * @param fieldIndex index starts from 1, not 0
 * @returns a field on specific section and row
 */
export const getFieldFromLayout = async (
  layout: RecordLayout,
  sectionIndex: number,
  rowIndex: number,
  fieldIndex: number
): Promise<RecordLayoutItem> => {
  const section = await layout.getSection(sectionIndex);
  const row = await section.getRow(rowIndex);
  const field = await row.getItem(fieldIndex);
  return field;
};

/**
 * @description select picklist/combobox from
 * @param field field on the page
 * @param valueIndex index starts from 1, not 0
 */
export const selectPicklist = async (
  field: RecordLayoutItem,
  valueIndex: number
): Promise<void> => {
  const fieldInlineEditButton = await field.getInlineEditButton();
  await fieldInlineEditButton.click();

  const picklist = await field.getPicklist();
  const combobox = await picklist.getComboBox();
  const baseCombobox = await combobox?.getBase();
  await baseCombobox?.expandForDisabledInput();

  const item = await baseCombobox?.getItem(valueIndex);
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
