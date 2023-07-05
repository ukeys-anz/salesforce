import { LightningElement, track } from "lwc";
import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";

export default class closeCase extends OmniscriptBaseMixin(LightningElement) {
  @track showLWC = false;
  @track showOmni = false;

  connectedCallback() {
    const params = {
      input: {},
      sClassName: "Vlocity_Utils",
      sMethodName: "getDisableOmni",
      options: {}
    };
    this.omniRemoteCall(params, true).then((res) => {
      if (res.result.disableOmni) {
        this.showLWC = true; //if custom setting for disable omni is true, lwc will be displayed
      } else {
        this.showOmni = true;
      }
    });
  }
}
