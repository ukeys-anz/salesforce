import { LightningElement, api, wire } from "lwc";
import fetchEligibleCasesForPrecheck from "@salesforce/apex/AccountClosureController.fetchEligibleCasesForPrecheck";
import initiateAccountClosurePrecheck from "@salesforce/apex/AccountClosureController.initiateAccountClosurePrecheck";

import { CloseActionScreenEvent } from "lightning/actions";

const caseColumns = [
  { label: "Product", fieldName: "product" },
  { label: "Account Number", fieldName: "accountNumber" },
  { label: "Account Type", fieldName: "accountType" },
  {
    label: "Child Case Number",
    fieldName: "childCaseNumberUrl",
    type: "url",
    typeAttributes: { label: { fieldName: "childCaseNumber" } }
  }
];
export default class InitiateAccountClosurePrecheck extends LightningElement {
  caseColumns = caseColumns;
  casesData = [];
  eligibleChildCases = [];
  successfulCases = [];
  failureCases = [];
  responseDataSuccess = [];
  responseDataFailed = [];
  loading = true;
  isPrecheckSuccess = false;
  isPrecheckFailed = false;
  hasError = false;
  errorMsg;
  @api recordId;

  get showSuccessIcon() {
    return this.isPrecheckSuccess === true && this.isPrecheckFailed === false;
  }

  get showOnlyFailureText() {
    return this.isPrecheckSuccess === false && this.isPrecheckFailed === true;
  }

  get showSuccessSection() {
    return this.isPrecheckSuccess === true;
  }

  get showFailureSection() {
    return this.isPrecheckFailed === true;
  }

  get isPrecheckDone() {
    return this.isPrecheckSuccess === false && this.isPrecheckFailed === false;
  }

  @wire(fetchEligibleCasesForPrecheck, { parentCaseId: "$recordId" })
  getEligibleChildCasesForPrecheck({ data }) {
    this.loading = true;
    try {
      if (data && data.length > 0) {
        this.eligibleChildCases = data;
        this.casesData = this.generateData(data);
      }
    } catch (error) {
      this.handleError();
    } finally {
      this.loading = false;
    }
  }

  async handleInitiateAccountClosure() {
    this.loading = true;
    try {
      const childCasesDetailsPostPrecheck =
        await initiateAccountClosurePrecheck({
          parentCaseId: this.recordId,
          eligibleCasesForPrecheck: this.eligibleChildCases
        });
      this.segregatePrecheckResults(childCasesDetailsPostPrecheck);
    } catch (error) {
      this.handleError();
    } finally {
      this.loading = false;
    }
  }

  segregatePrecheckResults(childCasesDetailsPostPrecheck) {
    childCasesDetailsPostPrecheck.forEach((record) => {
      if (record.Sub_Status__c === "Success") {
        this.successfulCases.push(record);
      } else if (record.Sub_Status__c === "Failed") {
        this.failureCases.push(record);
      }
    });
    this.updateResponseData();
  }

  updateResponseData() {
    if (this.successfulCases.length > 0) {
      this.isPrecheckSuccess = true;
      this.responseDataSuccess = this.generateResponseData(
        this.successfulCases,
        true
      );
    }
    if (this.failureCases.length > 0) {
      this.isPrecheckFailed = true;
      this.responseDataFailed = this.generateResponseData(
        this.failureCases,
        false
      );
    }
  }

  handleCancel() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }

  handleError() {
    this.hasError = true;
    this.errorMsg =
      "Please try again. Raise a fault through TechAssist if the problem persists.";
  }

  generateData(caseRecords) {
    return caseRecords.map((caseRecord) => ({
      id: caseRecord.Id,
      product: caseRecord.Product.Name,
      accountNumber:
        caseRecord.FinServ__FinancialAccount__r
          .FinServ__FinancialAccountNumber__c,
      accountType:
        caseRecord.Account_Type__c === "Individual" ? "Sole" : "Joint",
      childCaseNumber: "#" + caseRecord.CaseNumber,
      childCaseNumberUrl: "/" + caseRecord.Id
    }));
  }

  generateResponseData(caseRecords, isSuccessIcon) {
    return caseRecords.map((caseRecord) => ({
      id: caseRecord.Id,
      product: caseRecord.Product.Name,
      accountNumber:
        caseRecord.FinServ__FinancialAccount__r
          .FinServ__FinancialAccountNumber__c,
      accountType:
        caseRecord.Account_Type__c === "Individual" ? "Sole" : "Joint",
      childCaseNumber: caseRecord.CaseNumber,
      isSuccessIcon: isSuccessIcon,
      workFlow: caseRecord.Status
    }));
  }
}
