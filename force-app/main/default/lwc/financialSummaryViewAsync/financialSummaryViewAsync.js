import { LightningElement, api } from "lwc";
import getSummariesByResponseId from "@salesforce/apex/FinancialSummaryController.getSummariesByResponseId";
import getDataFromCallout from "@salesforce/apex/FinancialSummaryController.getDataFromCallout";
import insertDataInCache from "@salesforce/apex/FinancialSummaryController.insertDataInCache";
import getFinSummaryMetadata from "@salesforce/apex/FinancialSummaryController.getFinSummaryMetadata";
import { subscribe, unsubscribe } from "lightning/empApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

const CALCULATION_IN_PROGRESS = "Calculation is in progress";
const NO_AVAILABLE_BALANCE = "No available balance";
const UNEXPECTED_ERROR = "Unexpected error";
const DATA_FOUND_IN_CACHE = "Data found in cache";
const TOTAL_CUSTOMER_BALANCE = "TOTAL_CUSTOMER_BALANCE";
const TOTAL_ASSET_FINANCE_BALANCE = "TOTAL_ASSET_FINANCE_BALANCE";
const TOTAL_DEBIT_BALANCE = "TOTAL_DEBIT_BALANCE";
const TOTAL_CREDIT_BALANCE = "TOTAL_CREDIT_BALANCE";
const TOTAL_CUSTOMER_LIMIT = "TOTAL_CUSTOMER_LIMIT";
const CLG_CREDIT_RISK = "CLG_CREDIT_RISK";
const TOTAL_MORTAGE_LIMIT = "TOTAL_MORTAGE_LIMIT";
const CCRM_PROFILE = "ANZ CCRM Standard User";
const ML_USER_PROFILE = "ANZ ML Standard User";
const ADMIN_PROFILE = "System Administrator";

export default class financialSummaryViewAsync extends LightningElement {
  @api recordId;
  @api channelName = "/event/Financial_Summary_Calculation__e";
  financialSummaryData;
  totalCustBalance;
  totalAssetBalance;
  lastSummaryCalculated = "";
  showSpinner = false;
  subscription = {};
  countTotalBalance = 0;
  countNoOfTerminals = 0;
  countTotalAssetBalance = 0;
  callTotalCustBalanceApi = false;
  callTotalLimitsApi = false;
  callAssetFinanceBalanceApi = false;
  showTotalBalValue = false;
  showTerminalValue = false;
  showAssetValue = false;
  isDisableRefresh = false;
  platformEventList = [];
  errorResponse;
  updatedResponse;
  showTotalBalOtherValue = false;
  totalBalOtherValue;
  showAssetOtherValue = false;
  assetOtherValue;
  financialSummariesCallout;
  showDebitBalOtherValue = false;
  totalDebitOtherBalance;
  showDebitBalValue = false;
  totalDebitBalance;
  showCreditBalValue = false;
  showCreditBalOtherValue = false;
  totalCreditBalance;
  totalCreditOtherBalance;
  showLimitOtherValue = false;
  totalLimitOtherValue;
  showLimitValue = false;
  totalLimitValue;
  totalLimitCount = 0;
  clgCreditRating = NO_AVAILABLE_BALANCE;
  totalMortageValue;
  showTotalMortageValue = false;
  totalMortageOtherValue = NO_AVAILABLE_BALANCE;
  showTotalMortageOtherValue = true;
  totalMortageCount = 0;
  callMorageLimitApi = false;
  @api jtestRunning = false;
  currentUserProfile;
  summaryValuesToDisplay = [];
  showAssetFinanceInfo = false;
  showTotalCustmerBalanceInfo = false;
  showTotalLimitInfo = false;
  showClgCreditRatingInfo = false;
  showCreditBalanceInfo = false;
  showDebitBalanceInfo = false;
  showMortageLimitInfo = false;

