import { LightningElement, track, wire, api } from "lwc";
import getPersonAccount from "@salesforce/apex/TransactionHistoryController.getPersonAccount";
import { getRecord } from "lightning/uiRecordApi";
import { publish, MessageContext } from "lightning/messageService";
import ExpandCollapseAll from "@salesforce/messageChannel/ListCollapseExpandAll__c";
import { handleErrorShowToast } from "c/utils";
import hasAccountsGoalsPermission from "@salesforce/customPermission/ANZx_Accounts_and_Goals";
import { getOptionalFieldValue, processTransaction } from "./helpers/util";
import transaction_logos from "@salesforce/resourceUrl/transaction_logos";

import {
  TRANSACTION_STATUSES,
  TRANSACTION_TYPES,
  CARD_TYPES,
  PERSON_ACCOUNT_ID_RETRIEVE_ERROR,
  PAYMENT_TYPES,
  PAYMENT_SUB_TYPES
} from "c/transactionHistoryService";

//Remapping the status and types returned from the API so they
//are more readable on the UI
const transactionStatusMapping = {
  TRANSACTION_STATUS_UNSPECIFIED: TRANSACTION_STATUSES.Unspecified,
  TRANSACTION_STATUS_PENDING: TRANSACTION_STATUSES.Pending,
  TRANSACTION_STATUS_POSTED: TRANSACTION_STATUSES.Posted
};
const transactionTypeMapping = {
  TRANSACTION_TYPE_UNSPECIFIED: TRANSACTION_TYPES.Unknown,
  TRANSACTION_TYPE_CARD: TRANSACTION_TYPES.Card,
  TRANSACTION_TYPE_DIRECT_DEBIT: TRANSACTION_TYPES.Direct_Debit,
  TRANSACTION_TYPE_FEE: TRANSACTION_TYPES.Fee,
  TRANSACTION_TYPE_INTEREST: TRANSACTION_TYPES.Interest,
  TRANSACTION_TYPE_DEPOSIT_WITHDRAWL: TRANSACTION_TYPES.Deposit_Withdrawal, // TRANSACTION_TYPE_DEPOSIT_WITHDRAWL with typo as this is what Fabric sends, confirmed with their team
  TRANSACTION_TYPE_TRANSFER: TRANSACTION_TYPES.Transfer,
  TRANSACTION_TYPE_PAYID: TRANSACTION_TYPES.PAYID,
  TRANSACTION_TYPE_BSB_ACC_NUM: TRANSACTION_TYPES.BSB_ACC,
  TRANSACTION_TYPE_BPAY: TRANSACTION_TYPES.BPAY,
  TRANSACTION_TYPE_OTHER: TRANSACTION_TYPES.Other,
  TRANSACTION_TYPE_SALARY: TRANSACTION_TYPES.Salary,
  TRANSACTION_TYPE_PAYMENT: TRANSACTION_TYPES.Payment
};
const cardMapping = {
  CARD_SCHEME_UNSPECIFIED: CARD_TYPES.Unknown,
  CARD_SCHEME_VISA: CARD_TYPES.Visa,
  CARD_SCHEME_MASTERCARD: CARD_TYPES.Mastercard,
  CARD_SCHEME_EFTPOS: CARD_TYPES.EFTPOS,
  CARD_SCHEME_AMERICAN_EXPRESS: CARD_TYPES.American_Express
};

const dateOptions = {
  weekday: "long",
  year: "numeric",
  month: "long",
  day: "numeric"
};

const timeOptions = { hour: "2-digit", minute: "2-digit" };

export default class TransactionHistoryBoard extends LightningElement {
  @api recordId;
  // gets component title, search, error, startDate & endDate through financialAccountParent LWC
  @api error;
  @api hasError;
  @track fullTransactionList = [];
  @track transactionList = [];
  @track showSearchBar = false;
  @track filterList = [];
  @track savedMaxIndex = 0;
  expandAll = false;
  startDate;
  endDate;
  todayDate = this.getDefaultDate();
  disableSearch = true;
  links;
  @api loading;
  @api showRaiseDispute;
  @api disputeRecordTypesFromParent;
  @api transactionTypeDisputeIdMapFromParent;
  personAccount;
  showWarning = true;
  lastDateInPayload;
  allTags;
  allMerchants;
  @api componentTitle;
  @api tstartDate;
  @api tendDate;
  //Used to clear the transactionList value so we dont
  //append new transactions when trying to filter them
  @api clearTransactions;
  //Triggers the load more button to be a spinner so we dont
  //trigger loading on the whole component to append new data
  @api transactionLoadMore;
  @api ocvId;

