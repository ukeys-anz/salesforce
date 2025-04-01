import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";
import { LightningElement, track, api } from "lwc";
import getFinancialAccounts from "@salesforce/apex/GetCustomerInformation.fetchCustomerFinancialAccounts";
import tmp from "./customerAccount.html";
const FINANCIAL_DIFFICULTY = "4";
const COLLECTIONS = "17";
const EXCL_ACC = ["CAP-CIS:APP", "CAP-CIS:CAP", "CAP-CIS:CAB", "CAP-CIS:MOS"];
const POLICY_NUM = [
  "AccountPolicyNumber",
  "AccountPolicyNumber2",
  "AccountPolicyNumber3"
];

export default class CustomerAccount extends OmniscriptBaseMixin(
  LightningElement
) {
  @track options;
  @track _omniData;
  @track value;
  @track allValues = [];
  @track issueTypes = [];
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
      data.ComplaintDetails &&
      data.ComplaintDetails.Issue2Checkbox === "No" &&
      data.ComplaintDetails.AccountPolicyNumber2 &&
      this.omniJsonDef.name === "AccountPolicyNumber2" &&
      !data.CustomerDetails.complaintAbout
    ) {
      this.omniUpdateDataJson("");
      this.value = "";
      this.allValues = [];
    }
    if (
      data.ComplaintDetails &&
      (data.ComplaintDetails.Issue2Checkbox === "No" ||
        data.ComplaintDetails.Issue3Checkbox === "No") &&
      data.ComplaintDetails.AccountPolicyNumber3 &&
      this.omniJsonDef.name === "AccountPolicyNumber3" &&
      !data.CustomerDetails.complaintAbout
    ) {
      this.omniUpdateDataJson("");
      this.value = "";
      this.allValues = [];
    }
  }

  async populateAccountNumbers(data) {
    let cmpDet = data.Case.ComplaintDetails;
    let accountId = data.Case.AccountId;
    this.issueTypes = [cmpDet.IssueType, cmpDet.IssueType2, cmpDet.IssueType3];
    this.options = [];
    let issueTypeChange = this.checkIssueTypeChange(this.issueTypes);
    if (accountId && this.checkCustomerIdentifier(data)) {
      let result = await getFinancialAccounts({
        accId: accountId
      });
      if (!result) {
        return;
      }
      if (issueTypeChange) {
        this.options = this.getAccountNumbers(result, true);
      } else {
        this.options = result.map((i) => {
          let accNum = i?.Account_Key__c.substring(
            0,
            i?.Account_Key__c.indexOf("_")
          );
          return { label: accNum, value: accNum };
        });
      }
      this.validateNAoption(data);
    }

    if (this.checkForCacheCustomer(data)) {
      let accounts = data.Response.accounts;
      if (issueTypeChange) {
        this.options = this.getAccountNumbers(accounts, false);
      } else {
        this.options = accounts.map((i) => {
          return { label: i.accountNumber, value: i.accountNumber };
        });
      }
    }

    // To select all Account/Policy Number values by default when Issue typen is 'Financial Difficulty & Hardship'
    if (
      data.Case.CustomerDetails &&
      data.Case.CustomerDetails.complaintAbout &&
      !this.allValues.length > 0
    ) {
      this.allValues.push("N/A");
      this.value = "N/A";
    }
    let cmpDetails = data ? (data.Case ? data.Case.ComplaintDetails : "") : "";
    if (this.checkIssueTypeFDH(this.issueTypes)) {
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

  getAccountNumbers(data, isCustomer) {
    if (isCustomer) {
      return data
        .filter((i) => !EXCL_ACC.includes(i.FinServ__FinancialAccountType__c))
        .map((i) => {
          let accNum = i?.Account_Key__c.substring(
            0,
            i?.Account_Key__c.indexOf("_")
          );
          return {
            label: accNum,
            value: accNum
          };
        });
    }
    return data
      .filter((i) => !EXCL_ACC.includes(i.productCode))
      .map((i) => {
        return {
          label: i.accountNumber,
          value: i.accountNumber
        };
      });
  }
  checkCustomerIdentifier(data) {
    return (
      data.Case.CustomerDetails.CustomerIdentifier ===
        "Customer/Business CAP ID" && data.enableAccountLookUp === true
    );
  }
  checkIssueTypeFDH(issueTypes) {
    return (
      issueTypes.includes(FINANCIAL_DIFFICULTY) &&
      POLICY_NUM.includes(this.omniJsonDef.name)
    );
  }
  checkForCacheCustomer(data) {
    return (
      data?.Response?.accounts &&
      (data.Case.CustomerDetails.CustomerIdentifier === "CACHE ID" ||
        (data.Case.CustomerDetails.CustomerIdentifier ===
          "Customer/Business CAP ID" &&
          data.enableAccountLookUp === false))
    );
  }
  checkIssueTypeChange(issueTypes) {
    let financialIssues = [COLLECTIONS, FINANCIAL_DIFFICULTY];
    return (
      financialIssues.some((el) => issueTypes.includes(el)) &&
      POLICY_NUM.includes(this.omniJsonDef.name)
    );
  }

  handleChange(event) {
    this.value = event.target.value;
    if (!this.allValues.includes(this.value)) this.allValues.push(this.value);
    this.updateDataJson();
  }

  handleRemove(event) {
    if (this.checkIssueTypeFDH(this.issueTypes)) {
      return;
    }
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
