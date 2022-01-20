import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import hasAccountsGoalsPermission from "@salesforce/customPermission/ANZx_Accounts_and_Goals";

export default class FinancialGoalsPersonAccount extends NavigationMixin(
  LightningElement
) {
  goalDetails;
  @api savingsAccount;
  viewAll = false;
  showInfoModal = false;
  hasGoals;

  @api
  get goalData() {
    return this.goalDetails;
  }

  set goalData(value) {
    this.goalDetails = value;
  }

  get displayContent() {
    return hasAccountsGoalsPermission;
  }

  get timestamp() {
    //Create timestamp for last updated
    let updated = new Date();

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

  connectedCallback() {
    if (this.goalDetails && this.goalDetails.length > 0) {
      this.hasGoals = true;
      //Only need to display 3 goals
      if (this.goalDetails.length > 3) {
        this.goalDetails = this.goalDetails.slice(0, 3);
        this.viewAll = true;
      }
    } else {
      this.hasGoals = false;
    }
  }

  handleInfoModal() {
    this.showInfoModal = !this.showInfoModal;
  }

  navigateToRecordViewPage() {
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: this.savingsAccount,
        actionName: "view"
      }
    });
  }

  navigateToRecordViewPageFilter(event) {
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: this.savingsAccount,
        actionName: "view"
      },
      state: {
        c__goalId: event.currentTarget.dataset.id
      }
    });
  }
}
