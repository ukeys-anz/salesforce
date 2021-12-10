/* LWC IMPORTS */
import { LightningElement, api, wire } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import { handleErrorShowToast } from "c/utils";

/* IMPORT API METHODS*/
import getAccounts from "@salesforce/apex/CoachBankingAPIRepository.getAccountsAura";

/* IMPORT APEX METHODS */
import getTotalBalance from "@salesforce/apex/TotalBalanceController.getTotalBalance";
import getTotalSaved from "@salesforce/apex/TotalBalanceController.getTotalSaved";
import updateAccounts from "@salesforce/apex/UpdateFinancialAccounts.updateAccounts";
import getFinancialAccounts from "@salesforce/apex/FinancialAccountController.getFinancialAccounts";

/* IMPORT PERMISSIONS */
import hasAccountsGoalsPermission from "@salesforce/customPermission/ANZx_Accounts_and_Goals";

/* IMPORT SCHEMA FIELDS */
import ACCOUNT_OCV_ID_FIELD from "@salesforce/schema/Account.OCV_ID__c";

export default class PersonAccountFinancialDetails extends LightningElement {
  @api recordId;
  @api objectName;
  accountDetails = [];
  goalDetails = [];
  accountNumbers = [];
  goalAccountNumbers = [];
  ocvId;
  loading;
  checkingError;
  savingsError;
  goalError;
  totalBalanceError;
  accountData = {
    checking: [],
    savings: []
  };

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
    this.accountDetails = [];
    this.goalDetails = [];
    this.accountNumbers = [];
    this.goalAccountNumbers = [];
    this.accountData = {
      checking: [],
      savings: []
    };

    try {
      //Get the latest account details and update them
      let { accountList } = await getAccounts({
        ocvId: this.ocvId
      });
      if (accountList) {
        accountList.forEach((account) => {
          // check to drop or show an error message against a particular Fin Account record based on response
          if (account.isValid) {
            this.accountNumbers.push(account.accountNumber);
            let accountInformation = {
              Name: account.name,
              FinServ__FinancialAccountNumber__c: account.accountNumber,
              FinServ__Balance__c: account.balance.value,
              FinServ__CurrentPostedBalance__c: account.currentBalance.value,
              BSB__c: account.bsb.toString(),
              FinServ__OpenDate__c: account.openDate
            };

            this.accountDetails.push(accountInformation);
            if (account.accountType === "Savings") {
              this.goalAccountNumbers.push(account.accountNumber);
              let goalInformation = {
                name: account.goal.name,
                accountNumber: account.accountNumber,
                targetAmount: account.goal.targetAmount
                  ? account.goal.targetAmount.value
                  : "",
                currentBalance: account.currentBalance.value,
                startDate: account.goal.startDate,
                targetDate: account.goal.targetDate
                  ? account.goal.targetDate
                  : "",
                icon: account.goal.iconId
              };
              this.goalDetails.push(goalInformation);
            }
          }
        });

        try {
          //Update accounts
          await updateAccounts({
            ownerId: this.recordId,
            accountNumbers: this.accountNumbers,
            financialAccounts: this.accountDetails
          });
        } catch (error) {
          handleErrorShowToast(
            this,
            "Failed To Update Account Details",
            error,
            "Failed to update account details. Please refresh and try again. If issue persists please contact your System Administrator.",
            "pester"
          );
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
            let checkingAccount = await getFinancialAccounts({
              ownerId: this.recordId,
              recordLimit: 1,
              type: "checking"
            });
            checkingAccount = this.handleAccountBadgeClass(checkingAccount);
            this.accountData.checking.push(checkingAccount[0]);
          } catch (error) {
            this.checkingError =
              "Failed to retrieve checking account details. Please refresh and try again. If issue persists please contact your System Administrator";
            handleErrorShowToast(
              this,
              "Failed To Retrieve Checking Account Details",
              error,
              this.checkingError,
              "pester"
            );
          }

          try {
            let savingsAccount = await getFinancialAccounts({
              ownerId: this.recordId,
              recordLimit: 1,
              type: "savings"
            });
            savingsAccount = this.handleAccountBadgeClass(savingsAccount);
            this.accountData.savings.push(savingsAccount[0]);
          } catch (error) {
            this.savingsError =
              "Failed to retrieve savings account details. Please refresh and try again. If issue persists please contact your System Administrator";
            handleErrorShowToast(
              this,
              "Failed To Retrieve Savings Account Details",
              error,
              this.savingsError,
              "pester"
            );
          }
        }
      }
    } catch (error) {
      handleErrorShowToast(
        this,
        "Failed To Retrieve Account Details",
        error,
        "Failed to retrieve latest account details. Please refresh and try again. If issue persists please contact your System Administrator",
        "pester"
      );
    } finally {
      this.loading = false;
    }
  }

  handleAccountBadgeClass(finAccounts) {
    finAccounts.forEach((account) => {
      //Set the badge class based on the status
      if (account.FinServ__Status__c === "Active") {
        account.badgeClass = "slds-badge slds-theme_success";
      } else {
        account.badgeClass = "slds-badge slds-theme_error";
      }
    });

    return finAccounts;
  }
}
