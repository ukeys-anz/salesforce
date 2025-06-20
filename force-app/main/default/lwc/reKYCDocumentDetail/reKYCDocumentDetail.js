import { LightningElement, api, track, wire } from "lwc";
import { getFieldValue, getRecord } from "lightning/uiRecordApi";
import trustMeErrorMessage from "@salesforce/label/c.TrustMeDocumentSecErrorMessage";
import detokenize from "@salesforce/apex/VaultController.detokenizeDocumentNumber";
import { SimpleToast } from "c/utils";
import { getRelatedListRecords } from "lightning/uiRelatedListApi";

// ReKYC Documents Custom Fields
import CUSTOMER_UUID from "@salesforce/schema/ReKYC_Document_Detail__c.Customer_UUID__c";
import DAON_EVALUATION_OUTCOME from "@salesforce/schema/ReKYC_Document_Detail__c.Daon_Evaluation_Outcome__c";
import DATE_OF_BIRTH from "@salesforce/schema/ReKYC_Document_Detail__c.Date_Of_Birth__c";
import EIDV_VERIFICATION_OUTCOME from "@salesforce/schema/ReKYC_Document_Detail__c.eIDV_Verification_Outcome__c";
import EVALUATION_DATE from "@salesforce/schema/ReKYC_Document_Detail__c.Evaluation_Date__c";
import EVALUATION_OUTCOME from "@salesforce/schema/ReKYC_Document_Detail__c.Evaluation_Outcome__c";
import EXISTING_SELFIE from "@salesforce/schema/ReKYC_Document_Detail__c.Existing_Selfie__c";
import MANUAL_VERIFICATION_OUTCOME from "@salesforce/schema/ReKYC_Document_Detail__c.Manual_Verification_Outcome__c";
import QAS from "@salesforce/schema/ReKYC_Document_Detail__c.QAS__c";
import RESIDENTIAL_ADDRESS from "@salesforce/schema/ReKYC_Document_Detail__c.Residential_Address__c";
import SELFIE_VERIFICATION_OUTCOME from "@salesforce/schema/ReKYC_Document_Detail__c.Selfie_Verification_Outcome__c";
import TRUSTME_FIRST_NAME from "@salesforce/schema/ReKYC_Document_Detail__c.TrustMe_First_Name__c";
import TRUSTME_MIDDLE_NAME from "@salesforce/schema/ReKYC_Document_Detail__c.TrustMe_Middle_Name__c";
import TRUSTME_LAST_NAME from "@salesforce/schema/ReKYC_Document_Detail__c.TrustMe_Last_Name__c";
import TRUSTME_RESIDENTIAL_ADDRESS from "@salesforce/schema/ReKYC_Document_Detail__c.TrustMe_Residential_Address__c";
import TRUSTME_SELFIE_REFERENCE from "@salesforce/schema/ReKYC_Document_Detail__c.TrustMe_Selfie_Reference__c";
import TRUSTME_PRIMARY_DOC_ID from "@salesforce/schema/ReKYC_Document_Detail__c.TrustMe_Primary_Document_ID__c";
import TRUSTME_SECONDARY_DOC_ID from "@salesforce/schema/ReKYC_Document_Detail__c.TrustMe_Secondary_Document_ID__c";
import TRUSTME_SECONDARY_DOC from "@salesforce/schema/ReKYC_Document_Detail__c.Secondary_Documents__c";
import TRUSTME_PRIMARY_DOC from "@salesforce/schema/ReKYC_Document_Detail__c.Primary_Documents__c";
import DAON_SELFIE_MATCH_ID from "@salesforce/schema/ReKYC_Document_Detail__c.Daon_Selfie_Match_ID__c";
// Case Fields
import FIELD_DAON_CHECK_ID from "@salesforce/schema/Case.Daon_Check_Id__c";
import FIELD_DAON_USER_ID from "@salesforce/schema/Case.Daon_User_Id__c";
import OCV_ID_FIELD from "@salesforce/schema/Case.OCV_Id__c";

