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

  @wire(getRecord, {
    recordId: "$recordId",
    fields: [ACCOUNT_OCV_ID_FIELD]
  })
  wiredRecord({ data }) {
    if (data && hasAccountsGoalsPermission) {
      this.ocvId = data.fields.OCV_ID__c.value;
      if (this.ocvId) {
        this.getFinancialData();
      }
    }
  }

  get displayContent() {
    return hasAccountsGoalsPermission;
  }

  async getFinancialData() {
    //Reset values to avoid duplicates
    this.loading = true;
    this.goalDetails = [];
    this.accountData = {
      checking: [],
      savings: []
    };
    this.savingsJar = [];
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

      try {
        this.goalDetails = await getAccountBuckets({ ocvId: this.ocvId });
        //Savings jar will always be default, so retrieve it
        //to pass through to other components that need it
        this.savingsJar = this.goalDetails.account_buckets.filter((obj) => {
          return obj.is_default === true;
        })[0];
      } catch (error) {
        handleErrorShowToast(
          this,
          "Failed To Retrieve Goal Details",
          error,
          "Failed to retrieve latest goal details. Please refresh and try again. If issue persists please contact your System Administrator",
          "pester"
        );
      }

      this.loading = false;
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
      }
    });

    return finAccounts;
  }
}
