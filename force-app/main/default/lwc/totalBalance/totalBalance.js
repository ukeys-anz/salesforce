import { LightningElement, api, wire } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import hasAccountsGoalsPermission from "@salesforce/customPermission/ANZx_Accounts_and_Goals";
import getFinancialTotalBalance from "@salesforce/apex/TotalBalanceController.getTotalBalance";
import getFinancialTotalSaved from "@salesforce/apex/TotalBalanceController.getTotalSaved";
import getFinancialAccountFabric from "@salesforce/apex/FinancialAccountController.getFinancialAccountFabric";
import { handleErrorShowToast } from "c/utils";
import ACCOUNT_OCV_ID_FIELD from "@salesforce/schema/Account.OCV_ID__c";

export default class TotalBalance extends LightningElement {
  @api recordId;
  @api isFinancesTab;
  @api isWhatsHappeningTab;
  totalBalance;
  totalSaved;
  totalBalanceError;
  loading;
  showInfoModal = false;
  totalFinPositionClicked;
  totalSavedColumn =
    "slds-col slds-size_1-of-1 slds-large-size_1-of-2 slds-var-p-around_small";
  totalSavedAlignment = "header-column slds-float_right";

  @wire(getRecord, {
    recordId: "$recordId",
    fields: [ACCOUNT_OCV_ID_FIELD]
  })
  async wiredRecord({ data }) {
    if (data) {
      if (this.isWhatsHappeningTab) {
        this.fetchDataFromFabric(data.fields.OCV_ID__c.value);
      }
    }
  }

  get displayContent() {
    return hasAccountsGoalsPermission;
  }

  connectedCallback() {
    this.loading = true;
    window.addEventListener(
      "refreshFinances_" + this.recordId,
      this.handleRefreshFinances.bind(this)
    );
  }

  async fetchDataFromFabric(ocvIdFromAccount) {
    this.loading = true;
    try {
      await getFinancialAccountFabric({
        ocvId: ocvIdFromAccount,
        accountNumbers: []
      });
    } catch (error) {
      handleErrorShowToast(
        this,
        "Failed To Retrieve Account Details",
        error,
        "Failed to retrieve latest account details. Please refresh and try again. If issue persists please contact your System Administrator",
        "pester"
      );
    } finally {
      await this.fetchFinancialDataFromDB();
    }
  }

  async handleRefreshFinances(event) {
    this.loading = true;
    if (event?.detail === "FetchBalance") {
      await this.fetchFinancialDataFromDB();
    }
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

  closeModal() {
    this.showInfoModal = false;
  }
}
