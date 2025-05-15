import { LightningElement, api, wire } from "lwc";
import { showToast } from "c/utils";
import {
  getRecord,
  getFieldValue,
  notifyRecordUpdateAvailable
} from "lightning/uiRecordApi";
import disconnectANZAccounts from "@salesforce/apex/PDIAssistedController.disconnectANZAccounts";

export default class PdiDisconnectANZAccounts extends LightningElement {
  @api recordId;
  isLoading = false;
  personId;
  personaId;

  MSG = {
    SUCCESS:
      "The customer's linked accounts have been disconnected successfully.",
    ERROR: {
      NO_DATA: "Error while retrieving record data. Please try again.",
      MISSING_DATA:
        "The customer's UUID and Persona ID are required to proceed."
    }
  };

  @wire(getRecord, {
    recordId: "$recordId",
    fields: [
      "PersonDigitalIdentity__x.UUID__c",
      "PersonDigitalIdentity__x.Persona_ID__c"
    ]
  })
  record({ data, error }) {
    if (error) {
      this.handleError(this.MSG.ERROR.NO_DATA);
      return;
    }
    if (!data) {
      return;
    }

    this.personId = getFieldValue(data, "PersonDigitalIdentity__x.UUID__c");
    this.personaId = getFieldValue(
      data,
      "PersonDigitalIdentity__x.Persona_ID__c"
    );

    if (!this.personId || !this.personaId) {
      this.handleError(this.MSG.ERROR.MISSING_DATA);
    }
  }

  async handleConfirm() {
    try {
      this.isLoading = true;

      await disconnectANZAccounts({
        personId: this.personId,
        personaId: this.personaId
      });
      notifyRecordUpdateAvailable([{ recordId: this.recordId }]);
      this.handleSuccess();
    } catch (error) {
      this.handleError(error.body.message);
    } finally {
      this.isLoading = false;
    }
  }

  handleError(message) {
    showToast(this, message, null, null, "error");
    this.handleClose();
  }

  handleSuccess() {
    showToast(this, this.MSG.SUCCESS, null, null, "success");
    this.handleClose();
  }

  handleClose() {
    const closeActionEvent = new CustomEvent("closeaction");
    this.dispatchEvent(closeActionEvent);
  }
}