  async connectedCallback() {
    this.handleSubscribe();
    this.showSpinner = true;

    try {
      if (this.jtestRunning === true) {
        this.currentUserProfile = CCRM_PROFILE;
      }
      let finSummaryWrapperSettingRecords = await getFinSummaryMetadata();
      this.currentUserProfile =
        finSummaryWrapperSettingRecords.strCurrentUserProfileName;
      this.populateSummaryValuesToDisplayList(
        finSummaryWrapperSettingRecords.lstOfSymmarySetting
      );
      this.handleValuesToDisplay();
      this.populateFinancialSummaryCallout();

      let resultSummaries = await getSummariesByResponseId({
        finSumCallout: this.financialSummariesCallout
      });
      this.showSpinner = false;
      this.financialSummaryData = resultSummaries;
      this.showTotalBalOtherValue = this.showAssetOtherValue = true;
      this.showDebitBalOtherValue =
        this.showCreditBalOtherValue =
        this.showLimitOtherValue =
          true;
      this.totalLimitOtherValue =
        this.totalCreditOtherBalance =
        this.totalDebitOtherBalance =
        this.totalBalOtherValue =
        this.assetOtherValue =
          CALCULATION_IN_PROGRESS;
    } catch (error) {
      this.errorResponse = error;
      this.showSpinner = false;
      this.handleError();
    }
    if (this.financialSummaryData.cacheAck === DATA_FOUND_IN_CACHE) {
      if (this.financialSummaryData.totalBalance !== undefined) {
        this.showTotalBalValue = true;
        this.showTotalBalOtherValue = false;
        this.totalCustBalance = this.financialSummaryData.totalBalance;
        this.countTotalBalance++;
        this.showDebitBalValue = true;
        this.showDebitBalOtherValue = false;
        this.totalDebitBalance = this.financialSummaryData.totalDebitBalance;
        this.showCreditBalValue = true;
        this.showCreditBalOtherValue = false;
        this.totalCreditBalance = this.financialSummaryData.totalCreditBalance;
        this.callTotalCustBalanceApi = false;
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
        this.showDebitBalValue = false;
        this.showDebitBalOtherValue = true;
        this.totalDebitOtherBalance =
          this.financialSummaryData.totalDebitBalanceAck;
        this.showCreditBalValue = false;
        this.showCreditBalOtherValue = true;
        this.totalCreditBalance =
          this.financialSummaryData.totalCreditBalanceAck;
      }
      if (this.financialSummaryData.totalAssetFinanceBalance !== undefined) {
        this.showAssetValue = true;
        this.showAssetOtherValue = false;
        this.totalAssetBalance =
          this.financialSummaryData.totalAssetFinanceBalance;
        this.countTotalAssetBalance++;
        this.callAssetFinanceBalanceApi = false;
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

      if (this.financialSummaryData.totalLimitValue !== undefined) {
        this.showLimitValue = true;
        this.showLimitOtherValue = false;
        this.totalLimitValue = this.financialSummaryData.totalLimitValue;
        this.totalLimitCount++;
        this.callTotalLimitsApi = false;
      }
      if (
        this.financialSummaryData.totalLimitValue === undefined &&
        (this.financialSummaryData.totalLimitsAck === NO_AVAILABLE_BALANCE ||
          this.financialSummaryData.totalLimitsAck === UNEXPECTED_ERROR)
      ) {
        this.showLimitValue = false;
        this.showLimitOtherValue = true;
        this.totalLimitValue = this.financialSummaryData.totalLimitAck;
        this.totalLimitCount++;
      }

      this.lastSummaryCalculated =
        "Last summary calculated : " +
        this.financialSummaryData.lastSummaryUpdateDate;
      if (this.canUnsubscribePlatformEvent()) {
        this.unsubscribePlatformEvent();
      } else if (
        this.callTotalCustBalanceApi === true ||
        this.callAssetFinanceBalanceApi === true ||
        this.callTotalLimitsApi === true
      ) {
        this.populateFinancialSummaryCallout();
        this.handleSummariesCalloutOnRefresh(this.financialSummariesCallout);
      }
    } else {
      this.handleNoAvailableBalance(this.financialSummaryData);
    }
  }

  get showCCCalculationMsg() {
    return (
      this.currentUserProfile === ML_USER_PROFILE ||
      this.currentUserProfile === ADMIN_PROFILE
    );
  }

  handleSubscribe() {
    subscribe(this.channelName, -1, (message) => {
      let len = this.platformEventList.length;
      this.platformEventList.push(message);
      if (len === 0) {
        this.handleInsert();
      }
      this.handlePlatformEvent(message);
      if (this.canUnsubscribePlatformEvent()) {
        this.isDisableRefresh = false;
        this.unsubscribePlatformEvent();
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
    let mapOfSummaries = this.createMapOfSummaries(message.data.payload);
    if (
      message.data.payload.Response_Id__c === this.recordId &&
      message.data.payload.Status__c === "Success"
    ) {
      this.handlePlatformEventSuccess(mapOfSummaries);
    } else if (
      message.data.payload.Response_Id__c === this.recordId &&
      message.data.payload.Status__c === "Error"
    ) {
      this.handlePlatformEventError(mapOfSummaries);
    }
  }

  handlePlatformEventSuccess(mapOfSummaries) {
    this.showSpinner = true;
    if (mapOfSummaries.has(TOTAL_CUSTOMER_BALANCE)) {
      this.showTotalBalValue = true;
      this.showTotalBalOtherValue = false;
      this.totalCustBalance = mapOfSummaries.get(TOTAL_CUSTOMER_BALANCE);
      this.countTotalBalance += 1;
      this.callTotalCustBalanceApi = false;

      this.showDebitBalValue = true;
      this.showDebitBalOtherValue = false;
      this.totalDebitBalance = mapOfSummaries.get(TOTAL_DEBIT_BALANCE);

      this.showCreditBalValue = true;
      this.showCreditBalOtherValue = false;
      this.totalCreditBalance = mapOfSummaries.get(TOTAL_CREDIT_BALANCE);
    }
    if (mapOfSummaries.has(TOTAL_ASSET_FINANCE_BALANCE)) {
      this.showAssetValue = true;
      this.showAssetOtherValue = false;
      this.totalAssetBalance = mapOfSummaries.get(TOTAL_ASSET_FINANCE_BALANCE);
      this.countTotalAssetBalance += 1;
      this.callAssetFinanceBalanceApi = false;
    }
    if (mapOfSummaries.has(TOTAL_CUSTOMER_LIMIT)) {
      this.showLimitValue = true;
      this.showLimitOtherValue = false;
      this.totalLimitValue = mapOfSummaries.get(TOTAL_CUSTOMER_LIMIT);
      this.totalLimitCount += 1;
      this.callTotalLimitsApi = false;
    }
    this.handleLastSummaryCalculation();
    this.showSpinner = false;
  }

  handlePlatformEventError(mapOfSummaries) {
    this.showSpinner = true;
    if (mapOfSummaries.has(TOTAL_CUSTOMER_BALANCE)) {
      this.showTotalBalValue = false;
      this.showTotalBalOtherValue = true;
      this.totalBalOtherValue = UNEXPECTED_ERROR;
      this.countTotalBalance += 1;
      this.callTotalCustBalanceApi = false;
      this.showDebitBalValue = false;
      this.showDebitBalOtherValue = true;
      this.totalDebitOtherBalance = UNEXPECTED_ERROR;
      this.showCreditBalValue = false;
      this.showCreditBalOtherValue = true;
      this.totalCreditOtherBalance = UNEXPECTED_ERROR;
    }
    if (mapOfSummaries.has(TOTAL_ASSET_FINANCE_BALANCE)) {
      this.showAssetValue = false;
      this.showAssetOtherValue = true;
      this.assetOtherValue = UNEXPECTED_ERROR;
      this.countTotalAssetBalance += 1;
      this.callAssetFinanceBalanceApi = false;
    }
    if (mapOfSummaries.has(TOTAL_CUSTOMER_LIMIT)) {
      this.showLimitValue = false;
      this.showLimitOtherValue = true;
      this.totalLimitOtherValue = UNEXPECTED_ERROR;
      this.totalLimitCount += 1;
      this.callTotalLimitsApi = false;
    }
    this.handleLastSummaryCalculation();
    this.showSpinner = false;
  }

  // Format of Summary : {"Summary__c":" {"items": ["subType": "TOTAL_CREDIT_BALANCE","subTypeValue" : 0}]}"}
  // will return map of SubType -> SubTypeValue
  createMapOfSummaries(msgPayload) {
    const summaryJson = JSON.parse(JSON.stringify(msgPayload)).Summary__c;
    const items = JSON.parse(summaryJson).items;
    let mapOfSummaries = new Map();
    items.forEach((item) => {
      mapOfSummaries.set(item.subType, item.subTypeValue);
    });
    return mapOfSummaries;
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
      this.errorResponse = error;
      this.showSpinner = false;
      this.handleError();
    }
  }

  handleRefresh() {
    this.platformEventList = [];
    this.showSpinner = true;
    this.isDisableRefresh = true;
    this.totalLimitCount =
      this.countTotalBalance =
      this.countNoOfTerminals =
      this.countTotalAssetBalance =
        0;
    this.handleValuesToDisplay();
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
      callAssetFinanceBalanceApi: this.callAssetFinanceBalanceApi,
      callTotalLimitsApi: this.callTotalLimitsApi
    };
  }

  handleNoAvailableBalance(result) {
    if (result.totalBalanceAck === NO_AVAILABLE_BALANCE) {
      this.showTotalBalValue = false;
      this.showTotalBalOtherValue = true;
      this.totalBalOtherValue = NO_AVAILABLE_BALANCE;
      this.countTotalBalance++;
      this.showDebitBalValue = false;
      this.showDebitBalOtherValue = true;
      this.totalDebitOtherBalance = NO_AVAILABLE_BALANCE;
      this.showCreditBalValue = false;
      this.showCreditBalOtherValue = true;
      this.totalCreditOtherBalance = NO_AVAILABLE_BALANCE;
    }
    if (result.assetBalanceAck === NO_AVAILABLE_BALANCE) {
      this.showAssetValue = false;
      this.showAssetOtherValue = true;
      this.assetOtherValue = NO_AVAILABLE_BALANCE;
      this.countTotalAssetBalance++;
    }
    if (result.totalLimitAck === NO_AVAILABLE_BALANCE) {
      this.showLimitValue = false;
      this.showLimitOtherValue = true;
      this.totalLimitOtherValue = NO_AVAILABLE_BALANCE;
      this.totalLimitCount++;
    }
    if (this.canUnsubscribePlatformEvent()) {
      this.unsubscribePlatformEvent();
    }
  }

  disconnectedCallback() {
    if (this.subscription) {
      this.unsubscribePlatformEvent();
    }
  }

  canUnsubscribePlatformEvent() {
    return !(
      this.callTotalCustBalanceApi ||
      this.callTotalLimitsApi ||
      this.callAssetFinanceBalanceApi
    );
  }

  unsubscribePlatformEvent() {
    unsubscribe(this.subscription, () => {
      this.subscription = "";
    });
  }

  handleValuesToDisplay() {
    if (this.summaryValuesToDisplay.includes(TOTAL_ASSET_FINANCE_BALANCE)) {
      this.showAssetFinanceInfo = true;
      this.callAssetFinanceBalanceApi = true;
    }
    if (this.summaryValuesToDisplay.includes(TOTAL_CUSTOMER_BALANCE)) {
      this.showTotalCustmerBalanceInfo = true;
      this.callTotalCustBalanceApi = true;
    }
    if (this.summaryValuesToDisplay.includes(TOTAL_CUSTOMER_LIMIT)) {
      this.showTotalLimitInfo = true;
      this.callTotalLimitsApi = true;
    }
    if (this.summaryValuesToDisplay.includes(CLG_CREDIT_RISK)) {
      this.showClgCreditRating = true;
    }
    if (this.summaryValuesToDisplay.includes(TOTAL_CREDIT_BALANCE)) {
      this.showCreditBalanceInfo = true;
      this.callTotalCustBalanceApi = true;
    }
    if (this.summaryValuesToDisplay.includes(TOTAL_DEBIT_BALANCE)) {
      this.showDebitBalanceInfo = true;
      this.callTotalCustBalanceApi = true;
    }
    if (this.summaryValuesToDisplay.includes(TOTAL_MORTAGE_LIMIT)) {
      this.showMortageLimitInfo = true;
      this.callMorageLimitApi = true;
    }
  }

  populateSummaryValuesToDisplayList(finSummarySettingRecords) {
    finSummarySettingRecords.forEach((record) => {
      if (record.User_Profile__c.split(";").includes(this.currentUserProfile)) {
        this.summaryValuesToDisplay.push(record.Summary_Name__c);
      }
    });
  }
}
