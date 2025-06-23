import { LightningElement, api, wire, track } from "lwc";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import Label_EXTRA_CARE_INFO from "@salesforce/label/c.Extra_Care_Info_Message";
import Label_EXTRA_CARE_REVIEW from "@salesforce/label/c.Extra_Care_Review_Message";
import OPPORTUNITY_ACCOUNTID from "@salesforce/schema/Opportunity.AccountId";
import LEAD_ACCOUNTID from "@salesforce/schema/Lead.FinServ__RelatedAccount__c";
import SHOW_EXTRACARE_ALERT from "@salesforce/schema/Account.ShowExtraCareAlert__c";
import EXTRACARE_TIMEPERIOD from "@salesforce/schema/Account.ExtraCareTimePeriod__c";
import hasExtraCarePermission from "@salesforce/customPermission/ExtracareReadOnly";

export default class ExtraCareNotification extends LightningElement {
  @api recordId;
  @api objectApiName;
  @track details = {};
  accountId;
  opportunityId;
  leadId;
  showExtraCareAlert;
  extraCareTimePeriod;

  connectedCallback() {
    if (!hasExtraCarePermission) {
      return;
    }
    if (this.objectApiName === "Account") {
      this.accountId = this.recordId;
    } else if (this.objectApiName === "Opportunity") {
      this.opportunityId = this.recordId;
    } else {
      this.leadId = this.recordId;
    }
  }

  @wire(getRecord, {
    recordId: "$opportunityId",
    fields: OPPORTUNITY_ACCOUNTID
  })
  wiredOpportunity({ error, data }) {
    if (data) {
      this.accountId = getFieldValue(data, OPPORTUNITY_ACCOUNTID);
    } else if (error) {
      this.toast.error(
        "Error",
        "An error occurred while loading Extra Care Notification."
      );
    }
  }

  @wire(getRecord, { recordId: "$leadId", fields: LEAD_ACCOUNTID })
  wiredLead({ error, data }) {
    if (data) {
      this.accountId = getFieldValue(data, LEAD_ACCOUNTID);
    } else if (error) {
      this.toast.error(
        "Error",
        "An error occurred while loading Extra Care Notification."
      );
    }
  }

  @wire(getRecord, {
    recordId: "$accountId",
    fields: [SHOW_EXTRACARE_ALERT, EXTRACARE_TIMEPERIOD]
  })
  wiredAccount({ error, data }) {
    if (data) {
      this.showExtraCareAlert = getFieldValue(data, SHOW_EXTRACARE_ALERT);
      this.extraCareTimePeriod = getFieldValue(data, EXTRACARE_TIMEPERIOD);
      this.setDetails();
    } else if (error) {
      this.toast.error(
        "Error",
        "An error occurred while loading Extra Care Notification."
      );
    }
  }

  setDetails() {
    if (!this.showExtraCareAlert) {
      this.details.iconName = "utility:info";
      this.details.headerText = "Extra Care";
      this.details.bodyText = Label_EXTRA_CARE_INFO;
    } else {
      this.details.iconName = "utility:warning";
      this.details.headerText = "Review extra care with customer";
      this.details.bodyText = Label_EXTRA_CARE_REVIEW;
    }
  }

  get displayComponent() {
    return (
      hasExtraCarePermission &&
      this.extraCareTimePeriod &&
      this.extraCareTimePeriod !== "Not required"
    );
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
}
