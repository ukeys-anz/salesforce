import { LightningElement, api } from "lwc";

export default class RealFormIdBtn extends LightningElement {
  @api recordId;
  get prefill() {
    let pf = { ContextId: this.recordId, otherParam: undefined };
    console.log(JSON.stringify(pf));
    return pf;
  }
}
