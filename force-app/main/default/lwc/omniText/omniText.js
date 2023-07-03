import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";
import { LightningElement, track } from "lwc";
import tmp from "./omniText.html";

export default class OmniText extends OmniscriptBaseMixin(LightningElement) {
  @track isRequired = false;
  @track isPicklist = false;
  @track isText = false;
  @track options = [];

  connectedCallback() {
    if (this.omniJsonDef && this.omniJsonDef.name === "Country") {
      this.isPicklist = true;
    } else {
      this.isText = true;
    }
  }

  render() {
    if (this.omniJsonData && this.omniJsonData.Case)
      this.setRequired(this.omniJsonData.Case);
    return tmp;
  }

  setRequired(data) {
    if (
      data.CustomerDecision === "Agrees" &&
      (this.omniJsonDef.name === "firstName" ||
        this.omniJsonDef.name === "LastName")
    ) {
      this.isRequired = true;
    } else if (
      (data.ResolutionInformation.custWrittenResponse === "Yes" ||
        data.ResolutionInformation.complaintRelatedHardship === "Yes") &&
      (this.omniJsonDef.name === "Street" || this.omniJsonDef.name === "Suburb")
    ) {
      this.isRequired = true;
    } else {
      this.isRequired = false;
    }
  }

  handleChange(event) {
    this.omniUpdateDataJson(event.target.value);
  }
}
