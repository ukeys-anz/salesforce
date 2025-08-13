import { LightningElement, wire, api } from "lwc";
import getloanApplication from "@salesforce/apex/LoanApplicationController.getLoanPreferenceDetails";
import GetLoanApplicationDetails from "@salesforce/messageChannel/GetLoanApplicationDetails__c";
import { loadStyle } from "lightning/platformResourceLoader";
import styling from "@salesforce/resourceUrl/accordionStyling";
import { publish, MessageContext } from "lightning/messageService";
import {
  transformMonthToYearMonth,
  setTimestampShorthand,
  handleAmountConversion
} from "c/utils";
import {
  repaymentFrequencyMap,
  interestRateTypeMap,
  repaymentTypeMap
} from "c/loanApplicationUtils";

const API_ERROR =
  "An error has occurred. Please refresh and try again. If the problem persists, please contact your System Administrator.";

const DATA_NOT_AVAILABLE_ERROR =
  "Current loan details will only be displayed after the customer selects this information during the application process.";

export default class CurrentLoanDetailsDisplay extends LightningElement {
  @api recordId;
  componentSpinner = false;
  isError = false;
  isRequestedLoanDetailsError = false;
  loanApplicationData = {};
  currentLoanItems = [];
  iconName;

  @wire(MessageContext)
  messageContext;

  connectedCallback() {
    Promise.all([loadStyle(this, styling)]);
    this.getloanApplicationDetails();
  }

  getloanApplicationDetails() {
    this.componentSpinner = true;
    getloanApplication({
      loanId: this.recordId,
      skipCacheForCallout: true
    })
      .then((response) => {
        // passing complete data to Requested loan details component
        this.loanApplicationData = response;

        if (!response?.refinanceLiabilities?.length) {
          this.isError = true;
          this.errorMessage = DATA_NOT_AVAILABLE_ERROR;
          this.iconName = "utility:connected_apps";
          return;
        }

        //transforming the data coming from getloanapplciation API
        this.currentLoanItems = this.transformLoanLiabilitiesData(
          response.refinanceLiabilities
        );
      })
      .catch((error) => {
        this.errorMessage = API_ERROR;
        this.iconName = "utility:error";
        this.isError = true;
        this.isRequestedLoanDetailsError = true;
      })
      .finally(() => {
        this.componentSpinner = false;
        publish(this.messageContext, GetLoanApplicationDetails, {
          getLoanDetails: this.loanApplicationData,
          isError: this.isRequestedLoanDetailsError
        });
      });
  }

  transformLoanLiabilitiesData(liabilities) {
    let hasMultipleLiabilties = liabilities.length > 1;
    return liabilities.map((item, index) => {
      return {
        anzPlusHomeLoans: this.getAnzPlusHomeLoans(item.plusLiability),
        loanBalance: this.getLoanBalances(item.outstandingBalance),
        rateType: this.getRateType(item.initialTerm?.interestRateType),
        repaymentType: this.getRepaymentType(item.initialTerm?.repaymentType),
        remainingPeriod: this.getRemainingPeriod(item),
        remainingTerm: this.getRemainingTerm(item),
        totalRemainingTerm: this.getTotalRemainingTerm(item),
        breakCosts: this.getBreakCosts(item.breakCosts),
        updatedTime: this.getUpdatedTime(item.updateTime),
        interestRate: this.getInterestRate(item.initialTerm?.interestRate),
        subsequentInterestRate: this.getSubsequentInterestRate(item),
        repaymentFrequency: this.getRepaymentFrequency(item.repaymentFrequency),
        label: hasMultipleLiabilties
          ? "Loan Details " + (index + 1)
          : "Loan Details"
      };
    });
  }

  getAnzPlusHomeLoans(data) {
    if (data == null) {
      return;
    }
    return data ? "Yes" : "No";
  }

  getUpdatedTime(data) {
    if (!data) {
      return;
    }
    return setTimestampShorthand(data);
  }

  getBreakCosts(data) {
    if (data == null) {
      return;
    }
    return data ? "Yes" : "No";
  }

  getLoanBalances(data) {
    if (!data) {
      return;
    }
    return handleAmountConversion(data.units, data.nanos);
  }

  getRateType(data) {
    if (!data) {
      return;
    }
    return interestRateTypeMap.get(data);
  }

  getRepaymentFrequency(data) {
    if (!data) {
      return;
    }
    return repaymentFrequencyMap.get(data);
  }

  getRepaymentType(data) {
    if (!data) {
      return;
    }
    return repaymentTypeMap.get(data);
  }

  getRemainingPeriod(data) {
    if (
      data.initialTerm?.repaymentType !== "REPAYMENT_TYPE_INTEREST_ONLY" ||
      data.initialTerm?.remainingTerm == null
    ) {
      return;
    }
    return transformMonthToYearMonth(data.initialTerm.remainingTerm);
  }

  getRemainingTerm(data) {
    if (
      data.initialTerm?.repaymentType === "REPAYMENT_TYPE_INTEREST_ONLY" &&
      data.subsequentTerm?.remainingTerm != null
    ) {
      return transformMonthToYearMonth(data.subsequentTerm.remainingTerm);
    }

    if (
      data.initialTerm?.repaymentType === "REPAYMENT_TYPE_PRINCIPAL_INTEREST" &&
      data.initialTerm?.remainingTerm != null
    ) {
      return transformMonthToYearMonth(data.initialTerm.remainingTerm);
    }
    return;
  }

  getInterestRate(data) {
    if (data == null) {
      return;
    }
    return (data / 100).toFixed(2) + "%";
  }

  getSubsequentInterestRate(data) {
    if (
      data.initialTerm?.repaymentType !== "REPAYMENT_TYPE_INTEREST_ONLY" ||
      data.subsequentTerm?.interestRate == null
    ) {
      return;
    }
    return (data.subsequentTerm.interestRate / 100).toFixed(2) + "%";
  }

  getTotalRemainingTerm(data) {
    if (data.initialTerm?.repaymentType !== "REPAYMENT_TYPE_INTEREST_ONLY") {
      return;
    }

    let initialRemaining = data.initialTerm?.remainingTerm ?? 0;
    let subsequentRemaining = data.subsequentTerm?.remainingTerm ?? 0;
    return transformMonthToYearMonth(initialRemaining + subsequentRemaining);
  }
}
