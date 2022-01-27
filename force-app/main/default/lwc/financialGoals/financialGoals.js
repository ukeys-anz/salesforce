import { LightningElement, api } from "lwc";

import { NavigationMixin } from "lightning/navigation";

import hasAccountsGoalsPermission from "@salesforce/customPermission/ANZx_Accounts_and_Goals";
// import { handleErrorShowToast, showToast } from "c/utils";

export default class FinancialGoals extends NavigationMixin(LightningElement) {
  @api recordId;
  //Goal details received through personAccountFinancialDetails LWC
  @api goalData;
  @api error;
  @api preselectedGoal;
  goalList = [];
  allGoals = [];
  timestamp;
  showInfoModal = false;
  viewMore;
  goalFilters = [];
  hasRendered = false;

  get displayContent() {
    return hasAccountsGoalsPermission;
  }

  connectedCallback() {
    if (hasAccountsGoalsPermission) {
      //Set timestamp
      if (!this.timestamp) {
        this.setTimestamp();
      }

      if (this.goalData?.goalList?.length > 1) {
        this.allGoals = [...this.goalData.goalList];
        //NOTE FABRIC CURRENTLY DOESNT ALLOW PAGINATION,
        //AS IT IS BEING BUILT CURRENTLY, SO API RETURNS ALL GOALS
        //If we get more than 3 records, set view more to true and get first 3 records
        if (this.allGoals.length > 3) {
          this.viewMore = true;
          // this.goalList = this.goalList.slice(0, 3);
          this.goalList = this.allGoals.splice(0, 3);
        } else {
          this.goalList = this.allGoals;
        }

        if (!this.timestamp && !this.error) {
          this.setTimestamp();
        }
      } else {
        //If no goals set goals to null as template condition checks
        //dont seem to mark as false if array empty
        this.goalList = null;
      }
    }
  }

  renderedCallback() {
    if (!this.hasRendered) {
      //If we get a preselected goal, mark it as active on screen
      if (this.goalData?.goalList?.length > 1) {
        if (this.preselectedGoal) {
          let goal = this.template.querySelector(
            `div[data-id="${this.preselectedGoal}"]`
          );
          goal.classList.add("active");
          //Add to goal filters
          this.goalFilters = [...this.goalFilters, this.preselectedGoal];
          this.dispatchEvent(
            new CustomEvent("filtergoals", {
              detail: {
                goalFilters: this.goalFilters
              }
            })
          );
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
    this.dispatchEvent(
      new CustomEvent("filtergoals", {
        detail: {
          goalFilters: this.goalFilters
        }
      })
    );
  }

  handleLoadMore() {
    this.goalList.push(...this.allGoals.splice(0, 3));
    if (this.allGoals.length === 0) {
      this.viewMore = false;
    }

    //Below will be the code used when we have pagination available to us
    //via the API
    //The provided URL doesn't go through MS, so we need
    //to retrieve the params and pass them to the Apex class
    //and append it to the request
    // try {
    //   let nextSubstring = `${this.goalData.nextToken.substring(
    //     this.goalData.nextToken.indexOf("?")
    //   )}`;

    //   this.dispatchEvent(
    //     new CustomEvent("loadmoregoals", {
    //       bubbles: true,
    //       detail: {
    //         substring: nextSubstring
    //       }
    //     })
    //   );
    // } catch (error) {
    //   handleErrorShowToast(
    //     this,
    //     "Failed To Load Goals",
    //     error,
    //     "Failed to retrieve goal details. Please refresh and try again. If issue persists please contact your System Administrator",
    //     "pester"
    //   );
    // }
  }
}
