import { LightningElement, api } from "lwc";
import customerContactDetails from "@salesforce/apex/VerifiedContactDetails.customerContactDetails";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { recordsPrepration } from "./helper/helper-record-factory";

export default class VerifiedContactDetails extends LightningElement {
  relatedListTitle = "Verified Contact Details";
  iconName = "standard:contact";
  @api recordId;
  plainRecords;
  records;
  showRelatedList = false;

  connectedCallback() {
    this.showRelatedList = false;
    customerContactDetails({
      recordId: this.recordId,
      phoneUsageType: "Security Mobile",
      emailUsageType: "Security Email"
    })
      .then((result) => {
        this.plainRecords = result;
        this.records = recordsPrepration(this.plainRecords);
        if (this.records.length) {
          this.showRelatedList = true;
        }
      })
      .catch((error) => {
        this.showToast("Error on Finding Verified Contact Detail", error.body);
        console.error(JSON.stringify(error));
      });
  }

  showToast(theTitle, theMessage) {
    const event = new ShowToastEvent({
      title: theTitle,
      message: theMessage,
      variant: "error"
    });
    this.dispatchEvent(event);
  }
}
