import { LightningElement, wire } from "lwc";
import { loadStyle } from "lightning/platformResourceLoader";
import styling from "@salesforce/resourceUrl/accordionStyling";
import { subscribe, MessageContext } from "lightning/messageService";
import GetLoanApplicationDetails from "@salesforce/messageChannel/GetLoanApplicationDetails__c";
import { transformMonthToYearMonth, handleAmountConversion } from "c/utils";
import {
  repaymentFrequencyMap,
  interestRateTypeMap,
  repaymentTypeMap,
  propertyUseMap
} from "c/loanApplicationUtils";

const API_ERROR =
  "An error has occurred. Please refresh and try again. If the problem persists, please contact your System Administrator.";
const DATA_NOT_AVAILABLE =
  "Requested Loan Details will only be displayed after the customer selects this information during the application process.";

export default class RequestedLoanDetails extends LightningElement {
  subscription;
  repaymentType;
  interestLoanPeriod;
  requestedLoanAmount;
  borrowAdditionalFunds;
  multiParty;
  propertyUse;
  loanTerm;
  interestRateType;
  repaymentFrequency;
  errorMessage;
  applicationErrorMessage;
  preferenceError = false;
  applicationError = false;
  componentSpinner = false;
  iconName;

  @wire(MessageContext)
  messageContext;

  connectedCallback() {
    this.componentSpinner = true;
    Promise.all([loadStyle(this, styling)]);
    this.subscribeToMessageChannel();
  }
  subscribeToMessageChannel() {
    if (!this.subscription) {
      this.subscription = subscribe(
        this.messageContext,
        GetLoanApplicationDetails,
        (message) => this.handleLoanDetails(message)
      );
    }
  }

  handleLoanDetails(message) {
    this.componentSpinner = false;
    if (message.isError) {
      this.preferenceError = true;
      this.errorMessage = API_ERROR;
      this.iconName = "utility:error";
      return;
    }
    if (
      message.getLoanDetails?.joint == null &&
      (message.getLoanDetails.preferences?.length ?? 0) === 0
    ) {
      this.preferenceError = true;
      this.errorMessage = DATA_NOT_AVAILABLE;
      this.iconName = "utility:connected_apps";
      return;
    }
    this.transformLoanPreferencesDetails(message.getLoanDetails);
  }
  transformLoanPreferencesDetails(data) {
    this.multiParty = this.getMultiParty(data?.joint);
    if ((data.preferences?.length ?? 0) === 0) {
      return;
    }
    let preference = data.preferences[0];
    this.repaymentType = repaymentTypeMap.get(
      preference.initialLoanTermDetails?.repaymentType
    );
    this.interestLoanPeriod = this.getInterestLoanPeriod(
      preference.initialLoanTermDetails?.loanTermMonths
    );
    this.borrowAdditionalFunds = preference.funds?.length > 1 ? true : false;
    this.requestedLoanAmount = this.getRequestedLoanAmount(
      preference.loanAmount
    );
    this.propertyUse = propertyUseMap.get(preference.productType);
    this.loanTerm = this.getLoanTermDetails(preference.termMonths);
    this.interestRateType = interestRateTypeMap.get(
      preference.initialLoanTermDetails?.interestRateType
    );
    this.repaymentFrequency = repaymentFrequencyMap.get(
      preference.repaymentFrequency
    );
  }

  getRequestedLoanAmount(data) {
    if (!data) {
      return null;
    }
    return handleAmountConversion(data.units, data.nanos);
  }

  getLoanTermDetails(data) {
    if (data == null) {
      return null;
    }
    return transformMonthToYearMonth(data);
  }

  getInterestLoanPeriod(data) {
    if (this.repaymentType !== "Interest Only" || data == null) {
      return null;
    }
    return transformMonthToYearMonth(data);
  }
  getMultiParty(data) {
    if (data == null) {
      return null;
    }
    return data ? "Yes" : "No";
  }
}
