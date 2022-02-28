import { LightningElement, api } from "lwc";

import hasAccountsGoalsPermission from "@salesforce/customPermission/ANZx_Accounts_and_Goals";

export default class TotalBalance extends LightningElement {
  @api recordId;
  //Total balance/saved received through personAccountFinancialDetails LWC
  @api totalBalance;
  @api totalSaved;
  showInfoModal = false;
  totalFinPositionClicked;
  @api error;

  get displayContent() {
    return hasAccountsGoalsPermission;
  }

  handleInfoModal(event) {
    this.totalFinPositionClicked =
      event.target.dataset.id === "total-fin-position" ? true : false;
    this.showInfoModal = !this.showInfoModal;
  }
}
