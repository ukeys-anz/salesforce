import { LightningElement, api } from "lwc";
import sopEditSpending from "c/sopEditSpending";

export default class SopSpendingsAddressItem extends LightningElement {
  @api addressItem;
  @api hasAddEditPermission;
  @api recordId;
  @api sop;

  isCollapsed = true;

  toggleAddressL3() {
    this.isCollapsed = !this.isCollapsed;
  }

  handleClick() {
    sopEditSpending.open({
      size: "medium",
      content: JSON.stringify(this.addressItem),
      recordId: this.recordId,
      sop: this.sop
    });
  }
}
