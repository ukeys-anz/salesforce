import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";

export default class ChangeRecordTypeDefaultValue extends NavigationMixin(
  LightningElement
) {
  @api recordId;
  @api updatedRT;
  @api defaultValues;

  visibilityFlag = false;
  fields = [];
  loading = false;

  changedFields = [];

  connectedCallback() {
    let defaultValues = JSON.parse(this.defaultValues);
    for (let key in defaultValues) {
      if (typeof key !== "undefined") {
        this.fields.push({ name: key, value: defaultValues[key] });
      }
    }
    this.loading = true;
  }

  async handleNextPage() {
    await this.handleCancelButton();
    await this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: this.recordId,
        objectApiName: "Case",
        actionName: "edit"
      },
      state: {
        recordTypeId: this.updatedRT
      }
    });
  }

  handleCancelButton() {
    const cancelDefaultValue = new CustomEvent("canceldefaultvalue", {
      detail: { close: true }
    });
    // Fire the custom event
    this.dispatchEvent(cancelDefaultValue);
  }

  handleSendValues(event) {
    // stop the form from submitting
    event.preventDefault();
    //Get the fields
    const fields = event.detail.fields;
    //Set the field for the hidden lightning-input-field
    for (let i = 0; i < this.changedFields.length; i++) {
      let changedField = this.changedFields[i];
      fields[changedField.name] = changedField.value;
    }
    this.handleSubmit(event, fields);
  }

  handleSubmit(event, fields) {
    // stop the form from submitting
    event.preventDefault();
    //Submit the form
    this.template.querySelector(".submitRecordEditForm").submit(fields);
  }

  handleChosenValue(e) {
    let name = e.target.fieldName;
    let value = e.target.value;
    this.changedFields.push({ name, value });
  }
}
