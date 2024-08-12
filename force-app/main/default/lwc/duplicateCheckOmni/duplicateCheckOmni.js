import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";
import { LightningElement, track } from "lwc";
import { RefreshEvent } from "lightning/refresh";
import tmp from "./duplicateCheckOmni.html";

export default class DuplicateCheckOmni extends OmniscriptBaseMixin(
  LightningElement
) {
  loading = false;
  showError = false;
  showResult = false;
  custNo;
  @track missingFields = [];
  @track modalMsg;
  @track showModal = false;
  @track modalHeader = "Error";

  closeModal() {
    this.showModal = false;
  }
  render() {
    return tmp;
  }

  callDuplicateCheck() {
    this.showModal = false;
    this.showResult = false;
    this.missingFields = [];
    this.modalMsg = "";
    this.valCustomerFields();
    if (this.missingFields.length > 0) {
      this.modalMsg = "Customer Number is required for duplicate search.";
      this.showModal = true;
    } else {
      this.showModal = false;
      this.showResult = true;
      this.custNo =
        this.omniJsonData.Case.CustomerDetails.CustomerIdentifier ===
        "Customer/Business CAP ID"
          ? (this.custNo = this.omniJsonData.Case.CustomerDetails.Customer)
          : (this.custNo = this.omniJsonData.Case.CustomerDetails.Customer1);
      const inputsForIP = {
        customerIdentifier:
          this.omniJsonData.Case.CustomerDetails.CustomerIdentifier,
        customerId: this.custNo
      };

      const params = {
        input: JSON.stringify(inputsForIP),
        sClassName: "omnistudio.IntegrationProcedureService",
        sMethodName: "Case_getInfo",
        options: {}
      };

      this.omniRemoteCall(params, true)
        .then((response) => {
          let res = JSON.parse(JSON.stringify(response));
          this.omniApplyCallResp(res.result.IPResult);
        })
        .catch((error) => {
          window.console.log(error, "error");
        });
      return this.dispatchEvent(new RefreshEvent());
    }
    return null;
  }
  // Set input for duplicate search flow.
  get inputVariables() {
    return [
      {
        name: "CustomerNumber",
        type: "String",
        value: this.custNo
      }
    ];
  }
  // validate that the required field Customer Number for dupe search has been provided
  valCustomerFields() {
    if (
      (this.omniJsonData.Case.CustomerDetails.CustomerIdentifier ===
        "Customer/Business CAP ID" &&
        !this.omniJsonData.Case.CustomerDetails.Customer) ||
      (this.omniJsonData.Case.CustomerDetails.CustomerIdentifier ===
        "CACHE ID" &&
        !this.omniJsonData.Case.CustomerDetails.Customer1)
    ) {
      this.missingFields.push("Customer Number");
    }
  }
}
