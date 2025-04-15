import { LightningElement, api, track } from "lwc";
import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";

export default class CustomerIdentifier extends OmniscriptBaseMixin(
  LightningElement
) {
  @track _omniData;
  isReadOnly = false;
  hasSetCustomerIdentifier = false;

  picklistoptions = [
    { label: "--Clear--", value: " " },
    { label: "Customer/Business CAP ID", value: "Customer/Business CAP ID" },
    { label: "CACHE ID", value: "CACHE ID" }
  ];

  selectedValue = "Customer/Business CAP ID";

  @api set omniJsonData(data) {
    this._omniData = data;
    if (data && data.Case) {
      this.isReadOnly = this.setisReadOnly(this._omniData);

      if (!this.hasSetCustomerIdentifier) {
        this.hasSetCustomerIdentifier = true;
        this.setCustomeridentifier();
      }
    }
  }

  get omniJsonData() {
    return this._omniData;
  }

  setisReadOnly(data) {
    if (!data.enableAccountLookUp) {
      return false;
    }
    return !data.isEligibleAppForLookUp &&
      data.Case.isThisCustomerComplaint === "Yes" &&
      data.Case?.AccountId
      ? true
      : false;
  }

  handleChange(event) {
    this.selectedValue = event.target.value;
    this.setCustomeridentifier();
  }

  setCustomeridentifier() {
    let Case = JSON.parse(JSON.stringify(this.omniJsonData.Case));
    Case.CustomerDetails.CustomerIdentifier = this.selectedValue;
    this.omniApplyCallResp({ Case });
  }
}
