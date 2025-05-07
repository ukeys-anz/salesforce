import { LightningElement, api, wire } from "lwc";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { subscribe, MessageContext } from "lightning/messageService";
import getLoanPreference from "@salesforce/apex/LoanPreferenceController.getLoanPreference";
import getCalculateLoanRepayment from "@salesforce/apex/LoanPreferenceController.getCalculateLoanRepayment";
import getAdditionFundsForLoanPreference from "@salesforce/apex/AdditionalFundsController.getAdditionFundsForLoanPreference";
import updateLoanPreference from "@salesforce/apex/LoanPreferenceController.updateLoanPreference";
import hasEditPermission from "@salesforce/customPermission/Loan_Preference_Edit";
import hasDeletePermission from "@salesforce/customPermission/Loan_Preference_Delete";
import INTEREST_RATE_TYPE from "@salesforce/schema/LoanApplicationFinancial.Interest_Rate_Type__c";
import LOAN_REPAYMENT_TYPE from "@salesforce/schema/LoanApplicationFinancial.Loan_Repayment_Type__c";
import BORROW_ADDITIONAL_FUND from "@salesforce/schema/LoanApplicationFinancial.Borrow_Additional_Funds__c";
import OFFSET from "@salesforce/schema/LoanApplicationFinancial.Offset__c";
import RLA_STATUS_APINAME from "@salesforce/schema/ResidentialLoanApplication.Status";
import LoanPreferenceDeleteCashOutPurpose from "c/loanPreferenceDeleteCashOutPurpose";
import LoanPreferenceAddFundsAndPurpose from "c/loanPreferenceAddFundsAndPurpose";
import { handleErrorShowToast, showToast } from "c/utils";
import RefreshLoanPreference from "@salesforce/messageChannel/RefreshLoanPreference__c";

import { getRecord, getFieldValue } from "lightning/uiRecordApi";

const MASTER_RECORD_TYPE_ID = "012000000000000AAA"; // Master record type - using it due to that there isn’t a default record type
const SUCCESS_MESSAGE = "Changes to Loan Preferences were successfully saved.";
const UPDATE_ERROR_MESSAGE =
  "The changes to the Loan Preferences did not save. Please try again.";
const LOAN_PREF_ERROR = "Failed to load Loan Preferences details.";
const ADD_FUND_ERROR = "Failed to load Additional Cash Out details.";
const DELETE_PERMISSION_ERROR_MESSAGE =
  "Do not have permission to update this value";
export default class LoanPreferenceDetailsDisplay extends LightningElement {
  @api recordId;
  errorMessage;
  componentSpinner = false;
  loanPreferenceDetails = {};
  loanPreferenceEditDetails = {};
  additionalFunds = {};
  interestRateTypeMap = new Map();
  loanRepaymentTypeMap = new Map();
  showViewScreen = false;
  showEditScreen = false;
  showBlankScreen = false;
  calculateLoanRepaymentError = false;
  deletePermissionError = "";
  monthValue;
  yearValue;
  totalMonths;
  showLoanAdditionalFund = false;
  applicationStatus;
  loanRepaymentTypeVal;
  interestRateTypeVal;
  loanRepaymentFrequencyVal;
  lastUpdatedDate;
  interestRateVal;
  offsetOptions = [];
  additionalFundOptions = [];

  frequencyOptions = [
    {
      label: "Weekly",
      value: "REPAYMENT_FREQUENCY_WEEKLY"
    },
    {
      label: "Fortnightly",
      value: "REPAYMENT_FREQUENCY_FORTNIGHTLY"
    },
    {
      label: "Monthly",
      value: "REPAYMENT_FREQUENCY_MONTHLY"
    }
  ];

  get isEditAllowed() {
    return hasEditPermission && this.applicationStatus === "STATE_REFERRED";
  }

  //wired method to get residential loan data
  @wire(getRecord, {
    recordId: "$recordId",
    fields: [RLA_STATUS_APINAME]
  })
  wiredAccount({ data }) {
    if (data) {
      this.applicationStatus = getFieldValue(data, RLA_STATUS_APINAME); // Storing the loan status field value

      if (this.applicationStatus !== "STATE_CAPTURE") {
        this.loadLoanPreferenceData(); // calling loadLoanPreferenceData API after getting status
        this.subscribeToMessageChannel();
      } else {
        this.showBlankScreen = true;
        this.showViewScreen = false;
        this.showEditScreen = false;
      }
    }
  }

  @wire(MessageContext)
  messageContext;
  subscription;