import {
  buildTrustMeCustAttribute,
  buildTrustMeSelfieAndPrimDoc,
  buildTrustMeAdditionalContext,
  transformResponseForAddress,
  FILES_BY_DOCUMENTTYPE,
  DOCUMENTYPE
} from "./reKYCDocumentDetailsHelper";

const FIELDS = [
  "ReKYC_Document_Detail__c.Customer_UUID__c",
  "ReKYC_Document_Detail__c.Daon_Evaluation_Outcome__c",
  "ReKYC_Document_Detail__c.Daon_Selfie_Match_ID__c",
  "ReKYC_Document_Detail__c.Date_Of_Birth__c",
  "ReKYC_Document_Detail__c.eIDV_Verification_Outcome__c",
  "ReKYC_Document_Detail__c.Evaluation_Date__c",
  "ReKYC_Document_Detail__c.Evaluation_Outcome__c",
  "ReKYC_Document_Detail__c.Existing_Selfie__c",
  "ReKYC_Document_Detail__c.Manual_Verification_Outcome__c",
  "ReKYC_Document_Detail__c.Name",
  "ReKYC_Document_Detail__c.QAS__c",
  "ReKYC_Document_Detail__c.Residential_Address__c",
  "ReKYC_Document_Detail__c.Residential_Address_Geolocation__Latitude__s",
  "ReKYC_Document_Detail__c.Residential_Address_Geolocation__Longitude__s",
  "ReKYC_Document_Detail__c.Selfie_Verification_Outcome__c",
  "ReKYC_Document_Detail__c.TrustMe_First_Name__c",
  "ReKYC_Document_Detail__c.TrustMe_Middle_Name__c",
  "ReKYC_Document_Detail__c.TrustMe_Last_Name__c",
  "ReKYC_Document_Detail__c.TrustMe_Residential_Address__c",
  "ReKYC_Document_Detail__c.TrustMe_Residential_Address_Geolocation__Latitude__s",
  "ReKYC_Document_Detail__c.TrustMe_Residential_Address_Geolocation__Longitude__s",
  "ReKYC_Document_Detail__c.TrustMe_Selfie_Reference__c",
  "ReKYC_Document_Detail__c.TrustMe_Primary_Document_ID__c",
  "ReKYC_Document_Detail__c.TrustMe_Secondary_Document_ID__c",
  "ReKYC_Document_Detail__c.Secondary_Documents__c",
  "ReKYC_Document_Detail__c.Primary_Documents__c"
];

const CASE_FIELDS = [
  "Case.Daon_Check_Id__c",
  "Case.Daon_User_Id__c",
  "Case.OCV_Id__c"
];

export default class ReKYCDocumentDetail extends LightningElement {
  @api recordId;
  showSpinner = false;
  showError = false;
  trustMeDocSecErrorMessage = trustMeErrorMessage;
  reKYCDetails;
  caseRec;
  data;
  trustmeCustAttribute;
  trustMeSelfieAndPrimaryIdDoc;
  additionalCustContext;
  addressDetails;
  @track reKYCDocDetails;
  activeSections = [
    "trustMeSelfieAndPrimaryIdDoc",
    "additionalCustContext",
    "addressDetails",
    "trustMeCustAttribute"
  ];
  toast = new SimpleToast(this);

  @wire(getRecord, { recordId: "$recordId", fields: CASE_FIELDS })
  wiredCase({ data, error }) {
    if (data) {
      this.caseRec = data;
    } else if (error) {
      this.error = error;
    }
  }

  @wire(getRelatedListRecords, {
    parentRecordId: "$recordId",
    relatedListId: "ReKYC_Document_Details__r",
    fields: FIELDS
  })
  async wiredReKYCDetails({ data, error }) {
    if (data) {
      this.reKYCDetails = data.records[0];
      this.mergeData();
      if (this.reKYCDocDetails.TrustMe_Primary_Document_ID__c) {
        await this.getDetokenizedValue();
      }
      this.getDocumentsDetails();
    } else if (error) {
      this.toast.error("Error loading ReKYC Documents details", error);
    }
  }

