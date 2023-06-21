import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";
import { LightningElement, track, api } from "lwc";
import tmp from "./customerAccount.html";
const FINANCIAL_DIFFICULTY = "4";
export default class CustomerAccount extends OmniscriptBaseMixin(
  LightningElement
) {
  @track options;
  @track _omniData;
  @track value;
  @track allValues = [];
  @track allSelected = false;
  @api set omniJsonData(data) {
    this._omniData = data;
    if (data && data.Case) {
      this.populateAccountNumbers(this._omniData);
      this.validateNAoption(this._omniData);
    }
  }

  get omniJsonData() {
    return this._omniData;
  }

  render() {
    return tmp;
  }

  populateAccountNumbers(data) {
    this.options = [];
    if (data && data.Response && data.Response.accounts) {
      data.Response.accounts.forEach((acc) => {
        this.options.push({
          label: acc.accountNumber,
          value: acc.accountNumber
        });
      });
    }

    // To select all Account/Policy Number values by default when Issue typen is 'Financial Difficulty & Hardship'
    if (
      data.Case.CustomerDetails &&
      data.Case.CustomerDetails.complaintAbout &&
      !this.allValues.length > 0 &&
      this.omniJsonDef.name === "AccountPolicyNumber"
    ) {
      this.allValues.push("N/A");
      this.value = "N/A";
    }
    let cmpDetails = data ? (data.Case ? data.Case.ComplaintDetails : "") : "";
    if (
      (cmpDetails.IssueType === FINANCIAL_DIFFICULTY &&
        this.omniJsonDef.name === "AccountPolicyNumber") ||
      (cmpDetails.IssueType2 === FINANCIAL_DIFFICULTY &&
        this.omniJsonDef.name === "AccountPolicyNumber2") ||
      (cmpDetails.IssueType3 === FINANCIAL_DIFFICULTY &&
        this.omniJsonDef.name === "AccountPolicyNumber3")
    ) {
      this.allValues = [];
      this.options.forEach((acc) => {
        this.allValues.push(acc.value);
        this.value = acc.value;
      });
      if (!this.allSelected) {
        this.updateDataJson();
      }
      this.allSelected = true;
    } else if (
      cmpDetails.IssueType !== FINANCIAL_DIFFICULTY ||
      cmpDetails.IssueType2 !== FINANCIAL_DIFFICULTY ||
      cmpDetails.IssueType3 !== FINANCIAL_DIFFICULTY
    ) {
      if (this.allSelected) {
        this.allValues = [];
        this.value = "";
        this.allSelected = false;
        this.updateDataJson();
      }
    }
  }

  handleChange(event) {
    this.value = event.target.value;
    if (!this.allValues.includes(this.value)) this.allValues.push(this.value);
    this.updateDataJson();
  }

  handleRemove(event) {
    this.value = "";
    const valueRemoved = event.target.name;
    this.allValues.splice(this.allValues.indexOf(valueRemoved), 1);
    this.updateDataJson();
  }

  updateDataJson() {
    let accString = "";
    this.allValues.forEach((ele) => {
      accString = accString + ele + ";";
    });
    this.omniUpdateDataJson(accString);
  }

  validateNAoption(data) {
    if (
      (data.Case.displayNAOption &&
        this.omniJsonDef.name === "AccountPolicyNumber") ||
      (data.Case.displayNAOption2 &&
        this.omniJsonDef.name === "AccountPolicyNumber2") ||
      (data.Case.displayNAOption3 &&
        this.omniJsonDef.name === "AccountPolicyNumber3")
    ) {
      this.options.push({ label: "N/A", value: "N/A" });
    } else {
      if (this.allValues && this.allValues.length > 0)
        this.allValues.splice(this.allValues.indexOf("N/A"), 1);
    }
    if (data && data.Case && data.Case.CustomerDetails) {
      if (data.Case.CustomerDetails.expressCaseCreationCheckbox === "Yes") {
        this.expCase = "Yes";
      }
      if (
        data.Case.CustomerDetails.expressCaseCreationCheckbox === "No" &&
        this.expCase === "Yes"
      ) {
        this.allValues.splice(this.allValues.indexOf("N/A"), 1);
        this.value = "";
      }
    }
  }
}
