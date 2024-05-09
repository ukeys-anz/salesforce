import { LightningElement, api } from "lwc";
import hasAccountsGoalsPermission from "@salesforce/customPermission/ANZx_Accounts_and_Goals";

export default class RefreshFinances extends LightningElement {
  @api recordId;

  get displayContent() {
    return hasAccountsGoalsPermission;
  }

  refreshData(event) {
    event.preventDefault();
    window.dispatchEvent(
      new CustomEvent("refreshFinances_" + this.recordId, {})
    );
  }
}