  @wire(getPicklistValues, {
    recordTypeId: MASTER_RECORD_TYPE_ID,
    fieldApiName: INTEREST_RATE_TYPE
  })
  wiredIntrestTypeValues({ data }) {
    if (data) {
      data.values.forEach((item) => {
        this.interestRateTypeMap.set(item.value, item.label);
      });
    }
  }

  @wire(getPicklistValues, {
    recordTypeId: MASTER_RECORD_TYPE_ID,
    fieldApiName: LOAN_REPAYMENT_TYPE
  })
  wiredRepaymentValues({ data }) {
    if (data) {
      data.values.forEach((item) => {
        this.loanRepaymentTypeMap.set(item.value, item.label);
      });
    }
  }

  @wire(getPicklistValues, {
    recordTypeId: MASTER_RECORD_TYPE_ID,
    fieldApiName: OFFSET
  })
  wiredOffsetValues({ data }) {
    if (data) {
      this.offsetOptions = data.values.map((object) => {
        return { label: object.label, value: object.value };
      });
    }
  }
  @wire(getPicklistValues, {
    recordTypeId: MASTER_RECORD_TYPE_ID,
    fieldApiName: BORROW_ADDITIONAL_FUND
  })
  wiredFundsValues({ data }) {
    if (data) {
      this.additionalFundOptions = data.values.map((object) => {
        return { label: object.label, value: object.value };
      });
    }
  }

  async loadLoanPreferenceData() {
    this.componentSpinner = true;
    try {
      // Callout to get the Loan Preference details
      const loanPreferenceViewModel = await getLoanPreference({
        loanId: this.recordId
      });
      if (loanPreferenceViewModel) {
        this.transformLoanPreferenceValues(loanPreferenceViewModel);
      }
      try {
        // Callout to get the Loan Repayment Details
        const calculateLoanRepayment = await getCalculateLoanRepayment({
          loanId: this.recordId
        });
        if (calculateLoanRepayment) {
          this.loanPreferenceDetails.estimatedRepaymentAmount =
            calculateLoanRepayment?.convertedAmount;
          this.interestRateVal = this.readableIntrestRate(
            calculateLoanRepayment?.interestRate
          );
        }
      } catch (error) {
        this.calculateLoanRepaymentError = true;
      }

      try {
        // Callout to get the Additional Fund Details
        const additionalFunds = await getAdditionFundsForLoanPreference({
          recordId: this.recordId
        });
        if (additionalFunds) {
          this.additionalFunds = additionalFunds;
          this.showLoanAdditionalFund = true;
        }
      } catch (error) {
        handleErrorShowToast(this, "", null, ADD_FUND_ERROR, "pester");
      }

      this.loanPreferenceDetails = { ...this.loanPreferenceDetails };
      this.showViewScreen = true;
      this.showEditScreen = false;
      this.showBlankScreen = false;
    } catch (error) {
      handleErrorShowToast(this, "", error, LOAN_PREF_ERROR, "pester");
    } finally {
      this.componentSpinner = false;
    }
  }

  transformLoanPreferenceValues(loanPreferenceViewModel) {
    this.loanPreferenceDetails = loanPreferenceViewModel;
    //loan repayment type, intrest rate type and repayment frequency are required on loan preference creation process on mobile so not adding null checks
    this.loanRepaymentTypeVal = this.loanRepaymentTypeMap.get(
      loanPreferenceViewModel.loanRepaymentType
    );

    this.interestRateTypeVal = this.interestRateTypeMap.get(
      loanPreferenceViewModel.interestRateType
    );

    this.loanRepaymentFrequencyVal = this.frequencyOptions.find(
      (item) => item.value === loanPreferenceViewModel.loanRepaymentFrequency
    ).label;

    this.lastUpdatedDate = this.setTimestamp(
      loanPreferenceViewModel?.lastUpdatedDate,
      loanPreferenceViewModel?.timeZone
    );
    this.yearValue = Math.floor(loanPreferenceViewModel.loanTermInMonths / 12); //divide my 12 and round down
    this.monthValue = loanPreferenceViewModel.loanTermInMonths % 12; //get the reminder of month
  }

  //Convert Datetime into readable formate
  setTimestamp(timestamp, userTimeZone) {
    if (!timestamp) return null;
    //Create timestamp for last updated
    let lastModified = new Date(timestamp).toLocaleString("en-AU", {
      timeZone: userTimeZone,
      day: "numeric",
      month: "numeric",
      year: "numeric",
      hour: "numeric",
      minute: "numeric",
      hour12: true
    });
    return lastModified;
  }

  //Readable intrestRate
  readableIntrestRate(intrestRate) {
    if (!intrestRate) {
      return null;
    }
    return intrestRate / 100 + "%";
  }

