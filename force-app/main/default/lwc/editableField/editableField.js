import { LightningElement, api } from "lwc";

export default class EditableField extends LightningElement {
  @api rowId;
  @api name;
  @api label;
  @api value;
  @api helpText;
  @api isRequired;
  @api isInvalid = false;
  @api readOnly = false;
  @api validationErrorForAccountClosureReason;
  @api validationErrorForAccountName;
  @api validationErrorForAccountBsb;
  @api validationErrorForAccountNumber;

  @api options = [];

  get errorsMsgs() {
    if (!this.isInvalid) {
      return [];
    }
    let errorList = [];
    if (this.validationErrorForAccountClosureReason) {
      errorList.push(this.validationErrorForAccountClosureReason);
    }
    if (this.validationErrorForAccountName) {
      errorList.push(this.validationErrorForAccountName);
    }
    if (this.validationErrorForAccountBsb) {
      errorList.push(this.validationErrorForAccountBsb);
    }
    if (this.validationErrorForAccountNumber) {
      errorList.push(this.validationErrorForAccountNumber);
    }
    return errorList;
  }

  get isInputField() {
    return this.type === "input";
  }

  get isComboboxField() {
    return this.type === "combobox";
  }

  @api
  get type() {
    // Default to input if no type is specified
    return this._type || "input";
  }

  set type(value) {
    this._type = value;
  }

  handleInputChange(event) {
    const value = event.target.value;
    const name = event.target.name;
    const rowId = this.rowId;

    // Dispatch the custom event to the parent with field change data
    const changeEvent = new CustomEvent("fieldchange", {
      detail: { rowId, name, value }
    });
    this.dispatchEvent(changeEvent);
  }
}
