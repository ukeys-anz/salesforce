import { LightningElement, api, wire, track } from "lwc";
import { showToast } from "c/utils";
import { getRecord, getRecordNotifyChange } from "lightning/uiRecordApi";
import { CloseActionScreenEvent } from "lightning/actions";
import hasEditPermission from "@salesforce/customPermission/ANZx_Edit_COB_Primary_ID_Document";
import detokenizeCOBPIDData from "@salesforce/apex/COBPIDViewAndEditController.detokenizeCOBPIDData";
import updateCOBPIDData from "@salesforce/apex/COBPIDViewAndEditController.updateCOBPIDData";

const RECORD_FIELDS = [
  "COBPrimaryIDDocument__c.IdDocumentType__c",
  "COBPrimaryIDDocument__c.PersonaId__c",
  "COBPrimaryIDDocument__c.CustomerOnboardingApplication__r.EquifaxAttemptCount__c"
];

export default class CobPidViewAndEdit extends LightningElement {
  @api recordId;
  @track data = {};

  _personaId;
  _initDetokenizedData = {};
  _equifaxAttemptCount = 0;

  isLoading = false;
  error;

  async connectedCallback() {
    // give ReadOnly lightning-input lwc component a default indentation to align the text in default lightning-input
    const inputAlignLeft = document.createElement("style");
    inputAlignLeft.innerText = `.slds-form-element__control input[readonly]{ padding-left:0.55rem!important; }`;
    document.body.appendChild(inputAlignLeft);

    this.isLoading = true;
  }

  get allowEdit() {
    return hasEditPermission;
  }

  get disableSave() {
    return !this.isValidChange || this.error !== undefined;
  }

  get readOnly() {
    return !this.allowEdit || this.reachedEditLimit || this.error !== undefined;
  }

  get reachedEditLimit() {
    return this._equifaxAttemptCount >= 2;
  }

  get panelHeader() {
    if (this.allowEdit) {
      return "Edit Details";
    }

    return "View Details";
  }

  get isPassportType() {
    return this.data?.IdDocumentType__c === "Passport";
  }

  get isLicenceType() {
    return this.data?.IdDocumentType__c === "Licence";
  }

  get showNumberFields() {
    return this.isPassportType || this.isLicenceType;
  }

  get isValidChange() {
    for (const [key, value] of Object.entries(this.data)) {
      // old (init) value is changed
      if (this._initDetokenizedData[key] !== value) {
        return true;
      }
    }

    return false;
  }

  @wire(getRecord, {
    recordId: "$recordId",
    fields: RECORD_FIELDS
  })
  async wiredRecord({ error, data }) {
    this.isLoading = true;

    if (data) {
      this.data = {
        ...this.data,
        IdDocumentType__c: data.fields.IdDocumentType__c.value
      };
      this._personaId = data.fields.PersonaId__c.value;
      this._equifaxAttemptCount =
        data.fields.CustomerOnboardingApplication__r.value.fields.EquifaxAttemptCount__c.value;

      await this.detokenize();
    } else if (error) {
      this.error = error;
      this.data = {};
    }
  }

  async detokenize() {
    this.isLoading = true;

    try {
      this._initDetokenizedData = await detokenizeCOBPIDData({
        recordId: this.recordId
      });

      this.data = {
        ...this.data,
        ...this._initDetokenizedData
      };
      this.error = undefined;
    } catch (error) {
      this.data = {};
      this.error = error;

      showToast(
        this,
        "Error!",
        "Failed to detokenize encrypted data. Please contact your System Administrator.",
        "",
        "error",
        ""
      );
    }

    this.isLoading = false;
  }

  handleFieldChange(event) {
    this.data[event.target.dataset.id] = event.detail.value;
  }

  async handleSave() {
    this.isLoading = true;

    try {
      await updateCOBPIDData({
        record: this.data
      });
      this.error = undefined;

      await getRecordNotifyChange([{ recordId: this.recordId }]);

      showToast(
        this,
        "Success!",
        "Successfully updated details.",
        "",
        "success",
        ""
      );

      this.handleClose();
    } catch (error) {
      this.error = error;
      this.data = this._initDetokenizedData;

      showToast(
        this,
        "Error!",
        "Failed to update details. Please contact your System Administrator.",
        "",
        "error",
        ""
      );
    }

    this.isLoading = false;
  }

  handleClose() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }
}