  mergeData() {
    if (this.caseRec && this.reKYCDetails) {
      this.reKYCDocDetails = {
        Customer_UUID__c: getFieldValue(this.reKYCDetails, CUSTOMER_UUID),
        Daon_Evaluation_Outcome__c: getFieldValue(
          this.reKYCDetails,
          DAON_EVALUATION_OUTCOME
        ),
        Daon_Selfie_Match_ID__c: getFieldValue(
          this.reKYCDetails,
          DAON_SELFIE_MATCH_ID
        ),
        Date_Of_Birth__c: getFieldValue(this.reKYCDetails, DATE_OF_BIRTH),
        eIDV_Verification_Outcome__c: getFieldValue(
          this.reKYCDetails,
          EIDV_VERIFICATION_OUTCOME
        ),
        Evaluation_Date__c: getFieldValue(this.reKYCDetails, EVALUATION_DATE),
        Evaluation_Outcome__c: getFieldValue(
          this.reKYCDetails,
          EVALUATION_OUTCOME
        ),
        Existing_Selfie__c: getFieldValue(this.reKYCDetails, EXISTING_SELFIE),
        Manual_Verification_Outcome__c: getFieldValue(
          this.reKYCDetails,
          MANUAL_VERIFICATION_OUTCOME
        ),
        QAS__c: getFieldValue(this.reKYCDetails, QAS),
        Residential_Address__c: getFieldValue(
          this.reKYCDetails,
          RESIDENTIAL_ADDRESS
        ),
        Residential_Address_Geolocation__Latitude__s:
          this.reKYCDetails?.fields
            ?.Residential_Address_Geolocation__Latitude__s?.value,
        Residential_Address_Geolocation__Longitude__s:
          this.reKYCDetails?.fields
            ?.Residential_Address_Geolocation__Longitude__s?.value,

        Selfie_Verification_Outcome__c: getFieldValue(
          this.reKYCDetails,
          SELFIE_VERIFICATION_OUTCOME
        ),
        TrustMe_First_Name__c: getFieldValue(
          this.reKYCDetails,
          TRUSTME_FIRST_NAME
        ),
        TrustMe_Middle_Name__c: getFieldValue(
          this.reKYCDetails,
          TRUSTME_MIDDLE_NAME
        ),
        TrustMe_Last_Name__c: getFieldValue(
          this.reKYCDetails,
          TRUSTME_LAST_NAME
        ),
        TrustMe_Residential_Address__c: getFieldValue(
          this.reKYCDetails,
          TRUSTME_RESIDENTIAL_ADDRESS
        ),
        TrustMe_Residential_Address_Geolocation__Latitude__s:
          this.reKYCDetails?.fields
            ?.TrustMe_Residential_Address_Geolocation__Latitude__s?.value,

        TrustMe_Residential_Address_Geolocation__Longitude__s:
          this.reKYCDetails?.fields
            ?.TrustMe_Residential_Address_Geolocation__Longitude__s?.value,

        TrustMe_Selfie_Reference__c: getFieldValue(
          this.reKYCDetails,
          TRUSTME_SELFIE_REFERENCE
        ),
        TrustMe_Primary_Document_ID__c: getFieldValue(
          this.reKYCDetails,
          TRUSTME_PRIMARY_DOC_ID
        ),
        TrustMe_Secondary_Document_ID__c: getFieldValue(
          this.reKYCDetails,
          TRUSTME_SECONDARY_DOC_ID
        ),
        Secondary_Documents__c: JSON.parse(
          getFieldValue(this.reKYCDetails, TRUSTME_SECONDARY_DOC)
        ),
        Primary_Documents__c: JSON.parse(
          getFieldValue(this.reKYCDetails, TRUSTME_PRIMARY_DOC)
        ),
        OCV_Id__c: getFieldValue(this.caseRec, OCV_ID_FIELD),
        Daon_User_Id__c: getFieldValue(this.caseRec, FIELD_DAON_USER_ID),
        Daon_Check_Id__c: getFieldValue(this.caseRec, FIELD_DAON_CHECK_ID)
      };
    }
  }

