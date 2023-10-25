import { LightningElement, api } from "lwc";
export default class CustomerCommRecordsDashboard extends LightningElement {
  @api originalVizUrl;
  @api vizUrl = this.originalVizUrl;
}
