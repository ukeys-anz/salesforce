import { LightningElement, api, wire } from "lwc";
import fetchChildCasesForClosure from "@salesforce/apex/AccountClosureController.fetchChildCasesForClosure";
import getPackageClosureAura from "@salesforce/apex/AccountClosureStravinskyController.getPackageClosureAura";
import updateCaseStatus from "@salesforce/apex/AccountClosureStravinskyController.updateCaseStatus";
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

export default class AccountClosureButton extends LightningElement {
  caseColumns = caseColumns;
  casesData = [];
  childCases = [];
  responseDataSuccess = [];
  responseDataFailed = [];
  successfulCases = [];
  failedCases = [];
  isAccountClosed = false;
  isAccountClosedSuccess = false;
  isAccountClosedFailure = false;
  hasError = false;
  errorMsg;
  error;

  @api recordId;

  @wire(fetchChildCasesForClosure, { parentCaseId: "$recordId" })
  wiredData({ data }) {
    try {
      if (data && data.length > 0) {
        this.childCases = data;
        this.casesData = this.generateData(data);
      }
    } catch (error) {
      if (error.body && error.body.message) {
        this.error = error.body.message;
      }
      this.handleError();
    }
  }

  get showSuccessIcon() {
    return (
      this.isAccountClosedSuccess === true &&
      this.isAccountClosedFailure === false
    );
  }

  async handleCloseAccounts() {
    try {
      const results = await Promise.allSettled(
        this.childCases.map((caseRecord) =>
          getPackageClosureAura({ recordId: caseRecord.Id })
            .then((response) => ({
              status: "fulfilled",
              caseDetails: caseRecord,
              result: response
            }))
            .catch((error) => ({
              status: "rejected",
              caseDetails: caseRecord,
              error: error.body ? error.body.message : error.message
            }))
        )
      );

      results.forEach((result) => {
        if (result.status === "fulfilled") {
          this.handleFulfilledResult(result.value);
        } else if (result.status === "rejected") {
          this.handleRejectedResult(result.reason.caseDetails);
        }
      });
      this.updateResponseData();
      await this.updateCaseStatusToClosed(this.successfulCases);
    } catch (error) {
      this.isAccountClosedSuccess = false;
      this.isAccountClosed = false;
      this.isAccountClosedFailure = false;
      if (error.body && error.body.message) {
        this.error = error.body.message;
      }
      this.handleError();
    }
  }

  handleFulfilledResult({ caseDetails, result }) {
    if (!result?.errorInfo && result?.accountsClosed > 0) {
      const successPackageData = this.generatePackageData(caseDetails);
      this.successfulCases.push(successPackageData);
    } else {
      const packageData = this.generatePackageData(caseDetails);
      this.failedCases.push(packageData);
    }
  }

  handleRejectedResult(caseDetails) {
    const failedPackageData = this.generatePackageData(caseDetails);
    this.failedCases.push(failedPackageData);
  }

  updateResponseData() {
    if (this.successfulCases.length > 0) {
      this.isAccountClosedSuccess = true;
      this.isAccountClosed = true;
      this.responseDataSuccess = this.generateResponseData(
        this.successfulCases,
        true
      );
    }
    if (this.failedCases.length > 0) {
      this.isAccountClosedFailure = true;
      this.isAccountClosed = true;
      this.responseDataFailed = this.generateResponseData(
        this.failedCases,
        false
      );
    }
  }

  generateResponseData(records, isSuccessIcon) {
    return records.map((record) => ({
      id: record.caseRecord.Id,
      product: record.caseRecord.Product.Name,
      accountNumber:
        record.caseRecord.FinServ__FinancialAccount__r
          .FinServ__FinancialAccountNumber__c,
      accountType:
        record.caseRecord.Account_Type__c === "Individual" ? "Sole" : "Joint",
      childCaseNumber: record.caseRecord.CaseNumber,
      isSuccessIcon: isSuccessIcon,
      workFlow: "Closed"
    }));
  }

  generateData(records) {
    return records.map((record) => ({
      id: record.Id,
      product: record.Product.Name,
      accountNumber:
        record.FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c,
      accountType: record.Account_Type__c === "Individual" ? "Sole" : "Joint",
      childCaseNumber: "#" + record.CaseNumber,
      childCaseNumberUrl: "/" + record.Id
    }));
  }

  generatePackageData(caseRecord) {
    return {
      caseRecord: caseRecord
    };
  }

  handleCancel() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }

  handleError() {
    this.hasError = true;
    this.errorMsg = this.error
      ? this.error
      : "Please try again. Raise a fault through TechAssist if the problem persists.";
  }

  async updateCaseStatusToClosed(records) {
    try {
      let caseIds = records.map((record) => record.caseRecord.Id);
      await updateCaseStatus({
        records: caseIds
      });
    } catch (error) {
      if (error.body && error.body.message) {
        this.error = error.body.message;
      }
      this.handleError();
    }
  }
}
