import { LightningElement, wire } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";

const FIELDS = [
  "Interaction.LastModifiedDate",
  "Interaction.LastModifiedBy.Name"
];

export default class CustomNextButtonOmni extends OmniscriptBaseMixin(
  LightningElement
) {
  onLoadLastModifiedDate;
  latestLastModifiedDate;
  lastModifiedBy;
  uiRecordId;
  boolWireCall = false;
  showLockRecordError = false;
  boolShowError = false;
  errorFromValidation = {};

  /**
   * Get the recordId from the Omniscript loaded
   */
  connectedCallback() {
    this.uiRecordId = this.omniJsonData.recordId;
  }

  /**
   * Get the last modified details of the interaction record.
   * @description This wire method basically compare the lastmodified date on load and the lastmodified date changed during the edit session.
   */
  @wire(getRecord, {
    recordId: "$uiRecordId",
    fields: FIELDS,
    refresh: "$boolWireCall"
  })
  wireRecord({ data, error }) {
    if (data) {
      if (!this.boolWireCall) {
        if (!this.onLoadLastModifiedDate && !this.lastModifiedBy) {
          this.onLoadLastModifiedDate = data.fields.LastModifiedDate.value;
          this.lastModifiedBy =
            data.fields.LastModifiedBy.value.fields.Name.value;
        }
      } else {
        this.latestLastModifiedDate = data.fields.LastModifiedDate.value;
        this.lastModifiedBy =
          data.fields.LastModifiedBy.value.fields.Name.value;
        if (this.onLoadLastModifiedDate !== this.latestLastModifiedDate) {
          this.showLockRecordError = true;
        }
        // Update the parent JSON by calling omniApplyCallResp
        if (!this.showLockRecordError) {
          if (this.boolShowError) {
            this.boolWireCall = false;
            this.omniApplyCallResp(this.errorFromValidation);
          } else {
            this.omniApplyCallResp(this.errorFromValidation);
            this.omniNextStep();
          }
        }
      }
    } else {
      console.error(
        "Error in Fetching Interaction LastModified Details -> " +
          JSON.stringify(error)
      );
    }
  }

  saveData(event) {
    if (event) {
      if (this.omniJsonData) {
        let reasonForVisits = this.omniJsonData.basenode;
        let actualTopics = this.omniJsonData.basenodeForReasonForCV;
        let products = this.omniJsonData.productbasenode;
        let recordTypeName = this.omniJsonData.RecordTypeName;
        this.boolShowError = false;
        this.errorFromValidation.reasonforvisiterror = false;

        //Filter only values if the selected is makrked as true
        reasonForVisits = reasonForVisits.filter(
          (item) => item.selected === true
        );
        actualTopics = actualTopics.filter((item) => item.selected === true);
        products = products.filter((item) => item.selected === true);

        //Here we add error to omniscript parent JSON if any of the three fields is having any error
        if (
          (reasonForVisits.length === 0 || reasonForVisits.length > 5) &&
          recordTypeName === "In Person"
        ) {
          this.errorFromValidation.reasonforvisiterror = true;
          this.boolShowError = true;
        }
        this.errorFromValidation.topicerror = false;
        if (
          (actualTopics.length === 0 || actualTopics.length > 5) &&
          recordTypeName !== "Message"
        ) {
          this.errorFromValidation.topicerror = true;
          this.boolShowError = true;
        }
        this.errorFromValidation.producterror = false;
        if (products.length === 0 || products.length > 5) {
          this.errorFromValidation.producterror = true;
          this.boolShowError = true;
        }

        if (!this.uiRecordId) {
          if (this.boolShowError) {
            this.omniApplyCallResp(this.errorFromValidation);
          } else {
            this.omniApplyCallResp(this.errorFromValidation);
            this.omniNextStep();
          }
        }
        this.boolWireCall = true;
      }
    }
  }
}
