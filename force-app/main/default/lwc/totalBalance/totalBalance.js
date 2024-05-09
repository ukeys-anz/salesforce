import { LightningElement, api } from "lwc";
import hasAccountsGoalsPermission from "@salesforce/customPermission/ANZx_Accounts_and_Goals";
import getFinancialTotalBalance from "@salesforce/apex/TotalBalanceController.getTotalBalance";
import getFinancialTotalSaved from "@salesforce/apex/TotalBalanceController.getTotalSaved";
import { handleErrorShowToast } from "c/utils";

export default class TotalBalance extends LightningElement {
  @api recordId;
  @api isFinancesTab;
  totalBalance;
  totalSaved;
  totalBalanceError;
  loading;
  showInfoModal = false;
  totalFinPositionClicked;
  totalSavedColumn =
    "slds-col slds-size_1-of-1 slds-large-size_1-of-2 slds-var-p-around_small";
  totalSavedAlignment = "header-column slds-float_right";

  get displayContent() {
    return hasAccountsGoalsPermission;
  }

  connectedCallback() {
    this.loading = true;
    if (!this.totalBalance) {
      this.fetchFinancialDataFromDB();
    }
    window.addEventListener(
      "refreshFinances_" + this.recordId,
      this.handleRefreshFinances.bind(this)
    );
  }

  async handleRefreshFinances() {
    this.loading = true;
    await this.fetchFinancialDataFromDB();
  }

  async fetchFinancialDataFromDB() {
    try {
      let { totalBalance } = await getFinancialTotalBalance({
        ownerId: this.recordId
      });
      this.totalBalance = totalBalance ? totalBalance : 0;
      let { totalSaved } = await getFinancialTotalSaved({
        ownerId: this.recordId
      });
      this.totalSaved = totalSaved ? totalSaved : 0;

      if (this.isFinancesTab) {
        this.totalSavedColumn =
          "slds-col slds-size_1-of-1 slds-large-size_2-of-12 slds-var-p-around_small";
        this.totalSavedAlignment = "header-column slds-float_left";
      }
    } catch (error) {
      this.totalBalanceError =
        "Failed to retrieve total balance details. Please refresh and try again. If issue persists please contact your System Administrator";
      handleErrorShowToast(
        this,
        "Failed To Retrieve Total Balance Details",
        error,
        this.totalBalanceError,
        "pester"
      );
    }
    this.loading = false;
  }

  disconnectedCallback() {
    window.removeEventListener(
      "refreshFinances_" + this.recordId,
      this.handleRefreshFinances.bind(this)
    );
  }

  handleInfoModal(event) {
    this.totalFinPositionClicked =
      event.target.dataset.id === "total-fin-position" ? true : false;
    this.showInfoModal = !this.showInfoModal;
  }
}
