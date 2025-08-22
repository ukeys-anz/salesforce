import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";
import { LightningElement, track, api, wire } from "lwc";
import getCustomerInfoLWC from "@salesforce/apex/IDRAPIRepository.getCustomerInfoLWC";
import getFinancialAccounts from "@salesforce/apex/GetCustomerInformation.fetchCustomerFinancialAccounts";
import logOCVError from "@salesforce/apex/IDRCaseActionsHelper.logOCVError";
import { getAccoutProductkeys } from "c/utils";

const FINANCIAL_DIFFICULTY = "4";
const COLLECTIONS = "17";
const EXCL_ACC = ["CAP-CIS:APP", "CAP-CIS:CAP", "CAP-CIS:CAB", "CAP-CIS:MOS"];
export default class CustomerAccount extends OmniscriptBaseMixin(
  LightningElement
) {
  @track options = [];
  @track _omniData;
  @track value;
  @track allValues = [];
  @track allSelected = false;
  customerCapId;
  customerIdentifier;
  ocvId;
  accId;
  financialAccounts = [];
  hasError = false;
  capIdAccounts = [];

  @api set omniJsonData(data) {
    this._omniData = data;
    if (data && data.Case) {
      this.customerCapId =
        data?.data?.fields.Source_System_ID__c.value?.replace(/^0+/, "");
      this.customerIdentifier = data.Case.CustomerDetails.CustomerIdentifier;
      this.ocvId = data?.data?.fields.OCV_ID__c.value;
      this.accId = data?.Case?.AccountId;
      this.populateAccountNumbers(this._omniData);
      this.validateNAoption(this._omniData);
      this.clearAccountFields(this._omniData.Case.ComplaintDetails);
    }
  }

  get omniJsonData() {
    return this._omniData;
  }

  //To clear Account number 2 and Account number 3 fields
  clearAccountFields(data) {
    if (
      data?.Issue2Checkbox === "No" &&
      data?.AccountPolicyNumber2 &&
      this.omniJsonDef.name === "AccountPolicyNumber2"
    ) {
      this.omniUpdateDataJson("");
      this.value = "";
      this.allValues = [];
    }
    if (
      (data?.Issue2Checkbox === "No" || data?.Issue3Checkbox === "No") &&
      data?.AccountPolicyNumber3 &&
      this.omniJsonDef.name === "AccountPolicyNumber3"
    ) {
      this.omniUpdateDataJson("");
      this.value = "";
      this.allValues = [];
    }
  }

  @wire(getCustomerInfoLWC, {
    customerId: "$customerCapId",
    customerIdentifier: "$customerIdentifier"
  })
  wiredFetchAccounts({ error, data }) {
    if (error?.body.message === "OCV Down") {
      this.getFinancialAccountData();
      logOCVError({
        message: error.body.message,
        customerId: this.customerCapId
      });
    }
    this.capIdAccounts = data?.accounts;
    this.allValues = [];
    this.populateAccountNumbers(this._omniData);
  }

  populateAccountNumbers(data) {
    this.options = [];
    if (this.checkForCacheCustomer(data)) {
      this.createAccountOptions(
        data.Response.accounts,
        this.checkIssueTypeChange(data.Case.ComplaintDetails)
      );
    }
    if (this.capIdAccounts?.length && this.checkCustomerIdentifier(data)) {
      this.createAccountOptions(
        this.capIdAccounts,
        this.checkIssueTypeChange(data.Case.ComplaintDetails)
      );
      this.validateNAoption(data);
    }
    if (this.financialAccounts?.length && this.checkCustomerIdentifier(data)) {
      this.createFinancialAccountOptions(
        this.financialAccounts,
        this.checkIssueTypeChange(data.Case.ComplaintDetails)
      );
      this.validateNAoption(data);
    }

    // To select all Account/Policy Number values by default when Issue typen is 'Financial Difficulty & Hardship'
    if (
      data?.Case?.CustomerDetails?.complaintAbout &&
      !this.allValues?.length
    ) {
      this.allValues.push("N/A");
      this.value = "N/A";
    }
    let cmpDetails = data ? (data.Case ? data.Case.ComplaintDetails : "") : "";
    if (this.checkIssueTypeFDH(cmpDetails)) {
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
  async getFinancialAccountData() {
    if (!this.accId) {
      return;
    }
    this.hasError = true;
    let result = await getFinancialAccounts({
      accId: this.accId,
      ocvId: this.ocvId
    });
    if (!result) {
      return;
    }
    this.financialAccounts = result.map((i) => {
      let accNum = getAccoutProductkeys(
        i.FinServ__FinancialAccount__r.Account_Key__c
      );
      return accNum;
    });

    this.populateAccountNumbers(this._omniData);
  }

  createAccountOptions(accounts, issueTypeChange) {
    if (!Array.isArray(accounts)) {
      return;
    }
    this.options = [];
    if (issueTypeChange) {
      this.options = this.getAccountNumbers(accounts);
    } else {
      this.options = accounts.map((i) => {
        return { label: i.accountNumber, value: i.accountNumber };
      });
    }
  }
  createFinancialAccountOptions(finacialAccounts, issueTypeChange) {
    if (!Array.isArray(finacialAccounts)) {
      return;
    }
    if (issueTypeChange) {
      this.options = this.getAccountNumbers(finacialAccounts);
    } else {
      this.options = finacialAccounts.map((i) => {
        return { label: i, value: i };
      });
    }
  }

  getAccountNumbers(data) {
    if (this.hasError) {
      return data
        .filter((i) => !EXCL_ACC.includes(i))
        .map((i) => {
          return {
            label: i,
            value: i
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
  checkIssueTypeFDH(cmpDet) {
    return (
      (cmpDet.IssueType === FINANCIAL_DIFFICULTY &&
        this.omniJsonDef.name === "AccountPolicyNumber") ||
      (cmpDet.IssueType2 === FINANCIAL_DIFFICULTY &&
        this.omniJsonDef.name === "AccountPolicyNumber2") ||
      (cmpDet.IssueType3 === FINANCIAL_DIFFICULTY &&
        this.omniJsonDef.name === "AccountPolicyNumber3")
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
  checkIssueTypeChange(cmpDet) {
    return (
      ((cmpDet.IssueType === COLLECTIONS ||
        cmpDet.IssueType === FINANCIAL_DIFFICULTY) &&
        this.omniJsonDef.name === "AccountPolicyNumber") ||
      ((cmpDet.IssueType2 === COLLECTIONS ||
        cmpDet.IssueType2 === FINANCIAL_DIFFICULTY) &&
        this.omniJsonDef.name === "AccountPolicyNumber2") ||
      ((cmpDet.IssueType3 === COLLECTIONS ||
        cmpDet.IssueType3 === FINANCIAL_DIFFICULTY) &&
        this.omniJsonDef.name === "AccountPolicyNumber3")
    );
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
      if (!this.options.some((opt) => opt.value === "N/A")) {
        this.options.push({ label: "N/A", value: "N/A" });
      }
    } else {
      if (this.allValues?.length && this.allValues.indexOf("N/A") !== -1)
        this.allValues.splice(this.allValues.indexOf("N/A"), 1);
    }
    if (data?.Case?.CustomerDetails) {
      if (data.Case.CustomerDetails.expressCaseCreationCheckbox === "Yes") {
        this.expCase = "Yes";
      }
      if (
        data?.Case?.CustomerDetails?.expressCaseCreationCheckbox === "No" &&
        this.expCase === "Yes"
      ) {
        this.allValues.splice(this.allValues.indexOf("N/A"), 1);
        this.value = "";
      }
    }
  }
}
