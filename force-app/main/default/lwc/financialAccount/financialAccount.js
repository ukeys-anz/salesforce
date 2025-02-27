import { LightningElement, api, wire } from "lwc";

import { NavigationMixin } from "lightning/navigation";
import { getRecord } from "lightning/uiRecordApi";
import PRODUCT_NAME_FIELD from "@salesforce/schema/Product2.Name";

import hasAccountsGoalsPermission from "@salesforce/customPermission/ANZx_Accounts_and_Goals";

import { handleAccountHeaderData } from "c/utils";

const ACCOUNT_TYPES_CONSTANT = {
  checking: "Everyday - ANZ Plus Account",
  savings: "Savings - ANZ Save Account",
  savingss2: "Savings - ANZ Plus Flex Saver Account"
};

const ACCOUNT_TYPES = {
  checking: "Everyday - ",
  savings: "Savings - ",
  savingss2: "Savings - "
};

export default class FinancialAccount extends NavigationMixin(
  LightningElement
) {
  @api recordId;
  @api accountType;
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
  productId;
  _accountDetails;

  @api
  set accountDetails(val) {
    this._accountDetails = val;
  }

  get accountDetails() {
    return this._accountDetails;
  }

  @wire(getRecord, {
    recordId: "$productId",
    fields: [PRODUCT_NAME_FIELD]
  })
  product({ data }) {
    if (data) {
      this.componentTitle =
        ACCOUNT_TYPES[this.accountType.toLowerCase()] +
        data?.fields?.Name?.value;
    }
  }

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

  connectedCallback() {
    this.productId = this._accountDetails[0]?.FinServ__ProductName__c;
    if (this.accountType) {
      if (!this.productId) {
        this.componentTitle =
          ACCOUNT_TYPES_CONSTANT[this.accountType.toLowerCase()];
      }
      let accountHeaderData = handleAccountHeaderData(this.accountType);
      this.balanceTitle = accountHeaderData.balanceTitle;
      this.iconColor = accountHeaderData.iconColor;
      this.titleIcon = accountHeaderData.titleIcon;
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

  closeModal() {
    this.showInfoModal = false;
  }
}
