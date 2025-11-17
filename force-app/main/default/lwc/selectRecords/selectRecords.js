import { LightningElement, wire, api } from "lwc";
import { CloseActionScreenEvent } from "lightning/actions";
import { getRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getFocusedTabInfo, refreshTab } from "lightning/platformWorkspaceApi";
import getRecords from "@salesforce/apex/GenericController.getData";
import updateRecords from "@salesforce/apex/GenericController.updateData";
import signAuth from "./signingAuthority.html";
import defaultSpinner from "./defaultSpinner.html";

const fields = [
  "Case.Account.OCV_ID__c",
  "Case.AccountId",
  "Case.RecordType.DeveloperName",
  "Case.Type"
];

const CONTROLLER_MAP = {
  Signing_Authority_Update: "SigningAuthorityUpdateController",
  Assisted_Transfer: "AssistedTransferController"
};

const SIGN_AUTH_UPDATE_RT = "Signing_Authority_Update";

const ALL_TO_SIGN_HEADER_MESSAGE =
  "Displaying All to Sign account. Only one account can be updated at a time.";

const ANY_TO_SIGN_HEADER_MESSAGE =
  "Displaying Any to Sign account. Only one account can be updated at a time.";

export default class SelectRecords extends LightningElement {
  data = [];
  @api recordId;
  maxRowSelection = "1";
  customerOcvId;
  accountId;
  recordTypeDevName;
  issueType;
  showNoDataMessage = false;
  selectedRows = [];
  saveClicked = false;
  showChild = false;
  selectedRowData = {};

  columns = [
    { label: "Product", fieldName: "Product_Name__c" },
    {
      label: "Account Number",
      fieldName: "FinServ__FinancialAccountNumber__c"
    },
    { label: "Ownership", fieldName: "Ownership__c" },
    { label: "Number Of Signatures", fieldName: "Number_Of_Signatures__c" }
  ];

  templateMap = {
    [SIGN_AUTH_UPDATE_RT]: signAuth
  };

  render() {
    if (this.recordTypeDevName) {
      return this.templateMap[this.recordTypeDevName];
    }
    return defaultSpinner;
  }

  @wire(getRecord, { recordId: "$recordId", fields })
  wiredData({ data }) {
    try {
      if (data) {
        this.customerOcvId =
          data.fields?.Account?.value?.fields?.OCV_ID__c?.value;
        this.recordTypeDevName =
          data.fields?.RecordType?.value?.fields?.DeveloperName?.value;
        this.issueType = data.fields?.Type?.value;
        if (this.customerOcvId) {
          this.getData();
        }
      }
    } catch (error) {
      this.handleToastNotification(
        "Failed To fetch data",
        "Failed to fetch data. Please refresh and try again. If the issue persists, please contact your System Administrator",
        "Error"
      );
    }
  }

  closeModal() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }

  get headerMessage() {
    if (this.issueType === "Change to Any to Sign") {
      return ALL_TO_SIGN_HEADER_MESSAGE;
    }
    return ANY_TO_SIGN_HEADER_MESSAGE;
  }

  async getData() {
    try {
      const params = {
        parentCaseId: this.recordId,
        ocvId: this.customerOcvId,
        recordType: this.recordTypeDevName,
        issueType: this.issueType
      };
      let apexController = CONTROLLER_MAP[this.recordTypeDevName];
      let finAccounts = await getRecords({
        apexController,
        param: JSON.stringify(params)
      });
      this.data = finAccounts;
      this.showNoDataMessage = this.data.length === 0;
    } catch (error) {
      this.handleToastNotification(
        "Failed To retrieve the records",
        "Failed to retrieve the records. Please refresh and try again. If the issue persists, please contact your System Administrator",
        "Error"
      );
    }
  }

  async updateData(event) {
    try {
      let finAccountId;
      if (this.selectedRows.length) {
        finAccountId = this.selectedRows[0]?.Id;
      }
      const params = {
        caseRecordId: this.recordId,
        financialAccount: finAccountId,
        recordType: this.recordTypeDevName,
        toAccountAmount: event?.detail?.amountTo?.toAccountAmount,
        toAccount: event?.detail?.amountTo?.toAccount,
        toAccountNumber: event?.detail?.amountTo?.toAccountNumber,
        toAccountBsb: event?.detail?.amountTo?.toAccountBsb,
        transferReason: event?.detail?.amountTo?.transferReason
      };
      this.saveClicked = true;
      let apexController = CONTROLLER_MAP[this.recordTypeDevName];
      await updateRecords({
        apexController,
        param: JSON.stringify(params)
      });
      this.handleToastNotification(
        "Case Updated",
        "Successfully Updated the Case",
        "success"
      );
      this.closeModal();
      this.refreshTab();
    } catch (error) {
      this.handleToastNotification(
        "Failed To update the Case",
        "Failed to update the Case. Please refresh and try again. If the issue persists, please contact your System Administrator",
        "Error"
      );
      this.closeModal();
    }
  }

  get saveDisabled() {
    return (
      !this.selectedRows.length || this.saveClicked || this.showNoDataMessage
    );
  }

  handleRowSelection(event) {
    this.selectedRows = event.detail.selectedRows;
    this.selectedRowData = { ...this.selectedRows[0] };
    this.showChild = this.selectedRows.length > 0 ? true : false;
  }

  handleToastNotification(title, message, variant) {
    this.dispatchEvent(
      new ShowToastEvent({
        title: title,
        message: message,
        variant: variant
      })
    );
  }

  async refreshTab() {
    const { tabId } = await getFocusedTabInfo();
    await refreshTab(tabId, {
      includeAllSubtabs: false
    });
  }
}
