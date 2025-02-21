import { LightningElement, api, wire } from "lwc";
import { CurrentPageReference } from "lightning/navigation";
import { CloseActionScreenEvent } from "lightning/actions";
import { notifyRecordUpdateAvailable } from "lightning/uiRecordApi";
import OPP_ID_FIELD from "@salesforce/schema/Opportunity.Id";
import OPP_ID_CUST_FIELD from "@salesforce/schema/Opportunity.Opportunity_ID__c";
import APP_KEY_FIELD from "@salesforce/schema/Opportunity.Application_Key__c";
import LOANAPP_FIELD from "@salesforce/schema/Opportunity.Loanapp_Reference__c";
import AMOUNT_FIELD from "@salesforce/schema/Opportunity.Amount";
import TPMI_FIELD from "@salesforce/schema/Opportunity.TPMI__c";
import EXPECTED_SETTLEMENT_DT_FIELD from "@salesforce/schema/Opportunity.Expected_Settlement_Date__c";
import SERVICING_BRANCH_FIELD from "@salesforce/schema/Opportunity.Servicing_Branch__c";
import CUSTOMER_NEEDS_FIELD from "@salesforce/schema/Opportunity.Customer_Needs__c";
import BIRTHDATE_FIELD from "@salesforce/schema/Contact.Birthdate";
import GENDER_FIELD from "@salesforce/schema/Contact.Gender__c";
import createOpenLoanApp from "@salesforce/apex/OpportunityCreateOpenLoanappController.createOpenLoanApp";
import getOpportunityDetails from "@salesforce/apex/OpportunityCreateOpenLoanappController.getOpportunityDetails";
import updateOpportunity from "@salesforce/apex/OpportunityCreateOpenLoanappController.updateOpportunity";
import SimpologyBaseUrl from "@salesforce/label/c.Simpology_Base_Url";
import LoanappPrerequisiteLabel from "@salesforce/label/c.LoanappPrerequisiteLabel";
import LoanappFriendlyErrorMessage from "@salesforce/label/c.LoanappFriendlyErrorMessage";

const USER_FRIENDLY_ERROR = LoanappFriendlyErrorMessage;
const VALID_CUSTOMER_NEEDS = [
  "Home Loan - Bridging Finance",
  "Home Loan - Refinance",
  "Home Loan - Refinance + Purchase",
  "Home Loan - Construction",
  "Home Loan - Purchase",
  "Home Loan - Other"
];
export default class OpportunityCreateOpenLoanapp extends LightningElement {
  @api recordId;
  wiredRecordId;
  openApp = false;
  oppDetails;
  oppString;
  applicationKey;
  isLoading = false;
  _interval;
  progress = 0;
  showError = false;
  userFriendlyErrorMessage = USER_FRIENDLY_ERROR;
  label = {
    SimpologyBaseUrl,
    LoanappPrerequisiteLabel,
    LoanappFriendlyErrorMessage
  };
  validCustomerNeeds = VALID_CUSTOMER_NEEDS;

  @wire(CurrentPageReference)
  getStateParams(currentPageReference) {
    if (currentPageReference) {
      this.wiredRecordId = currentPageReference.state.recordId;
    }
  }

  get bodyText() {
    return `${this.openApp ? "Opening" : "Creating"} Loanapp for ${
      this.oppDetails?.Name
    }. You will be automatically redirected to Simpology Loanapp.`;
  }

  get headerText() {
    if (this.oppDetails) {
      return this.openApp ? "Opening Loanapp" : "Creating Loanapp";
    }
    return "";
  }

  get navigationURL() {
    return this.label.SimpologyBaseUrl.replace("{0}", this.applicationKey);
  }

  get showProgressScreen() {
    return this.oppDetails && !this.showError;
  }

