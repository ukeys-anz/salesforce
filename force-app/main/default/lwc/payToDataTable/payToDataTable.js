import { LightningElement, track, api } from "lwc";
import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";

const actions = [{ label: "Show details", name: "showdetails" }];

const columns = [
  { label: "Payee Name", fieldName: "initiatingPartyName" },
  { label: "Mandate ID", fieldName: "name" },
  { label: "Status", fieldName: "statusDescription" },
  {
    label: "Amount",
    fieldName: "amount",
    initialWidth: 100,
    cellAttributes: { alignment: "right" }
  },
  {
    label: "Maximum Amount",
    fieldName: "maxAmount",
    initialWidth: 100,
    cellAttributes: { alignment: "right" }
  },
  {
    type: "action",
    typeAttributes: { rowActions: actions }
  }
];
const CURRENT_AGREEMENTS_HEADER =
  "These are the current agreements. To make changes and enable the buttons, select one Payee at a time and then click 'Pause' or 'Cancel'.";
const PAUSED_AGREEMENTS_HEADER =
  "These are payments that are paused and don't effect the contract. To make changes and enable the buttons, select one Payee at a time and then click 'Resume' or 'Cancel'.";
const CANCELLED_AGREEMENTS_HEADER =
  "These are the cancelled agreements. If the customer changes their mind, they'll need to request a new agreement from the merchant.";

