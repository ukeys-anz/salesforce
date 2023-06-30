import { LightningElement } from "lwc";
import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";

export default class CustomNextButtonOmni extends OmniscriptBaseMixin(
  LightningElement
) {
  saveData(event) {
    if (event) {
      if (this.omniJsonData) {
        let reasonForVisits = this.omniJsonData.basenode;
        let actualTopics = this.omniJsonData.basenodeForReasonForCV;
        let products = this.omniJsonData.productbasenode;
        let recordTypeName = this.omniJsonData.RecordTypeName;
        let boolShowError = false;
        let errorFromValidation = {};
        errorFromValidation.reasonforvisiterror = false;

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
          errorFromValidation.reasonforvisiterror = true;
          boolShowError = true;
        }
        errorFromValidation.topicerror = false;
        if (actualTopics.length === 0 || actualTopics.length > 5) {
          errorFromValidation.topicerror = true;
          boolShowError = true;
        }
        errorFromValidation.producterror = false;
        if (products.length === 0 || products.length > 5) {
          errorFromValidation.producterror = true;
          boolShowError = true;
        }

        // Update the parent JSON by calling omniApplyCallResp
        if (boolShowError) {
          this.omniApplyCallResp(errorFromValidation);
        } else {
          this.omniApplyCallResp(errorFromValidation);
          this.omniNextStep();
        }
      }
    }
  }
}
