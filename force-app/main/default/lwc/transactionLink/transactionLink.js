import { api, track } from "lwc";
import LightningModal from "lightning/modal";
import { SimpleToast } from "c/utils";
import {
  ACCOUNT_COLUMNS,
  TXN_COLUMNS,
  REVIEW_TXN_COLUMNS
} from "./helper/columns";
import getFinancialAccounts from "@salesforce/apex/TransactionLinkController.getFinancialAccounts";
import getTransactionHistoryAura from "@salesforce/apex/CoachBankingAPIRepository.getTransactionHistoryAuraV2";

export default class TransactionLink extends LightningModal {
  toast = new SimpleToast(this);
  label;
  currentNav = "selectFA";
  isLoading = false;

  @api accId;
  @api originalTxnAccs = [];
  @api originalTxnIds = [];

  @track accounts = [];
  selectedAccRow;
  selectedAccId = [];

  transactions = [];
  selectedTxnIds = [];
  @track newTxns = {};
  @track removedTxns = {};

  todayDate = new Date().toISOString().slice(0, 10);
  startDate;
  endDate;
  nextUri;

  faColumns = ACCOUNT_COLUMNS;
  txnColumns = TXN_COLUMNS;
  reviewTxnColumns = REVIEW_TXN_COLUMNS;

  @track nav = {
    selectFA: {
      label: "Add Transactions",
      prevAction: null,
      nextAction: "selectTransactions",
      onActive: () => this.service.loadFinancialAccounts(),
      isVisible: false,
      nextButtonLabel: "Next",
      maxRowSelection: 1
    },
    selectTransactions: {
      label: "Add Transactions",
      prevAction: "selectFA",
      nextAction: "review",
      onActive: () => {
        this.handler.search();
      },
      isVisible: false,
      nextButtonLabel: "Review attached transactions",
      maxRowSelection: 50
    },
    review: {
      label: "Review Attached Transactions",
      prevAction: "selectTransactions",
      nextAction: "submit",
      isVisible: false,
      nextButtonLabel: "Save"
    },
    submit: {
      onActive: () => this.handler.submit()
    }
  };

  @api showSpinner() {
    this.isLoading = true;
  }

  @api hideSpinner() {
    this.isLoading = false;
  }

  get currentNavAction() {
    return this.nav[this.currentNav];
  }

  get isNextButtonDisabled() {
    const nextStepValidators = {
      selectFA: () => this.selectedAccRow,
      selectTransactions: () =>
        Object.keys(this.newTxns).length ||
        Object.keys(this.removedTxns).length,
      review: () => true
    };
    return !nextStepValidators[this.currentNav]?.();
  }

  get isBackButtonDisabled() {
    return !this.currentNavAction.prevAction;
  }

  get transactionFound() {
    return this.transactions && this.transactions.length > 0;
  }

  get tnxAdded() {
    return Object.values(this.newTxns);
  }

  get tnxRemoved() {
    return Object.values(this.removedTxns);
  }

  get txnsUIData() {
    return this.transactions.map((txn) => {
      let dynamicIcon;
      if (this.newTxns[txn.TransactionId]) {
        dynamicIcon = "utility:add";
      } else if (this.removedTxns[txn.TransactionId]) {
        dynamicIcon = "utility:dash";
      }

      return {
        ...txn,
        dynamicIcon
      };
    });
  }

  get isDateRangeSelected() {
    return this.startDate && this.endDate;
  }

  get disableSearch() {
    if (!this.isDateRangeSelected) return true;

    let isDateRangeValid = this.helper.isDateRangeWithinThreeMonths(
      this.startDate,
      this.endDate
    );
    return (
      (this.startDate <= this.endDate &&
        this.endDate <= this.todayDate &&
        isDateRangeValid) === false
    );
  }

  get maxStartDate() {
    if (this.endDate && this.endDate < this.todayDate) {
      return this.endDate;
    }
    return this.todayDate;
  }

  get maxTxnSelection() {
    const txnIds = this.transactions.map((txn) => txn.TransactionId);
    const hiddenOrigTxnIds = this.originalTxnIds.filter(
      (id) => !this.removedTxns[id] && !txnIds.includes(id)
    );
    const hiddenNewTxnIds = Object.keys(this.newTxns).filter(
      (id) => !txnIds.includes(id)
    );
    return 50 - hiddenOrigTxnIds.length - hiddenNewTxnIds.length;
  }

