import { LightningElement, api } from "lwc";
import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";
export default class resolutionPathwayCustomButtons extends OmniscriptBaseMixin(
  LightningElement
) {
  @api isLastState;
  @api isFeedbackState;
  get nextStepLabel() {
    if (this.isLastState) {
      return "Finish";
    } else if (this.isFeedbackState) {
      return "Submit Responses";
    }
    return "Next";
  }
  get showStartMenu() {
    return this.isFeedbackState ? false : true;
  }
  handleNext() {
    this.omniNextStep();
  }
  handlePrevious() {
    this.omniPrevStep();
  }
  handleStartMenu() {
    this.resetDefault();
    this.omniNavigateTo(1);
  }
  resetDefault() {
    let masterData = this.omniJsonData;
    let data = {};
    let keys = Object.keys(masterData);
    for (let i = 0; i < keys.length; i++) {
      let key = keys[i];
      if (key.startsWith("Call")) {
        data[key] = false;
      }
    }
    this.omniApplyCallResp(data);
  }
}
