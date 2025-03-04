import { LightningElement, api, wire } from "lwc";

import { NavigationMixin } from "lightning/navigation";
import { openTab, EnclosingTabId } from "lightning/platformWorkspaceApi";

import hasAccountsGoalsPermission from "@salesforce/customPermission/ANZx_Accounts_and_Goals";

export default class FinancialAccount extends NavigationMixin(
  LightningElement
) {
  @api recordId;
  //Account details, savings jar & error received through financialAccountParent LWC
  @api accountDetails;
  @api savingsJar;
  @api error;
  @api accountOwnersList;
  @api componentTitle;
  @api componentSubTitle;
  @api balanceTitle;
  @api titleIcon;
  @api iconColor;
  @api productCode;
  showInfoModal = false;
  productTitle;

  @wire(EnclosingTabId) tabId;

  get displayContent() {
    return hasAccountsGoalsPermission;
  }

  get timestamp() {
    //Create timestamp for last updated
    //Use last modified date if the data is fetched from SF, otherwise,
    //the data is directly from fabric so we can use current time
    let updated = this.accountDetails[0].LastModifiedDate
      ? new Date(this.accountDetails[0].LastModifiedDate)
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
  get processedFinAccounts() {
    return this.handleAccountInformation(this.accountDetails);
  }

  handleAccountInformation(finAccounts) {
    // As per story ANZX-113310 Colour of status “Active”, “Dormant“, “Closed” is changed .Hence, changing the badge class
    //console.log('from child lwc : '+ JSON.stringify(finAccounts));

    const updatedFinAccounts = finAccounts.map((account) => {
      let finAccount = { ...account };
      // Set badgeClass based on finserv_status
      finAccount.badgeClass =
        finAccount.finserv_status === "Active" ||
        finAccount.finserv_status === "Open"
          ? "slds-badge slds-theme_success"
          : finAccount.finserv_status === "Closed"
            ? "slds-badge closedBadgeClass"
            : finAccount.finserv_status === "Dormant"
              ? "slds-badge dormantBadgeClass"
              : "slds-badge";

      // Only show Savings Jar when finserv_status is not "CLOSED"
      finAccount.showSavingsJar =
        this.savingsJar &&
        Object.keys(this.savingsJar).length > 0 &&
        finAccount.finserv_status !== "Closed";
      // Only show showMultipartyBadge when the ownership type is "Multi-party"
      if (
        finAccount.finserv_status !== "Closed" &&
        finAccount.finserv_ownership === "Multi-party"
      ) {
        finAccount.showMultipartyBadge = true;
        finAccount.finserv_ownership = "Joint";
      }
      return finAccount;
    });
    return updatedFinAccounts;
  }

  navigateToRecordViewPage(event) {
    const accountID = event.currentTarget.dataset.id;
    openTab({
      recordId: accountID
    }).catch((error) => {
      console.error(error);
    });
  }

  handleInfoModal() {
    this.showInfoModal = !this.showInfoModal;
  }

  closeModal() {
    this.showInfoModal = false;
  }
}
