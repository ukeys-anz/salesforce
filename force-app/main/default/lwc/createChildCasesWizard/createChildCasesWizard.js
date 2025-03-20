import { LightningElement, api, wire, track } from "lwc";
import { CloseActionScreenEvent } from "lightning/actions";
import { getRecord } from "lightning/uiRecordApi";
import { getFocusedTabInfo, refreshTab } from "lightning/platformWorkspaceApi";
import { handleErrorShowToast } from "c/utils";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import confirmationOfPayeeDOM from "./confirmationOfPayeeDOM.html";
import accountClosureDOM from "./accountClosureDOM.html";
import defaultSpinnerDOM from "./defaultSpinnerDOM.html";
import getDataForDatatable from "@salesforce/apex/CaseGroupController.getDataForDatatable";
const fields = ["Case.Account.OCV_ID__c", "Case.AccountId", "Case.Type"];
const columns = [
  { label: "Product", fieldName: "productName" },
  { label: "Account Number", fieldName: "accountNumber" },
  { label: "Account Type", fieldName: "finAccountType" }
];
const accountClosureColumns = [
  { label: "Signing Authority", fieldName: "signingAuthority" },
  { label: "Available Balance", fieldName: "balance", type: "currency" }
];
const confirmationOfPayeeColumns = [
  { label: "CoP Status", fieldName: "accountStatusCOP" }
];

const ERROR_MESSAGE =
  "Please try again. Raise a fault through TechAssist if the problem persists.";
const ISSUE_TYPE_ACCOUNT_CLOSURE = "Account Closure";
const ISSUE_TYPE_CONFIRMATION_OF_PAYEE_OPT_IN = "Confirmation of Payee Opt-In";
const ISSUE_TYPE_CONFIRMATION_OF_PAYEE_OPT_OUT =
  "Confirmation of Payee Opt-Out";

export default class CreateChildCasesWizard extends LightningElement {
  @api recordId;
  data = [];
  finAccData = [];
  selectedRowsData = [];
  accountDetails = [];
  loading = false;
  hasFetchedAccounts = false;
  @track columns = columns;
  showCheckbox = false;
  hasError = false;
  isFinAccountsAvailable = false;
  showFinDataTable = true;
  _showNoDataMessage = false;
  customerOcvId;
  accountId;
  issueType;
  errorMsg;
  templateMap = {
    [ISSUE_TYPE_ACCOUNT_CLOSURE]: accountClosureDOM,
    [ISSUE_TYPE_CONFIRMATION_OF_PAYEE_OPT_IN]: confirmationOfPayeeDOM,
    [ISSUE_TYPE_CONFIRMATION_OF_PAYEE_OPT_OUT]: confirmationOfPayeeDOM
  };

  render() {
    if (this.issueType) {
      return this.templateMap[this.issueType];
    }
    return defaultSpinnerDOM;
  }

  ownershipMap = {
    Single: { displayValue: "Sole", apiValue: "Individual" },
    "Multi-party": { displayValue: "Joint", apiValue: "Joint" }
  };

  get showNoDataMessage() {
    return this._showNoDataMessage;
  }

  set showNoDataMessage(value) {
    this._showNoDataMessage = value.length === 0;
  }

  get selectedRows() {
    return this.selectedRowsData;
  }

  set selectedRows(value) {
    this.showCheckbox = value.length > 1;
    this.selectedRowsData = value;
  }

  @wire(getRecord, { recordId: "$recordId", fields })
  wiredData({ data }) {
    try {
      if (data && !this.hasFetchedAccounts) {
        this.customerOcvId =
          data.fields?.Account?.value?.fields?.OCV_ID__c?.value;
        this.accountId = data.fields?.AccountId?.value;
        this.issueType = data.fields?.Type?.value;
        this.render();
        if (this.customerOcvId) {
          this.hasFetchedAccounts = true;
          this.initialiseIssueType();
          this.getData();
        }
      }
    } catch (error) {
      this.handleError(error);
    }
  }

  async getData() {
    this.loading = true;
    try {
      const params = {
        issueType: this.issueType,
        parentCaseId: this.recordId,
        ocvId: this.customerOcvId
      };
      this.data = await getDataForDatatable({
        params
      });
      this.finAccData = this.fetchSuccessRecords(this.data);
      this.handleErrorRecords(this.data);
      this.showNoDataMessage = this.finAccData;
    } catch (error) {
      this.handleError(error);
      this.showNoDataMessage = this.finAccData;
      handleErrorShowToast(
        this,
        "Failed To Retrieve Account Details",
        error,
        "Failed to retrieve latest account details. Please refresh and try again. If the issue persists, please contact your System Administrator",
        "pester"
      );
    } finally {
      this.loading = false;
    }
  }

  handleRowSelection(event) {
    this.selectedRows = event.detail.selectedRows;
  }

  handleCasesCreated() {
    this.showFinDataTable = false;
    this.refreshTab();
  }

  handleErrorVisibilty(event) {
    this.hasError = event.detail.showError;
    this.errorMsg = event.detail.errorMessage;
  }

  handleCancelAction() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }

  handleError() {
    this.hasError = true;
    this.errorMsg = ERROR_MESSAGE;
  }
  // handle error records
  handleErrorRecords(records) {
    let errorAccountNumbers = records
      .filter((record) => record.isError)
      .map((record) => record.accountNumber);
    if (errorAccountNumbers.length > 0) {
      this.showOnlyToast(
        "Failed To Retrieve COP status for Account Numbers - " +
          errorAccountNumbers.join(", "),
        "Failed to retrieve latest account details. Please refresh and try again. If the issue persists, please contact your System Administrator",
        "warning"
      );
    }
  }

  fetchSuccessRecords(records) {
    return records.filter((record) => !record.isError);
  }

  async refreshTab() {
    const { tabId } = await getFocusedTabInfo();
    await refreshTab(tabId, {
      includeAllSubtabs: false
    });
  }

  initialiseIssueType() {
    if (this.issueType === ISSUE_TYPE_ACCOUNT_CLOSURE) {
      this.columns = this.columns.concat(accountClosureColumns);
    } else if (
      this.issueType === ISSUE_TYPE_CONFIRMATION_OF_PAYEE_OPT_IN ||
      this.issueType === ISSUE_TYPE_CONFIRMATION_OF_PAYEE_OPT_OUT
    ) {
      this.columns = this.columns.concat(confirmationOfPayeeColumns);
    }
  }

  showOnlyToast(title, msg, variant) {
    const evt = new ShowToastEvent({
      title: title,
      message: msg,
      variant: variant
    });
    this.dispatchEvent(evt);
  }
}
