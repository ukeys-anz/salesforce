import { LightningElement, wire, api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CloseActionScreenEvent } from "lightning/actions";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { getPicklistValuesByRecordType } from "lightning/uiObjectInfoApi";
import { CurrentPageReference } from "lightning/navigation";
import saveAccountDetails from "@salesforce/apex/ManageExtraCareController.handleExtraCareUpdate";
import getStagingRecordStatus from "@salesforce/apex/ManageExtraCareController.getStagingRecordStatus";
import canManageHighRiskVictim from "@salesforce/customPermission/ManageExtraCareHighRiskScamVictim";
import RECORD_TYPE_ID_FIELD from "@salesforce/schema/Account.RecordTypeId";
import ACCOUNT_ID from "@salesforce/schema/Account.Id";
import TIME_PERIOD from "@salesforce/schema/Account.ExtraCareTimePeriod__c";
import REASON from "@salesforce/schema/Account.ExtraCareReason__c";
import NOTES from "@salesforce/schema/Account.ExtraCareNotes__c";
import REVIEW_DATE from "@salesforce/schema/Account.ExtraCareReviewDate__c";
import DISCLOSURE from "@salesforce/schema/Account.ExtraCareDisclosure__c";
import CONSENT from "@salesforce/schema/Account.ExtraCareConsent__c";
import OCVID from "@salesforce/schema/Account.OCV_ID__c";
import SOURCE_SYSTEM_ID from "@salesforce/schema/Account.Source_System_ID__c";
import SOURCE_SYSTEM_NAME from "@salesforce/schema/Account.Source_System_Name__c";
import ACCOUNT_OBJECT from "@salesforce/schema/Account";
import {
  IsConsoleNavigation,
  getFocusedTabInfo,
  refreshTab
} from "lightning/platformWorkspaceApi";

const FIELDS = [
  TIME_PERIOD,
  REASON,
  NOTES,
  REVIEW_DATE,
  DISCLOSURE,
  CONSENT,
  OCVID,
  SOURCE_SYSTEM_ID,
  SOURCE_SYSTEM_NAME,
  RECORD_TYPE_ID_FIELD
];
const HIGH_RISK_VICTIM_ERROR =
  "You are not authorised to add or remove 'High risk scam victim'";
const PENDING_STATUS_MESSAGE =
  "The latest request is observed to be in 'Pending' Status. Please try again after some time";
const ERROR_STATUS_MESSAGE =
  "Unable to edit Extra Care information. Click retry to try again.";
const SENSITIVE_REASONS = [
  "Cognitive capacity concerns",
  "Disability",
  "Aboriginal and/or Torres Strait Islander",
  "Incarceration/recently released from incarceration",
  "Literacy and/or language barriers including limited English",
  "Propensity to commit self harm",
  "Serious medical conditions (including mental health)"
];
const HIGH_RISK_REASONS = "High Risk Scam Victim";

const NOTES_HELP_TEXT =
  "Only record information that is needed to ensure appropriate provision of extra care to the customer, keeping the notes brief. DO NOT leave notes with your opinion, derogatory comments, or emotive language. For support or more information, refer to KnowHow or relevant knowledge article.";

export default class ManageExtraCare extends LightningElement {
  @api recordId;
  accountId;
  @track oldAccount = {};
  @track newAccount = {};
  isLoading = true;
  @track disableTimePeriodValue = false;
  @track stagingRecordIsPendingOrErrorStatus = false;
  @track timePeriodOptions = [];
  @track recordTypeId;
  @track reasonOptions = [];
  notesHelpText = NOTES_HELP_TEXT;
  @wire(IsConsoleNavigation) isConsoleNavigation;
  @wire(getRecord, { recordId: "$recordId", fields: FIELDS })
  wiredRecord({ error, data }) {
    if (data) {
      this.recordTypeId = data.fields.RecordTypeId.value;
      this.oldAccount = this.makeAccount(data);
      this.newAccount = this.makeAccount(data);
      this.newAccount.ExtraCareConsent__c = false;
      this.newAccount.ExtraCareDisclosure__c = false;
      this.isLoading = false;
      this.fetchStagingRecordStatus();
    } else if (error) {
      this.toast.error(
        "Error",
        "An error occurred while loading case details, please try again later."
      );
    }
  }

