import { checkBoxFields, infoFields, fieldLabelMap } from "./helper-sf-const";

const fieldObjectCreator = (fieldName) => {
  const fieldInfoObj = { label: "", checkbox: false, value: "" };
  fieldInfoObj.label = fieldLabelMap[fieldName];
  fieldInfoObj.checkbox = checkBoxFields.includes(fieldName);
  return fieldInfoObj;
};

export function allFieldsObjectCreator() {
  const res = {};
  for (const field in fieldLabelMap) {
    res[field] = infoFields.includes(field) ? fieldObjectCreator(field) : "";
  }
  return res;
}

export function fieldUrlLinkCreator(object, recordId) {
  return `/lightning/r/${object}/${recordId}/view`;
}

export function changeDateFieldDisplayValue(dateValue) {
  return dateValue ? dateValue.split("-").reverse().join("/") : "";
}
