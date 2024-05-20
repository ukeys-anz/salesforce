import { LightningElement, api, wire } from "lwc";

import { NavigationMixin } from "lightning/navigation";
import { openTab, EnclosingTabId } from "lightning/platformWorkspaceApi";

import hasAccountsGoalsPermission from "@salesforce/customPermission/ANZx_Accounts_and_Goals";
import { handleAccountHeaderData } from "c/utils";

const ACCOUNT_TYPES = {
  checking: "Everyday - ANZ Plus Account",
  savings: "Savings - ANZ Save Account",
  savingss2: "Savings - ANZ Save Grow Account"
};

export default class FinancialAccount extends NavigationMixin(
  LightningElement
) {
  @api recordId;
  @api accountType;
  //Account details, savings jar & error received through financialAccountParent LWC
  @api accountDetails;
  @api savingsJar;
  @api error;
  @api accountOwnersList;
  componentTitle;
  balanceTitle;
  showInfoModal = false;
  productTitle;
  titleIcon;
  iconColor;

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

  connectedCallback() {
    if (this.accountType) {
      this.componentTitle = ACCOUNT_TYPES[this.accountType.toLowerCase()];
      let accountHeaderData = handleAccountHeaderData(this.accountType);
      this.balanceTitle = accountHeaderData.balanceTitle;
      this.productTitle = accountHeaderData.productTitle;
      this.iconColor = accountHeaderData.iconColor;
      this.titleIcon = accountHeaderData.titleIcon;
    }
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
}
