import { LightningElement, api, wire } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import fetchChildCasesForClosure from "@salesforce/apex/AccountClosureController.fetchChildCasesForClosure";
import getPackageClosureAura from "@salesforce/apex/AccountClosureStravinskyController.getPackageClosureAura";
import updateCaseStatusAndPostChatterMessage from "@salesforce/apex/AccountClosureStravinskyController.updateCaseStatusAndPostChatterMessage";
import { CloseActionScreenEvent } from "lightning/actions";
import { getFocusedTabInfo, refreshTab } from "lightning/platformWorkspaceApi";

const fields = ["Case.Account.OCV_ID__c"];

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
  isAccountClosedSuccess = "pending";
  isAccountClosedFailure = "pending";
  hasError = false;
  loading = false;
  intialloading = false;
  hasFetchedCases = false;
  errorMsg;
  customerOcvId;

  @api recordId;

  get showSuccessIcon() {
    return (
      this.isAccountClosedSuccess === "success" &&
      this.isAccountClosedFailure !== "failure"
    );
  }

  get showSuccessSection() {
    return this.isAccountClosedSuccess === "success";
  }

  get showFailureSection() {
    return this.isAccountClosedFailure === "failure";
  }

  get isAccountClosureComplete() {
    return (
      this.isAccountClosedSuccess === "pending" &&
      this.isAccountClosedFailure === "pending" &&
      !this.intialloading
    );
  }

  get showLoading() {
    return this.intialloading || this.loading;
  }

  @wire(getRecord, { recordId: "$recordId", fields })
  wiredData({ data }) {
    try {
      this.intialloading = true;
      if (data && !this.hasFetchedCases) {
        this.customerOcvId =
          data.fields?.Account?.value?.fields?.OCV_ID__c?.value;
        if (this.customerOcvId) {
          this.hasFetchedCases = true;
          this.getChildCasesForClosure();
        }
      }
    } catch (error) {
      this.handleError(error);
    }
  }

  async getChildCasesForClosure() {
    try {
      const caseDetails = await fetchChildCasesForClosure({
        parentCaseId: this.recordId
      });
      if (caseDetails && caseDetails.length > 0) {
        this.childCases = caseDetails;
        this.casesData = this.generateData(caseDetails);
        this.intialloading = false;
      }
    } catch (error) {
      this.handleError();
    }
  }

  async handleCloseAccounts() {
    try {
      this.loading = true;
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
      await this.refreshTab();
    } catch (error) {
      this.loading = false;
      this.handleError(error);
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
    this.loading = false;
    if (this.successfulCases.length > 0) {
      this.isAccountClosedSuccess = "success";
      this.responseDataSuccess = this.generateResponseData(
        this.successfulCases,
        true
      );
    }
    if (this.failedCases.length > 0) {
      this.isAccountClosedFailure = "failure";
      this.responseDataFailed = this.generateResponseData(
        this.failedCases,
        false
      );
    }
  }

  generateResponseData(records, isSuccessIcon) {
    return records.map((record) => ({
      id: record.caseRecord.Id,
      product: record.caseRecord?.Product?.Name || null,
      accountNumber:
        record.caseRecord?.FinServ__FinancialAccount__r
          ?.FinServ__FinancialAccountNumber__c || null,
      accountType:
        record.caseRecord.Account_Type__c === "Individual" ? "Sole" : "Joint",
      childCaseNumber: record.caseRecord.CaseNumber,
      isSuccessIcon: isSuccessIcon,
      workFlow: isSuccessIcon ? "Closed" : "Escalated"
    }));
  }

  generateData(records) {
    return records.map((record) => ({
      id: record.Id,
      product: record?.Product?.Name || null,
      accountNumber:
        record?.FinServ__FinancialAccount__r
          ?.FinServ__FinancialAccountNumber__c || null,
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
    this.errorMsg =
      "Please try again. Raise a fault through TechAssist if the problem persists.";
  }

  async updateCaseStatusToClosed(records) {
    try {
      let caseIds = records.map((record) => record.caseRecord.Id);
      await updateCaseStatusAndPostChatterMessage({
        records: caseIds
      });
    } catch (error) {
      this.handleError(error);
    }
  }

  async refreshTab() {
    const { tabId } = await getFocusedTabInfo();
    await refreshTab(tabId, {
      includeAllSubtabs: false
    });
  }
}
