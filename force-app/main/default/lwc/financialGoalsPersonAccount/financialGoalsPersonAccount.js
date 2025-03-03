import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import hasAccountsGoalsPermission from "@salesforce/customPermission/ANZx_Accounts_and_Goals";
import { MULTI_PARTY, JOINT } from "c/transactionHistoryService";

export default class FinancialGoalsPersonAccount extends NavigationMixin(
  LightningElement
) {
  goalDetails;
  showInfoModal = false;
  hasGoals;
  @api error;
  onLoadGoalDisplayCount = 2;
  productName;
  balanceTitle;

  @api
  get goalData() {
    return this.goalDetails;
  }

  set goalData(value) {
    this.goalDetails = structuredClone(value);
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
    this.processGoalDetails(this.goalDetails);
  }

  handleInfoModal(event) {
    this.productName = event.currentTarget.dataset.productname;
    this.balanceTitle = event.currentTarget.dataset.balancetitle;
    this.showInfoModal = !this.showInfoModal;
  }

  navigateToFinancialAccountViewPage(event) {
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: event.currentTarget.dataset.id,
        actionName: "view"
      }
    });
  }

  navigateToRecordViewPageFilter(event) {
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: event.currentTarget.dataset.finid,
        actionName: "view"
      },
      state: {
        c__goalId: event.currentTarget.dataset.id
      }
    });
  }

  processGoalDetails(goalDetails) {
    if (!goalDetails || goalDetails.length === 0) {
      this.hasGoals = false;
      return;
    }

    this.hasGoals = true;

    goalDetails.forEach((record) => {
      // Check if record has valid buckets and showGoal is true
      if (!record.buckets || record.showGoal !== true) {
        record.haveGoals = false;
        return;
      }

      // Handle the buckets
      if (record.buckets.length >= this.onLoadGoalDisplayCount) {
        record.goalsLeftToView = this.pendingGoalssTobeViewed(
          record.buckets.length
        );
        record.buckets = record.buckets.slice(0, this.onLoadGoalDisplayCount);
        record.viewAll = true;
      } else {
        record.viewAll = false;
      }

      // General flags and properties
      record.haveGoals = true;
      record.showMultipartyBadge = record.ownershipType === MULTI_PARTY;
      record.ownershipType = record.showMultipartyBadge
        ? JOINT
        : record.ownershipType;
    });

    // Sort the goal details by sortOrder
    goalDetails.sort(
      (firstGoal, secondGoal) => firstGoal.sortOrder - secondGoal.sortOrder
    );
  }

  pendingGoalssTobeViewed(bucketsLength) {
    return bucketsLength > this.onLoadGoalDisplayCount
      ? bucketsLength - this.onLoadGoalDisplayCount
      : 0;
  }

  closeModal() {
    this.showInfoModal = false;
  }
}
