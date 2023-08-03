import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";
import { LightningElement, track, api } from "lwc";
import tmp from "./customerAccount.html";
const FINANCIAL_DIFFICULTY = "4";
const COLLECTIONS = "17";
const EXCL_ACC = ["CAP-CIS:APP", "CAP-CIS:CAP", "CAP-CIS:CAB", "CAP-CIS:MOS"];

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
      this.clearAccountFields(this._omniData.Case.ComplaintDetails);
    }
  }

  get omniJsonData() {
    return this._omniData;
  }

  render() {
    return tmp;
  }

  //To clear Account number 2 and Account number 3 fields
  clearAccountFields(data) {
    if (
      data &&
      data.Issue2Checkbox === "No" &&
      data.AccountPolicyNumber2 &&
      this.omniJsonDef.name === "AccountPolicyNumber2"
    ) {
      this.omniUpdateDataJson("");
      this.value = "";
      this.allValues = [];
    }
    if (
      data &&
      (data.Issue2Checkbox === "No" || data.Issue3Checkbox === "No") &&
      data.AccountPolicyNumber3 &&
      this.omniJsonDef.name === "AccountPolicyNumber3"
    ) {
      this.omniUpdateDataJson("");
      this.value = "";
      this.allValues = [];
    }
  }

  populateAccountNumbers(data) {
    this.options = [];
    if (data && data.Response && data.Response.accounts) {
      let accounts = data.Response.accounts;
      let cmpDet = data.Case.ComplaintDetails;
      if (
        ((cmpDet.IssueType === COLLECTIONS ||
          cmpDet.IssueType === FINANCIAL_DIFFICULTY) &&
          this.omniJsonDef.name === "AccountPolicyNumber") ||
        ((cmpDet.IssueType2 === COLLECTIONS ||
          cmpDet.IssueType === FINANCIAL_DIFFICULTY) &&
          this.omniJsonDef.name === "AccountPolicyNumber2") ||
        ((cmpDet.IssueType3 === COLLECTIONS ||
          cmpDet.IssueType === FINANCIAL_DIFFICULTY) &&
          this.omniJsonDef.name === "AccountPolicyNumber3")
      ) {
        accounts.forEach((acc) => {
          if (!EXCL_ACC.includes(acc.productCode)) {
            this.options.push({
              label: acc.accountNumber,
              value: acc.accountNumber
            });
          }
        });
      } else {
        accounts.forEach((acc) => {
          this.options.push({
            label: acc.accountNumber,
            value: acc.accountNumber
          });
        });
      }
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
    accString = accString.substring(0, accString.length - 1);
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
      if (
        this.allValues &&
        this.allValues.length > 0 &&
        this.allValues.indexOf("N/A") !== -1
      )
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
