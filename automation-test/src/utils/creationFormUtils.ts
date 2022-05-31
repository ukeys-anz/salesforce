import RecordCreationForm from "pageObjects/recordCreationForm";
import RecordCreationFormField from "pageObjects/recordCreationFormField";
import RecordCreationFormPicklistOption from "pageObjects/recordCreationFormPicklistOption";
import { PicklistOptionIndexRange } from "types/layout";
import { FieldOptions, FieldDefinition } from "types/field";
import CaseFieldsDefinition from "constants/case/caseFieldsDefinition";
import KnowledgeFieldsDefinition from "constants/knowledge/knowledgeFieldsDefinition";
import * as faker from "faker";
import * as creationFormUtils from "utils/creationFormUtils";
import * as commonUtils from "utils/commonUtils";
import { SObject } from "constants/enums";

export const selectPicklist = async (
  picklistField: RecordCreationFormField,
  picklistDOMIndex: number,
  picklistOptionIndexRange: PicklistOptionIndexRange
): Promise<RecordCreationFormPicklistOption | null | void> => {
  const recordCreationFormRoot = await utam.load(RecordCreationForm);

  await picklistField.expandPicklist();

  // get picklist dropdown options
  const picklist = (await recordCreationFormRoot.getPicklists())[
    picklistDOMIndex
  ];

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

  // select an item from picklist
  await picklist.selectOptionByIndex(itemIndex);
};

// if we need to verify a specific select option in picklist
// then return this picklist option item for further verify
export const selectPicklistByOptionTitle = async (
  fieldLabel: string,
  picklistDOMIndex: number,
  optionTitle: string
): Promise<boolean> => {
  const recordCreationFormRoot = await utam.load(RecordCreationForm);
  const fields = await recordCreationFormRoot.getAllFields();

  if (!fields || fields.length === 0) {
    return false;
  }

  // get field from layout
  const field = await getFieldByLabel(fields, fieldLabel);

  if (!field) {
    return false;
  }

  // click picklist field to expand options
  await field.expandPicklist();

  // get picklist dropdown options
  const picklist = (await recordCreationFormRoot.getPicklists())[
    picklistDOMIndex
  ];

  const option = await picklist.getOptionByTitle(optionTitle);

  if (option) {
    await option.select();
    return true;
  }

  return false;
};

export const getFieldByLabel = async (
  fields: RecordCreationFormField[],
  label: string
): Promise<RecordCreationFormField | null> => {
  let field: RecordCreationFormField | null = null;
  let found = false;

  for (let i = 0; i < fields.length; i++) {
    const fieldLabel = await fields[i].getLabel();

    if (fieldLabel === label) {
      field = fields[i];
      found = true;
      break;
    }
  }

  if (found) {
    return field;
  }

  // different creation form behavior
  for (let i = 0; i < fields.length; i++) {
    const fieldLabel = await fields[i].getReadOnlyLabel();

    if (fieldLabel === label) {
      field = fields[i];
      break;
    }
  }

  return field;
};

export const fillInFields = async (
  sobject: SObject,
  fieldIndexMap: Map<string, number>,
  fieldsToFill: FieldDefinition[]
): Promise<Map<string, number>> => {
  const recordCreationFormRoot = await utam.load(RecordCreationForm);
  const fields = await recordCreationFormRoot.getAllFields();

  if (!fields || fields.length === 0) {
    return fieldIndexMap;
  }

  let currentIndex = 0;

  for (const fieldToFill of fieldsToFill) {
    const fieldIndex = fieldIndexMap.get(fieldToFill.label);

    // current field label and index have been resolved already, fill in the field
    if (fieldIndex !== undefined) {
      await fillInField(sobject, fields[fieldIndex], fieldToFill.options);
    }
    // current field label and index have not been resolved yet,
    // resolve the promise, get the label and mark the index, and fill in the field
    else {
      // only works if passing in the firstFieldIndex
      if (fieldToFill.options?.firstFieldIndex) {
        currentIndex = fieldToFill.options.firstFieldIndex;
      }

      for (let i = currentIndex; i < fields.length; i++) {
        const fieldLabel = await fields[i].getLabel();
        // save resolved label into cache, ignore null label
        // cache all labels in case fields passed in out-of-order
        if (fieldLabel) {
          fieldIndexMap.set(fieldLabel, i);
        }

        if (fieldLabel === fieldToFill.label) {
          await fillInField(sobject, fields[i], fieldToFill.options);
          currentIndex = ++i;
          break;
        }
      }
    }
  }

  await browser.pause(1000);
  return fieldIndexMap;
};

export const fillInField = async (
  sobject: SObject,
  field: RecordCreationFormField,
  fieldOptions?: FieldOptions
): Promise<void> => {
  const type = getFieldTypeByLabel(sobject, await field.getLabel());

  switch (type) {
    case "text":
      await fillInTextField(field, fieldOptions?.textContent);
      break;
    case "textarea":
      await fillInTextAreaField(field);
      break;
    case "number":
      await fillInNumberField(field);
      break;
    case "picklist":
      await fillInPicklistField(
        field,
        fieldOptions!.picklistDOMIndex!,
        fieldOptions!.picklistOptionIndexRange!
      );
      break;
    case "lookup":
      await fillInLookupField(field, fieldOptions!.lookupText!);
      break;
    case "date":
      await fillInDateField(field);
      break;
    default:
      console.error("Not a valid field.");
  }
};

const getFieldTypeByLabel = (sobject: SObject, label: string) => {
  let fieldDefinition: FieldDefinition;

  if (sobject === SObject.Case) {
    fieldDefinition = CaseFieldsDefinition.get(label)!;
  } else if (sobject === SObject.Knowledge) {
    fieldDefinition = KnowledgeFieldsDefinition.get(label)!;
  }

  return fieldDefinition!.type;
};

const fillInTextField = async (
  field: RecordCreationFormField,
  textContent?: string | undefined
): Promise<void> => {
  const content = textContent ? textContent : faker.datatype.string(100);
  await field.editText(content);
};

const fillInTextAreaField = async (
  field: RecordCreationFormField
): Promise<void> => {
  const fakeContent = faker.datatype.string(100);
  await field.editTextarea(fakeContent);
};

const fillInNumberField = async (
  field: RecordCreationFormField
): Promise<void> => {
  const fakeNumber = faker.datatype.number({ min: 1, max: 100 });
  await field.editNumber(fakeNumber.toString());
};

const fillInPicklistField = async (
  field: RecordCreationFormField,
  picklistDOMIndex: number,
  picklistOptionIndexRange: PicklistOptionIndexRange
): Promise<void> => {
  await creationFormUtils.selectPicklist(
    field,
    picklistDOMIndex,
    picklistOptionIndexRange
  );
};

const fillInLookupField = async (
  field: RecordCreationFormField,
  lookupText: string
): Promise<void> => {
  await field.clickLookup();
  await browser.pause(1000);
  await field.searchLookup(lookupText);
  await browser.pause(1000);
  await field.selectLookupResultByTitle(lookupText);
  await browser.pause(1000);
};

const fillInDateField = async (
  field: RecordCreationFormField
): Promise<void> => {
  const randomFutureDateStr = commonUtils.getRandomFutureDateFormattedString();
  await field.editText(randomFutureDateStr);
};
