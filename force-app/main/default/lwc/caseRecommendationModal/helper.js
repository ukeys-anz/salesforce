import { getFieldValue } from "lightning/uiRecordApi";

export function computeLogic(filters, oldData, newData) {
  return filters.every((filter) => {
    const field = filter.field;

    const newValue = getFieldValue(newData, field);
    const oldValue = getFieldValue(oldData, field);

    const operator = filter.operator;
    const values = getValues(filter.value);

    if (operator === "equals") {
      return values.includes(newValue) && oldValue === newValue;
    }
    if (operator === "changedTo") {
      return values.includes(newValue) && newValue !== oldValue;
    }
    if (operator === "oldEquals") {
      return values.includes(oldValue);
    }

    const matchedValue = values.find((value) => newValue.includes(value));
    if (operator === "contains") {
      return matchedValue;
    }
    if (operator === "notContains") {
      return !matchedValue;
    }

    return false;
  });
}

function getValues(values) {
  const isArray = Array.isArray(values);
  if (!isArray) {
    return [values];
  }
  return values;
}
