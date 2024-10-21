import { LightningElement, api, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { openTab, EnclosingTabId } from "lightning/platformWorkspaceApi";
import getStaticResource from "@salesforce/resourceUrl/h1account";
import getHomeLoanFinancialAccountId from "@salesforce/apex/HomeLoanController.getLinkedHomeLoanFinancialAccountRole";
import hasHomeLoanPermission from "@salesforce/customPermission/ANZx_Home_Loan";
import hasFinancialAccountPermission from "@salesforce/customPermission/FinServ__FinancialServicesCloudStandard";
import { handleErrorShowToast } from "c/utils";

import templateCard from "./homeLoanAccountCard.html";
import templateDetail from "./homeLoanAccountDetail.html";
export default class HomeLoanAccountCard extends NavigationMixin(
  LightningElement
) {
  @wire(EnclosingTabId) tabId;
  @api recordId;
  @api accountDetails;
  @api error;
  @api objectApiName;
  @api ownershipType;
  @api accountOwnersList;
  @api offsetDetails;
  timestamp;
  financialAccounts = [];
  showBalanceModal = false;
  offsetList;
  showRedrawAvailableModal = false;
  financialAccounRoleList = [];
  loanImageUrl = getStaticResource + "/images/Mortgage.png";
  errorImageUrl = getStaticResource + "/images/PermissionError.png";
  hasError;
  activeSections = ["loandetails", "repaymentdetails"];
  errorMsg =
    "Failed To Retrieve Home Loan Account. Please refresh and try again. If issue persists please contact your System Administrator";
  singleFinAccount;
  multiparty = false;

  // Map for rendering the HTML
  templateMap = {
    Account: templateCard,
    FinServ__FinancialAccount__c: templateDetail
  };

  connectedCallback() {
    if (hasHomeLoanPermission) {
      this.init();
    }
    this.timestamp = this.handleLastModifiedTimestamp();
  }

  get isAccountTab() {
    return this.objectApiName === "Account";
  }
  get isFinAccountTab() {
    return this.objectApiName === "FinServ__FinancialAccount__c";
  }

  async init() {
    if (this.ownershipType === "Multi-party") {
      this.multiparty = true;
    }
    if (this.accountDetails) {
      this.financialAccounts = JSON.parse(this.accountDetails);
      try {
        //Only need to get financial account id if we are on person account
        if (this.isAccountTab) {
          this.financialAccounRoleList = await getHomeLoanFinancialAccountId({
            customerId: this.recordId
          });
        }

        this.financialAccounts.forEach((finAccount) => {
          if (this.financialAccounRoleList && this.isAccountTab) {
            //Retrieve record id for linked fin account
            this.financialAccounRoleList.forEach((account) => {
              if (
                account.FinServ__FinancialAccount__r
                  .FinServ__FinancialAccountNumber__c ===
                finAccount.account_number
              ) {
                finAccount.recordId = account.FinServ__FinancialAccount__c;
              }
            });
            finAccount.offsetDetails = this.handleOffsetDetails(
              finAccount,
              this.offsetDetails
            );
            finAccount.isOffsetListEmpty =
              (finAccount.offsetDetails?.length ?? 0) === 0;
          }
          finAccount.lastModifiedTimestamp =
            this.handleLastModifiedTimestamp(finAccount);
          finAccount.accountActive = this.handleAccountActive(finAccount.state);
          finAccount.loanTerm = this.handleLoanTerm(finAccount);
          finAccount.nextRepayment = this.handleNextRepayment(finAccount);
          finAccount.repaymentType = this.handleRepaymentType(finAccount);
          finAccount.settlementDate = this.handleSettlementDate(finAccount);
          finAccount.repaymentFrequency =
            this.handleRepaymentFrequency(finAccount);
          finAccount.rateType = this.handleRateType(finAccount);
        });

        if (this.isFinAccountTab) {
          this.singleFinAccount = this.financialAccounts[0];
          this.offsetList = this.handleOffsetDetails(
            this.singleFinAccount,
            this.offsetDetails
          );
        }

        const financialAccountOpenList = this.financialAccounts.filter(
          (eachAccount) => {
            return eachAccount.state !== "ACCOUNT_STATE_CLOSED";
          }
        );
        this.financialAccounts = financialAccountOpenList;
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
    return this.templateMap[this.objectApiName];
  }

  get hasPermissionIssue() {
    return !(hasHomeLoanPermission && hasFinancialAccountPermission);
  }

  get showHomeLoan() {
    return this.financialAccounts.length > 0;
  }

  get showOffsetData() {
    return this.offsetList?.length > 0;
  }

  get hasOffsetError() {
    return this.offsetDetails?.hasError;
  }

  handleAccountActive(state) {
    return state === "ACCOUNT_STATE_CLOSED" ? false : true;
  }

  handleLastModifiedTimestamp(account) {
    let updated = account
      ? new Date(account.loan_details.valid_at)
      : new Date();
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

  //USED IN THE FINANCIAL ACCOUNT VIEW FOR SHOWING LOAN TERM
  handleLoanTerm(account) {
    let termInMonth = account.loan_details.loan_term;
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

  handleNextRepayment(account) {
    let nextRepaymentDate = new Date(
      account.loan_details.next_payment_date.year,
      Number(account.loan_details.next_payment_date.month) - 1,
      account.loan_details.next_payment_date.day
    ).toLocaleDateString("en-au", {
      year: "numeric",
      month: "short",
      day: "2-digit"
    });
    return nextRepaymentDate;
  }

  //USED IN FINANCIAL ACCOUNT
  handleRepaymentType(account) {
    switch (account.loan_details.repayment_type) {
      case "REPAYMENT_TYPE_PRINCIPAL_INTEREST":
        return "Principal & Interest";
      case "REPAYMENT_TYPE_INTEREST_ONLY":
        return "Interest only";
      default:
        return null;
    }
  }

  //USED IN FINANCIAL ACCOUNT
  handleSettlementDate(account) {
    let settleDate = new Date(
      account.loan_details.loan_start_date.year,
      Number(account.loan_details.loan_start_date.month) - 1,
      account.loan_details.loan_start_date.day
    ).toLocaleDateString("en-au", {
      year: "numeric",
      month: "short",
      day: "2-digit"
    });

    return settleDate;
  }

  //USED IN FINANCIAL ACCOUNT
  handleRepaymentFrequency(account) {
    switch (account.loan_details.repayment_frequency) {
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

  //USED IN FINANCIAL ACCOUNT
  handleRateType(account) {
    switch (account.product_details.marketing_code) {
      case "HLVAR01":
        return "Variable";
      case "HLFXD01":
        return "Fixed";
      default:
        return null;
    }
  }

  //USED IN FINANCIAL ACCOUNT AND CUSTOMER FINANCIALS PAGE
  handleOffsetDetails(account, offsetAccountDetails) {
    var offsetData = [];
    if (offsetAccountDetails == null || offsetAccountDetails?.hasError) {
      return offsetData;
    }
    offsetData = offsetAccountDetails.loan_offsets
      .filter(
        (offsetAccount) => offsetAccount.loan_account === account.account_number
      )
      .flatMap((item) =>
        item.offsetDetails.map((detail) => ({
          financialAccountNumber: detail.financialAccountNumber,
          financialAccountId: detail.financialAccountId
        }))
      );
    return offsetData;
  }

  navigateToRecordViewPage(event) {
    const recordIdToOpen = event.currentTarget.dataset.id;
    if (this.isAccountTab || this.isFinAccountTab) {
      this[NavigationMixin.Navigate]({
        type: "standard__recordPage",
        attributes: {
          recordId: recordIdToOpen,
          actionName: "view"
        }
      });
    } else {
      openTab({
        recordId: recordIdToOpen
      }).catch((error) => {
        console.error(error);
      });
    }
  }

  handleBalanceModal() {
    this.showBalanceModal = !this.showBalanceModal;
  }

  handleRedrawAvailableModal() {
    this.showRedrawAvailableModal = !this.showRedrawAvailableModal;
  }
}
