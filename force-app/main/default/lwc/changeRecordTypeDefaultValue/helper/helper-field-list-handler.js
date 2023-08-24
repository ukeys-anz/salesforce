import { fieldListArray, lookUpArray } from "./helper-field-list";

class FieldFactory {
  constructor(selectedRT, defaultFieldValues) {
    this.fieldList = fieldListArray(selectedRT);
    this.lookupArray = lookUpArray();
    this.defaultFieldValues = { ...defaultFieldValues };
    this.fieldListSet = new Set(fieldListArray(selectedRT));
    this.defaultFieldValuesSet = new Set(Object.keys(defaultFieldValues));
    this.lookupFields = [];
    this.allOtherFields = [];
  }

  booleanDefaultValueHandler = (defaultFieldValue) => {
    const result = {
      true: true,
      false: false
    };
    return result[defaultFieldValue] || defaultFieldValue;
  };

  fieldOnForm() {
    const fieldsToform = [...this.fieldListSet].filter((f) =>
      this.defaultFieldValuesSet.has(f)
    );
    const fieldList = this.fieldList.map((fieldName) => {
      const isDefaultValueFlag = fieldsToform.includes(fieldName);
      const isLookupFields = this.lookupArray.includes(fieldName);
      return {
        name: fieldName,
        value: isDefaultValueFlag
          ? this.booleanDefaultValueHandler(this.defaultFieldValues[fieldName])
          : "",
        defaultFieldValueFlag: isDefaultValueFlag,
        lookupFieldFlag: isLookupFields
      };
    });

    this.lookupFields = fieldList.filter((f) => f.lookupFieldFlag);
    this.allOtherFields = fieldList.filter((f) => !f.lookupFieldFlag);
  }

  fieldWithDefaultValueNotOnList() {
    const fieldsNotOnform = [...this.defaultFieldValuesSet].filter(
      (f) => !this.fieldListSet.has(f)
    );
    let resultObject = {};
    if (!fieldsNotOnform.length) return resultObject;
    fieldsNotOnform.forEach(
      (fieldName) =>
        (resultObject[fieldName] = this.booleanDefaultValueHandler(
          this.defaultFieldValues[fieldName]
        ))
    );
    return resultObject;
  }
}

export const fieldFactory = (selectedRT, defaultFieldValues) => {
  let fields = new FieldFactory(selectedRT, defaultFieldValues);
  fields.fieldOnForm();
  return {
    lookupFields: fields.lookupFields,
    allOtherFields: fields.allOtherFields,
    defaultValueFieldsNotOnForm: fields.fieldWithDefaultValueNotOnList()
  };
};
