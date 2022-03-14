import { LightningElement, api, track } from "lwc";

import { NavigationMixin } from "lightning/navigation";

import hasAccountsGoalsPermission from "@salesforce/customPermission/ANZx_Accounts_and_Goals";
// import { handleErrorShowToast, showToast } from "c/utils";

export default class FinancialGoals extends NavigationMixin(LightningElement) {
  @api recordId;
  @api error;
  @api preselectedGoal;
  @api loadingMore;
  @track goalList = [];
  timestamp;
  showInfoModal = false;
  goalFilters = [];
  hasRendered = false;
  nextPageToken;

  //Goal details received through personAccountFinancialDetails LWC
  @api
  get goalData() {
    return this.goalList;
  }

  set goalData(goals) {
    if (goals.goalList?.length > 0) {
      this.nextPageToken = goals.nextPageToken;
      this.goalList = [...this.goalList, ...goals.goalList];
    }

    //Set to null so the no goals message displays
    if (this.goalList.length === 0) {
      this.goalList = null;
    }
  }

  get displayContent() {
    return hasAccountsGoalsPermission;
  }

  connectedCallback() {
    if (hasAccountsGoalsPermission) {
      //Set timestamp
      if (!this.timestamp) {
        this.setTimestamp();
      }
    }
  }

  renderedCallback() {
    if (!this.hasRendered) {
      //If we get a preselected goal, mark it as active on screen
      if (this.goalList?.length > 0) {
        if (this.preselectedGoal) {
          let goal = this.template.querySelector(
            `div[data-id="${this.preselectedGoal}"]`
          );
          goal.classList.add("active");
          //Add to goal filters
          this.goalFilters = [...this.goalFilters, this.preselectedGoal];
          this.dispatchFilters();
        }
      }
      //Set has rendered to true so it doesn't run again
      this.hasRendered = true;
    }
  }

  setTimestamp() {
    //Create timestamp for last updated
    const today = new Date();
    this.timestamp =
      today.getDate() +
      " " +
      today.toLocaleString("en-AU", {
        month: "long"
      }) +
      " " +
      today.getFullYear() +
      " | " +
      today.toLocaleString("en-AU", {
        hour: "numeric",
        minute: "numeric",
        hour12: true
      });
  }

  handleInfoModal() {
    this.showInfoModal = !this.showInfoModal;
  }

  handleFilter(event) {
    const evt = event.currentTarget;
    evt.classList.toggle("active");
    //Add or remove goal filter
    if (!this.goalFilters.includes(evt.dataset.id)) {
      //adding filter
      this.goalFilters = [...this.goalFilters, evt.dataset.id];
    } else {
      //Remove from filter
      this.goalFilters = this.goalFilters.filter((obj) => {
        return obj !== evt.dataset.id;
      });
    }
  }

  handleLoadMore() {
    try {
      this.dispatchEvent(
        new CustomEvent("loadmoregoals", {
          bubbles: true,
          detail: {
            nextPageToken: this.nextPageToken
          }
        })
      );
    } catch (error) {
      handleErrorShowToast(
        this,
        "Failed To Load Goals",
        error,
        "Failed to retrieve goal details. Please refresh and try again. If issue persists please contact your System Administrator",
        "pester"
      );
    }
  }

  handleClearFilters() {
    this.goalFilters = [];
    let activeGoals = this.template.querySelectorAll(".active");
    activeGoals.forEach((el) => {
      el.classList.remove("active");
    });
    this.dispatchFilters();
  }

  dispatchFilters() {
    this.dispatchEvent(
      new CustomEvent("filtergoals", {
        bubbles: true,
        detail: {
          goalFilters: this.goalFilters
        }
      })
    );
  }
}