  handleEdit() {
    this.loadEditModel();
    this.toggleScreen();
  }

  loadEditModel() {
    this.loanPreferenceEditDetails = { ...this.loanPreferenceDetails };
  }

  toggleScreen() {
    this.showEditScreen = !this.showEditScreen;
    this.showViewScreen = !this.showViewScreen;
  }

  //method to handle cancel functionality
  handleCancel() {
    this.toggleScreen();
  }
  //method on save of edit page
  handleSave() {
    this.makeUpdateLoanCallout();
  }

  handleAmountChange(event) {
    this.loanPreferenceEditDetails.currentLoanBalance = Number(
      event.target.value
    );
  }
  handleFrequencyChanges(event) {
    this.loanPreferenceEditDetails.loanRepaymentFrequency = event.target.value;
  }
  handleMonthChange(event) {
    this.monthValue = event.target.value;
    this.loanPreferenceEditDetails.loanTermInMonths = this.getTotalMonths();
  }
  handleYearChange(event) {
    this.yearValue = event.target.value;
    this.loanPreferenceEditDetails.loanTermInMonths = this.getTotalMonths();
  }
  handleOffsetChanges(event) {
    this.loanPreferenceEditDetails.offset = event.target.value;
  }
  handlBorrowAdditionalChanges(event) {
    this.deletePermissionError = "";
    if (
      event.target.value === "No" &&
      event.target.value !== this.loanPreferenceDetails.borrowAdditionalFunds
    ) {
      if (!hasDeletePermission) {
        this.deletePermissionError = DELETE_PERMISSION_ERROR_MESSAGE;
        return;
      }
      this.loanPreferenceEditDetails.borrowAdditionalFunds = event.target.value;
      LoanPreferenceDeleteCashOutPurpose.open({
        size: "small",
        purposeName: "All",
        fundRecords: null,
        loanPreferenceData: this.loanPreferenceEditDetails
      }).then((result) => {
        // if modal closed with X button, promise returns result = 'undefined'
        // if modal closed with OK button, promise returns result = 'okay'
        if (result === undefined || result === "okay") {
          this.toggleScreen();
        }
      });
    }
    if (
      event.target.value === "Yes" &&
      event.target.value !== this.loanPreferenceDetails.borrowAdditionalFunds
    ) {
      this.loanPreferenceEditDetails.borrowAdditionalFunds = event.target.value;
      //If additional funds are not available then null will be passed otherwise additional funds array will be passed in specific format(amount,value,otherReason)
      const transformedAdditionalFunds =
        (this.additionalFunds?.additionalFunds?.length ?? 0) === 0
          ? null
          : this.additionalFunds.additionalFunds.map((fund) => ({
              amount: fund.amount,
              value: fund.purpose,
              otherReason: fund.otherReason
            }));
      LoanPreferenceAddFundsAndPurpose.open({
        size: "small",
        fundRecords: transformedAdditionalFunds,
        loanPreferenceData: this.loanPreferenceEditDetails
      }).then((result) => {
        // if modal closed with X button, promise returns result = 'undefined'
        // if modal closed with OK button, promise returns result = 'okay'
        if (result === undefined || result === "okay") {
          this.toggleScreen();
        }
      });
    }
  }
  getTotalMonths() {
    return this.yearValue * 12 + Number(this.monthValue);
  }

  //handles callout
  async makeUpdateLoanCallout() {
    this.componentSpinner = true;
    try {
      this.calloutResponse = await updateLoanPreference({
        updateLoanPreferenceData: this.loanPreferenceEditDetails,
        additionalFundsData: this.additionalFunds
      });
      if (this.calloutResponse?.successful) {
        showToast(this, "", SUCCESS_MESSAGE, "", "Success", "dismissable");
      } else {
        if (this.calloutResponse?.message === "") {
          this.calloutResponse.message = UPDATE_ERROR_MESSAGE;
        }
        handleErrorShowToast(
          this,
          "",
          "Error",
          this.calloutResponse?.message,
          "pester"
        );
      }
      this.refreshData();
      this.toggleScreen();
    } catch (error) {
      handleErrorShowToast(this, "", error, UPDATE_ERROR_MESSAGE, "pester");
    } finally {
      this.componentSpinner = false;
    }
  }

  subscribeToMessageChannel() {
    if (!this.subscription) {
      this.subscription = subscribe(
        this.messageContext,
        RefreshLoanPreference,
        (message) => {
          if (message.refresh) {
            this.refreshData();
          }
        }
      );
    }
  }
  refreshData() {
    this.loadLoanPreferenceData();
  }
}
