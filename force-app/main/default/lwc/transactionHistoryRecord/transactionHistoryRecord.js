import { LightningElement, track, api, wire } from "lwc";

import { subscribe, MessageContext } from "lightning/messageService";
import ExpandCollapseAll from "@salesforce/messageChannel/ListCollapseExpandAll__c";

import { NavigationMixin } from "lightning/navigation";
import canRaiseDispute from "@salesforce/customPermission/ANZx_Raise_Dispute";
import { prepopulateDisputesFields } from "./helper/disputes-fields-mapping";
import { encodeDefaultFieldValues } from "lightning/pageReferenceUtils";

export default class TransactionHistoryRecord extends NavigationMixin(
  LightningElement
) {
  @api transactionRecord;
  @api expandAll;
  @track showTransactionDetails;
  zoomLevel = 15;

  @wire(MessageContext)
  messageContext;
  subscription = null;
  showRecordTypeSelection = false;
  @api disputeRecordTypes;
  selectedDisputeRecordType;
  @api personAccountId;
  @api financialAccountId;

  connectedCallback() {
    this.subscription = subscribe(
      this.messageContext,
      ExpandCollapseAll,
      (message) => {
        if (message.expand) {
          this.showTransactionDetails = true;
        } else if (!message.expand) {
          this.showTransactionDetails = false;
        }
      }
    );

    if (this.expandAll) {
      this.showTransactionDetails = true;
    }
  }

  get disableRaiseDisputeBtn() {
    return !canRaiseDispute;
  }

  get amountConvertedValue() {
    return this.transactionRecord.international_amount.charged.value;
  }

  get amountConvertedCurrency() {
    return this.transactionRecord.international_amount.charged.currency_code;
  }

  get amountExchangeRateValue() {
    return this.transactionRecord.international_amount.exchange_rate.value;
  }

  get amountNumber() {
    let relatedAmount = this.transactionRecord.amount.value;
    if (relatedAmount < 0) {
      relatedAmount = -relatedAmount;
    }
    return relatedAmount;
  }

  get positiveAmount() {
    return this.transactionRecord.amount.value >= 0;
  }

  get negativeAmount() {
    return this.transactionRecord.amount.value < 0;
  }

  get transactionDate() {
    return this.transactionRecord.TransactionDate;
  }

  get transactionTime() {
    return this.transactionRecord.transaction_time;
  }

  handleDetailsToggle() {
    this.showTransactionDetails = !this.showTransactionDetails;
  }

  // Handle raising dispute
  handleRaiseDispute() {
    if (typeof this.transactionRecord.disputeRecordTypeId === "undefined") {
      this.showRecordTypeSelection = true;
    } else {
      this.selectedDisputeRecordType = this.transactionRecord.disputeRecordTypeId;
      this.handleNavigateToDisputeForm();
    }
  }

  // Handle toggling modal
  handleToggleModal() {
    this.showRecordTypeSelection = !this.showRecordTypeSelection;
  }

  // Handle selecting dispute record type
  handleSelectedRecordType(event) {
    this.selectedDisputeRecordType = event.detail.value;
  }

  // Navigating to dispute capture form
  handleNavigateToDisputeForm() {
    let defaultFieldValuesObj = prepopulateDisputesFields(
      this.personAccountId,
      this.financialAccountId,
      this.transactionRecord.type,
      this.transactionRecord
    );

    this[NavigationMixin.Navigate]({
      type: "standard__objectPage",
      attributes: {
        objectApiName: "Case",
        actionName: "new"
      },
      state: {
        defaultFieldValues: encodeDefaultFieldValues(defaultFieldValuesObj),
        nooverride: "1",
        recordTypeId: this.selectedDisputeRecordType
      }
    });
    // Close modal after user clicks Next
    this.showRecordTypeSelection = false;
  }
}
