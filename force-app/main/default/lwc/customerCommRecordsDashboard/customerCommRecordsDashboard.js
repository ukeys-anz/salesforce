import { LightningElement, api } from "lwc";
export default class CustomerCommRecordsDashboard extends LightningElement {
  originalVizUrl;
  @api
  get vizUrl() {
    return this.originalVizUrl;
  }

  set vizUrl(val) {
    this.originalVizUrl = val;
  }
}