  get countAttachedTxns() {
    return (
      Object.keys(this.newTxns).length +
      this.originalTxnIds.length -
      Object.keys(this.removedTxns).length
    );
  }

  connectedCallback() {
    this.navigate("selectFA");
  }

  navigate(item) {
    const navItem = this.nav[item];
    if (navItem.onActive) navItem.onActive();

    if (!navItem.nextAction) return;
    this.label = navItem.label;
    this.currentNav = item;
    Object.entries(this.nav).forEach(([key, value]) => {
      value.isVisible = key === item;
    });
  }

  handler = {
    back: () => {
      const prevAction = this.currentNavAction.prevAction;
      if (prevAction) {
        this.isLoading = false;
        this.navigate(prevAction);
      }
    },
    next: () => {
      const nextAction = this.currentNavAction.nextAction;
      if (nextAction) {
        this.navigate(nextAction);
      }
    },
    cancel: () => {
      this.close();
    },
    accSelection: (e) => {
      const selectedRow = e.detail.selectedRows[0];
      // clear if the account selection changed
      if (
        this.selectedAccId.length === 0 ||
        selectedRow.Id !== this.selectedAccId[0]
      ) {
        this.transactions = [];
        this.selectedTxnIds = [];
        this.newTxns = {};
        this.removedTxns = {};
        this.helper.resetDateFields();
      }

      this.helper.setSelectedAccount(selectedRow);
    },
    txnSelection: (e) => {
      if (!e.detail.config.action) return;
      // Block deselectAllRows and selectAllRows
      if (
        e.detail.config.action === "deselectAllRows" ||
        e.detail.config.action === "selectAllRows"
      ) {
        // setTimeOut used here to reset the selected rows back to previous state,
        // since the select event is effective after the table has been rendered
        const temp = this.selectedTxnIds;
        this.selectedTxnIds = [];
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
          this.selectedTxnIds = temp;
        }, 0);
        this.toast.warning("Cannot select/deselect all rows at the same time");
        return;
      }

