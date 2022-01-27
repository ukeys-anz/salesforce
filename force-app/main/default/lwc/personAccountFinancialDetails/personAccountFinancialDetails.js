/* LWC IMPORTS */
import { LightningElement, api, wire } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import { handleErrorShowToast } from "c/utils";

/* IMPORT APEX METHODS */
import getTotalBalance from "@salesforce/apex/TotalBalanceController.getTotalBalance";
import getTotalSaved from "@salesforce/apex/TotalBalanceController.getTotalSaved";
import getFinancialAccountFabric from "@salesforce/apex/FinancialAccountController.getFinancialAccountFabric";
import getFinancialAccountDB from "@salesforce/apex/FinancialAccountController.getFinancialAccountDB";
import getAccountBuckets from "@salesforce/apex/AccountBucketsController.getAccountBuckets";

/* IMPORT PERMISSIONS */
import hasAccountsGoalsPermission from "@salesforce/customPermission/ANZx_Accounts_and_Goals";

/* IMPORT SCHEMA FIELDS */
import ACCOUNT_OCV_ID_FIELD from "@salesforce/schema/Account.OCV_ID__c";

//Import goal images
import goal_themes from "@salesforce/resourceUrl/goal_themes";

export default class PersonAccountFinancialDetails extends LightningElement {
  @api recordId;
  goalDetails = [];
  ocvId;
  loading;
  goalError;
  totalBalanceError;
  accountData = {
    checking: [],
    savings: []
  };
  savingsJar = [];
  //Pass this to the goals lwc so we can navigate to the
  //savings financial account
  savingsId;

  @wire(getRecord, {
    recordId: "$recordId",
    fields: [ACCOUNT_OCV_ID_FIELD]
  })
  async wiredRecord({ data }) {
    this.loading = true;
    if (data && hasAccountsGoalsPermission) {
      this.ocvId = data.fields.OCV_ID__c.value;
      if (this.ocvId) {
        await this.getFinancialAccount();
        await this.getGoals();
      }
    }
    this.loading = false;
  }

  get displayContent() {
    return hasAccountsGoalsPermission;
  }

  async getFinancialAccount() {
    this.accountData = {
      checking: [],
      savings: []
    };
    try {
      //Attempt to get the latest account details from fabric
      let accountDetails = await getFinancialAccountFabric({
        ocvId: this.ocvId,
        accountNumbers: []
      });
      this.handleAccountInformation(accountDetails);
    } catch (error) {
      handleErrorShowToast(
        this,
        "Failed To Retrieve Account Details",
        error,
        "Failed to retrieve latest account details. Please refresh and try again. If issue persists please contact your System Administrator",
        "pester"
      );

      //If the API callout fails to fetch latest data, use this as a fallback to fetch
      //the records stored in Salesforce
      let accountDetails = await getFinancialAccountDB({
        ownerId: this.recordId,
        type: ["checking", "savings"]
      });
      this.handleAccountInformation(accountDetails);
    } finally {
      try {
        let { totalBalance } = await getTotalBalance({
          ownerId: this.recordId
        });
        this.totalBalance = totalBalance;

        let { totalSaved } = await getTotalSaved({
          ownerId: this.recordId
        });
        this.totalSaved = totalSaved;
      } catch (error) {
        this.totalBalanceError =
          "Failed to retrieve total balance details. Please refresh and try again. If issue persists please contact your System Administrator";
        handleErrorShowToast(
          this,
          "Failed To Retrieve Total Balance Details",
          error,
          this.totalBalanceError,
          "pester"
        );
      }
    }
  }

  async getGoals() {
    this.goalDetails = [];
    this.savingsJar = null;
    try {
      let goalData = await getAccountBuckets({ ocvId: this.ocvId });
      goalData = this.handleGoalThemes(goalData);
      //Savings jar will always be default, so retrieve it
      //to pass through to other components that need it
      this.savingsJar = goalData.account_buckets.filter((obj) => {
        return obj.is_default;
      })[0];
      //Remove savings jar as its not displayed on goals component
      this.goalDetails = goalData.account_buckets.filter((obj) => {
        return !obj.is_default;
      });
    } catch (error) {
      this.goalError =
        "Failed to retrieve latest goal details. Please refresh and try again. If issue persists please contact your System Administrator";
      handleErrorShowToast(
        this,
        "Failed To Retrieve Goal Details",
        error,
        this.goalError,
        "pester"
      );
    }
  }

  handleAccountInformation(finAccounts) {
    finAccounts.forEach((account) => {
      //Set the badge class based on the status
      account.badgeClass =
        account.FinServ__Status__c === "Active"
          ? "slds-badge slds-theme_success"
          : "slds-badge slds-theme_error";
      //Determine the type of financial account
      if (
        account.FinServ__FinancialAccountType__c.toLowerCase() === "checking"
      ) {
        this.accountData.checking.push(account);
      } else {
        this.accountData.savings.push(account);
        this.savingsId = account.Id;
      }
    });

    return finAccounts;
  }

  handleGoalThemes(goalList) {
    goalList.account_buckets.forEach((goal) => {
      if (goal.is_default) {
        goal.image = `${goal_themes}/SAVINGS_JAR.png`;
      } else {
        //Check if goal has theme otherwise use default
        if (goal?.goal?.theme) {
          //If goal is unspecified, assign the image of "something else"
          if (
            goal.goal.theme === "GOAL_THEME_UNSPECIFIED" ||
            goal.goal.theme === "GOAL_THEME_CUSTOM"
          ) {
            goal.image = `${goal_themes}/GOAL_THEME_SOMETHING_ELSE.png`;
          } else {
            goal.image = `${goal_themes}/${goal.goal.theme}.png`;
          }
        } else if (goal?.goal?.emoji?.value) {
          goal.emoji = goal.goal.emoji.value;
        } else {
          goal.image = `${goal_themes}/GOAL_THEME_SOMETHING_ELSE.png`;
        }
      }
      //Determine percentage for goal
      if (goal?.goal?.target_amount?.value) {
        //Work out percentage for fill
        goal.fillPercent = Math.floor(
          (goal.balance.value / goal.goal.target_amount.value) * 100
        );
      } else {
        goal.fillPercent = goal.balance.value > 0 ? 100 : 0;
      }
    });

    return goalList;
  }

  async refreshData() {
    this.loading = true;
    await this.getFinancialAccount();
    await this.getGoals();
    this.loading = false;
  }
}
