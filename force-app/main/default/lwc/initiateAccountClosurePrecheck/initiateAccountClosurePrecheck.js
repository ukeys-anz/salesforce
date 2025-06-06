import { LightningElement, api, wire } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import fetchEligibleCasesForPrecheck from "@salesforce/apex/AccountClosureController.fetchEligibleCasesForPrecheck";
import initiateAccountClosurePrecheck from "@salesforce/apex/AccountClosureController.initiateAccountClosurePrechecks";
import processResponsesAndUpdateCases from "@salesforce/apex/AccountClosureController.processResponsesAndUpdateCases";
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
export default class InitiateAccountClosurePrecheck extends LightningElement {
  caseColumns = caseColumns;
  customerOcvId;
  casesData = [];
  eligibleChildCases = [];
  successfulCases = [];
  failureCases = [];
  precheckResponse = [];
  responseDataSuccess = [];
  responseDataFailed = [];
  loading = false;
  hasFetchedCases = false;
  initialLoading = false;
  isPrecheckSuccess = false;
  isPrecheckFailed = false;
  hasError = false;
  errorMsg;
  batchSize = 20;
  @api recordId;

  get showSuccessIcon() {
    return this.isPrecheckSuccess && !this.isPrecheckFailed;
  }

  get showOnlyFailureText() {
    return !this.isPrecheckSuccess && this.isPrecheckFailed;
  }

  get showSuccessSection() {
    return this.isPrecheckSuccess;
  }

  get showFailureSection() {
    return this.isPrecheckFailed;
  }

  get isPrecheckNotDone() {
    return (
      !this.isPrecheckSuccess && !this.isPrecheckFailed && !this.initialLoading
    );
  }

  get showLoading() {
    return this.initialLoading || this.loading;
  }

  @wire(getRecord, { recordId: "$recordId", fields })
  wiredData({ data }) {
    try {
      if (data && !this.hasFetchedCases) {
        this.customerOcvId =
          data.fields?.Account?.value?.fields?.OCV_ID__c?.value;
        if (this.customerOcvId) {
          this.hasFetchedCases = true;
          this.getEligibleChildCasesForPrecheck();
        }
      }
    } catch (error) {
      this.handleError(error);
    }
  }

  async getEligibleChildCasesForPrecheck() {
    this.initialLoading = true;
    try {
      const caseDetails = await fetchEligibleCasesForPrecheck({
        parentCaseId: this.recordId
      });
      if (caseDetails && caseDetails.length > 0) {
        this.eligibleChildCases = caseDetails;
        this.casesData = this.generateData(caseDetails);
        this.initialLoading = false;
      }
    } catch (error) {
      this.handleError();
    }
  }

  async handleInitiateAccountClosure() {
    this.precheckResponse = [];
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
            customerOcvId: this.customerOcvId,
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
        if (response.status === "fulfilled") {
          const responsevalue = response?.value;
          if (responsevalue?.result) {
            this.precheckResponse.push(responsevalue?.result);
          } else if (
            responsevalue?.error &&
            responsevalue?.error.contains("salesforceCaseNumber")
          ) {
            this.precheckResponse.push(responsevalue?.error);
          }
        } else {
          this.handleRejectedResult(response.value.caseDetails);
        }
      });

      if (this.precheckResponse.length > 0) {
        await this.processPrecheckResponse(this.precheckResponse.flat());
      }
      await this.refreshTab();
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
      const processedResponses = this.generateResponseToProcess(records);
      const childCasesDetailsPostPrecheck =
        await processResponsesAndUpdateCases({
          accountClosurePrecheckResponse: processedResponses,
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
      product: caseRecord?.Product?.Name || null,
      accountNumber:
        caseRecord?.FinServ__FinancialAccount__r
          ?.FinServ__FinancialAccountNumber__c || null,
      accountType:
        caseRecord?.Account_Type__c === "Individual"
          ? "Sole"
          : caseRecord?.Account_Type__c,
      childCaseNumber: "#" + caseRecord.CaseNumber,
      childCaseNumberUrl: "/" + caseRecord.Id
    }));
  }

  generateResponseData(caseRecords, isSuccessIcon) {
    return caseRecords.map((caseRecord) => ({
      id: caseRecord.Id,
      product: caseRecord?.Product?.Name || null,
      accountNumber:
        caseRecord?.FinServ__FinancialAccount__r
          ?.FinServ__FinancialAccountNumber__c || null,
      accountType:
        caseRecord?.Account_Type__c === "Individual"
          ? "Sole"
          : caseRecord?.Account_Type__c,
      childCaseNumber: caseRecord.CaseNumber,
      isSuccessIcon: isSuccessIcon,
      workFlow: caseRecord.Status
    }));
  }

  generateResponseToProcess(records) {
    const processedResponses = records.map((response) => {
      const {
        salesforceCaseNumber,
        acceptance,
        unsatisfiedPreconditions,
        businessProcessId,
        code,
        message
      } = response;
      let failedReasons = [];

      if (acceptance === "ACCEPTANCE_REJECTED" && unsatisfiedPreconditions) {
        failedReasons = Object.keys(unsatisfiedPreconditions)
          .filter(
            (precheckKey) =>
              unsatisfiedPreconditions[precheckKey]?.eligibility ===
              "ELIGIBILITY_INELIGIBLE"
          )
          .map((precheckKey) => {
            return precheckKey === "nonzeroAvailableBalance"
              ? this.updatePrecheckKeyDynamic(
                  precheckKey,
                  unsatisfiedPreconditions[precheckKey]
                )
              : precheckKey;
          });
      }

      return {
        salesforceCaseNumber,
        acceptance,
        failedReasons,
        businessProcessId,
        code,
        message
      };
    });
    return processedResponses;
  }

  async refreshTab() {
    const { tabId } = await getFocusedTabInfo();
    await refreshTab(tabId, {
      includeAllSubtabs: false
    });
  }

  updatePrecheckKeyDynamic(precheckKey, precondition) {
    return parseFloat(precondition?.availableBalance?.units) > 0
      ? precheckKey + "_positive"
      : precheckKey + "_negative";
  }
}