  @wire(MessageContext)
  messageContext;
  @wire(getRecord, {
    recordId: "$recordId",
    fields: []
  })
  wireRecord({ data }) {
    if (data) {
      this.startDate = this.inputStartDate(this.tstartDate);
      this.endDate = this.inputEndDate(this.tendDate);
      this.handleGetPersonAccount();
    }
  }

  get displayContent() {
    return hasAccountsGoalsPermission;
  }

  get showLoadMore() {
    return this.links && this.links.next && this.links.next.uri ? true : false;
  }

  @api
  get transactionData() {
    return this.fullTransactionList;
  }

  set transactionData(transactions) {
    if (this.clearTransactions) {
      this.transactionList = [];
    }
    if (transactions) {
      //The data is being received proxied, so we stringify it
      //and parse it to unproxy it
      transactions = JSON.parse(JSON.stringify(transactions));
      this.fullTransactionList = transactions.embedded?.transactions
        ? transactions.embedded?.transactions
        : [];
      this.links = transactions.links;
      this.allMerchants = transactions.embedded?.merchants
        ? transactions.embedded.merchants
        : [];
      this.allTags = transactions.embedded?.tags
        ? transactions.embedded.tags
        : [];
      let updatedFullList = [];

      if (this.fullTransactionList.length > 0) {
        for (let i = 0; i < this.fullTransactionList.length; i++) {
          let currentTransaction = this.fullTransactionList[i];

          //Remap type and status
          currentTransaction.formatted_type = currentTransaction.type
            ? transactionTypeMapping[currentTransaction.type]
            : "Unknown";
          currentTransaction.status = currentTransaction.status
            ? transactionStatusMapping[currentTransaction.status]
            : "Unknown";

          // Set the transaction's dispute record type Id
          currentTransaction.disputeRecordTypeId = this.getRecordTypeId(
            currentTransaction
          );

          //Process date and time, set showDateTitle
          let currentDate = this.getDateObject(
            currentTransaction.transactionDateLocal
          );

          currentTransaction.transaction_date = currentTransaction.transactionDateLocal
            ? new Date(currentTransaction.transactionDateLocal)
                .toISOString()
                .split("T")[0]
            : null;

          currentTransaction.transaction_posted_date = currentTransaction.transaction_posted_date
            ? new Date(currentTransaction.transaction_posted_date)
                .toISOString()
                .split("T")[0]
            : null;

          // Date only value to be passed to default field values, use locale "en-CA" to get YYYY-MM-DD format
          this.setTransactionDisplayDateTime(currentTransaction);
          /* 
              To prevent the issue where the first transaction the next payload has the same date as the last transaction in the previous payload and
              shows its date title again (date title showing twice), we will compare the current date with the previous date
              */
          currentTransaction.showDateTitle = this.showDateTitle(
            currentDate,
            this.lastDateInPayload
          );
          this.lastDateInPayload = currentDate;

          //Apply odd or even for each item to determine background
          currentTransaction.rowColour =
            "slds-card slds-m-bottom_small transaction-item ";
          currentTransaction.rowColour += i % 2 === 0 ? "even" : "odd";

          if (currentTransaction.tags && currentTransaction.tags.length > 0) {
            currentTransaction.tagList = [];
            let tagDetails = this.getTagDetails(currentTransaction.tags);
            //loop through tags
            tagDetails.forEach((tag) => {
              //Truncate tag name
              if (tag.name && tag.name.length > 15) {
                tag.name = tag.name.substring(0, 14) + "...";
              }
              currentTransaction.tagList.push(tag.name);
            });
          }

          //Handle merchant details
          if (currentTransaction.merchant_id?.value) {
            currentTransaction = this.handleMerchantDetails(currentTransaction);
          }

          //If no image details use default
          if (
            !currentTransaction.logo &&
            !currentTransaction.source_image &&
            !currentTransaction.source_emoji &&
            !currentTransaction.destination_image &&
            !currentTransaction.destination_emoji
          ) {
            currentTransaction.logo = `${transaction_logos}/TRANSACTION_LOGO_DEFAULT.png`;
          }

          //Remap card scheme to be user friendly
          if (currentTransaction.card) {
            currentTransaction.card.formatted_scheme = currentTransaction.card
              .scheme
              ? cardMapping[currentTransaction.card.scheme]
              : "Unknown";
          }

          //Check if international transaction
          if (currentTransaction.international_amount) {
            currentTransaction.internationalDetails = true;
          }

          currentTransaction.error = currentTransaction.error
            ? currentTransaction.error
            : "N/A";

          //Handle processing of transaction optional fields
          currentTransaction = processTransaction(currentTransaction);

          updatedFullList.push(currentTransaction);
        }
        updatedFullList.forEach((e) => {
          this.transactionList.push(e);
        });
      } else {
        this.transactionList = null;
      }
    }
  }

