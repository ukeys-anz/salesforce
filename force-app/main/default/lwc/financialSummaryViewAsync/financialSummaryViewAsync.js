import { LightningElement, api } from "lwc";
import getSummariesByResponseId from "@salesforce/apex/CCRMFinancialSummaryController.getSummariesByResponseId";
import insertDataInCache from "@salesforce/apex/CCRMFinancialSummaryController.insertDataInCache";
import summariesCallout from "@salesforce/apex/CCRMFinancialSummaryController.summariesCallout";
import { subscribe, unsubscribe } from "lightning/empApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class financialSummaryViewAsync extends LightningElement {
  @api recordId;
  @api channelName = "/event/Financial_Summary_Calculation__e";
  financialSummaryData;
  totalCustBalance;
  totalTerminal;
  totalAssetBalance;
  acknowledgementSent;
  lastSummaryCalculated = "";
  showSpinner = false;
  subscription = {};
  countTotalBalance = 0;
  countNoOfTerminals = 0;
  countTotalAssetBalance = 0;
  totalCustBalanceApiCallout = true;
  terminalApiCallout = true;
  assetFinanceBalanceApiCallout = true;
  showtotalBalCalculationProgress = false;
  showTerminalCalculationProgress = false;
  showAssetCalculationProgress = false;
  isDisableRefresh = false;
  platformEventList = [];
  errorResponse;
  successResponse;

  async connectedCallback() {
    this.handleSubscribe();
    this.showSpinner = true;
    try {
      let resultSummaries = await getSummariesByResponseId({
        responseId: this.recordId
      });
      this.showSpinner = false;
      this.financialSummaryData = resultSummaries;
      this.showtotalBalCalculationProgress = true;
      this.showTerminalCalculationProgress = true;
      this.showAssetCalculationProgress = true;
      this.acknowledgementSent = this.financialSummaryData.acknowledgement;
    } catch (error) {
      this.errorResponse = error.body.message;
      this.showSpinner = false;
      this.handleError();
    }

    if (this.acknowledgementSent !== "Request sent") {
      if (this.financialSummaryData.totalBalance !== undefined) {
        this.showtotalBalCalculationProgress = false;
        this.totalCustBalance = this.financialSummaryData.totalBalance;
      }
      if (this.financialSummaryData.totalMerchantTerminals !== undefined) {
        this.showTerminalCalculationProgress = false;
        this.totalTerminal = this.financialSummaryData.totalMerchantTerminals;
      }
      if (this.financialSummaryData.totalAssetFinanceBalance !== undefined) {
        this.showAssetCalculationProgress = false;
        this.totalAssetBalance = this.financialSummaryData.totalAssetFinanceBalance;
      }
      this.lastSummaryCalculated =
        "Last summary calculated : " +
        this.financialSummaryData.lastSummaryUpdateDate;
      if (
        this.totalCustBalance !== undefined &&
        this.totalTerminal !== undefined &&
        this.totalAssetBalance !== undefined
      ) {
        unsubscribe(this.subscription, () => {
          this.subscription = "";
        });
      } else {
        if (this.totalCustBalance !== undefined) {
          this.countTotalBalance++;
          this.totalCustBalanceApiCallout = false;
        }
        if (this.totalTerminal !== undefined) {
          this.countNoOfTerminals++;
          this.terminalApiCallout = false;
        }
        if (this.totalAssetBalance !== undefined) {
          this.countTotalAssetBalance++;
          this.assetFinanceBalanceApiCallout = false;
        }

        this.handleSummariesCallout(
          this.totalCustBalanceApiCallout,
          this.terminalApiCallout,
          this.assetFinanceBalanceApiCallout
        );
      }
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
      insertDataInCache({ response: JSON.stringify(message) }).then(() => {
        this.platformEventList.shift();
        this.handleInsert();
      });
    }
  }

  handlePlatformEvent(message) {
    this.showSpinner = true;
    if (message.data.payload.Response_Id__c === this.recordId) {
      if (message.data.payload.Summary_Type__c === "TOTAL_CUSTOMER_BALANCE") {
        this.showtotalBalCalculationProgress = false;
        this.totalCustBalance = message.data.payload.Summary__c;
      } else if (message.data.payload.Summary_Type__c === "TERMINALS") {
        this.showTerminalCalculationProgress = false;
        this.totalTerminal = message.data.payload.Summary__c;
      } else if (
        message.data.payload.Summary_Type__c === "TOTAL_ASSET_FINANCE_BALANCE"
      ) {
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

  async handleSummariesCallout(
    totalCustBalanceToCall,
    terminalApiToCall,
    assetFinanceBalanceApiToCall
  ) {
    this.showSpinner = true;
    try {
      let summariesCalloutResult = await summariesCallout({
        responseId: this.recordId,
        callTotalCustomerBalanceApi: totalCustBalanceToCall,
        callTerminalApi: terminalApiToCall,
        callTotalAssetBalanceApi: assetFinanceBalanceApiToCall
      });
      this.successResponse = summariesCalloutResult;
      this.showSpinner = false;
    } catch (error) {
      this.errorResponse = error.body.message;
      this.showSpinner = false;
      this.handleError();
    }
  }

  async handleGetUpdatedResult() {
    this.platformEventList = [];
    this.showSpinner = true;
    this.isDisableRefresh = true;
    this.countTotalBalance = this.countNoOfTerminals = this.countTotalAssetBalance = 0;
    this.totalCustBalanceApiCallout = this.terminalApiCallout = this.assetFinanceBalanceApiCallout = true;
    if (!this.subscription) {
      this.handleSubscribe();
    }
    this.handleSummariesCallout(
      this.totalCustBalanceApiCallout,
      this.terminalApiCallout,
      this.assetFinanceBalanceApiCallout
    );
  }

  disconnectedCallback() {
    if (this.subscription) {
      unsubscribe(this.subscription, () => {
        this.subscription = "";
      });
    }
  }
}
