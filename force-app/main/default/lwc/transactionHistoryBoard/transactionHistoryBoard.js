import { LightningElement, track, wire, api } from "lwc";
import getTransactions from "@salesforce/apex/CoachBankingAPIRepository.getTransactionHistoryAura";
import getDisputeRecordTypeMap from "@salesforce/apex/TransactionHistoryController.getDisputeRecordTypeMap";
import getPersonContactId from "@salesforce/apex/TransactionHistoryController.getPersonContactId";
import { getRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import FIN_ACCOUNT_OCV_ID_FIELD from "@salesforce/schema/FinServ__FinancialAccount__c.OCV_ID__c";
import FIN_ACCOUNT_ACCOUNT_NUMBER_FIELD from "@salesforce/schema/FinServ__FinancialAccount__c.FinServ__FinancialAccountNumber__c";
import { publish, MessageContext } from "lightning/messageService";
import ExpandCollapseAll from "@salesforce/messageChannel/ListCollapseExpandAll__c";
import { handleErrorShowToast } from "c/utils";
import hasAccountsGoalsPermission from "@salesforce/customPermission/ANZx_Accounts_and_Goals";

//Remapping the status and types returned from the API so they
//are more readable on the UI
const transactionStatusMapping = {
  TRANSACTION_STATUS_UNSPECIFIED: "Unknown",
  TRANSACTION_STATUS_PENDING: "Pending",
  TRANSACTION_STATUS_POSTED: "Posted"
};
const transactionTypeMapping = {
  TRANSACTION_TYPE_UNSPECIFIED: "Unknown",
  TRANSACTION_TYPE_CARD: "Card",
  TRANSACTION_TYPE_DIRECT_DEBIT: "Direct Debit",
  TRANSACTION_TYPE_FEE: "Fee",
  TRANSACTION_TYPE_INTEREST: "Interest",
  TRANSACTION_TYPE_DEPOSIT_WITHDRAWAL: "Deposit Withdrawal",
  TRANSACTION_TYPE_TRANSFER: "Transfer",
  TRANSACTION_TYPE_PAYID: "PAYID",
  TRANSACTION_TYPE_BSB_ACC_NUM: "BSB/ACC",
  TRANSACTION_TYPE_BPAY: "BPAY",
  TRANSACTION_TYPE_OTHER: "Other"
};
const cardMapping = {
  CARD_SCHEME_UNSPECIFIED: "Unknown",
  CARD_SCHEME_VISA: "Visa",
  CARD_SCHEME_MASTERCARD: "MasterCard",
  CARD_SCHEME_EFTPOS: "EFTPOS",
  CARD_SCHEME_AMERICAN_EXPRESS: "American Express"
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
  fullTransactionList = [];
  @track transactionList = [];
  @track showSearchBar = false;
  @track filterList = [];
  @track savedMaxIndex = 0;
  expandAll = false;
  startDate = this.getDefaultDate();
  endDate = this.getDefaultDate();
  todayDate = this.getDefaultDate();
  disableSearch = true;
  ocvId;
  accountNumber;
  hasError = false;
  errorMessage;
  links;
  loading = true;
  disputeRecordTypes = [];
  transactionTypeDisputeIdMap = {};
  personContactId = "";
  showWarning = true;
  lastDateInPayload;
  allTags;
  allMerchants;

  @wire(MessageContext)
  messageContext;
  //Get the OCVID and Account Number to send to
  //the API and get the transactions
  @wire(getRecord, {
    recordId: "$recordId",
    fields: [FIN_ACCOUNT_OCV_ID_FIELD, FIN_ACCOUNT_ACCOUNT_NUMBER_FIELD]
  })
  wiredProject({ data }) {
    if (data && hasAccountsGoalsPermission) {
      this.ocvId = data.fields.OCV_ID__c.value;
      this.accountNumber = data.fields.FinServ__FinancialAccountNumber__c.value;
      this.handleGetPersonContactId();
      if (this.disputeRecordTypes.length === 0) {
        this.handleGetDisputeRecordTypeDetails();
      }
      this.fetchTransactions();
    }
  }

  get displayContent() {
    return hasAccountsGoalsPermission;
  }

  get showLoadMore() {
    return this.links && this.links.next && this.links.next.href ? true : false;
  }

  fetchTransactions(
    paramUrl = "",
    isSearch = false,
    startDateString = "",
    endDateString = ""
  ) {
    //This check here is to prevent Salesforce from triggering
    //the API and appending duplicate transactions into our list
    //ie: modifying the financial account record triggers the API
    //and appends the initial transaction results onto our list
    if (
      this.transactionList.length > 0 &&
      !startDateString &&
      !endDateString &&
      !paramUrl
    ) {
      this.loading = false;
      return;
    }
    getTransactions({
      ocvId: this.ocvId,
      accountNumber: this.accountNumber,
      startDate: startDateString,
      endDate: endDateString,
      paramUrl: paramUrl
    })
      .then((result) => {
        if (result) {
          this.fullTransactionList = result.embedded.transactions;
          this.links = result.links;
          this.allMerchants = result.embedded.merchants;
          this.allTags = result.embedded.tags;
          let updatedFullList = [];

          if (this.fullTransactionList) {
            for (let i = 0; i < this.fullTransactionList.length; i++) {
              let currentTransaction = { ...this.fullTransactionList[i] };

              // Set the transaction's dispute record type Id
              currentTransaction.disputeRecordTypeId = this.transactionTypeDisputeIdMap[
                currentTransaction.type
              ];

              //Remap type and status
              currentTransaction.type = currentTransaction.type
                ? transactionTypeMapping[currentTransaction.type]
                : "Unknown";
              currentTransaction.status = currentTransaction.status
                ? transactionStatusMapping[currentTransaction.status]
                : "Unknown";

              //Process date and time, set showDateTitle
              let currentDate = this.getDateObject(
                currentTransaction.transactionDateLocal
              );

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

              if (
                currentTransaction.tags &&
                currentTransaction.tags.length > 0
              ) {
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
              if (currentTransaction.merchantId?.value) {
                currentTransaction = this.handleMerchantDetails(
                  currentTransaction
                );
              }

              //Remap card scheme to be user friendly
              if (currentTransaction.card) {
                currentTransaction.card.scheme = currentTransaction.card.scheme
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
              updatedFullList.push(currentTransaction);
            }
          }

          //Clear transaction list to only display search results
          if (isSearch) {
            this.transactionList = [];
          }
          updatedFullList.forEach((e) => {
            this.transactionList.push(e);
          });
        }

        this.loading = false;
      })
      .catch((error) => {
        this.errorMessage =
          "Failed to retrieve transaction history. Please refresh and try again. If the problem persists, please contact your System Administrator.";
        if (error.body && error.body.message) {
          let message = this.handleError(error.body.message);
          //Catch any system error messages (most readable errors wont be a single word)
          if (message && message.split(" ").length > 1) {
            this.errorMessage = message;
          }
        }
        this.hasError = true;
        this.loading = false;
        this.showToast(
          "Transaction History Load Failed",
          this.errorMessage,
          error
        );
      });
  }

  handleMerchantDetails(transaction) {
    //Fetch first response as transactions should only have 1 merchant
    let merchantDetails = this.getMerchantDetails(
      transaction.merchantId.value
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
              Latitude: merchantDetails.address.coordinates.latitude.value,
              Longitude: merchantDetails.address.coordinates.longitude.value
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
      transaction.logo = null;
    }

    transaction.merchantEmail = this.getOptionalFieldValue(
      merchantDetails.email
    );

    transaction.merchantPhoneNumber = this.getOptionalFieldValue(
      merchantDetails.phone_number
    );

    transaction.merchantWebsiteUrl = this.getOptionalFieldValue(
      merchantDetails.website_url
    );

    return transaction;
  }

  showToast(theTitle, theMessage, theVariant) {
    const event = new ShowToastEvent({
      title: theTitle,
      message: theMessage,
      variant: theVariant
    });
    this.dispatchEvent(event);
  }

  handleLoadMore() {
    //The provided URL doesn't go through MS, so we need
    //to retrieve the params and pass them to the Apex class
    //and append it to the request
    let nextSubstring = `${this.links.next.href.substring(
      this.links.next.href.indexOf("?")
    )}`;

    this.fetchTransactions(nextSubstring);
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
      this.loading = true;

      //Create dates based off the user selection
      let startDate = this.startDate + " 00:00:00";
      let endDate = this.endDate + " 23:59:59";

      this.fetchTransactions("", true, startDate, endDate);
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

  //This function is required as some errors are returned
  //as stringified json
  handleError(error) {
    try {
      JSON.parse(error);
    } catch (e) {
      return error;
    }
    return JSON.parse(error).message;
  }

  // Construct a map of transaction type and its corresponding case record type
  handleGetDisputeRecordTypeDetails() {
    getDisputeRecordTypeMap()
      .then((result) => {
        if (result) {
          const returnedMap = JSON.parse(result);
          this.transactionTypeDisputeIdMap.TRANSACTION_TYPE_CARD =
            returnedMap.Card_Dispute.Id;
          this.transactionTypeDisputeIdMap.TRANSACTION_TYPE_DEPOSIT_WITHDRAWAL =
            returnedMap.ATM_Dispute.Id;
          this.transactionTypeDisputeIdMap.TRANSACTION_TYPE_BSB_ACC_NUM =
            returnedMap.Direct_Entry_Dispute.Id;
          // Sort the map so record types will be presented in A-Z order
          const sortedReturnedMap = Object.fromEntries(
            Object.entries(returnedMap).sort()
          );
          // Construct a map of dispute record type's label and Id to send to transaction record
          for (const [key, value] of Object.entries(sortedReturnedMap)) {
            let recordTypeItem = {};
            recordTypeItem.developerName = key;
            recordTypeItem.label = value.Name;
            recordTypeItem.value = value.Id;
            this.disputeRecordTypes.push(recordTypeItem);
          }
        }
      })
      .catch((error) => {
        handleErrorShowToast(
          this,
          "Failed To Retrieve Dispute Record Types",
          error,
          "Failed to retrieve dispute record types. Please refresh and try again. If the problem persists, please contact your System Administrator.",
          "pester"
        );
      });
  }

  // Getting person contact Id so we can pre-populated it on the data capture form
  handleGetPersonContactId() {
    getPersonContactId({
      financialAccountId: this.recordId
    })
      .then((result) => {
        if (result != null) {
          this.personContactId = result;
        }
      })
      .catch((error) => {
        handleErrorShowToast(
          this,
          "Failed To Retrieve Contact Id",
          error,
          "Failed to retrieve contact Id. Please refresh and try again. If the problem persists, please contact your System Administrator.",
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
  getMerchantDetails(merchantId) {
    return this.allMerchants.filter((merchant) => {
      return merchantId === merchant.merchantId;
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

  //This function checks if an optional value exists and returns it else
  //returns unknown
  getOptionalFieldValue(field) {
    return field ? field.value : "Unknown";
  }
}
