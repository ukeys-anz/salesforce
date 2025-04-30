import { LightningElement, api } from "lwc";
import { FlowNavigationNextEvent } from "lightning/flowSupport";

export default class ContactPointFlowFooter extends LightningElement {
  stopFlow;
  @api
  get terminate() {
    return this.stopFlow;
  }
  handleButtonClick(event) {
    let actionClicked = event.target.name;

    if (actionClicked === "Cancel") {
      this.stopFlow = true;
    }
    try {
      this.dispatchEvent(new FlowNavigationNextEvent());
    } catch (ex) {
      console.log("Exception: " + ex);
    }
  }
}
