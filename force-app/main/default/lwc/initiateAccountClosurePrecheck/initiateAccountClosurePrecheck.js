import { LightningElement, api, wire } from "lwc";
import fetchEligibleCasesForPrecheck from "@salesforce/apex/AccountClosureController.fetchEligibleCasesForPrecheck";
import initiateAccountClosurePrecheck from "@salesforce/apex/AccountClosureController.initiateAccountClosurePrecheck";
import processResponsesAndUpdateCases from "@salesforce/apex/AccountClosureController.processResponsesAndUpdateCases";
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
  precheckResponse = [];
  responseDataSuccess = [];
  responseDataFailed = [];
  loading = false;
  eligibleCasesFound = false;
  isPrecheckSuccess = false;
  isPrecheckFailed = false;
  hasError = false;
  errorMsg;
  batchSize = 20;
  @api recordId;

  get showSuccessIcon() {
    return this.isPrecheckSuccess && !this.isPrecheckFailed && !this.hasError;
  }

  get showOnlyFailureText() {
    return !this.isPrecheckSuccess && this.isPrecheckFailed && !this.hasError;
  }

  get showSuccessSection() {
    return this.isPrecheckSuccess && !this.hasError;
  }

  get showFailureSection() {
    return this.isPrecheckFailed && !this.hasError;
  }

  get isPrecheckNotDone() {
    return (
      !this.isPrecheckSuccess &&
      !this.isPrecheckFailed &&
      this.eligibleCasesFound
    );
  }

  get isEligibleCasesFound() {
    return this.eligibleCasesFound;
  }

  @wire(fetchEligibleCasesForPrecheck, { parentCaseId: "$recordId" })
  getEligibleChildCasesForPrecheck({ data }) {
    try {
      if (data && data.length > 0) {
        this.eligibleChildCases = data;
        this.casesData = this.generateData(data);
        this.eligibleCasesFound = true;
      }
    } catch (error) {
      this.handleError();
    }
  }

  async handleInitiateAccountClosure() {
    this.loading = true;
    this.hasError = false;
    try {
      const childCasesBatches = this.createChildCaseBatches(
        this.eligibleChildCases,
        this.batchSize
      );
      const results = await Promise.allSettled(
        childCasesBatches.map((batch) =>
          initiateAccountClosurePrecheck({
            parentCaseId: this.recordId,
            eligibleCasesForPrecheck: batch
          })
            .then((response) => ({
              status: "fulfilled",
              caseDetails: batch,
              result: response
            }))
            .catch((error) => ({
              status: "rejected",
              caseDetails: batch,
              error: error.body ? error.body.message : error.message
            }))
        )
      );

      results.forEach((response) => {
        if (response.status === "fulfilled" && response?.value?.result) {
          this.precheckResponse.push(response?.value?.result);
        } else {
          this.handleRejectedResult(response.value.caseDetails);
        }
      });

      if (this.precheckResponse.length > 0) {
        await this.processPrecheckResponse(this.precheckResponse.flat());
      }
    } catch (error) {
      this.handleError();
    } finally {
      this.loading = false;
    }
  }

  createChildCaseBatches(casesRecords, batchSize) {
    const batches = [];
    for (let i = 0; i < casesRecords.length; i += batchSize) {
      batches.push(casesRecords.slice(i, i + batchSize));
    }
    return batches;
  }

  handleRejectedResult(caseDetails) {
    caseDetails.forEach((record) => {
      this.failedCases.push(record);
    });
  }

  async processPrecheckResponse(records) {
    try {
      const childCasesDetailsPostPrecheck =
        await processResponsesAndUpdateCases({
          fabricSealResponseList: records,
          eligibleCasesForPrecheck: this.eligibleChildCases
        });

      if (
        childCasesDetailsPostPrecheck &&
        childCasesDetailsPostPrecheck.length > 0
      ) {
        this.segregatePrecheckResults(childCasesDetailsPostPrecheck);
      }
    } catch (error) {
      this.handleError();
    }
  }

  segregatePrecheckResults(childCasesDetailsPostPrecheck) {
    childCasesDetailsPostPrecheck.forEach((record) => {
      if (record.Sub_Status__c === "Processing") {
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
