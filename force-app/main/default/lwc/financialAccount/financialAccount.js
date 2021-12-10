import { LightningElement, api } from "lwc";

import { NavigationMixin } from "lightning/navigation";

import hasAccountsGoalsPermission from "@salesforce/customPermission/ANZx_Accounts_and_Goals";

const ACCOUNT_TYPES = {
  checking: "Everyday - ANZ Plus Account",
  savings: "Savings - ANZ Save Account"
};

export default class EverydayAccount extends NavigationMixin(LightningElement) {
  @api recordId;
  @api accountType;
  //Account details received through personAccountFinancialDetails LWC
  @api accountDetails;
  @api error;
  componentTitle;
  balanceTitle;
  showInfoModal = false;
  productTitle;
  titleIcon;

  get displayContent() {
    return hasAccountsGoalsPermission;
  }

  get timestamp() {
    //Create timestamp for last updated
    let updated = new Date(this.accountDetails[0].LastModifiedDate);

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
    this.componentTitle = ACCOUNT_TYPES[this.accountType.toLowerCase()];
    if (this.accountType.toLowerCase() === "checking") {
      this.balanceTitle = "Everyday Funds";
      this.productTitle = "ANZ Plus";
      this.titleIcon = "custom:custom51";
    } else {
      this.balanceTitle = "Total Saved";
      this.productTitle = "ANZ Save";
      this.titleIcon = "custom:custom17";
    }
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
