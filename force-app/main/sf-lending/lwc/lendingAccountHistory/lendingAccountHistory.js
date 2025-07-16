import { LightningElement, wire, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { handleErrorShowToast } from "c/utils";
import { getRecord } from "lightning/uiRecordApi";
import getListOfLoanAccountChanges from "@salesforce/apex/HomeLoanHistoryController.getListOfLoanAccountChanges";
import OCV_ID_FIELD from "@salesforce/schema/FinServ__FinancialAccount__c.OCV_ID__c";
import FIN_ACCOUNT_NUMBER from "@salesforce/schema/FinServ__FinancialAccount__c.FinServ__FinancialAccountNumber__c";

const TOAST_ERROR_MSG =
  "Failed to retrieve account history. Please refresh and try again. If the problem persists, please contact your System Administrator.";

const PRODUCT_TYPE = new Map([
  ["LOAN_PRODUCT_TYPE_OWNER_OCCUPIED", "Live In"],
  ["LOAN_PRODUCT_TYPE_INVESTOR", "Investment"]
]);

export default class LendingAccountHistory extends NavigationMixin(
  LightningElement
) {
  @api recordId;
  accountHistoryData = null;
  historyDetails = [];
  ocvId;
  loanAccNumber;
  startDate = "";
  endDate = "";
  disableSearch = true;
  showSpinner = true;
  lastUpdated;
  noHistoryData = false;

  /* columns for Data Table */
  columns = [
    { label: "Date", fieldName: "updatedTime" },
    { label: "Change Request", fieldName: "changeRequest" },
    {
      label: "User",
      fieldName: "user",
      type: "button",
      typeAttributes: {
        label: { fieldName: "user" },
        name: "view_user",
        title: "User",
        variant: "base"
      }
    },
    {
      label: "Related To",
      fieldName: "caseNumber",
      type: "button",
      typeAttributes: {
        label: { fieldName: "caseNumber" },
        name: "view_case",
        title: "Related To",
        variant: "base"
      }
    },
    {
      label: "Field",
      fieldName: "field",
      hideDefaultActions: true
    },
    {
      label: "Original Value",
      fieldName: "originalValue",
      hideDefaultActions: true
    },
    { label: "New Value", fieldName: "newValue", hideDefaultActions: true }
  ];

  /* get OCV ID,Fin Account Number and pass to getAccountHistoryData method */
  @wire(getRecord, {
    recordId: "$recordId",
    fields: [OCV_ID_FIELD, FIN_ACCOUNT_NUMBER]
  })
  wiredData({ error, data }) {
    if (data) {
      this.ocvId = data.fields.OCV_ID__c.value;
      this.loanAccNumber = data.fields.FinServ__FinancialAccountNumber__c.value;
      this.getAccountHistoryData();
    } else if (error) {
      this.showToast("Error fetching record data", "error");
    }
  }

  /* callout to apex method, update data based on response */
  getAccountHistoryData() {
    this.showSpinner = true;
    getListOfLoanAccountChanges({
      ocvId: this.ocvId,
      loanAccNumber: this.loanAccNumber
    })
      .then((result) => {
        const currentDate = new Date();
        this.lastUpdated = this.setTimestamp(currentDate, true);
        
        if ((result?.accountHistoryList?.length ?? 0 ) === 0) {
          this.accountHistoryData = null;
          this.noHistoryData = true;
        } else if (result && result.accountHistoryList.length > 0) {
          result.accountHistoryList.forEach((item) => {
            item.updatedTime = this.setTimestamp(item.updatedTime, false);
            item.newValue = PRODUCT_TYPE.get(item.newValue);
          });
          this.historyDetails = result.accountHistoryList.sort(
            (a, b) => new Date(b.updatedTime) - new Date(a.updatedTime)
          );
          this.accountHistoryData = [...this.historyDetails];
        }
      })
      .catch((error) => {
        this.accountHistoryData = null;
        handleErrorShowToast(this, "", error, TOAST_ERROR_MSG, "pester");
      })
      .finally(() => {
        this.showSpinner = false;
      });
  }

  /* handle refresh all button */
  handleRefresh() {
    this.noHistoryData = false;
    this.getAccountHistoryData();
  }

  /* handle Start Date change*/
  handleStartDateChange(e) {
    this.startDate = e.detail.value;
    if (!this.startDate && !this.endDate) {
      this.disableSearch = true;
      this.handleClearFilter();
    } else if (
      (this.endDate && this.startDate > this.endDate) ||
      this.startDate > this.todayDate
    ) {
      this.disableSearch = true;
    } else if (this.startDate || this.endDate) {
      this.disableSearch = false;
    } else {
      this.disableSearch = true;
    }
  }

  /* handle End Date change*/
  handleEndDateChange(e) {
    this.endDate = e.detail.value;
    if (!this.endDate && !this.startDate) {
      this.disableSearch = true;
      this.handleClearFilter();
    } else if (
      (this.startDate && this.endDate < this.startDate) ||
      this.endDate > this.todayDate
    ) {
      this.disableSearch = true;
    } else if (this.endDate || this.startDate) {
      this.disableSearch = false;
    } else {
      this.disableSearch = true;
    }
  }

  /* handle Search button click */
  handleSearch() {
    this.handleClearFilter();
    const start = new Date(this.startDate);
    const end = new Date(this.endDate);
    this.accountHistoryData = this.historyDetails.filter((item) => {
      const itemDate = this.convertStringToDate(item.updatedTime);
      if (this.startDate && this.endDate) {
        return itemDate >= start && itemDate <= end;
      } else if (this.startDate && !this.endDate) {
        return itemDate >= start;
      } else if (this.endDate && !this.startDate) {
        return itemDate <= end;
      }
    });
    if (this.accountHistoryData.length === 0) {
      this.accountHistoryData = null;
      this.noHistoryData = true;
    }
  }

  /* convert string (Eg.18/2/2025, 1:57pm) to required Date format */
  convertStringToDate(dateStr) {
    const datePart = dateStr.split(",")[0];
    const [day, month, year] = datePart.split("/");
    const formattedTime = `${year}-${this.formatNumber(month)}-${this.formatNumber(day)}`;
    return new Date(formattedTime);
  }

  formatNumber(number) {
    return number.padStart(2, "0");
  }

  /* Navigate to User/Case record page based on user click */
  handleClick(event) {
    const actionName = event.detail.action.name;
    const row = event.detail.row;

    if (actionName === "view_user" && row.userId) {
      this.navigateToRecordViewPage(row.userId, "User");
    } else if (actionName === "view_case" && row.caseId) {
      this.navigateToRecordViewPage(row.caseId, "Case");
    }
  }

  navigateToRecordViewPage(recordId, objectType) {
    if (!recordId || !objectType) {
      return;
    }

    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: recordId,
        objectApiName: objectType,
        actionName: "view"
      }
    });
  }

  /* Time Stamp format update */
  setTimestamp(timestamp, withSeparator) {
    let lastUpdated = new Date(timestamp).toLocaleString("en-AU", {
      day: "numeric",
      month: withSeparator ? "long" : "numeric",
      year: "numeric",
      hour: "numeric",
      minute: "numeric",
      hour12: true
    });

    if (withSeparator) {
      lastUpdated = lastUpdated.replace("at", "|");
    }
    return lastUpdated;
  }

  handleClearFilter() {
    if (this.historyDetails.length > 0) {
      this.accountHistoryData = [...this.historyDetails];
    }
  }
}
