import { LightningElement, api, wire } from "lwc";
import { CurrentPageReference } from "lightning/navigation";
import { CloseActionScreenEvent } from "lightning/actions";
import { notifyRecordUpdateAvailable } from "lightning/uiRecordApi";
import ANZX_CUSTOMER_FIELD from "@salesforce/schema/Account.ANZx_Customer__c";
import CUSTOMER_NEEDS_FIELD from "@salesforce/schema/Opportunity.Customer_Needs__c";
import TPMI_FIELD from "@salesforce/schema/Opportunity.TPMI__c";
import SAO_FIELD from "@salesforce/schema/User_Territory__c.SAO__c";
import OWNER_FIELD from "@salesforce/schema/Opportunity.OwnerId";
import TERRITORY_FIELD from "@salesforce/schema/Opportunity.Territory__c";
import createANZPlusLoanapp from "@salesforce/apex/OpportunityCreateOpenLoanappController.createANZPlusLoanapp";
import getOpportunityDetails from "@salesforce/apex/OpportunityCreateOpenLoanappController.getOpportunityDetails";
import getUserTerritory from "@salesforce/apex/OpportunityCreateOpenLoanappController.getUserTerritory";
import LoanappFriendlyErrorMessage from "@salesforce/label/c.LoanappFriendlyErrorMessage";
import ANZPlusPrerequisiteLabel from "@salesforce/label/c.ANZPlusPrerequisiteLabel";
import ANZPlusTPMISAOLabel from "@salesforce/label/c.ANZPlusTPMISAOLabel";
const VALID_CUSTOMER_NEEDS = ["ANZ Plus Home Loan - Refinance"];
const USER_FRIENDLY_ERROR = LoanappFriendlyErrorMessage;

export default class OpportunityCreateAnzPlusLoanapp extends LightningElement {
  @api recordId;
  oppDetails;
  userTerritoryDetails;
  isLoading = false;
  showError = false;
  oppString;
  progress = 0;
  showSuccess = false;
  userFriendlyErrorMessage;
  validCustomerNeeds = VALID_CUSTOMER_NEEDS;
  applicationId;
  label = {
    ANZPlusPrerequisiteLabel,
    ANZPlusTPMISAOLabel
  };
  @wire(CurrentPageReference)
  getStateParams(currentPageReference) {
    if (currentPageReference) {
      this.wiredRecordId = currentPageReference.state.recordId;
    }
  }

  get bodyText() {
    return `Creating ANZ Plus Loan Application for ${this.oppDetails?.Name}!`;
  }

  get allowCreateLoanapp() {
    return (
      this.oppDetails &&
      this.oppDetails.Account[ANZX_CUSTOMER_FIELD.fieldApiName] &&
      this.validCustomerNeeds.includes(
        this.oppDetails[CUSTOMER_NEEDS_FIELD.fieldApiName]
      )
    );
  }

  get isTPMIAndSAOPopulated() {
    return (
      this.oppDetails[TPMI_FIELD.fieldApiName] &&
      this.userTerritoryDetails &&
      this.userTerritoryDetails[SAO_FIELD.fieldApiName]
    );
  }

  async connectedCallback() {
    try {
      this.isLoading = true;
      this.oppString = await getOpportunityDetails({
        recordId: this.wiredRecordId
      });
      this.oppDetails = JSON.parse(this.oppString);
      this.userTerritoryDetails = await getUserTerritory({
        ownerId: this.oppDetails[OWNER_FIELD.fieldApiName],
        territoryId: this.oppDetails[TERRITORY_FIELD.fieldApiName]
      });
      this.isLoading = false;
      this.showProgressScreen = true;
      this.maintainProgressBar();
      if (!this.allowCreateLoanapp || !this.isTPMIAndSAOPopulated) {
        this.userFriendlyErrorMessage = !this.allowCreateLoanapp
          ? this.label.ANZPlusPrerequisiteLabel
          : this.label.ANZPlusTPMISAOLabel;
        this.showProgressScreen = false;
        this.showError = true;
        return;
      }
      this.sendRequestToLex();
    } catch (error) {
      this.isLoading = false;
      this.showProgressScreen = false;
      this.showError = true;
    }
  }

  maintainProgressBar() {
    // eslint-disable-next-line @lwc/lwc/no-async-operation
    this._interval = setInterval(() => {
      if (this.progress < 10) {
        this.progress = this.progress + 2;
      } else if (this.progress >= 10 && this.progress < 50) {
        this.progress = this.progress + 2;
      } else if (this.progress >= 50 && this.progress <= 99) {
        this.progress =
          this.progress >= 90 && this.progress !== 99
            ? this.progress + 1
            : this.progress === 99
              ? (this.progress = 99)
              : this.progress + 2;
      }
    }, 400);
  }

  async sendRequestToLex() {
    this.progress = 0;
    try {
      let response = await createANZPlusLoanapp({
        oppJson: this.oppString,
        ut: this.userTerritoryDetails
      });
      this.progress = 98;
      this.showProgressScreen = false;
      if (response.status === "success") {
        this.showSuccess = true;
        this.applicationId = response.applicationId;
        await notifyRecordUpdateAvailable([{ recordId: this.recordId }]);
      } else if (response.status === "error") {
        this.showError = true;
        this.userFriendlyErrorMessage = `${USER_FRIENDLY_ERROR}: ${response.message}`;
      }
    } catch (error) {
      this.showError = true;
      this.showProgressScreen = false;
      let errorString = error.body.message;
      this.setUserFriendlyErrorMessage(errorString);
    }
  }

  setUserFriendlyErrorMessage(errorString) {
    // try catch to check string is json or not
    try {
      let errorJson = JSON.parse(errorString);
      this.userFriendlyErrorMessage = `${USER_FRIENDLY_ERROR}: ${errorJson.message ?? errorString}`;
    } catch (jsonex) {
      this.userFriendlyErrorMessage = `${USER_FRIENDLY_ERROR}: ${errorString}`;
    }
  }

  closeQuickAction() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }
}
