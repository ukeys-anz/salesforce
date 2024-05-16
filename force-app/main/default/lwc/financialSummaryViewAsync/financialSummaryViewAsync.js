import { LightningElement, api } from "lwc";
import getSummariesByResponseId from "@salesforce/apex/CCRMFinancialSummaryController.getSummariesByResponseId";
import getDataFromCallout from "@salesforce/apex/CCRMFinancialSummaryController.getDataFromCallout";
import insertDataInCache from "@salesforce/apex/CCRMFinancialSummaryController.insertDataInCache";
import { subscribe, unsubscribe } from "lightning/empApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

const CALCULATION_IN_PROGRESS = "Calculation is in progress";
const NO_AVAILABLE_BALANCE = "No Available Balance";
const UNEXPECTED_ERROR = "Unexpected error";
const DATA_FOUND_IN_CACHE = "Data found in cache";
const TOTAL_CUSTOMER_BALANCE = "TOTAL_CUSTOMER_BALANCE";
const TERMINALS = "TERMINALS";
const TOTAL_ASSET_FINANCE_BALANCE = "TOTAL_ASSET_FINANCE_BALANCE";
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
  showTotalBalValue = false;
  showTerminalValue = false;
  showAssetValue = false;
  isDisableRefresh = false;
  platformEventList = [];
  errorResponse;
  updatedResponse;
  showTotalBalOtherValue = false;
  totalBalOtherValue;
  showTerminalOtherValue = false;
  terminalOtherValue;
  showAssetOtherValue = false;
  assetOtherValue;
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
      this.showTotalBalOtherValue = this.showTerminalOtherValue = this.showAssetOtherValue = true;
      this.totalBalOtherValue = this.terminalOtherValue = this.assetOtherValue = CALCULATION_IN_PROGRESS;
    } catch (error) {
      this.errorResponse = error.body.message;
      this.showSpinner = false;
      this.handleError();
    }

    if (this.financialSummaryData.cacheAck === DATA_FOUND_IN_CACHE) {
      if (this.financialSummaryData.totalBalance !== undefined) {
        this.showTotalBalValue = true;
        this.showTotalBalOtherValue = false;
        this.totalCustBalance = this.financialSummaryData.totalBalance;
        this.countTotalBalance++;
      }
      if (
        this.financialSummaryData.totalBalance === undefined &&
        (this.financialSummaryData.totalBalanceAck === NO_AVAILABLE_BALANCE ||
          this.financialSummaryData.totalBalanceAck === UNEXPECTED_ERROR)
      ) {
        this.showTotalBalValue = false;
        this.showTotalBalOtherValue = true;
        this.totalBalOtherValue = this.financialSummaryData.totalBalanceAck;
        this.countTotalBalance++;
      }
      if (this.financialSummaryData.totalMerchantTerminals !== undefined) {
        this.showTerminalValue = true;
        this.showTerminalOtherValue = false;
        this.totalTerminal = this.financialSummaryData.totalMerchantTerminals;
        this.countNoOfTerminals++;
      }
      if (
        this.financialSummaryData.totalMerchantTerminals === undefined &&
        (this.financialSummaryData.terminalAck === NO_AVAILABLE_BALANCE ||
          this.financialSummaryData.terminalAck === UNEXPECTED_ERROR)
      ) {
        this.showTerminalValue = false;
        this.showTerminalOtherValue = true;
        this.terminalOtherValue = this.financialSummaryData.terminalAck;
        this.countNoOfTerminals++;
      }
      if (this.financialSummaryData.totalAssetFinanceBalance !== undefined) {
        this.showAssetValue = true;
        this.showAssetOtherValue = false;
        this.totalAssetBalance = this.financialSummaryData.totalAssetFinanceBalance;
        this.countTotalAssetBalance++;
      }
      if (
        this.financialSummaryData.totalAssetFinanceBalance === undefined &&
        (this.financialSummaryData.assetBalanceAck === NO_AVAILABLE_BALANCE ||
          this.financialSummaryData.assetBalanceAck === UNEXPECTED_ERROR)
      ) {
        this.showAssetValue = false;
        this.showAssetOtherValue = true;
        this.assetOtherValue = this.financialSummaryData.assetBalanceAck;
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
      if (message.data.payload.Summary_Type__c === TOTAL_CUSTOMER_BALANCE) {
        this.countTotalBalance++;
      } else if (message.data.payload.Summary_Type__c === TERMINALS) {
        this.countNoOfTerminals++;
      } else if (
        message.data.payload.Summary_Type__c === TOTAL_ASSET_FINANCE_BALANCE
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
    if (
      message.data.payload.Response_Id__c === this.recordId &&
      message.data.payload.Status__c === "Success"
    ) {
      this.handlePlatformEventSuccess(message);
    } else if (
      message.data.payload.Response_Id__c === this.recordId &&
      message.data.payload.Status__c === "Error"
    ) {
      this.handlePlatformEventError(message);
    }
  }

  handlePlatformEventSuccess(message) {
    this.showSpinner = true;
    if (message.data.payload.Summary_Type__c === TOTAL_CUSTOMER_BALANCE) {
      this.showTotalBalValue = true;
      this.showTotalBalOtherValue = false;
      this.totalCustBalance = message.data.payload.Summary__c;
    } else if (message.data.payload.Summary_Type__c === TERMINALS) {
      this.showTerminalValue = true;
      this.showTerminalOtherValue = false;
      this.totalTerminal = message.data.payload.Summary__c;
    } else if (
      message.data.payload.Summary_Type__c === TOTAL_ASSET_FINANCE_BALANCE
    ) {
      this.showAssetValue = true;
      this.showAssetOtherValue = false;
      this.totalAssetBalance = message.data.payload.Summary__c;
    }
    this.handleLastSummaryCalculation();
    this.showSpinner = false;
  }

  handlePlatformEventError(message) {
    this.showSpinner = true;
    if (message.data.payload.Summary_Type__c === TOTAL_CUSTOMER_BALANCE) {
      this.showTotalBalValue = false;
      this.showTotalBalOtherValue = true;
      this.totalBalOtherValue = UNEXPECTED_ERROR;
    } else if (message.data.payload.Summary_Type__c === TERMINALS) {
      this.showTerminalValue = false;
      this.showTerminalOtherValue = true;
      this.terminalOtherValue = UNEXPECTED_ERROR;
    } else if (
      message.data.payload.Summary_Type__c === TOTAL_ASSET_FINANCE_BALANCE
    ) {
      this.showAssetValue = false;
      this.showAssetOtherValue = true;
      this.assetOtherValue = UNEXPECTED_ERROR;
    }
    this.handleLastSummaryCalculation();
    this.showSpinner = false;
  }

  handleLastSummaryCalculation() {
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
    if (result.totalBalanceAck === NO_AVAILABLE_BALANCE) {
      this.showTotalBalValue = false;
      this.showTotalBalOtherValue = true;
      this.totalBalOtherValue = NO_AVAILABLE_BALANCE;
      this.countTotalBalance++;
    }
    if (result.terminalAck === NO_AVAILABLE_BALANCE) {
      this.showTerminalValue = false;
      this.showTerminalOtherValue = true;
      this.terminalOtherValue = NO_AVAILABLE_BALANCE;
      this.countNoOfTerminals++;
    }
    if (result.assetBalanceAck === NO_AVAILABLE_BALANCE) {
      this.showAssetValue = false;
      this.showAssetOtherValue = true;
      this.assetOtherValue = NO_AVAILABLE_BALANCE;
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