  async getDetokenizedValue() {
    try {
      const primaryDocs = this.reKYCDocDetails.TrustMe_Primary_Document_ID__c;
      const primaryDetokenizedValue = await this.service.detokenize(
        primaryDocs,
        DOCUMENTYPE[this.reKYCDocDetails.Primary_Documents__c[0].type]
      );
      this.reKYCDocDetails.TrustMe_Primary_Document_ID__c =
        primaryDetokenizedValue;

      const secondaryDocs =
        this.reKYCDocDetails?.TrustMe_Secondary_Document_ID__c;
      if (!secondaryDocs) {
        const secondaryDetokenizedValue = await service.detokenize(
          secondaryDocs,
          DOCUMENTYPE[this.reKYCDocDetails.Secondary_Documents__c[0].type]
        );
        this.reKYCDocDetails.TrustMe_Secondary_Document_ID__c =
          secondaryDetokenizedValue;
      }
    } catch (error) {
      this.toast.error("Error detokenising the document identifiers");
    }
  }

  getDocumentsDetails() {
    if (!this.reKYCDocDetails) {
      return;
    }
    this.trustmeCustAttribute = buildTrustMeCustAttribute(this.reKYCDocDetails);
    this.trustMeSelfieAndPrimaryIdDoc = buildTrustMeSelfieAndPrimDoc(
      this.reKYCDocDetails
    );
    this.additionalCustContext = buildTrustMeAdditionalContext(
      this.reKYCDocDetails
    );
    this.addressDetails = transformResponseForAddress(this.reKYCDocDetails);
  }

  service = {
    detokenize: async (documentId, documentType) => {
      if (!documentId) {
        return new Promise((resolve) => resolve(""));
      }
      return detokenize({
        documentId,
        documentType,
        ...this.customerToken
      });
    }
  };

  get primaryLayout() {
    if (!this.reKYCDocDetails?.Primary_Documents__c) {
      return null;
    }
    const documents = this.reKYCDocDetails?.Primary_Documents__c;

    if (!documents || !Array.isArray(documents)) {
      return null;
    }
    return [
      {
        title: "Primary Document",
        size: 4,
        files: FILES_BY_DOCUMENTTYPE[documents[0].type]
      }
    ];
  }

  get primarymetadata() {
    if (!this.reKYCDocDetails?.Primary_Documents__c) {
      return null;
    }

    return {
      idxDocumentId:
        this.reKYCDocDetails?.Primary_Documents__c[0].idx_document_id,
      idxIdCheckId: this.reKYCDocDetails?.Daon_Check_Id__c,
      idxUserId: this.reKYCDocDetails?.Daon_User_Id__c,
      relatedRecordId: this.recordId,
      ...this.customerToken
    };
  }

  get secondaryLayout() {
    if (!this.reKYCDocDetails?.Secondary_Documents__c) {
      return null;
    }
    const documents = this.reKYCDocDetails?.Secondary_Documents__c;

    if (!documents || !Array.isArray(documents)) {
      return null;
    }
    return [
      {
        title: "Secondary Document",
        size: 4,
        files: FILES_BY_DOCUMENTTYPE[documents[0].type]
      }
    ];
  }

  get secondarymetadata() {
    if (!this.reKYCDocDetails?.Secondary_Documents__c) {
      return null;
    }
    return {
      idxDocumentId:
        this.reKYCDocDetails?.Secondary_Documents__c[0].idx_document_id,
      idxIdCheckId: this.reKYCDocDetails?.Daon_Check_Id__c,
      idxUserId: this.reKYCDocDetails?.Daon_User_Id__c,
      relatedRecordId: this.recordId,
      ...this.customerToken
    };
  }

  get customerToken() {
    return {
      customerId: this.reKYCDocDetails?.OCV_Id__c,
      customerIdType: "OCVID"
    };
  }
}
