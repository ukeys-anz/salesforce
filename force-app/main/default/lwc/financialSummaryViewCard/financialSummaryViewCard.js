import { api, LightningElement } from "lwc";

export default class financialSummaryViewCard extends LightningElement {
  @api headerName;
  @api headerValue;
  @api showOtherValue;
  @api headerOtherValue;
}