  @wire(CurrentPageReference)
  getStateParameters(currentPageReference) {
    if (currentPageReference) {
      this.accountId = currentPageReference.state.recordId;
    }
  }

  connectedCallback() {
    this.fetchStagingRecordStatus();
  }
  @wire(getPicklistValuesByRecordType, {
    objectApiName: ACCOUNT_OBJECT,
    recordTypeId: "$recordTypeId"
  })
  picklistValueHandler({ data, error }) {
    if (data) {
      this.timePeriodOptions =
        data.picklistFieldValues[TIME_PERIOD.fieldApiName]?.values || [];
      this.reasonOptions =
        data.picklistFieldValues[REASON.fieldApiName]?.values || [];
    } else if (error) {
      this.toast.error(
        "Error",
        "An error occurred while fetching TimePeriod/Reason(s). Please try again later."
      );
    }
  }
  get minReviewDate() {
    let today = new Date();
    today.setDate(today.getDate() + 1);
    return today.toISOString().split("T")[0];
  }
  fetchStagingRecordStatus() {
    // Fetch the staging record status when the page loads
    const invalidStatuses = {
      Pending: PENDING_STATUS_MESSAGE,
      Error: ERROR_STATUS_MESSAGE
    };
    getStagingRecordStatus({ accountId: this.accountId })
      .then((data) => {
        if (!Object.keys(invalidStatuses).includes(data)) {
          return;
        }
        this.stagingRecordIsPendingOrErrorStatus = true;
        this.disableTimePeriodValue = true;
        this.toast.error("Error", invalidStatuses[data]);
      })
      .catch((error) => {
        this.toast.error(
          "Error",
          "An error occurred while fetching Customer Profile Staging record. Please try again later."
        );
        console.log(error);
      });
  }

  get isDisabled() {
    if (this.stagingRecordIsPendingOrErrorStatus) {
      return true;
    }
    return this.newAccount.ExtraCareTimePeriod__c === "Not required";
  }

  get showReviewDate() {
    if (
      this.isDisabled ||
      !this.newAccount ||
      !this.newAccount.ExtraCareTimePeriod__c
    ) {
      return false;
    }
    return this.newAccount.ExtraCareTimePeriod__c.toLowerCase().includes(
      "temporarily required"
    );
  }

  get showConsent() {
    return this.selectedReasons.some((reason) => {
      return SENSITIVE_REASONS.includes(reason);
    });
  }
  get isDisclosureDisabled() {
    if (this.isDisabled) {
      return true;
    }

    return (
      this.oldAccount.ExtraCareTimePeriod__c ===
        this.newAccount.ExtraCareTimePeriod__c &&
      this.oldAccount.ExtraCareReason__c === this.newAccount.ExtraCareReason__c
    );
  }

  get selectedReasons() {
    let reason = this.newAccount.ExtraCareReason__c;
    if (!reason) {
      return [];
    }
    return reason.split(";");
  }

  makeAccount(data) {
    let account = {
      [ACCOUNT_ID.fieldApiName]: this.recordId,
      [RECORD_TYPE_ID_FIELD.fieldApiName]: this.recordTypeId
    };
    FIELDS.forEach((field) => {
      account[field.fieldApiName] = getFieldValue(data, field);
    });

    if (!account.ExtraCareTimePeriod__c) {
      account.ExtraCareTimePeriod__c = "Not required";
    }
    return account;
  }

  toast = {
    error: (title, message) => {
      this.dispatchEvent(
        new ShowToastEvent({ title, message, variant: "error" })
      );
    },
    success: (title, message) => {
      this.dispatchEvent(
        new ShowToastEvent({ title, message, variant: "success" })
      );
    }
  };

