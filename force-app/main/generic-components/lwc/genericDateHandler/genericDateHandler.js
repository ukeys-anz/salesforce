import { LightningElement, api } from "lwc";
import { getCustomformatDateTimeValue } from "c/genericUtils";

export default class GenericDateHandler extends LightningElement {
  @api field;
  _value; // private backing field

  @api
  get value() {
    return this._value;
  }
  set value(val) {
    this._value = val;
  }

  timeZone;
  needTime = true;
  dateFormat;

  connectedCallback() {
    this.needTime = true;
    this.dateFormat = "en-GB";
    this.timeZone = "Australia/Sydney";
  }

  get _fieldLabel() {
    if (this.field && Object.hasOwn(this.field, "fieldLabel")) {
      return this.field.fieldLabel;
    }
    return "";
  }

  get _dataValue() {
    if (this._value) {
      return getCustomformatDateTimeValue(this._value, {
        dateFormat: this.dateFormat,
        timeZone: this.timeZone,
        needTime: this.needTime
      });
    }
    return "";
  }

  set _dataValue(val) {
    this._value = val;
  }
}
