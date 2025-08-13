import { LightningElement, api } from "lwc";
import { getCustomformatDateTimeValue } from "c/genericUtils";

export default class GenericDateHandler extends LightningElement {
  @api field;
  @api value;
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
    if (this.value) {
      return (this.value = getCustomformatDateTimeValue(this.value, {
        dateFormat: this.dateFormat,
        timeZone: this.timeZone,
        needTime: this.needTime
      }));
    }
    return "";
  }

  set _dataValue(value) {
    this.value = value;
  }
}