  handler = {
    save: () => {
      if (!this.validation.validate()) {
        return;
      }
      this.isLoading = true;

      saveAccountDetails({
        newAccount: this.newAccount,
        oldAccount: this.oldAccount
      })
        .then(async () => {
          await this.refreshTab();
          this.toast.success(
            "Success",
            "Extra Care details saved successfully."
          );
        })
        .catch((error) => {
          this.toast.error(
            "Error",
            "An error occurred while saving Extra Care details, please try again later"
          );
          console.log(error);
        })
        .finally(() => {
          this.isLoading = false;
          this.handler.cancel();
        });
    },
    cancel: () => {
      this.dispatchEvent(new CloseActionScreenEvent());
    },
    handleChange: (e) => {
      let field = e.target;
      if (!field) {
        return;
      }
      if (field.type === "checkbox") {
        this.newAccount[field.dataset.id] = field.checked;
        return;
      }
      if (field.dataset.id === "ExtraCareReason__c") {
        this.newAccount[field.dataset.id] = field.value.sort().join(";");
        this.validation.checkHighRiskScamVictim(field.value);
        this.updateReviewDate();
        return;
      }
      this.newAccount[field.dataset.id] = field.value;
      if (field.dataset.id === "ExtraCareTimePeriod__c") {
        this.updateReviewDate();
        //reset fields
        this.newAccount.ExtraCareDisclosure__c = false;
        this.newAccount.ExtraCareConsent__c = false;
        if (field.value === "Not required") {
          this.newAccount.ExtraCareReason__c = "";
          this.newAccount.ExtraCareNotes__c = "";
          this.newAccount.ExtraCareReviewDate__c = "";
        }
      }
    }
  };

  validation = {
    validate: () => {
      let isValid = true;
      const fields = this.template.querySelectorAll(".input-class");
      fields.forEach((field) => {
        if (!field.checkValidity()) {
          field.reportValidity();
          isValid = false;
        }
      });
      return isValid;
    },
    checkHighRiskScamVictim: (reasons) => {
      if (canManageHighRiskVictim) {
        return;
      }
      let field = this.template.querySelector(
        "lightning-dual-listbox[data-id=ExtraCareReason__c]"
      );

      let oldReasons = this.oldAccount.ExtraCareReason__c || [];
      if (
        (reasons.includes(HIGH_RISK_REASONS) &&
          !oldReasons.includes(HIGH_RISK_REASONS)) ||
        (!reasons.includes(HIGH_RISK_REASONS) &&
          oldReasons.includes(HIGH_RISK_REASONS))
      ) {
        this.toast.error("Error", HIGH_RISK_VICTIM_ERROR);
        field.setCustomValidity(HIGH_RISK_VICTIM_ERROR);
        field.reportValidity();
      } else {
        field.setCustomValidity("");
        field.reportValidity();
      }
    }
  };

  async refreshTab() {
    if (!this.isConsoleNavigation) {
      return;
    }
    const { tabId } = await getFocusedTabInfo();
    await refreshTab(tabId, {
      includeAllSubtabs: false
    });
  }

  get disableSaveButton() {
    if (this.stagingRecordIsPendingOrErrorStatus) {
      return true;
    }
    if (
      this.oldAccount.ExtraCareTimePeriod__c !== "Not required" &&
      this.newAccount.ExtraCareTimePeriod__c === "Not required"
    ) {
      return false;
    }
    if (
      !this.newAccount.ExtraCareReason__c ||
      !this.newAccount.ExtraCareNotes__c ||
      !this.newAccount.ExtraCareDisclosure__c ||
      (this.showConsent && !this.newAccount.ExtraCareConsent__c) ||
      (this.showReviewDate && !this.newAccount.ExtraCareReviewDate__c)
    ) {
      return true;
    }
    return false;
  }

  updateReviewDate() {
    let today = new Date();
    today.setDate(today.getDate() + 1);
    let futureDate = new Date();
    futureDate.setFullYear(today.getFullYear() + 1);
    let oneYearFromToday = futureDate.toISOString().split("T")[0];
    // Review Date is not visible
    if (!this.showReviewDate) {
      this.newAccount.ExtraCareReviewDate__c = null;
      return;
    }
    // Reason is changed with having no prior value (Or)
    // TimePeriod changed with same reasons
    if (
      !this.oldAccount.ExtraCareReason__c ||
      (this.newAccount.ExtraCareReason__c &&
        this.newAccount.ExtraCareReviewDate__c == null)
    ) {
      this.newAccount.ExtraCareReviewDate__c = oneYearFromToday;
      return;
    }
    // Reason is changed while having some prior value(s)
    let oldEcReason = [...this.oldAccount.ExtraCareReason__c].sort();
    let newEcReason = [...this.newAccount.ExtraCareReason__c].sort();
    let ecReasonAreSame = oldEcReason.every(
      (val, index) => val === newEcReason[index]
    );
    if (!ecReasonAreSame && newEcReason.length > oldEcReason.length) {
      this.newAccount.ExtraCareReviewDate__c = oneYearFromToday;
    }
  }
}
