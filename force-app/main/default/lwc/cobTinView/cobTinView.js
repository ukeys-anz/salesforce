import { LightningElement, api, wire, track } from "lwc";
import { showToast, handleErrors } from "c/utils";
import { getRecord } from "lightning/uiRecordApi";
import { CloseActionScreenEvent } from "lightning/actions";
import detokenizeTaxResidencyData from "@salesforce/apex/COBTaxResidencyViewController.detokenizeCOBTaxResidencyData";

const RECORD_FIELDS = [
  "COBTaxResidency__c.PersonaId__c",
  "COBTaxResidency__c.TaxIdentificationNumber__c"
];

export default class CobTinView extends LightningElement {
  @api recordId;
  @track taxResidencyRecord = {};

  isLoaded = true;
  error;

  @wire(getRecord, {
    recordId: "$recordId",
    fields: RECORD_FIELDS
  })
  async wiredRecord({ error, data }) {
    this.isLoaded = false;

    if (data) {
      this.taxResidencyRecord = {
        ...data
      };

      await this.detokenize();
    } else if (error) {
      this.error = error;
      this.taxResidencyRecord = {};
    }
  }

  async detokenize() {
    this.isLoaded = false;

    try {
      const cobTaxResidency = {
        PersonaId__c: this.taxResidencyRecord.fields.PersonaId__c.value,
        TaxIdentificationNumber__c: this.taxResidencyRecord.fields
          .TaxIdentificationNumber__c.value
      };

      let detokenizedTin =
        cobTaxResidency.TaxIdentificationNumber__c !== null
          ? await detokenizeTaxResidencyData({
              cobTaxResidency: cobTaxResidency
            })
          : "";
      this.taxResidencyRecord.TaxIdentificationNumber__c = detokenizedTin;
      this.error = undefined;
    } catch (error) {
      this.taxResidencyRecord = {};
      this.error = error;

      showToast(this, "Error!", handleErrors(error), "", "error", "");
    }

    this.isLoaded = true;
  }

  handleClose() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }
}
