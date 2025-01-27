import getPackageClosureAura from "@salesforce/apex/StravinskyController.getPackageClosureAura";
import fetchFinancialAccounts from "@salesforce/apex/StravinskyController.fetchFinancialAccounts";
import getPackageClosureAuraFlex from "@salesforce/apex/StravinskyController.getPackageClosureAuraFlex";
import { api, LightningElement, wire } from "lwc";
import hasAccountClosurePermission from "@salesforce/customPermission/ANZx_Account_Closure";
import hasAccountClosurePilotPermission from "@salesforce/customPermission/ANZx_Account_Closure_Pilot";
import { handleErrorShowToast, showToast } from "c/utils";
import { getRecord } from "lightning/uiRecordApi";
import ACCOUNT_PRODUCT_FIELD from "@salesforce/schema/Case.Account_Product__c";

export default class AccountClosure extends LightningElement {
  @api recordId;
  loading = false;
  anzPlusValue;
  anzSaveValue;
  cardValue;
  packageValue;
  showConfirmation = false;
  isFlexSaverAccountClosure = false;
  showConfirmationSelectAccount = false;
  showConfirmationAccountClosure = false;
  selectedAccount = "";
  caseRecordDetails;
  dynamicColumnSize = "slds-col slds-size_1-of-4";
  packageData = {
    accountsClosed: null,
    cardsClosed: null,
    packagesClosed: null
  };
  selectAccountOptions = [];

  @wire(getRecord, {
    recordId: "$recordId",
    fields: [ACCOUNT_PRODUCT_FIELD]
  })
  async wiredRecord({ data }) {
    if (data) {
      {
        if (data.fields.Account_Product__c.value === "ANZ Plus Flex Saver") {
          this.isFlexSaverAccountClosure = true;
          this.dynamicColumnSize = "slds-col slds-size_1-of-1";
        } else {
          this.isFlexSaverAccountClosure = false;
          this.dynamicColumnSize = "slds-col slds-size_1-of-4";
        }
      }
    }
  }

  async showFAData() {
    this.selectAccountOptions = [];
    const accountFlexWrapper = await fetchFinancialAccounts({
      recordId: this.recordId
    });
    const allFinancialAccount = accountFlexWrapper.finAccounts;
    for (let index = 0; index < allFinancialAccount.length; index++) {
      const eachAccount = allFinancialAccount[index];
      this.selectAccountOptions.push({
        label: eachAccount.FinServ__FinancialAccountNumber__c,
        value: eachAccount.FinServ__FinancialAccountNumber__c
      });
    }
    this.caseRecordDetails = accountFlexWrapper.caseRecord;
    this.showConfirmationSelectAccount = true;
  }

  get displayEnabledButton() {
    return hasAccountClosurePermission;
  }

  toggleConfirmation() {
    this.showConfirmation = !this.showConfirmation;
    this.showConfirmationAccountClosure = false;
    this.showConfirmationSelectAccount = false;
    if (hasAccountClosurePilotPermission) {
      this.showFAData();
    } else {
      this.showConfirmationAccountClosure = true;
    }
  }

  async handleClosure() {
    if (hasAccountClosurePermission) {
      this.loading = true;
      this.toggleConfirmation();
      try {
        if (hasAccountClosurePilotPermission) {
          this.packageData = await getPackageClosureAuraFlex({
            caseRecord: this.caseRecordDetails,
            finAccountValue: this.selectedAccount
          });
        } else {
          this.packageData = await getPackageClosureAura({
            recordId: this.recordId
          });
        }

        //Set default messages and variant
        let message = "Account closure successful";
        let variant = "Success";

        if (
          !this.packageData?.errorInfo &&
          this.packageData?.accountsClosed > 0
        ) {
          //Build out the meta to display success statuses
          //as its not returned from API
          this.generatePackageData("Success", "Success", "Success");
          this.loading = false;
          showToast(this, "Account Closure", message, "", variant, "");
        } else {
          message = this.packageData?.errorInfo?.reason;
          variant = "Warning";

          let accountsClosedInfo =
            this.packageData?.accountsClosed > 0 ? "Success" : "Failed";
          let cardsClosedInfo =
            this.packageData?.cardsClosed > 0 ? "Success" : "Failed";
          let packagesClosedInfo =
            this.packageData?.packagesClosed > 0 ? "Success" : "Failed";
          this.generatePackageData(
            accountsClosedInfo,
            cardsClosedInfo,
            packagesClosedInfo
          );

          showToast(this, "Account Closure", message, "", variant, "");
          this.loading = false;
        }
      } catch (error) {
        this.loading = false;
        handleErrorShowToast(
          this,
          "Account Closure Failed",
          error,
          "Account Closure Failed. Please refresh and try again. Raise a fault through TechAssist if the problem persists"
        );
      }

      this.loading = false;
    }
  }

  showToast(theTitle, theMessage) {
    const event = new ShowToastEvent({
      title: theTitle,
      message: theMessage
    });
    this.dispatchEvent(event);
  }

  generatePackageData(
    accountsClosedMessage,
    cardsClosedMessage,
    packagesClosedMessage
  ) {
    this.packageData = {
      accountsClosed: accountsClosedMessage,
      cardsClosed: cardsClosedMessage,
      packagesClosed: packagesClosedMessage
    };
  }

  handleAccountSelect(objEvent) {
    objEvent.preventDefault();
    this.selectedAccount = "accounts/" + objEvent.detail.value;
  }

  handleNextPage(objEvent) {
    objEvent.preventDefault();
    if (this.selectedAccount) {
      this.showConfirmationAccountClosure = true;
    }
  }
}
