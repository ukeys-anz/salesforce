import {
  fieldUrlLinkCreator,
  allFieldsObjectCreator,
  changeDateFieldDisplayValue
} from "./helper-field-factory";
import {
  infoFields,
  fieldNameToObjectNameMap,
  dateFields,
  recordTitleField,
  fieldsWithUrl,
  removeFieldToObjectNameMap
} from "./helper-sf-const";

const removeExtraField = (allFieldsObject, recordFieldValue, field) => {
  let deletedField = false;
  if (!recordFieldValue && removeFieldToObjectNameMap.includes(field)) {
    delete allFieldsObject[field];
    deletedField = true;
  }
  return deletedField;
};

const convertRowTitleFieldName = (allFieldsObject, field, recordFieldValue) => {
  return recordTitleField.includes(field)
    ? (allFieldsObject.rowTitle = recordFieldValue)
    : (allFieldsObject[field] = recordFieldValue);
};

const fillFieldValue = (allFieldsObject, field, recordFieldValue) => {
  allFieldsObject[field].hasOwnProperty("value")
    ? (allFieldsObject[field].value = recordFieldValue)
    : convertRowTitleFieldName(allFieldsObject, field, recordFieldValue);
  return allFieldsObject;
};

const fillFieldUrl = (allFieldsObject, field, recordId) => {
  if (fieldsWithUrl.includes(field)) {
    const usageTypeValue = allFieldsObject.rowTitle;
    const objectName = fieldNameToObjectNameMap[usageTypeValue];
    allFieldsObject[field] = fieldUrlLinkCreator(objectName, recordId);
  }
  return allFieldsObject;
};

const updateDateFieldValue = (allFieldsObject, field) => {
  if (dateFields.includes(field))
    allFieldsObject[field].value = changeDateFieldDisplayValue(
      allFieldsObject[field].value
    );
  return allFieldsObject;
};

const fillRecordObject = (record) => {
  const allFieldsObject = allFieldsObjectCreator();
  for (const field in allFieldsObject) {
    const recordFieldValue = record[field];
    if (removeExtraField(allFieldsObject, recordFieldValue, field)) continue;
    fillFieldValue(allFieldsObject, field, recordFieldValue);
    fillFieldUrl(allFieldsObject, field, record.Id);
    updateDateFieldValue(allFieldsObject, field);
  }
  return allFieldsObject;
};

const recordObjectCreator = (record) => {
  const allFieldsObject = fillRecordObject(record);
  const res = { info: [] };
  for (const field in allFieldsObject) {
    infoFields.includes(field)
      ? res.info.push(allFieldsObject[field])
      : (res[field] = allFieldsObject[field]);
  }
  return res;
};

export function recordsPrepration(records) {
  return records.map((record) => recordObjectCreator(record));
}
