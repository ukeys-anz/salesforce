import { LightningElement, api } from "lwc";

export default class GenericField extends LightningElement {
  @api field;
  @api value;

  get _fieldLabel() {
    if (this.field && Object.hasOwn(this.field, "fieldLabel")) {
      return this.field.fieldLabel;
    }
    return "";
  }
  get _dataValue() {
    if (this.value) {
      return this.value;
    }
    return "";
  }
  get isText() {
    if (this.field && Object.hasOwn(this.field, "inputType")) {
      return this.field.inputType === "text";
    }
    return false;
  }
  handleOnChange(event) {
    const value = event.target.value;
    this.dispatchEvent(
      new CustomEvent("changeinput", {
        detail: {
          fieldColumn: this.field.fieldColumn,
          fieldValue: value
        }
      })
    );
  }
}
