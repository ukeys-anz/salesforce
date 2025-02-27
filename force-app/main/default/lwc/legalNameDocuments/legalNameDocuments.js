import { LightningElement, api, wire } from "lwc";
import { getRecord, updateRecord, getFieldValue } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import tokenize from "@salesforce/apex/VaultController.tokenizeDocumentNumber";
import detokenize from "@salesforce/apex/VaultController.detokenizeDocumentNumber";

import FIELD_CASE_ID from "@salesforce/schema/Case.Id";

import FIELD_ACCOUNT_OCVID from "@salesforce/schema/Case.Account.OCV_ID__c";
import FIELD_CASE_STATUS from "@salesforce/schema/Case.Status";
import FIELD_DAON_DOCUMENT_ID from "@salesforce/schema/Case.Daon_Document_Id__c";
import FIELD_DAON_CHECK_ID from "@salesforce/schema/Case.Daon_Check_Id__c";
import FIELD_DAON_USER_ID from "@salesforce/schema/Case.Daon_User_Id__c";
import FIELD_DAON_WORKFLOW_ID from "@salesforce/schema/Case.Aegis_Workflow_Id__c";

import FIELD_DOCUMENT_TYPE from "@salesforce/schema/Case.DocumentType__c";
import FIELD_CERTIFICATE_IDENTIFIER_TYPE from "@salesforce/schema/Case.CertificateIdentifierType__c";
import FIELD_PASSPORT_NUMBER from "@salesforce/schema/Case.PassportNumber__c";
import FIELD_LICENCE_NUMBER from "@salesforce/schema/Case.LicenceNumber__c";
import FIELD_LICENCE_CARD_NUMBER from "@salesforce/schema/Case.LicenceCardNumber__c";
import FIELD_CERTIFICATE_IDENTIFIER from "@salesforce/schema/Case.CertificateIdentifier__c";

const FIELDS = [
  FIELD_ACCOUNT_OCVID,
  FIELD_CASE_STATUS,
  FIELD_DAON_DOCUMENT_ID,
  FIELD_DAON_CHECK_ID,
  FIELD_DAON_USER_ID,
  FIELD_DAON_WORKFLOW_ID,
  FIELD_DOCUMENT_TYPE,
  FIELD_CERTIFICATE_IDENTIFIER_TYPE,
  FIELD_PASSPORT_NUMBER,
  FIELD_LICENCE_NUMBER,
  FIELD_LICENCE_CARD_NUMBER,
  FIELD_CERTIFICATE_IDENTIFIER
];
const FILES_BY_DOCUMENTTYPE = {
  DOCUMENT_TYPE_AUSTRALIAN_PASSPORT: [
    {
      fileType: "DAON_FILE_TYPE_FRONT_PROCESSED",
      title: "Processed Document Front"
    },
    {
      fileType: "DAON_FILE_TYPE_FRONT_UNPROCESSED",
      title: "Unprocessed Document Front"
    }
  ],
  OTHER: [
    {
      fileType: "DAON_FILE_TYPE_FRONT_PROCESSED",
      title: "Processed Document Front"
    },
    {
      fileType: "DAON_FILE_TYPE_FRONT_UNPROCESSED",
      title: "Unprocessed Document Front"
    },
    {
      fileType: "DAON_FILE_TYPE_BACK_PROCESSED",
      title: "Processed Document Back"
    },
    {
      fileType: "DAON_FILE_TYPE_BACK_UNPROCESSED",
      title: "Unprocessed Document Back"
    }
  ]
};
export default class LegalNameDocuments extends LightningElement {
  inputMinLength = 4;
  inputMaxLength = 32;
  inputLengthError = `Please enter a value between ${this.inputMinLength} and ${this.inputMaxLength} characters.`;
  @api recordId;
  canShow = false;
  isLoading = false;
  passportNumber = "";
  licenceNumber = "";
  licenceCardNumber = "";
  certificateIdentifier = "";

  caseDetails;

  @wire(getRecord, {
    recordId: "$recordId",
    fields: FIELDS
  })
  wiredRecord({ error, data }) {
    if (error) {
      this.toast.error("Error loading case details", error);
    } else if (data) {
      this.caseDetails = data;
      if (this.canShow) {
        this.mapper.recordToInput();
      }
    }
  }

  get layout() {
    if (!this.caseDetails) {
      return null;
    }
    return [
      {
        title: "Identity Documents",
        size: 12,
        files:
          FILES_BY_DOCUMENTTYPE[this.getFieldValue(FIELD_DOCUMENT_TYPE)] ??
          FILES_BY_DOCUMENTTYPE.OTHER
      },
      {
        title: "Selfies",
        size: 10,
        files: [{ fileType: "DAON_FILE_TYPE_SELFIE_ENROLLED" }]
      }
    ];
  }

  get metadata() {
    if (!this.caseDetails) {
      return null;
    }
    return {
      idxDocumentId: this.getFieldValue(FIELD_DAON_DOCUMENT_ID),
      idxIdCheckId: this.getFieldValue(FIELD_DAON_CHECK_ID),
      idxUserId: this.getFieldValue(FIELD_DAON_USER_ID),
      workflowId: this.getFieldValue(FIELD_DAON_WORKFLOW_ID),
      relatedRecordId: this.recordId,
      ...this.customerToken
    };
  }

