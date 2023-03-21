import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import getStaticResource from "@salesforce/resourceUrl/h1account";
import getHomeLoanFinancialAccountId from "@salesforce/apex/HomeLoanController.getHomeLoanFinancialAccountId";
import hasHomeLoanPermission from "@salesforce/customPermission/ANZx_Home_Loan";
import hasFinancialAccountPermission from "@salesforce/customPermission/FinServ__FinancialServicesCloudStandard";
import { handleErrorShowToast } from "c/utils";

import templateCard from "./homeLoanAccountCard.html";
import templateDetail from "./homeLoanAccountDetail.html";
export default class HomeLoanAccountCard extends NavigationMixin(
  LightningElement
) {
  @api recordId;
  @api accountDetails;
  @api error;
  @api objectApiName;
  showBalanceModal = false;
  showRedrawAvailableModal = false;
  financialAccountId;
  loanImageUrl = getStaticResource + "/images/Mortgage.png";
  errorImageUrl = getStaticResource + "/images/PermissionError.png";
  hasError;
  activeSections = ["loandetails", "repaymentdetails"];
  errorMsg =
    "Failed To Retrieve Home Loan Account. Please refresh and try again. If issue persists please contact your System Administrator";

  connectedCallback() {
    if (hasHomeLoanPermission) {
      this.init();
    }
  }

  async init() {
    if (this.accountDetails) {
      try {
        this.financialAccountId = await getHomeLoanFinancialAccountId({
          customerId: this.recordId
        });
      } catch (error) {
        handleErrorShowToast(
          this,
          "Failed To Retrieve Home Loan Account.",
          error,
          this.errorMsg,
          "pester"
        );
      }
    }
  }

  render() {
    if (this.objectApiName === "FinServ__FinancialAccount__c") {
      return templateDetail;
    } else if (this.objectApiName === "Account") {
      return templateCard;
    }
    return null;
  }

  get accountActive() {
    return this.accountDetails.state === "ACCOUNT_STATE_CLOSED" ? false : true;
  }

  get hasPermissionIssue() {
    return !(hasHomeLoanPermission && hasFinancialAccountPermission);
  }

  get timestamp() {
    let updated = new Date(this.accountDetails.loan_details.valid_at);
    let lastUpdated =
      updated.getDate() +
      " " +
      updated.toLocaleString("en-AU", {
        month: "long"
      }) +
      " " +
      updated.getFullYear() +
      " | " +
      updated.toLocaleString("en-AU", {
        hour: "numeric",
        minute: "numeric",
        hour12: true
      });

    return lastUpdated;
  }

  get loanTerm() {
    let termInMonth = this.accountDetails.loan_details.loan_term;
    let months = { one: "month", other: "months" };
    let years = { one: "year", other: "years" };
    let m = termInMonth % 12;
    let y = Math.floor(termInMonth / 12);
    let result = [];
    if (y) {
      result.push(y + " " + getPlural(y, years));
    }
    if (m) {
      result.push(m + " " + getPlural(m, months));
    }

    function getPlural(number, word) {
      return (number === 1 && word.one) || word.other;
    }
    return result.join(" ");
  }

  get nextRepayment() {
    let nextrepaymentdate = new Date(
      this.accountDetails.loan_details.next_payment_date.year,
      Number(this.accountDetails.loan_details.next_payment_date.month) - 1,
      this.accountDetails.loan_details.next_payment_date.day
    ).toLocaleDateString("en-au", {
      year: "numeric",
      month: "short",
      day: "2-digit"
    });
    return nextrepaymentdate;
  }

  get repaymentType() {
    switch (this.accountDetails.loan_details.repayment_type) {
      case "REPAYMENT_TYPE_PRINCIPAL_INTEREST":
        return "Principal & Interest";
      case "REPAYMENT_TYPE_INTEREST_ONLY":
        return "Interest only";
      default:
        return null;
    }
  }

  get settlementDate() {
    let settleDate = new Date(
      this.accountDetails.loan_details.loan_start_date.year,
      Number(this.accountDetails.loan_details.loan_start_date.month) - 1,
      this.accountDetails.loan_details.loan_start_date.day
    ).toLocaleDateString("en-au", {
      year: "numeric",
      month: "short",
      day: "2-digit"
    });

    return settleDate;
  }

  get repaymentFrequency() {
    switch (this.accountDetails.loan_details.repayment_frequency) {
      case "REPAYMENT_FREQUENCY_FORTNIGHTLY":
        return "Fortnightly";
      case "REPAYMENT_FREQUENCY_MONTHLY":
        return "Monthly";
      case "REPAYMENT_FREQUENCY_QUARTERLY":
        return "Quarterly";
      case "REPAYMENT_FREQUENCY_HALF_YEARLY":
        return "Bi Annually";
      case "REPAYMENT_FREQUENCY_YEARLY":
        return "Annually";
      case "REPAYMENT_FREQUENCY_WEEKLY":
        return "Weekly";
      case "REPAYMENT_FREQUENCY_SEASONAL":
        return "?";
      default:
        return null;
    }
  }

  get rateType() {
    switch (this.accountDetails.product_details.marketing_code) {
      case "HLVAR01":
        return "Variable";
      case "HLFXD01":
        return "Fixed";
      default:
        return null;
    }
  }

  navigateToRecordViewPage() {
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: this.financialAccountId,
        actionName: "view"
      }
    });
  }

  handleBalanceModal() {
    this.showBalanceModal = !this.showBalanceModal;
  }

  handleRedrawAvailableModal() {
    this.showRedrawAvailableModal = !this.showRedrawAvailableModal;
  }
}
