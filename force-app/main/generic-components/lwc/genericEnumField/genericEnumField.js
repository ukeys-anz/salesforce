import { LightningElement, api } from "lwc";

export default class GenericEnumField extends LightningElement {
  _value;
  _fieldColumn;
  _enumData;
  @api
  get value() {
    return this._value;
  }
  set value(value) {
    this._value = value;
  }
  @api
  get fieldColumn() {
    return (this._fieldColumn = this.value);
  }
  set fieldColumn(value) {
    this._fieldColumn = value;
  }

  @api
  get enumData() {
    return this._enumData;
  }
  set enumData(value) {
    this._enumData = value;
  }

  get displayValue() {
    let fieldKey = this._fieldColumn;
    if (typeof fieldKey === "string" && fieldKey.includes(".")) {
      const parts = fieldKey.split(".");
      fieldKey = parts[parts.length - 1];
    }
    const Key = `${fieldKey}:${this._value}`;
    const displayLabel = this.enumData?.[Key] ?? this._value;
    return displayLabel;
  }
}
