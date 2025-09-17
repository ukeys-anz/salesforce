import { LightningElement, api, track, wire } from "lwc";
import { getRelatedListRecords } from "lightning/uiRelatedListApi";
import { getFieldValue } from "lightning/uiRecordApi";

// ReKYC Documents Custom Fields
import ADDRESS_VALID from "@salesforce/schema/ReKYC_Document_Detail__c.Trustme_Fraud_Address_Valid__c";
import KYC_INFO from "@salesforce/schema/ReKYC_Document_Detail__c.Trustme_Fraud_Customer_Details__c";
import PHOTO_MODIFIED from "@salesforce/schema/ReKYC_Document_Detail__c.Trustme_Fraud_Customer_Photo_Modified__c";
import FRAUD_LEGIBLE from "@salesforce/schema/ReKYC_Document_Detail__c.Trustme_Fraud_ID_Legible__c";
import PIC_OF_PIC from "@salesforce/schema/ReKYC_Document_Detail__c.Trustme_Fraud_ID_Not_Picture__c";
import MIDDLE_NAME from "@salesforce/schema/ReKYC_Document_Detail__c.Trustme_Fraud_MiddleNameCheck__c";
import SEC_FEATURE from "@salesforce/schema/ReKYC_Document_Detail__c.Trustme_Fraud_Security_Features__c";
import SELFIE_COMPARE from "@salesforce/schema/ReKYC_Document_Detail__c.Trustme_Fraud_Selfie_Comparison_Match__c";

const FIELDS = [
  "ReKYC_Document_Detail__c.Trustme_Fraud_Address_Valid__c",
  "ReKYC_Document_Detail__c.Trustme_Fraud_Customer_Details__c",
  "ReKYC_Document_Detail__c.Trustme_Fraud_Customer_Photo_Modified__c",
  "ReKYC_Document_Detail__c.Trustme_Fraud_ID_Legible__c",
  "ReKYC_Document_Detail__c.Trustme_Fraud_ID_Not_Picture__c",
  "ReKYC_Document_Detail__c.Trustme_Fraud_MiddleNameCheck__c",
  "ReKYC_Document_Detail__c.Trustme_Fraud_Security_Features__c",
  "ReKYC_Document_Detail__c.Trustme_Fraud_Selfie_Comparison_Match__c"
];

const TRUSTME_QA_CHECK = {
  Trustme_Fraud_Customer_Details__c: "KYC Information & ID Document Type Check",
  Trustme_Fraud_MiddleNameCheck__c: "Middle Name Check",
  Trustme_Fraud_Selfie_Comparison_Match__c: "Selfie Comparison Check",
  Trustme_Fraud_Address_Valid__c: "Residential Address - Validity Check",
  Trustme_Fraud_ID_Legible__c: "Customer Photo on ID Legibility Check",
  Trustme_Fraud_Customer_Photo_Modified__c:
    "Customer Photo on ID Modification Check",
  Trustme_Fraud_ID_Not_Picture__c: "Picture of a Picture of ID Check",
  Trustme_Fraud_Security_Features__c: "ID Document Security Features Check"
};

export default class ReKYCCAseTrustmeQACheckSection extends LightningElement {
  @api recordId;
  @track reKYCDocDetails;
  trustmeQAAttribute;
  activeSections = ["trustmeQAAttribute"];

  @wire(getRelatedListRecords, {
    parentRecordId: "$recordId",
    relatedListId: "ReKYC_Document_Details__r",
    fields: FIELDS
  })
  async wiredReKYCDetails({ data, error }) {
    if (data) {
      this.reKYCDetails = data.records[0];
      this.mergeData();
      this.buildData();
    } else if (error) {
      this.toast.error("Error loading ReKYC Documents details", error);
    }
  }

  mergeData() {
    if (this.reKYCDetails) {
      this.reKYCDocDetails = {
        Trustme_Fraud_Address_Valid__c: getFieldValue(
          this.reKYCDetails,
          ADDRESS_VALID
        ),
        Trustme_Fraud_Customer_Details__c: getFieldValue(
          this.reKYCDetails,
          KYC_INFO
        ),
        Trustme_Fraud_Customer_Photo_Modified__c: getFieldValue(
          this.reKYCDetails,
          PHOTO_MODIFIED
        ),
        Trustme_Fraud_ID_Legible__c: getFieldValue(
          this.reKYCDetails,
          FRAUD_LEGIBLE
        ),
        Trustme_Fraud_ID_Not_Picture__c: getFieldValue(
          this.reKYCDetails,
          PIC_OF_PIC
        ),
        Trustme_Fraud_MiddleNameCheck__c: getFieldValue(
          this.reKYCDetails,
          MIDDLE_NAME
        ),
        Trustme_Fraud_Security_Features__c: getFieldValue(
          this.reKYCDetails,
          SEC_FEATURE
        ),
        Trustme_Fraud_Selfie_Comparison_Match__c: getFieldValue(
          this.reKYCDetails,
          SELFIE_COMPARE
        )
      };
    }
  }

  buildData() {
    if (!this.reKYCDocDetails) {
      return;
    }

    this.trustmeQAAttribute = this.transformResponse(
      TRUSTME_QA_CHECK,
      this.reKYCDocDetails
    );
  }

  transformResponse(section, recordDetails) {
    if (!recordDetails) {
      return null;
    }
    return Object.entries(section)
      .filter(([key]) => recordDetails[key] === "No")
      .map(([key, value]) => ({
        label: value,
        fieldName: recordDetails[key]
      }));
  }
}