  handleMerchantDetails(transaction) {
    //Fetch first response as transactions should only have 1 merchant
    let merchantDetails = this.getMerchantDetails(
      transaction.merchant_id.value
    )[0];
    transaction.merchantDetails = true;

    transaction.merchantName = merchantDetails.name
      ? merchantDetails.name
      : merchantDetails.alternateName;

    if (merchantDetails.address) {
      if (
        merchantDetails.address.line_one &&
        merchantDetails.address.suburb &&
        merchantDetails.address.state &&
        merchantDetails.address.postcode
      ) {
        transaction.merchantLocation = `${merchantDetails.address.line_one.value}, ${merchantDetails.address.suburb.value} ${merchantDetails.address.state.value} ${merchantDetails.address.postcode.value}`;
      } else {
        transaction.merchantLocation = "Unknown";
      }

      if (merchantDetails.address.coordinates) {
        //Set the map markers for the map
        transaction.mapMarkers = [
          {
            location: {
              Latitude: merchantDetails.address.coordinates.latitude,
              Longitude: merchantDetails.address.coordinates.longitude
            }
          }
        ];
      }
    }

    if (
      merchantDetails.image_details &&
      (merchantDetails.image_details.light_url ||
        merchantDetails.image_details.dark_url)
    ) {
      transaction.logo = merchantDetails.image_details.light_url
        ? merchantDetails.image_details.light_url.value
        : merchantDetails.image_details.dark_url.value;
    } else {
      transaction.logo = `${transaction_logos}/TRANSACTION_LOGO_DEFAULT.png`;
    }

    transaction.merchantEmail = getOptionalFieldValue(merchantDetails.email);

    transaction.merchantPhoneNumber = getOptionalFieldValue(
      merchantDetails.phone_number
    );

    transaction.merchantWebsiteUrl = getOptionalFieldValue(
      merchantDetails.website_url
    );

    return transaction;
  }

  handleLoadMore() {
    //The provided URL doesn't go through MS, so we need
    //to retrieve the params and pass them to the Apex class
    //and append it to the request
    let nextSubstring = `${this.links.next.uri.substring(
      this.links.next.uri.indexOf("?")
    )}`;
    const event = new CustomEvent("loadmore", {
      detail: nextSubstring
    });
    this.dispatchEvent(event, {
      bubbles: true
    });
  }

  handleSearchFilterToggle() {
    this.showSearchBar = !this.showSearchBar;
  }

  handleCancelFilter() {
    this.showSearchBar = false;
  }

  handleSaveFilter(event) {
    this.filterList = event.detail.detail;
    this.savedMaxIndex = event.detail.maxIndex;
    this.showSearchBar = false;
  }

  handleExpandAll() {
    this.expandAll = !this.expandAll;
    const payload = { expand: this.expandAll };
    publish(this.messageContext, ExpandCollapseAll, payload);
  }

  handleSearch() {
    if (this.startDate && this.endDate) {
      this.transactionList = [];
      //Create dates based off the user selection
      let startDate = this.startDate + " 00:00:00";
      let endDate = this.endDate + " 23:59:59";
      const event = new CustomEvent("search", {
        detail: {
          startDateString: startDate,
          endDateString: endDate
        }
      });
      this.dispatchEvent(event, {
        bubbles: true
      });
    }
  }

  handleStartDateChange(e) {
    this.startDate = e.detail.value;
    if (this.startDate > this.endDate || this.startDate > this.todayDate) {
      this.disableSearch = true;
    } else if (this.startDate && this.endDate) {
      this.disableSearch = false;
    } else {
      this.disableSearch = true;
    }
  }

  handleEndDateChange(e) {
    this.endDate = e.detail.value;
    if (
      (this.startDate && this.endDate < this.startDate) ||
      this.endDate > this.todayDate
    ) {
      this.disableSearch = true;
    } else if (this.endDate && this.startDate) {
      this.disableSearch = false;
    } else {
      this.disableSearch = true;
    }
  }

