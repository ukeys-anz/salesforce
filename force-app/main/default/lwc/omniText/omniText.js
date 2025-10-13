import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";
import { LightningElement, track } from "lwc";
import tmp from "./omniText.html";
const addressFields = [
  "Country",
  "State",
  "Street",
  "Suburb",
  "CountryManual",
  "StateManual",
  "SuburbManual",
  "StreetManual"
];
const picklistFields = ["Country", "State", "CountryManual", "StateManual"];
export default class OmniText extends OmniscriptBaseMixin(LightningElement) {
  @track isRequired = false;
  @track isPicklist = false;
  @track isText = false;
  @track options = [];
  @track value;
  @track inpValue;

  isDisabled = false;

  setValues(data) {
    let typeOfAddress = this.omniJsonDef?.name;
    if (!addressFields.includes(typeOfAddress)) {
      return;
    }
    let addressValue = data?.CustomerDetails?.[typeOfAddress];
    this.isDisabled = this.checkforDisableInput(data) ?? false;
    if (picklistFields.includes(typeOfAddress) && addressValue) {
      this.value = addressValue;
      return;
    }
    this.inpValue = addressValue;
  }
  checkforDisableInput(data) {
    return (
      data?.disablAddress &&
      data?.CustomerDetails?.SearchAddressRadio === "Search Address"
    );
  }

  connectedCallback() {
    if (
      this.omniJsonDef?.name === "Country" ||
      this.omniJsonDef?.name === "CountryManual"
    ) {
      this.getOptions("", "", "", "getCountryPicklist");
      this.value = "Australia";
      this.getOptions(
        "IDR_NC_Country__c",
        "IDR_NC_State__c",
        this.value,
        "getDependentValues"
      );
    } else if (
      this.omniJsonDef?.name === "State" ||
      this.omniJsonDef?.name === "StateManual"
    ) {
      this.isPicklist = true;
    } else {
      this.isText = true;
    }
  }

  render() {
    if (this.omniJsonData?.Case?.isThisCustomerComplaint === "No") {
      this.setValues(this.omniJsonData?.Case);
    }
    if (this.omniJsonData?.Case) this.setRequired(this.omniJsonData.Case);
    if (
      this.omniJsonData?.States &&
      (this.omniJsonDef.name === "State" ||
        this.omniJsonDef.name === "StateManual")
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
      return;
    }
    if (
      (data.ResolutionInformation.custWrittenResponse === "Yes" ||
        data.ResolutionInformation.complaintRelatedHardship === "Yes") &&
      addressFields.includes(this.omniJsonDef.name)
    ) {
      this.isRequired = true;
      return;
    }
    this.isRequired = false;
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
