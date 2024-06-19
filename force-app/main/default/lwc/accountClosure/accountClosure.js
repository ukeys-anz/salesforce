import getPackageClosureAura from "@salesforce/apex/StravinskyController.getPackageClosureAura";
import { api, LightningElement, wire } from "lwc";
import hasAccountClosurePermission from "@salesforce/customPermission/ANZx_Account_Closure";
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
  isFlexSaverAccountClosure;
  dynamicColumnSize;
  packageData = {
    accountsClosed: null,
    cardsClosed: null,
    packagesClosed: null
  };

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

  get displayEnabledButton() {
    return hasAccountClosurePermission;
  }

  toggleConfirmation() {
    this.showConfirmation = !this.showConfirmation;
  }

  async handleClosure() {
    if (hasAccountClosurePermission) {
      this.loading = true;
      this.toggleConfirmation();
      try {
        this.packageData = await getPackageClosureAura({
          recordId: this.recordId
        });
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
}
