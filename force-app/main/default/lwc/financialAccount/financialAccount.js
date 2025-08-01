import { LightningElement, api } from "lwc";

import { NavigationMixin } from "lightning/navigation";

import hasAccountsGoalsPermission from "@salesforce/customPermission/ANZx_Accounts_and_Goals";
import FinancialAccountStatusForSorting from "@salesforce/label/c.FinancialAccountStatusForSorting";

export default class FinancialAccount extends NavigationMixin(
  LightningElement
) {
  @api recordId;
  //Account details received through personAccountFinancialDetails LWC
  @api accountDetails;
  @api error;
  //Added by Shivam to utilize the ocv id received through personAccountFinancialDetails LWC
  @api ocvId;
  @api componentTitle;
  @api componentSubTitle;
  @api balanceTitle;
  @api titleIcon;
  @api iconColor;
  @api productCode;
  showInfoModal = false;

  get displayContent() {
    return hasAccountsGoalsPermission;
  }

  get processedFinAccounts() {
    return this.handleAccountDetails(this.accountDetails);
  }

  get timestamp() {
    //Create timestamp for last updated
    //Use last modified date if the data is fetched from SF, otherwise,
    //the data is directly from fabric so we can use current time
    let updated = new Date();
    if (
      this.accountDetails &&
      this.accountDetails.length > 0 &&
      this.accountDetails[0].LastModifiedDate
    ) {
      updated = new Date(this.accountDetails[0].LastModifiedDate);
    }

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

  handleAccountDetails(accountDetails) {
    if (accountDetails) {
      accountDetails = accountDetails.map((account) => {
        let finAccount = { ...account };
        if (
          finAccount.finserv_status !== "Closed" &&
          finAccount.finserv_ownership === "Multi-party"
        ) {
          finAccount.showMultipartyBadge = true;
          finAccount.finserv_ownership = "Joint";
        }
        finAccount.isCard = finAccount.finserv_account_type === "Card";
        return finAccount;
      });
      accountDetails = this.sortFinancialAccounts(accountDetails);
    }
    return accountDetails.filter(
      (account) => account.finserv_status !== "Closed"
    );
  }

  sortFinancialAccounts(arrOfAccounts) {
    const accounts = [...arrOfAccounts];
    return accounts.sort((firstAccount, otherAccount) => {
      const statusOrder = FinancialAccountStatusForSorting.split(",");
      if (firstAccount.finserv_sortorder !== otherAccount.finserv_sortorder) {
        return firstAccount.finserv_sortorder - otherAccount.finserv_sortorder;
      }
      // Sort by status first
      if (
        firstAccount.finserv_sortorder === otherAccount.finserv_sortorder &&
        firstAccount.finserv_status !== otherAccount.finserv_status
      ) {
        return (
          statusOrder.indexOf(otherAccount.finserv_status) -
          statusOrder.indexOf(firstAccount.finserv_status)
        );
      }
      // Handle null openDate values
      if (
        firstAccount.finserv_opendate === null &&
        otherAccount.finserv_opendate !== null
      )
        return 1;
      if (
        otherAccount.finserv_opendate === null &&
        firstAccount.finserv_opendate !== null
      )
        return -1;

      // Sort by date next if status is same
      return (
        new Date(otherAccount.finserv_opendate) -
        new Date(firstAccount.finserv_opendate)
      );
    });
  }

  navigateToRecordViewPage(event) {
    //Added check for ownership to decide which account is joint or not to add ocvId of the owner from where it is called.
    let stateValue = null;
    if (event.currentTarget.dataset.ownership === "true") {
      stateValue = {
        c__ocvId: this.ocvId
      };
    }

    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: event.currentTarget.dataset.id,
        actionName: "view"
      },
      state: stateValue
    });
  }

  handleInfoModal() {
    this.showInfoModal = !this.showInfoModal;
  }

  closeModal() {
    this.showInfoModal = false;
  }
}
