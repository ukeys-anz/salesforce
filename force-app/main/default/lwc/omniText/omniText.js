import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";
import { LightningElement, track } from "lwc";
import tmp from "./omniText.html";

export default class OmniText extends OmniscriptBaseMixin(LightningElement) {
  @track isRequired = false;
  @track isPicklist = false;
  @track isText = false;
  @track options = [];
  @track value;

  connectedCallback() {
    if (this.omniJsonDef && this.omniJsonDef.name === "Country") {
      this.getOptions("", "", "", "getCountryPicklist");
      this.value = "Australia";
      this.getOptions(
        "IDR_NC_Country__c",
        "IDR_NC_State__c",
        this.value,
        "getDependentValues"
      );
    } else if (this.omniJsonDef && this.omniJsonDef.name === "State") {
      this.isPicklist = true;
    } else {
      this.isText = true;
    }
  }

  render() {
    if (this.omniJsonData && this.omniJsonData.Case)
      this.setRequired(this.omniJsonData.Case);
    if (
      this.omniJsonData &&
      this.omniJsonData.States &&
      this.omniJsonDef.name === "State"
    ) {
      this.options = [];
      this.omniJsonData.States.options.forEach((opt) => {
        this.options.push({ label: opt.value, value: opt.name });
      });
    }
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
      (this.omniJsonDef.name === "Street" ||
        this.omniJsonDef.name === "Suburb" ||
        this.omniJsonDef.name === "State" ||
        this.omniJsonDef.name === "Country")
    ) {
      this.isRequired = true;
    } else {
      this.isRequired = false;
    }
  }

  handleChange(event) {
    this.value = event.target.value;
    this.omniUpdateDataJson(this.value);
    if (event.target.name === "Country") {
      this.getOptions(
        "IDR_NC_Country__c",
        "IDR_NC_State__c",
        this.value,
        "getDependentValues"
      );
    }
  }

  /*
    This is method to call Apex CLass to fetch Country and State fields
    */
  getOptions(ctrlField, dependentField, ctrlFieldValue, methodName) {
    const inputs = {
      fieldName: ctrlField,
      dependField: dependentField,
      fieldValue: ctrlFieldValue
    };
    const params = {
      input: JSON.stringify(inputs),
      sClassName: "IDR_FetchPicklistValues",
      sMethodName: methodName,
      options: {}
    };
    this.omniRemoteCall(params, true).then((res) => {
      if (dependentField) {
        this.omniApplyCallResp({ States: res.result });
      } else {
        res.result.options.forEach((opt) => {
          this.options.push({ label: opt.value, value: opt.name });
        });
        this.isPicklist = true;
      }
    });
  }
}
