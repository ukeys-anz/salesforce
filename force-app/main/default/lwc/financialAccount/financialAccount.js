import { LightningElement, api } from "lwc";

import { NavigationMixin } from "lightning/navigation";

import hasAccountsGoalsPermission from "@salesforce/customPermission/ANZx_Accounts_and_Goals";

const ACCOUNT_TYPES = {
  checking: "Everyday - ANZ Plus Account",
  savings: "Savings - ANZ Save Account"
};

export default class FinancialAccount extends NavigationMixin(
  LightningElement
) {
  @api recordId;
  @api accountType;
  //Account details received through personAccountFinancialDetails LWC
  @api accountDetails;
  @api error;
  //Savings jar details received through personAccountFinancialDetails LWC
  @api savingsJar;
  //Added by Shivam to utilize the ocv id received through personAccountFinancialDetails LWC
  @api ocvId;
  componentTitle;
  balanceTitle;
  showInfoModal = false;
  productTitle;
  titleIcon;
  iconColor;

  get displayContent() {
    return hasAccountsGoalsPermission;
  }

  get hasAccountDetails() {
    return this.accountDetails && this.accountDetails.length > 0;
  }

  get timestamp() {
    //Create timestamp for last updated
    //Use last modified date if the data is fetched from SF, otherwise,
    //the data is directly from fabric so we can use current time
    let updated = new Date();
    if (this.accountDetails && this.accountDetails.length > 0) {
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

  connectedCallback() {
    if (this.accountType) {
      this.componentTitle = ACCOUNT_TYPES[this.accountType.toLowerCase()];
      if (this.accountType.toLowerCase() === "checking") {
        this.balanceTitle = "Everyday Funds";
        this.productTitle = "ANZ Plus";
        this.titleIcon = "custom:custom51";
        this.iconColor = "slds-m-right_small";
      } else {
        this.balanceTitle = "Total Saved";
        this.productTitle = "ANZ Save";
        this.titleIcon = "custom:custom17";
        this.iconColor = "slds-m-right_small cicon";
      }
    }
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
}