export default class PayToDataTable extends OmniscriptBaseMixin(
  LightningElement
) {
  maxrowselection = 1;
  @track record = {};
  mandates;
  @api response;
  @api launchedFrom;
  columns = columns;
  isOpen = false;
  totalRecords = 0;
  pageSize = 10;
  totalPages;
  pageNumber = 1;
  recordsToDisplay = [];
  mandateRecords;
  selectedRecords;
  showTableWoCheckboxes = false;
  isFiredFromSameComp = false;
  selectedRows = [];
  currentAgreementsHeader = CURRENT_AGREEMENTS_HEADER;
  pausedAgreementsHeader = PAUSED_AGREEMENTS_HEADER;
  cancelledAgreementsHeader = CANCELLED_AGREEMENTS_HEADER;

  get tableHeader() {
    if (this.response[0].hasError) {
      return "An error has occurred while loading mandates for this customer";
    } else if (this.response[0].mandates?.length > 0) {
      if (this.response[0].tableName === "current") {
        return this.currentAgreementsHeader;
      } else if (this.response[0].tableName === "paused") {
        return this.pausedAgreementsHeader;
      } else if (this.response[0].tableName === "cancelled") {
        return this.cancelledAgreementsHeader;
      }
      return null;
    }
    return (
      "There are no " +
      this.response[0].tableName +
      " agreements for this customer."
    );
  }

  connectedCallback() {
    if (this.launchedFrom === "omniscript") {
      this.handleOmniLaunchedData();
    } else {
      this.mandates = this.response[0].mandates;
      this.handleErrorRefresh();
      this.calculateLength();
    }
    this.handleConditionalDatatable();
    this.handleSingleMandateEventListener();
  }

  // Listen to the custom event if the lwc is laucnched from the omniscript
  handleOmniLaunchedData() {
    window.addEventListener("onrecordselection", this.handleMessage.bind(this));
  }

  // Listen to the custom event that handles the single row selection across tables
  handleSingleMandateEventListener() {
    window.addEventListener("onmandateselection", this.handleClearSelection);
  }

  handleErrorRefresh() {
    if (this.response[0].hasError) {
      this.dispatchEvent(
        new CustomEvent("checkRefresh", {
          bubbles: true,
          composed: true
        })
      );
    }
  }

  handleMessage(event) {
    const selectedMandateRecord = event.detail.value;
    // eslint-disable-next-line
    this.mandates = selectedMandateRecord;
    if (this.mandates !== null || this.mandates !== undefined) {
      let selectedMandate = {
        MandateObj: this.mandates[0]
      };
      this.omniApplyCallResp(selectedMandate);
      this.calculateLength();
    }
  }

  handleConditionalDatatable() {
    return (this.showTableWoCheckboxes =
      this.launchedFrom === "omniscript" ? true : false);
  }

  // Fires custom event on selection of the record
  handlerowselection() {
    this.selectedRecords = this.template
      .querySelector("lightning-datatable")
      .getSelectedRows();
    if (this.selectedRecords.length > 0) {
      this.isFiredFromSameComp = true;
      this.handleSingleMandateSelection();

      if (this.selectedRecords[0].status === "MANDATE_STATUS_CODE_SUSPENDED") {
        this.handlePausedMandateSelection();
      }
      if (this.selectedRecords[0].status === "MANDATE_STATUS_CODE_ACTIVE") {
        this.handleActiveMandateSelection();
      }
      this.dispatchEvent(
        new CustomEvent("onrecordselection", {
          detail: { value: this.selectedRecords },
          bubbles: true,
          composed: true
        })
      );
    }
  }

  // Fires Custom Event to make active mandate button enable
  handleActiveMandateSelection() {
    this.dispatchEvent(
      new CustomEvent("active", {
        bubbles: true,
        composed: true
      })
    );
  }

  // Fires Custom Event to make paused mandate button enable
  handlePausedMandateSelection() {
    this.dispatchEvent(
      new CustomEvent("paused", {
        bubbles: true,
        composed: true
      })
    );
  }

  // Fires custom event on record selection to allow single row selection
  handleSingleMandateSelection() {
    this.dispatchEvent(
      new CustomEvent("onmandateselection", {
        bubbles: true,
        composed: true
      })
    );
  }

  // handles the logic that allows only single record selection across tables
  handleClearSelection = () => {
    if (this.isFiredFromSameComp === false && this.selectedRecords != null) {
      this.template.querySelector("lightning-datatable").selectedRows = [];
    }
    this.isFiredFromSameComp = false;
  };

  // Calculates total length of the records and displays buttons accordingly
  calculateLength() {
    if (this.mandates !== null || this.mandates !== undefined) {
      this.totalRecords = this.mandates?.length;
      this.handleObjectProperties();
    } else {
      this.totalRecords = 0;
    }
  }

  // creates new property in object
  handleObjectProperties() {
    this.mandateRecords = JSON.parse(JSON.stringify(this.mandates));
    this.mandateRecords?.forEach((row) => {
      if (row.paymentInformation.amount != null) {
        row.amount =
          "$" +
          this.handleAmountConversion(
            row.paymentInformation.amount.units,
            row.paymentInformation.amount.nanos
          );
      }
      row.startDate = this.handleDateConversion(
        row.validityStartDate.day,
        row.validityStartDate.month,
        row.validityStartDate.year
      );
      row.accountNumber =
        row.debtorInformation.destinationAccount != null
          ? row.debtorInformation.destinationAccount.transactionAccountNumber
          : "";
      row.payId =
        row.debtorInformation.payid != null
          ? row.debtorInformation.payid.accountAliasIdentification
          : "";
      if (row.paymentInformation.maximumAmount != null) {
        row.maxAmount =
          "$" +
          this.handleAmountConversion(
            row.paymentInformation.maximumAmount.units,
            row.paymentInformation.maximumAmount.nanos
          );
      }
    });
    this.paginationHelper();
  }

  // converts units and nanos to salesforce decimal
  handleAmountConversion(units, nanos) {
    let unitValue =
      parseFloat(units) !== null &&
      parseFloat(units) !== undefined &&
      !isNaN(parseFloat(units))
        ? parseFloat(units)
        : 0;
    let nanosValue =
      parseFloat(nanos) !== null &&
      parseFloat(nanos) !== undefined &&
      !isNaN(parseFloat(nanos))
        ? parseFloat(nanos)
        : 0;
    return (unitValue + nanosValue / 1000000000).toFixed(2);
  }

  handleDateConversion(day, month, year) {
    return day + "-" + month + "-" + year;
  }

  get showComponent() {
    return this.totalRecords > 0;
  }

  get showNavButtons() {
    return this.totalRecords > 10 ? true : false;
  }

  // handles reocrd level actions
  handleRowAction(event) {
    const actionName = event.detail.action.name;
    this.isOpen = true;
    const row = event.detail.row;
    switch (actionName) {
      case "showdetails":
        this.showRowDetails(row);
        break;
      default:
    }
  }

  get bDisableFirst() {
    return this.pageNumber === 1;
  }

  get bDisableLast() {
    return this.pageNumber === this.totalPages;
  }

  nextPage() {
    this.pageNumber = this.pageNumber + 1;
    this.paginationHelper();
  }

  paginationHelper() {
    let originalRecords;
    if (this.launchedFrom === "omniscript") {
      this.recordsToDisplay = [];
    } else {
      originalRecords = JSON.parse(JSON.stringify(this.recordsToDisplay));
    }
    // calculate total pages
    this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
    // set page number
    if (this.pageNumber <= 1) {
      this.pageNumber = 1;
    } else if (this.pageNumber >= this.totalPages) {
      this.pageNumber = this.totalPages;
    }
    // set records to display on current page
    for (
      let i = (this.pageNumber - 1) * this.pageSize;
      i < this.pageNumber * this.pageSize;
      i++
    ) {
      if (i === this.totalRecords) {
        break;
      }
      if (this.mandateRecords != null) {
        if (this.launchedFrom === "omniscript") {
          this.recordsToDisplay.push(this.mandateRecords[i]);
        } else {
          originalRecords.push(this.mandateRecords[i]);
          this.recordsToDisplay = originalRecords;
        }
      }
    }
  }

  showRowDetails(row) {
    this.record = row;
  }

  hideModalBox() {
    this.isOpen = false;
  }
}
