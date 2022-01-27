import { LightningElement, api, track } from "lwc";

import { NavigationMixin } from "lightning/navigation";

import hasAccountsGoalsPermission from "@salesforce/customPermission/ANZx_Accounts_and_Goals";

export default class FinancialGoals extends NavigationMixin(LightningElement) {
  @api recordId;
  goals = [];
  //Goal details received through personAccountFinancialDetails LWC
  @api goalData;
  @track timestamp;
  @track viewAllGoals = false;
  accountNumbers = [];
  @api error;
  showInfoModal = false;

  get displayContent() {
    return hasAccountsGoalsPermission;
  }

  connectedCallback() {
    if (hasAccountsGoalsPermission) {
      //Set timestamp
      if (!this.timestamp) {
        this.setTimestamp();
      }
      let goalList;
      if (this.goalData) {
        goalList = this.goalData;
        goalList.forEach((finAccount) => {
          //Set account number as key and ID as value to link goals to accounts later
          this.accountNumbers[finAccount.FinServ__FinancialAccountNumber__c] =
            finAccount.Id;
        });
        //If we get more than 3 records, set view all to true and get first 3 records
        if (goalList.length > 3) {
          this.viewAllGoals = true;
          goalList = goalList.slice(0, 3);
        }

        if (!this.timestamp && !this.error) {
          this.setTimestamp();
        }

        for (let i = 0; i < goalList.length; i++) {
          let finGoal = { ...goalList[i] };

          finGoal.targetAmount = finGoal.targetAmount
            ? parseFloat(finGoal.targetAmount)
            : "";
          finGoal.currentBalance = parseFloat(finGoal.currentBalance);

          finGoal.Id = this.accountNumbers[finGoal.accountNumber];

          if (finGoal.targetAmount) {
            //Work out percentage for fill
            finGoal.fillPercent = Math.floor(
              (finGoal.currentBalance / finGoal.targetAmount) * 100
            );

            //Dont let overfill 100%
            finGoal.fillPercent =
              finGoal.fillPercent >= 100 ? 100 : finGoal.fillPercent;

            finGoal.balanceRemaining =
              finGoal.targetAmount - finGoal.currentBalance;
          } else {
            finGoal.fillPercent = finGoal.currentBalance > 0 ? 100 : 0;
          }

          finGoal.daysRemainingText = "Days remaining: ";
          // Override potential null values with generic values
          if (finGoal.targetDate) {
            const targetDate = new Date(finGoal.targetDate);
            const today = new Date();

            if (targetDate > today) {
              //Calculate time difference between two dates
              let timeDifference = targetDate.getTime() - today.getTime();

              //Calculate days remaining
              finGoal.daysRemaining = Math.round(
                timeDifference / (1000 * 60 * 60 * 24)
              );

              finGoal.recommendedSavings = finGoal.balanceRemaining
                ? (finGoal.balanceRemaining / finGoal.daysRemaining) * 7
                : "";

              finGoal.daysRemainingText += finGoal.daysRemaining;
            }

            finGoal.targetDate =
              targetDate.getDate() +
              " " +
              targetDate.toLocaleString("en-AU", {
                month: "long"
              }) +
              " " +
              targetDate.getFullYear();
          } else {
            finGoal.targetDate = "N/A";
          }

          //Format balances
          finGoal.targetAmount = finGoal.targetAmount
            ? new Intl.NumberFormat("en-AU", {
                style: "currency",
                currency: "AUD"
              }).format(finGoal.targetAmount)
            : "N/A";

          finGoal.currentBalance = new Intl.NumberFormat("en-AU", {
            style: "currency",
            currency: "AUD"
          }).format(finGoal.currentBalance);

          finGoal.recommendedSavings = finGoal.recommendedSavings
            ? new Intl.NumberFormat("en-AU", {
                style: "currency",
                currency: "AUD"
              }).format(finGoal.recommendedSavings)
            : "Unspecified";
          this.goals.push(finGoal);
        }
      } else {
        //If no goals set goals to null as template condition checks
        //dont seem to mark as false if array empty
        this.goals = null;
      }
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

  navigateToRecordViewPage(event) {
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: event.currentTarget.dataset.id,
        actionName: "view"
      }
    });
  }

  handleInfoModal() {
    this.showInfoModal = !this.showInfoModal;
  }
}
