import { LightningElement, api } from "lwc";

export default class EditableField extends LightningElement {
  @api rowId;
  @api name;
  @api label;
  @api value;
  @api helpText;
  @api isInvalid = false;
  @api readOnly = false;
  @api isRequired;
  @api validationErrorForAccountClosureReason;
  @api validationErrorForAccountName;
  @api validationErrorForAccountBsb;
  @api validationErrorForAccountNumber;

  @api options = [];

  get isClosureReasonInvalid() {
    return this.isInvalid && this.validationErrorForAccountClosureReason;
  }

  get isAccountNameInvalid() {
    return this.isInvalid && this.validationErrorForAccountName;
  }

  get isAccountBsbInvalid() {
    return this.isInvalid && this.validationErrorForAccountBsb;
  }

  get isAccountNumberInvalid() {
    return this.isInvalid && this.validationErrorForAccountNumber;
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
