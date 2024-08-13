import { LightningElement, api, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { encodeDefaultFieldValues } from "lightning/pageReferenceUtils";
import { handleErrorShowToast, handleErrors } from "c/utils";

export default class CreateNewRecord extends NavigationMixin(LightningElement) {
  @api objectApiName;
  @api recordTypeName;
  @api defaultFieldValues;
  @api buttonLabel;

  recordTypeId;
  @wire(getObjectInfo, { objectApiName: "$objectApiName" })
  getRecord({ error, data }) {
    if (data && this.recordTypeName) {
      let objArray = data.recordTypeInfos;

      for (let i in objArray) {
        if (objArray[i].name === this.recordTypeName) {
          this.recordTypeId = objArray[i].recordTypeId;
          break;
        }
      }
    } else if (error) {
      this.handleError(error);
    }
  }

  get encodedDefaultValues() {
    if (!this.defaultFieldValues) {
      return null;
    }
    let encodedValues =
      typeof this.defaultFieldValues === "object"
        ? this.defaultFieldValues
        : JSON.parse(this.defaultFieldValues);

    return encodeDefaultFieldValues(encodedValues);
  }

  get buttonLabelName() {
    return !this.buttonLabel ? "Create New Record" : this.buttonLabel;
  }

  connectedCallback() {
    if (!this.objectApiName) {
      handleErrorShowToast(
        this,
        "Error",
        "",
        "Error on loading the component information",
        "pester"
      );
    }
  }

  createNewRecord() {
    let state = {
      nooverride: "1",
      defaultFieldValues: this.encodedDefaultValues,
      recordTypeId: this.recordTypeId
    };
    this[NavigationMixin.Navigate]({
      type: "standard__objectPage",
      attributes: {
        objectApiName: this.objectApiName,
        actionName: "new"
      },
      state: state
    });
  }

  handleError = (error) => {
    const errorMessage = handleErrors.call(this, error);
    handleErrorShowToast(this, "Error", "", errorMessage, "pester");
  };
}