  get disableEdit() {
    return this.getFieldValue(FIELD_CASE_STATUS) === "Closed";
  }

  get customerToken() {
    return {
      customerId: this.getFieldValue(FIELD_ACCOUNT_OCVID),
      customerIdType: "OCVID"
    };
  }

  get documentType() {
    return this.getFieldValue(FIELD_DOCUMENT_TYPE);
  }

  get isLicence() {
    return this.documentType === "DOCUMENT_TYPE_AUSTRALIAN_DRIVERS_LICENCE";
  }

  get isPassport() {
    return this.documentType === "DOCUMENT_TYPE_AUSTRALIAN_PASSPORT";
  }

  getFieldValue(field) {
    return getFieldValue(this.caseDetails, field);
  }

  service = {
    save: async (data) => {
      this.isLoading = true;
      try {
        await updateRecord(data);
        this.toast.success("Document identifiers updated successfully");
      } catch (error) {
        this.toast.error("Error updating the document identifiers", error);
        console.error(error);
      } finally {
        this.isLoading = false;
      }
    },
    tokenize: (valueOrCollection) => {
      if (!valueOrCollection) {
        return new Promise((resolve) => resolve(""));
      }
      if (!Array.isArray(valueOrCollection)) {
        return tokenize({
          docNumber: valueOrCollection,
          docType: this.documentType,
          ...this.customerToken
        });
      }
      return Promise.all(
        valueOrCollection.map((value) => this.service.tokenize(value))
      );
    },
    detokenize: (valueOrCollection) => {
      if (!valueOrCollection) {
        return new Promise((resolve) => resolve(""));
      }
      if (!Array.isArray(valueOrCollection)) {
        return detokenize({
          docNumber: valueOrCollection,
          docType: this.documentType,
          ...this.customerToken
        });
      }
      return Promise.all(
        valueOrCollection.map((value) => this.service.detokenize(value))
      );
    }
  };

  mapper = {
    recordToInput: async () => {
      this.isLoading = true;
      try {
        [
          this.licenceNumber,
          this.licenceCardNumber,
          this.passportNumber,
          this.certificateIdentifier
        ] = await this.service.detokenize([
          this.getFieldValue(FIELD_LICENCE_NUMBER),
          this.getFieldValue(FIELD_LICENCE_CARD_NUMBER),
          this.getFieldValue(FIELD_PASSPORT_NUMBER),
          this.getFieldValue(FIELD_CERTIFICATE_IDENTIFIER)
        ]);
      } catch (error) {
        this.toast.error("Error tokenising the document identifiers", error);
        throw error;
      } finally {
        this.isLoading = false;
      }
    },
    inputToRecord: async () => {
      this.isLoading = true;
      try {
        const fields = { [FIELD_CASE_ID.fieldApiName]: this.recordId };
        [
          fields[FIELD_LICENCE_NUMBER.fieldApiName],
          fields[FIELD_LICENCE_CARD_NUMBER.fieldApiName],
          fields[FIELD_PASSPORT_NUMBER.fieldApiName],
          fields[FIELD_CERTIFICATE_IDENTIFIER.fieldApiName]
        ] = await this.service.tokenize([
          this.licenceNumber,
          this.licenceCardNumber,
          this.passportNumber,
          this.certificateIdentifier
        ]);
        return fields;
      } catch (error) {
        this.toast.error("Error detokenising the document identifiers", error);
        throw error;
      } finally {
        this.isLoading = false;
      }
    }
  };

  toast = {
    error: (title, message) => {
      this.dispatchEvent(
        new ShowToastEvent({
          title,
          message: this.getApexError(message),
          variant: "error"
        })
      );
    },
    success: (title, message) => {
      this.dispatchEvent(
        new ShowToastEvent({ title, message, variant: "success" })
      );
    }
  };

  handler = {
    handleChange: (e) => {
      let field = e.target.dataset.id;
      if (!field) {
        return;
      }
      this[field] = e.detail.value;
    },
    handleSave: async () => {
      const allValid = [
        ...this.template.querySelectorAll("lightning-input")
      ].reduce((validSoFar, inputFields) => {
        inputFields.reportValidity();
        return validSoFar && inputFields.checkValidity();
      }, true);

      if (allValid) {
        this.service.save({ fields: await this.mapper.inputToRecord() });
      }
    },
    handlePreview: () => {
      if ((this.canShow = !this.canShow)) {
        this.mapper.recordToInput();
      }
    }
  };

  getApexError(error, defaultMessage) {
    if (typeof error === "string") {
      return error;
    }
    if (!error.body) {
      return defaultMessage;
    }
    if (Array.isArray(error.body)) {
      return error.body.map((e) => e.message).join(", ");
    }
    if (typeof error.body.message === "string") {
      return error.body.message;
    }
    return defaultMessage;
  }
}
