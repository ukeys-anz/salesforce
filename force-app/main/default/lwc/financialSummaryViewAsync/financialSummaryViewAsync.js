import { LightningElement, api } from "lwc";
import getSummariesByResponseId from "@salesforce/apex/CCRMFinancialSummaryController.getSummariesByResponseId";
import getDataFromCallout from "@salesforce/apex/CCRMFinancialSummaryController.getDataFromCallout";
import insertDataInCache from "@salesforce/apex/CCRMFinancialSummaryController.insertDataInCache";
import { subscribe, unsubscribe } from "lightning/empApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class financialSummaryViewAsync extends LightningElement {
  @api recordId;
  @api channelName = "/event/Financial_Summary_Calculation__e";
  financialSummaryData;
  totalCustBalance;
  totalTerminal;
  totalAssetBalance;
  lastSummaryCalculated = "";
  showSpinner = false;
  subscription = {};
  countTotalBalance = 0;
  countNoOfTerminals = 0;
  countTotalAssetBalance = 0;
  callTotalCustBalanceApi = true;
  callTerminalApi = true;
  callAssetFinanceBalanceApi = true;
  showTotalBalCalculationProgress = false;
  showTerminalCalculationProgress = false;
  showAssetCalculationProgress = false;
  showTotalBalValue = false;
  showTerminalValue = false;
  showAssetValue = false;
  isDisableRefresh = false;
  platformEventList = [];
  errorResponse;
  updatedResponse;
  showNoTotalBalance = false;
  showNoTerminal = false;
  showNoAssetBalance = false;
  financialSummariesCallout;

  async connectedCallback() {
    this.handleSubscribe();
    this.showSpinner = true;

    this.populateFinancialSummaryCallout();

    try {
      let resultSummaries = await getSummariesByResponseId({
        finSumCallout: this.financialSummariesCallout
      });
      this.showSpinner = false;
      this.financialSummaryData = resultSummaries;
      this.showTotalBalCalculationProgress = true;
      this.showTerminalCalculationProgress = true;
      this.showAssetCalculationProgress = true;
    } catch (error) {
      this.errorResponse = error.body.message;
      this.showSpinner = false;
      this.handleError();
    }

    if (this.financialSummaryData.cacheAck === "Data found in cache") {
      if (this.financialSummaryData.totalBalance !== undefined) {
        this.showTotalBalValue = true;
        this.showTotalBalCalculationProgress = false;
        this.showNoTotalBalance = false;
        this.totalCustBalance = this.financialSummaryData.totalBalance;
        this.countTotalBalance++;
      }
      if (
        this.financialSummaryData.totalBalance === undefined &&
        this.financialSummaryData.totalBalanceAck === "No available balance"
      ) {
        this.showTotalBalCalculationProgress = false;
        this.showTotalBalValue = false;
        this.showNoTotalBalance = true;
        this.countTotalBalance++;
      }
      if (this.financialSummaryData.totalMerchantTerminals !== undefined) {
        this.showTerminalValue = true;
        this.showTerminalCalculationProgress = false;
        this.showNoTerminal = false;
        this.totalTerminal = this.financialSummaryData.totalMerchantTerminals;
        this.countNoOfTerminals++;
      }
      if (
        this.financialSummaryData.totalMerchantTerminals === undefined &&
        this.financialSummaryData.terminalAck === "No available balance"
      ) {
        this.showTerminalCalculationProgress = false;
        this.showTerminalValue = false;
        this.showNoTerminal = true;
        this.countNoOfTerminals++;
      }
      if (this.financialSummaryData.totalAssetFinanceBalance !== undefined) {
        this.showAssetValue = true;
        this.showAssetCalculationProgress = false;
        this.showNoAssetBalance = false;
        this.totalAssetBalance = this.financialSummaryData.totalAssetFinanceBalance;
        this.countTotalAssetBalance++;
      }
      if (
        this.financialSummaryData.totalAssetFinanceBalance === undefined &&
        this.financialSummaryData.assetBalanceAck === "No available balance"
      ) {
        this.showAssetCalculationProgress = false;
        this.showAssetValue = false;
        this.showNoAssetBalance = true;
        this.countTotalAssetBalance++;
      }
      this.lastSummaryCalculated =
        "Last summary calculated : " +
        this.financialSummaryData.lastSummaryUpdateDate;
      if (
        this.countTotalBalance > 0 &&
        this.countNoOfTerminals > 0 &&
        this.countTotalAssetBalance > 0
      ) {
        unsubscribe(this.subscription, () => {
          this.subscription = "";
        });
      } else {
        if (this.totalCustBalance !== undefined) {
          this.countTotalBalance++;
          this.callTotalCustBalanceApi = false;
        }
        if (this.totalTerminal !== undefined) {
          this.countNoOfTerminals++;
          this.callTerminalApi = false;
        }
        if (this.totalAssetBalance !== undefined) {
          this.countTotalAssetBalance++;
          this.callAssetFinanceBalanceApi = false;
        }
        if (
          this.callTotalCustBalanceApi === true ||
          this.callTerminalApi === true ||
          this.callAssetFinanceBalanceApi === true
        ) {
          this.populateFinancialSummaryCallout();
          this.handleSummariesCalloutOnRefresh(this.financialSummariesCallout);
        }
      }
    } else {
      this.handleNoAvailableBalance(this.financialSummaryData);
    }
  }

  handleSubscribe() {
    subscribe(this.channelName, -1, (message) => {
      let len = this.platformEventList.length;
      this.platformEventList.push(message);
      if (len === 0) {
        this.handleInsert();
      }
      this.handlePlatformEvent(message);
      if (message.data.payload.Summary_Type__c === "TOTAL_CUSTOMER_BALANCE") {
        this.countTotalBalance++;
      } else if (message.data.payload.Summary_Type__c === "TERMINALS") {
        this.countNoOfTerminals++;
      } else if (
        message.data.payload.Summary_Type__c === "TOTAL_ASSET_FINANCE_BALANCE"
      ) {
        this.countTotalAssetBalance++;
      }
      if (
        this.countTotalBalance > 0 &&
        this.countNoOfTerminals > 0 &&
        this.countTotalAssetBalance > 0
      ) {
        this.isDisableRefresh = false;
        unsubscribe(this.subscription, () => {
          this.subscription = "";
        });
      }
    }).then((response) => {
      this.subscription = response;
    });
  }

  handleInsert() {
    if (this.platformEventList.length > 0) {
      let message = this.platformEventList[0];
      insertDataInCache({
        response: JSON.stringify(message.data.payload)
      }).then(() => {
        this.platformEventList.shift();
        this.handleInsert();
      });
    }
  }

  handlePlatformEvent(message) {
    this.showSpinner = true;
    if (message.data.payload.Response_Id__c === this.recordId) {
      if (message.data.payload.Summary_Type__c === "TOTAL_CUSTOMER_BALANCE") {
        this.showTotalBalValue = true;
        this.showNoTotalBalance = false;
        this.showTotalBalCalculationProgress = false;
        this.totalCustBalance = message.data.payload.Summary__c;
      } else if (message.data.payload.Summary_Type__c === "TERMINALS") {
        this.showTerminalValue = true;
        this.showNoTerminal = false;
        this.showTerminalCalculationProgress = false;
        this.totalTerminal = message.data.payload.Summary__c;
      } else if (
        message.data.payload.Summary_Type__c === "TOTAL_ASSET_FINANCE_BALANCE"
      ) {
        this.showAssetValue = true;
        this.showNoAssetBalance = false;
        this.showAssetCalculationProgress = false;
        this.totalAssetBalance = message.data.payload.Summary__c;
      }
      const dateTimeNow = new Date();
      const date = String(dateTimeNow.getDate()).padStart(2, "0");
      const month = String(dateTimeNow.getMonth() + 1).padStart(2, "0");
      const year = String(dateTimeNow.getFullYear());
      const hours = String(dateTimeNow.getHours() % 12 || 12).padStart(2, "0");
      const min = String(dateTimeNow.getMinutes()).padStart(2, "0");
      const amPm = dateTimeNow.getHours() > 12 ? "PM" : "AM";
      this.lastSummaryCalculated =
        "Last summary calculated : " +
        date +
        "/" +
        month +
        "/" +
        year +
        " " +
        hours +
        ":" +
        min +
        " " +
        amPm;
    }
    this.showSpinner = false;
  }

  handleError() {
    this.dispatchEvent(
      new ShowToastEvent({
        title: "Error",
        message: "An unexpected error has been occured.",
        variant: "Error"
      })
    );
  }

  async handleSummariesCalloutOnRefresh(financialSummariesCallout) {
    this.showSpinner = true;
    try {
      let summariesCalloutResult = await getDataFromCallout({
        finSumCallout: financialSummariesCallout
      });
      this.updatedResponse = summariesCalloutResult;
      this.showSpinner = false;
      this.handleNoAvailableBalance(this.updatedResponse);
    } catch (error) {
      this.errorResponse = error.body.message;
      this.showSpinner = false;
      this.handleError();
    }
  }

  handleRefresh() {
    this.platformEventList = [];
    this.showSpinner = true;
    this.isDisableRefresh = true;
    this.countTotalBalance = this.countNoOfTerminals = this.countTotalAssetBalance = 0;
    this.callTotalCustBalanceApi = this.callTerminalApi = this.callAssetFinanceBalanceApi = true;
    if (!this.subscription) {
      this.handleSubscribe();
    }
    this.populateFinancialSummaryCallout();
    this.handleSummariesCalloutOnRefresh(this.financialSummariesCallout);
  }

  populateFinancialSummaryCallout() {
    this.financialSummariesCallout = {
      responseId: this.recordId,
      callTotalCustBalanceApi: this.callTotalCustBalanceApi,
      callTerminalApi: this.callTerminalApi,
      callAssetFinanceBalanceApi: this.callAssetFinanceBalanceApi
    };
  }

  handleNoAvailableBalance(result) {
    if (result.totalBalanceAck === "No available balance") {
      this.showTotalBalCalculationProgress = false;
      this.showTotalBalValue = false;
      this.showNoTotalBalance = true;
      this.countTotalBalance++;
    }
    if (result.terminalAck === "No available balance") {
      this.showTerminalCalculationProgress = false;
      this.showTerminalValue = false;
      this.showNoTerminal = true;
      this.countNoOfTerminals++;
    }
    if (result.assetBalanceAck === "No available balance") {
      this.showAssetCalculationProgress = false;
      this.showAssetValue = false;
      this.showNoAssetBalance = true;
      this.countTotalAssetBalance++;
    }
    if (
      this.countTotalBalance > 0 &&
      this.countNoOfTerminals > 0 &&
      this.countTotalAssetBalance > 0
    ) {
      unsubscribe(this.subscription, () => {
        this.subscription = "";
      });
    }
  }

  disconnectedCallback() {
    if (this.subscription) {
      unsubscribe(this.subscription, () => {
        this.subscription = "";
      });
    }
  }
}
