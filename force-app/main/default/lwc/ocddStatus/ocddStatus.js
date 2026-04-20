import { api, wire, LightningElement } from "lwc";
import { getApexError } from "c/utils";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import FIELD_ACCOUNT_OCVID from "@salesforce/schema/Account.OCV_ID__c";
import fetchOCDDStatus from "@salesforce/apex/ocddController.getOCDDKycReviewStatus";

export default class OcddStatus extends LightningElement {
  @api recordId;
  ocvId;
  ocddStatus;
  error;
  errorMessage;
  showSpinner = false;

  @wire(getRecord, {
    recordId: "$recordId",
    fields: [FIELD_ACCOUNT_OCVID]
  })
  wiredRecord({ data, error }) {
    if (error) {
      this.error = error;
      this.ocddStatus = undefined;
      this.errorMessage = getApexError(error);
      this.showSpinner = false;
      return;
    }
    if (!data) {
      return;
    }
    this.ocvId = getFieldValue(data, FIELD_ACCOUNT_OCVID);
    if (!this.ocvId) {
      this.errorMessage = "OCDD status not available: OCV ID is missing";
      this.showSpinner = false;
      return;
    }
    this.showSpinner = true;
    fetchOCDDStatus({ ocvId: this.ocvId })
      .then((result) => {
        this.ocddStatus = result;
        this.error = undefined;
        this.errorMessage = undefined;
      })
      .catch((err) => {
        this.error = err;
        this.ocddStatus = undefined;
        this.errorMessage = getApexError(err);
      })
      .finally(() => {
        this.showSpinner = false;
      });
  }
}