  // Getting person contact Id so we can pre-populated it on the data capture form
  handleGetPersonAccount() {
    getPersonAccount({
      financialAccountId: this.recordId
    })
      .then((result) => {
        if (result != null) {
          this.personAccount = result;
        }
      })
      .catch((error) => {
        handleErrorShowToast(
          this,
          "Failed To Retrieve Person Account Id",
          error,
          PERSON_ACCOUNT_ID_RETRIEVE_ERROR,
          "pester"
        );
      });
  }

  closeWarning() {
    this.showWarning = false;
  }

  // Get date object from the local time string returned from Apex
  getDateObject(localTimeString) {
    return new Date(localTimeString);
  }

  showDateTitle(currentDate, previousDate) {
    if (previousDate == null) {
      return true; // Show date title
    }
    return !this.areSameDate(currentDate, this.lastDateInPayload);
  }

  // Compare date objects and check if both are the same date
  areSameDate(date1, date2) {
    return (
      date1.getDate() === date2.getDate() &&
      date1.getMonth() === date2.getMonth() &&
      date1.getFullYear() === date2.getFullYear()
    );
  }

  setTransactionDisplayDateTime(transaction) {
    if (transaction.transactionDateLocal) {
      transaction.TransactionDate = this.getDateObject(
        transaction.transactionDateLocal
      ).toLocaleDateString("en-AU", dateOptions); // No time conversion is done here, just formatting to a string with the desired format
      transaction.transaction_time =
        this.getDateObject(transaction.transactionDateLocal).toLocaleTimeString(
          "en-AU",
          timeOptions
        ) + " AEST/AEDT"; // No time conversion is done here, just formatting to a string with the desired format
    } else {
      transaction.TransactionDate = transaction.transaction_time = "Unknown";
    }
  }

  // Get today's date as string in format YYYY-MM-DD
  getDefaultDate() {
    return new Date().toISOString().slice(0, 10);
  }

  //This function retrieves the details of the merchant based on the id
  //provided from the list of merchants given in the response.
  getMerchantDetails(merchant_id) {
    return this.allMerchants.filter((merchant) => {
      return merchant_id === merchant.merchant_id;
    });
  }

  // //This function retrieves the details of the tag based on the id
  // //provided from the list of tags given in the response. Tag Ids
  // //sent as array
  getTagDetails(tagIds) {
    return this.allTags.filter((tag) => {
      return tagIds.indexOf(tag.tag_id) > -1;
    });
  }

  // Get record type Id to direct user to the corresponding page layout
  getRecordTypeId(transaction) {
    switch (true) {
      case transaction.formatted_type === TRANSACTION_TYPES.Card:
        return this.transactionTypeDisputeIdMapFromParent.Card_Dispute;
      case transaction.formatted_type === TRANSACTION_TYPES.Deposit_Withdrawal:
        return this.transactionTypeDisputeIdMapFromParent.ATM_Dispute;
      case transaction.formatted_type === TRANSACTION_TYPES.BSB_ACC &&
        transaction.pay_anyone?.clearing_method !==
          PAYMENT_TYPES.PAYMENT_TYPE_FAST &&
        ![
          PAYMENT_SUB_TYPES.PAYMENT_SUB_TYPE_ICS1,
          PAYMENT_SUB_TYPES.PAYMENT_SUB_TYPE_ONUS
        ].includes(transaction.pay_anyone?.clearing_sub_method):
        return this.transactionTypeDisputeIdMapFromParent.Direct_Entry_Dispute;
      case [TRANSACTION_TYPES.BSB_ACC, TRANSACTION_TYPES.PAYID].includes(
        transaction.formatted_type
      ) &&
        transaction.pay_anyone?.clearing_method ===
          PAYMENT_TYPES.PAYMENT_TYPE_FAST &&
        [
          PAYMENT_SUB_TYPES.PAYMENT_SUB_TYPE_ICS1,
          PAYMENT_SUB_TYPES.PAYMENT_SUB_TYPE_ONUS
        ].includes(transaction.pay_anyone?.clearing_sub_method):
        return this.transactionTypeDisputeIdMapFromParent.NPP_Dispute;
      case transaction.formatted_type === TRANSACTION_TYPES.Direct_Debit:
        return this.transactionTypeDisputeIdMapFromParent.Direct_Debit_Dispute;
      case transaction.formatted_type === TRANSACTION_TYPES.BPAY:
        return this.transactionTypeDisputeIdMapFromParent.BPAY_Dispute;
      default:
        return "";
    }
  }

  inputStartDate(startDate) {
    if (!startDate) {
      startDate = this.getDefaultDate();
    }
    return startDate;
  }

  inputEndDate(endDate) {
    if (!endDate) {
      endDate = this.getDefaultDate();
    }
    return endDate;
  }
}