      this.selectedTxnIds = e.detail.selectedRows.map(
        (row) => row.TransactionId
      );
      for (const txn of this.transactions) {
        if (this.selectedTxnIds.includes(txn.TransactionId)) {
          this.helper.selectTxn(txn);
        } else {
          this.helper.unselectTxn(txn);
        }
      }
    },
    dateChange: (e) => {
      this[e.target.name] = e.detail.value;

      if (!this.isDateRangeSelected) {
        this.helper.setDateCustomValidity();
        return;
      }

      let isValidDateRange = this.helper.isDateRangeWithinThreeMonths(
        this.startDate,
        this.endDate
      );
      if (!isValidDateRange) {
        this.helper.setDateCustomValidity(
          "Selected date range cannot exceed 3 months."
        );
      } else {
        this.helper.setDateCustomValidity();
      }
    },
    search: async () => {
      this.transactions = [];
      this.selectedTxnIds = [];
      this.nextUri = null; // Reset pagination
      const transactions = await this.service.fetchTxns();
      this.helper.onLoadTxnTable(transactions);
    },
    resetSearch: () => {
      this.helper.resetDateFields();
      this.handler.search();
    },
    submit: () => {
      const txns = {
        account: this.selectedAccRow,
        transactions: {
          added: Object.values(this.newTxns),
          removed: Object.keys(this.removedTxns)
        }
      };
      this.dispatchEvent(
        new CustomEvent("submit", {
          detail: txns
        })
      );
    }
  };

  service = {
    loadFinancialAccounts: async () => {
      this.isLoading = true;
      try {
        this.accounts = await getFinancialAccounts({
          accId: this.accId
        });
        this.helper.accPreSelection();
      } catch (error) {
        this.helper.dispatchError("Error fetching financial accounts.");
      } finally {
        this.isLoading = false;
      }
    },
    fetchTxns: async () => {
      if (!this.selectedAccRow) {
        this.toast.error("Account is not selected");
        return [];
      }

      let startDate =
        this.startDate === undefined
          ? this.startDate
          : this.startDate + " 00:00:00";
      let endDate =
        this.endDate === undefined ? this.endDate : this.endDate + " 23:59:59";
      let paramUrlModel = {
        accountNumber: this.selectedAccRow.Account_Number__c,
        startDate: startDate,
        endDate: endDate,
        pageSize: 100,
        paramUrl: this.nextUri
      };

      this.isLoading = true;
      try {
        const txns = await getTransactionHistoryAura({
          ocvId: this.selectedAccRow.FinServ__FinancialAccount__r.OCV_ID__c,
          ownership: this.selectedAccRow.Ownership__c,
          paramUrlModel
        });

        if (this.isDateRangeSelected) {
          // Store the next page URL from links if available
          const nextUri = txns.links?.next?.uri;
          this.nextUri = nextUri
            ? nextUri.substring(nextUri.indexOf("?"))
            : null;
        }
        return this.helper.transformTransactions(txns);
      } catch (error) {
        this.toast.error("Error fetching transactions.");
        return [];
      } finally {
        this.isLoading = false;
      }
    }
  };

  async handleLoadMore() {
    if (!this.nextUri) return;

    const moreTxns = await this.service.fetchTxns();
    if (!moreTxns?.length) return;

    // Append new transactions to existing ones
    this.transactions = [...this.transactions, ...moreTxns];
    this.helper.onLoadTxnTable(this.transactions);
  }

  helper = {
    accPreSelection: () => {
      if (this.originalTxnAccs.length !== 1) {
        return;
      }

      let foundAccount = this.accounts.find(
        (account) => account.Account_Number__c === this.originalTxnAccs[0]
      );
      if (foundAccount) {
        this.helper.setSelectedAccount(foundAccount);
      }
    },
    setSelectedAccount: (selectedAcc) => {
      this.selectedAccId = [selectedAcc.Id];
      this.selectedAccRow = selectedAcc;
    },
    transformTransactions: (txns) => {
      // filter only posted transactions
      const postedTxns =
        txns.embedded?.transactions.filter(
          (txn) =>
            txn.status === "POSTED_INTRADAY" || txn.status === "POSTED_PRIORDAY"
        ) || [];

      return postedTxns.map((txn) => ({
        TransactionDate: txn.transaction_time,
        TransactionId: txn.transaction_id,
        Amount: txn.amount.value,
        PayerBSB: txn.pay_anyone?.other_entity.account?.bsb,
        PayerAccount:
          txn.pay_anyone?.other_entity.account?.transactionAccountNumber,
        Message: txn.pay_anyone?.message?.value,
        Title: txn.title,
        AccountDetails:
          this.selectedAccRow.Product_Name_Display__c +
          " " +
          this.selectedAccRow.Account_Number__c,
        Type: txn.type
      }));
    },
    onLoadTxnTable: (transactions) => {
      this.transactions = transactions;
      //find transaction IDs that are previously selected
      this.selectedTxnIds = transactions
        .filter(
          (txn) =>
            this.newTxns[txn.TransactionId] ||
            (this.originalTxnIds.includes(txn.TransactionId) &&
              !this.removedTxns[txn.TransactionId])
        )
        .map((txn) => txn.TransactionId);
    },
    selectTxn: (txn) => {
      if (this.originalTxnIds.includes(txn.TransactionId)) {
        delete this.removedTxns[txn.TransactionId];
      } else {
        this.newTxns[txn.TransactionId] = txn;
      }
    },
    unselectTxn: (txn) => {
      if (this.originalTxnIds.includes(txn.TransactionId)) {
        this.removedTxns[txn.TransactionId] = txn;
      } else {
        delete this.newTxns[txn.TransactionId];
      }
    },
    isDateRangeWithinThreeMonths: (start, end) => {
      if (!start || !end) return false;
      const startDt = new Date(start);
      const endDt = new Date(end);
      const months =
        (endDt.getFullYear() - startDt.getFullYear()) * 12 +
        (endDt.getMonth() - startDt.getMonth());
      return (
        months < 3 || (months === 3 && endDt.getDate() <= startDt.getDate())
      );
    },
    setDateCustomValidity: (message = "") => {
      let startDateField = this.refs.startDateInput;
      let endDateField = this.refs.endDateInput;
      // eslint-disable-next-line @lwc/lwc/no-async-operation
      setTimeout(() => {
        startDateField.setCustomValidity(message);
        startDateField.reportValidity();
        endDateField.setCustomValidity(message);
        endDateField.reportValidity();
      }, 0);
    },
    resetDateFields: () => {
      this.startDate = undefined;
      this.endDate = undefined;
    },
    dispatchError: (message) => {
      this.dispatchEvent(
        new CustomEvent("error", {
          detail: message
        })
      );
    }
  };
}