  //allow creation of loanapp only when following conditions are satisfied.
  get allowCreateLoanapp() {
    return (
      this.oppDetails &&
      this.oppDetails[AMOUNT_FIELD.fieldApiName] > 0 &&
      this.oppDetails[TPMI_FIELD.fieldApiName] &&
      this.oppDetails[EXPECTED_SETTLEMENT_DT_FIELD.fieldApiName] &&
      this.oppDetails[SERVICING_BRANCH_FIELD.fieldApiName] &&
      this.validCustomerNeeds.includes(
        this.oppDetails[CUSTOMER_NEEDS_FIELD.fieldApiName]
      ) &&
      this.oppDetails.OpportunityContactRoles?.records?.every(
        (ocr) =>
          ocr.Contact[BIRTHDATE_FIELD.fieldApiName] &&
          ocr.Contact[GENDER_FIELD.fieldApiName]
      )
    );
  }

  async connectedCallback() {
    try {
      this.isLoading = true;
      this.maintainProgressBar();
      this.oppString = await getOpportunityDetails({
        recordId: this.wiredRecordId
      });
      this.oppDetails = JSON.parse(this.oppString);
      this.isLoading = false;
      this.openApp = this.oppDetails[LOANAPP_FIELD.fieldApiName] ? true : false;
      if (!this.openApp && !this.allowCreateLoanapp) {
        this.userFriendlyErrorMessage = this.label.LoanappPrerequisiteLabel;
        this.isLoading = false;
        this.showError = true;
        return;
      }
      if (this.openApp && this.oppDetails[APP_KEY_FIELD.fieldApiName]) {
        this.navigateDirectlyToSimpology();
      } else {
        this.sendRequestToSimpology();
      }
    } catch (error) {
      this.isLoading = false;
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

  async sendRequestToSimpology() {
    this.progress = 0;
    try {
      let createOpenResult = await createOpenLoanApp({
        oppJson: this.oppString,
        isOpen: this.openApp
      });
      if (this.isNullResponse(createOpenResult)) {
        throw new Error("Null response");
      }
      this.progress = 98;
      this.applicationKey = createOpenResult;
      const oppInput = this.setApplicationKey(createOpenResult);
      await updateOpportunity({ opp: oppInput });
      await notifyRecordUpdateAvailable([{ recordId: this.recordId }]);
      this.progress = 100;
      window.open(this.navigationURL, "_blank");
      this.closeQuickAction();
    } catch (error) {
      if (error?.message === "Null response") {
        this.userFriendlyErrorMessage = `${USER_FRIENDLY_ERROR}: Simpology returned an empty response!`;
        this.showError = true;
        return;
      }
      this.userFriendlyErrorMessage = error.body.message.includes(
        "FIELD_CUSTOM_VALIDATION_EXCEPTION"
      )
        ? error.body.message.substring(
            82 + "FIELD_CUSTOM_VALIDATION_EXCEPTION".length
          )
        : `${USER_FRIENDLY_ERROR}: ${error.body.message}`;
      this.showError = true;
    }
  }

  setApplicationKey(createOpenResult) {
    const fields = {};
    fields[OPP_ID_FIELD.fieldApiName] = this.wiredRecordId;
    fields[APP_KEY_FIELD.fieldApiName] = createOpenResult;
    if (!this.openApp) {
      let leadingZerosTrimmed = this.oppDetails[OPP_ID_CUST_FIELD.fieldApiName];
      leadingZerosTrimmed = leadingZerosTrimmed.replace(/^0+/, "");
      fields[LOANAPP_FIELD.fieldApiName] = `MLCRM-${leadingZerosTrimmed}`;
    }
    return fields;
  }

  navigateDirectlyToSimpology() {
    this.applicationKey = this.oppDetails[APP_KEY_FIELD.fieldApiName];
    this.progress = 98;
    // eslint-disable-next-line @lwc/lwc/no-async-operation
    setTimeout(() => {
      window.open(this.navigationURL, "_blank");
      this.progress = 100;
      this.closeQuickAction();
    }, 1200);
  }

  isNullResponse(createOpenResult) {
    return (
      createOpenResult === "null" ||
      createOpenResult === "" ||
      createOpenResult === " " ||
      createOpenResult === null ||
      createOpenResult === undefined
    );
  }
  closeQuickAction() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }

  disconnectedCallback() {
    clearInterval(this._interval);
  }
}
