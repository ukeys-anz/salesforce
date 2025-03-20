import { LightningElement, api, wire } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import fetchChildCasesCoP from "@salesforce/apex/ConfirmationOfPayeeController.fetchChildCasesCoP";
import initiateModifyConfirmationOfPayee from "@salesforce/apex/ConfirmationOfPayeeController.initiateModifyConfirmationOfPayee";
import { CloseActionScreenEvent } from "lightning/actions";
import { getFocusedTabInfo, refreshTab } from "lightning/platformWorkspaceApi";

const fields = ["Case.Account.OCV_ID__c"];

const caseColumns = [
  { label: "Product", fieldName: "product" },
  { label: "Account Number", fieldName: "accountNumber" },
  { label: "Account Type", fieldName: "accountType" },
  { label: "Current CoP Status", fieldName: "currCOPStatus" },
  { label: "Requested CoP Status", fieldName: "reqCOPStatus" },
  {
    label: "Child Case Number",
    fieldName: "childCaseNumberUrl",
    type: "url",
    typeAttributes: { label: { fieldName: "childCaseNumber" } }
  }
];

const responseColumns = [
  { label: "Product", fieldName: "productName" },
  { label: "Account Number", fieldName: "accountNumber" },
  { label: "Account Type", fieldName: "accountType" },
  {
    label: "Child Case Number",
    fieldName: "childCaseNumberUrl",
    type: "url",
    typeAttributes: { label: { fieldName: "caseNumber" } }
  }
];
export default class InitiateModifyCOPStatus extends LightningElement {
  caseColumns = caseColumns;
  responseColumns = responseColumns;
  customerOcvId;
  casesData = [];
  eligibleChildCases = [];
  successfulCases = [];
  failureCases = [];
  loading = false;
  hasFetchedCases = false;
  initialLoading = true;
  isModificationSuccess = false;
  isModificationFailed = false;
  hasError = false;
  errorMsg;
  @api recordId;
  successData = [];
  failureData = [];
  showNoDataMessage = false;
  showPreviewMessage = false;

  issueTypeCOPMap = {
    "Confirmation of Payee Opt-Out": {
      currentValue: "OPT-IN",
      requestedValue: "OPT-OUT"
    },
    "Confirmation of Payee Opt-In": {
      currentValue: "OPT-OUT",
      requestedValue: "OPT-IN"
    }
  };

  get showPreviewSection() {
    return (
      !this.isModificationSuccess &&
      !this.isModificationFailed &&
      this.showPreviewMessage
    );
  }

  get showSuccessSection() {
    return this.isModificationSuccess;
  }

  get showFailureSection() {
    return this.isModificationFailed;
  }

  get isDataLoading() {
    return !this.initialLoading && !this.isModificationSuccess;
  }

  get isModificationNotDone() {
    return (
      !this.isModificationSuccess &&
      !this.isModificationFailed &&
      !this.showNoDataMessage
    );
  }

  get showLoading() {
    return this.initialLoading || this.loading;
  }

  @wire(getRecord, { recordId: "$recordId", fields })
  wiredData({ data }) {
    try {
      console.log("getRecord data " + JSON.stringify(data));
      if (data && !this.hasFetchedCases) {
        this.customerOcvId =
          data.fields?.Account?.value?.fields?.OCV_ID__c?.value;
        if (this.customerOcvId) {
          this.hasFetchedCases = true;
          this.getEligibleChildCasesForCOPStatusUpdate();
        }
      }
    } catch (error) {
      this.handleError(error);
    }
  }

  async getEligibleChildCasesForCOPStatusUpdate() {
    try {
      const caseDetails = await fetchChildCasesCoP({
        parentCaseId: this.recordId
      });
      console.log("caseDetails " + JSON.stringify(caseDetails));
      if (caseDetails && caseDetails.length > 0) {
        this.eligibleChildCases = caseDetails;
        console.log(
          "eligibleChildCases " + JSON.stringify(this.eligibleChildCases)
        );
        this.casesData = this.generateData(caseDetails);
        console.log(
          "this.casesData for datattable " + JSON.stringify(this.casesData)
        );
        this.showPreviewMessage = true;
      } else {
        this.showNoDataMessage = true;
      }
      this.initialLoading = false;
    } catch (error) {
      this.handleError();
    }
  }

  async handleModifyCOPStatus() {
    this.loading = true;
    this.hasError = false;
    try {
      const response = await initiateModifyConfirmationOfPayee({
        customerOcvId: this.customerOcvId,
        eligibleCases: this.eligibleChildCases
      });
      if (response?.successList?.length > 0) {
        this.successData = response.successList;
        this.isModificationSuccess = true;
      }
      if (response?.failureList?.length > 0) {
        this.failureData = response.failureList;
        this.isModificationFailed = true;
      }
      await this.refreshTab();
    } catch (error) {
      this.handleError();
    } finally {
      this.loading = false;
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
      product:
        caseRecord?.FinServ__FinancialAccount__r?.Product_Name__c || null,
      accountNumber:
        caseRecord?.FinServ__FinancialAccount__r
          ?.FinServ__FinancialAccountNumber__c || null,
      accountType:
        caseRecord?.FinServ__FinancialAccount__r.Ownership__c === "Individual"
          ? "Sole"
          : caseRecord?.FinServ__FinancialAccount__r.Ownership__c,
      childCaseNumberUrl: "/" + caseRecord.Id,
      childCaseNumber: "#" + caseRecord.CaseNumber,
      currCOPStatus: this.issueTypeCOPMap[caseRecord.Parent.Type].currentValue,
      reqCOPStatus: this.issueTypeCOPMap[caseRecord.Parent.Type].requestedValue
    }));
  }

  async refreshTab() {
    const { tabId } = await getFocusedTabInfo();
    await refreshTab(tabId, {
      includeAllSubtabs: false
    });
  }
}
