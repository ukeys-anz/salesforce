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
  @api accountType;
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
  get iconWrapperClass() {
    return this.accountType === "Card"
      ? `${this.iconColor} card-icon-color`
      : this.iconColor;
  }
  handleAccountInformation(finAccounts) {
    // As per story ANZX-113310 Colour of status “Active”, “Dormant“, “Closed” is changed .Hence, changing the badge class
    if (!finAccounts) {
      return null;
    }
    return finAccounts.map((account) => {
      const finAccount = { ...account };
      switch (finAccount.finserv_status) {
        case "Active":
        case "Open":
          finAccount.badgeClass = "slds-badge slds-theme_success";
          break;
        case "Closed":
          finAccount.badgeClass = "slds-badge closedBadgeClass";
          break;
        case "Dormant":
          finAccount.badgeClass = "slds-badge dormantBadgeClass";
          break;
        default:
          finAccount.badgeClass = "slds-badge";
      }
      finAccount.showSavingsJar =
        this.savingsJar &&
        Object.keys(this.savingsJar).length > 0 &&
        finAccount.finserv_status !== "Closed";
      if (
        finAccount.finserv_status !== "Closed" &&
        finAccount.finserv_ownership === "Multi-party"
      ) {
        finAccount.showMultipartyBadge = true;
        finAccount.finserv_ownership = "Joint";
      }
      return finAccount;
    });
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
