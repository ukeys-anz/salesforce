import { LightningElement, track, api, wire } from "lwc";

import { subscribe, MessageContext } from "lightning/messageService";
import ExpandCollapseAll from "@salesforce/messageChannel/ListCollapseExpandAll__c";

import { NavigationMixin } from "lightning/navigation";
import canRaiseDispute from "@salesforce/customPermission/ANZx_Raise_Dispute";

import { prepopulateDisputesFields } from "./helper/disputes-fields-mapping";
import { encodeDefaultFieldValues } from "lightning/pageReferenceUtils";
import logMissedTransaction from "@salesforce/apex/TransactionHistoryController.logMissedTransaction";
import getTokenizedCardNumber from "@salesforce/apex/DisputesController.getTokenizedCardNumber";
import {
  TRANSACTION_STATUSES,
  TRANSACTION_TYPES
} from "c/transactionHistoryService";

const ALLOWED_TRANSACTION_TYPES = [
  TRANSACTION_TYPES.BSB_ACC,
  TRANSACTION_TYPES.Card,
  TRANSACTION_TYPES.Direct_Debit,
  TRANSACTION_TYPES.Deposit_Withdrawal,
  TRANSACTION_TYPES.Unknown,
  TRANSACTION_TYPES.Salary,
  TRANSACTION_TYPES.Payment,
  TRANSACTION_TYPES.Interest,
  TRANSACTION_TYPES.PAYID,
  TRANSACTION_TYPES.BPAY
]; // Transaction types that a coach can raise a dispute for, as specified in ANZX-5492

const ALLOWED_DISPUTE_TYPES_FOR_SALARY = [
  "NPP_Dispute",
  "Direct_Entry_Dispute"
]; //Allowed dispute types for salary transaction

const TRANSFER_MESSAGE =
  "You can't raise a transaction dispute for a transfer between the ANZ Plus and ANZ Save accounts. Please let the customer know they can amend the payment themselves in the app.";
const PENDING_TRANSACTION_MESSAGE =
  "You can’t raise a dispute on a pending transaction. Please try again once payment has cleared.";
const UNKNOWN_TRANSACTION_MESSAGE =
  "You can’t raise a dispute on a transaction with unknown status.";

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
  @api disputeRecordTypesFromParent;
  disputeRecordTypes;
  selectedDisputeRecordType;
  @api personAccount;
  @api financialAccountId;
  @api ocvId;
  tokenizedCardNumber;
  loading;

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

    // Process the dispute type that will show up on the modal based on the transaction type, as specified in ANZX-5492
    this.disputeRecordTypes =
      this.transactionRecord.formatted_type === TRANSACTION_TYPES.Salary
        ? this.handleFilterModalDisputeTypes(
            this.disputeRecordTypesFromParent,
            ALLOWED_DISPUTE_TYPES_FOR_SALARY
          )
        : this.disputeRecordTypesFromParent;
  }

  // Tooltip for Raise Dispute button if disabled
  get disputeButtonTooltip() {
    switch (true) {
      case this.transactionRecord.formatted_type === TRANSACTION_TYPES.Transfer:
        return TRANSFER_MESSAGE;
      case this.transactionRecord.status === TRANSACTION_STATUSES.Pending:
        return PENDING_TRANSACTION_MESSAGE;
      case this.transactionRecord.status === TRANSACTION_STATUSES.Unspecified:
        return UNKNOWN_TRANSACTION_MESSAGE;
      default:
        return "";
    }
  }

  // Check if user should be able to raise a dispute, including the Raise Dispute custom permisison and
  // other conditions specified in ANZX-5492
  get disableRaiseDisputeBtn() {
    return (
      !canRaiseDispute ||
      !(this.transactionRecord.status === TRANSACTION_STATUSES.Posted) ||
      !ALLOWED_TRANSACTION_TYPES.includes(this.transactionRecord.formatted_type)
    );
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

  get sourceClass() {
    if (this.transactionRecord?.source_image?.includes("EVERYDAY_ACCOUNT")) {
      return "source-everyday-account";
    }
    return "source-image";
  }

  get destinationClass() {
    if (
      this.transactionRecord?.destination_image?.includes("EVERYDAY_ACCOUNT")
    ) {
      return "destination-everyday-account";
    }
    return "destination-image";
  }

  get logoClass() {
    if (this.transactionRecord?.logo?.includes("SAVINGS_JAR")) {
      return "savings-jar";
    }
    if (this.transactionRecord?.logo?.includes("LOGO_DEFAULT")) {
      return "logo-default";
    }
    return "logo-image";
  }

  handleDetailsToggle() {
    this.showTransactionDetails = !this.showTransactionDetails;
  }

  // Handle raising dispute
  handleRaiseDispute() {
    if (this.transactionRecord.disputeRecordTypeId === "") {
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
  async handleNavigateToDisputeForm() {
    let disputeType = this.handleGetDisputeTypeFromRecordTypeId(
      this.selectedDisputeRecordType
    );

    this.loading = true;
    await this.handleTokenizedCardSearch(disputeType);

    let defaultFieldValuesObj = prepopulateDisputesFields(
      this.personAccount,
      this.financialAccountId,
      disputeType,
      this.transactionRecord,
      this.tokenizedCardNumber
    );

    //If we fail to automatically infer record type, log error
    if (!this.transactionRecord.disputeRecordTypeId) {
      let logDetails = {
        transactionType: this.transactionRecord.formatted_type,
        selectedRecordType: this.selectedDisputeRecordType,
        transactionId: this.transactionRecord.transaction_id,
        financialAccountId: this.financialAccountId
      };

      logMissedTransaction({
        logDetails: logDetails
      });
    }

    this.loading = false;
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

  // Filter the list of dispute types that will be displayed on the modal
  handleFilterModalDisputeTypes(disputeTypesFromParent, allowedDisputeTypes) {
    return disputeTypesFromParent.filter((disputeType) =>
      allowedDisputeTypes.includes(disputeType.developerName)
    );
  }

  // Get this dispute type from record type Id
  handleGetDisputeTypeFromRecordTypeId(recordTypeId) {
    let disputeType = this.disputeRecordTypesFromParent.filter(
      (disputeRecordType) => disputeRecordType.value === recordTypeId
    )[0].label;
    return disputeType;
  }

  async handleTokenizedCardSearch(disputeType) {
    // Retrieve tokenized card # for Card and ATM Disputes only
    if (disputeType === "Card" || disputeType === "ATM") {
      let result = await getTokenizedCardNumber({
        ocvId: this.ocvId,
        transactionId: this.transactionRecord.transaction_id
      });
      this.tokenizedCardNumber = result;
    }
  }
}
