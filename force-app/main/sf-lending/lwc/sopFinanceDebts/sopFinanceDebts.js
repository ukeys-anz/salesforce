import { LightningElement, api, wire } from "lwc";
import SOP_DEBTS from "@salesforce/resourceUrl/SOP_Debts";
import hasAddPermission from "@salesforce/customPermission/SOP_Add";
import hasEditPermission from "@salesforce/customPermission/SOP_Edit";
import hasDeletePermission from "@salesforce/customPermission/SOP_Delete";
import { getRecord } from "lightning/uiRecordApi";
import {
  TYPE_MAP,
  DEBTS_MAP,
  FREQUENCY_MAP,
  handleFieldConditions,
  ACCOUNT_STATUS
} from "./helper";
import SopAddDebtsContainer from "c/sopAddDebtsContainer";
import SopEditDebtsContainer from "c/sopEditDebtsContainer";
import SopFinanceDeleteModal from "c/sopFinanceDeleteModal";

const FIELDS = ["ResidentialLoanApplication.Status"];

const SOURCE_MAP = {
  LIABILITY_SOURCE_TYPE_MANUAL: "Manual",
  LIABILITY_SOURCE_TYPE_BUREAU: "Credit Bureau",
  LIABILITY_SOURCE_TYPE_ANZ: "ANZ"
};
export default class SopFinanceDebts extends LightningElement {
  @api recordId;
  @api sopDebtsData;
  @api sopPartiesData;
  debtsData; //Use to clone the sopDebtsData
  noDataAvailable = false;
  errorMessage;
  sopDebtsImage = SOP_DEBTS;
  debts;
  allowEdit;
  allowAdd;
  allowDelete;

  get totalDebtAmount() {
    return -this.sopDebtsData.debtsTotalAmount;
  }

  @wire(getRecord, { recordId: "$recordId", fields: FIELDS })
  wiredRecord({ data }) {
    if (data) {
      this.allowAdd =
        hasAddPermission && data.fields.Status.value === "STATE_REFERRED";
      this.allowEdit =
        hasEditPermission && data.fields.Status.value === "STATE_REFERRED";
      this.allowDelete =
        hasDeletePermission && data.fields.Status.value === "STATE_REFERRED";
    }
  }

  connectedCallback() {
    this.debts = JSON.parse(JSON.stringify(DEBTS_MAP));
    //Check if data is not null
    if (this.sopDebtsData?.debts && this.sopDebtsData?.debts.length > 0) {
      this.handleDebts(this.sopDebtsData);
    } else {
      this.noDataAvailable = true;
    }
  }

  handleDebts(sopDebtsData) {
    //Need to clone data since cache is read only
    this.debtsData = JSON.parse(JSON.stringify(sopDebtsData));
    //Sort data in descending order by balance
    this.debtsData.debts.sort((a, b) => {
      //Sort by balance ascending if theres balance
      if (a.outstandingBalance && b.outstandingBalance) {
        return a.outstandingBalanceNegative - b.outstandingBalanceNegative;
      }
      //Sort by limit ascending if theres limit
      return (
        a.institutionalLiability?.limitAmountNegative -
        b.institutionalLiability?.limitAmountNegative
      );
    });

    let homeLoanCount = this.debtsData.debts.filter(
      (debt) => debt.type === "LIABILITY_TYPE_HOME_LOAN"
    ).length;

    //Loop through savings data and sort into the savings sections
    this.debtsData.debts.forEach((debt) => {
      debt.readableSourceType = SOURCE_MAP[debt.sourceType];
      debt.readableType = TYPE_MAP[debt.type];
      debt.showDeleteBtn = debt.readableSourceType === "Manual";

      if (
        (debt.readableType === "Home Loan" ||
          debt.readableType === "Line of Credit") &&
        debt.hasRefinance
      ) {
        debt.showDeleteBtn = false;
      }

      debt.readableFrequency = debt.institutionalLiability?.repaymentFrequency
        ? FREQUENCY_MAP[debt.institutionalLiability.repaymentFrequency]
        : "";
      debt.lastModified = this.setTimestamp(debt.updateTime);
      //Set certain field labels here as some debt types require a different label,
      //in which we override on the handleFieldConditionsMethod
      debt.redrawLabel = "Redraw Amount";
      debt.monthlyRepaymentLabel = "Monthly Repayment";
      debt.limitLabel = "Limit"; //prefix label for type of limit in switch below
      debt.bureauLimitLabel = "Credit Bureau Limit "; // append the limit type in switch below
      debt.paidInFullValue = debt.institutionalLiability?.paidInFull
        ? "Yes"
        : "No";
      debt.customerStatedClosedValue = debt.customerStatedClosed ? "Yes" : "No";
      debt.readableStatus =
        debt.status !== null ? ACCOUNT_STATUS[debt.status] : "";
      //Set debt to be editable by default
      debt.debtEditable = true;
      let foundDebt; //Declare here as lint rules prevent declaration of variables in switch case
      switch (debt.readableType) {
        case "Home Loan":
          debt.debtEditable = debt.hasRefinance ? false : true;
          if (debt.readableSourceType !== "ANZ") {
            debt.redrawLabel = "Available Redraw"; //Label is different specific on manual home loan
          }
          foundDebt = this.debts.find((d) => d.title === debt.readableType);
          handleFieldConditions(debt);
          foundDebt.debts.push(debt);
          if (homeLoanCount === 1) {
            debt.showDeleteBtn = false;
          }
          break;
        case "Credit Card":
          //Label is different specific on ANZ credit card
          if (debt.readableSourceType === "ANZ") {
            debt.monthlyRepaymentLabel = "Minimum Monthly Repayment";
          }
          debt.limitLabel = "Credit Limit";
          debt.bureauLimitLabel = "Credit Bureau Credit Limit";
          foundDebt = this.debts.find((d) => d.title === debt.readableType);
          handleFieldConditions(debt);
          foundDebt.debts.push(debt);
          break;
        case "Personal Loan":
          if (debt.readableSourceType === "ANZ") {
            debt.redrawLabel = "Available Redraw"; //Label is different specific on anz personal loan
          }
          foundDebt = this.debts.find((d) => d.title === debt.readableType);
          handleFieldConditions(debt);
          foundDebt.debts.push(debt);
          break;
        case "Vehicle Loan":
          foundDebt = this.debts.find((d) => d.title === debt.readableType);
          handleFieldConditions(debt);
          foundDebt.debts.push(debt);
          break;
        case "Buy Now Pay Later":
          debt.arrangementType =
            debt.type === "LIABILITY_TYPE_BPL_FACILITY"
              ? "Spend Limit"
              : debt.type === "LIABILITY_TYPE_BPL_LOAN"
                ? "Fixed Amount"
                : "";
          debt.limitLabel = "Spend Limit";
          debt.bureauLimitLabel = "Credit Bureau Spend Limit";
          foundDebt = this.debts.find((d) => d.title === debt.readableType);
          handleFieldConditions(debt);
          foundDebt.debts.push(debt);
          break;
        case "Vehicle Lease/Hire Purchase":
          foundDebt = this.debts.find((d) => d.title === debt.readableType);
          handleFieldConditions(debt);
          foundDebt.debts.push(debt);
          break;
        case "HECS-HELP":
          debt.hecsWithheldPaymentValue = debt.studentLoan?.hecsWithheldPayment
            ? "Yes"
            : "No";
          foundDebt = this.debts.find((d) => d.title === debt.readableType);
          handleFieldConditions(debt);
          foundDebt.debts.push(debt);
          break;
        case "Line of Credit":
          debt.debtEditable = debt.hasRefinance ? false : true;
          debt.limitLabel = "Credit Limit";
          debt.bureauLimitLabel = "Credit Bureau Credit Limit";
          foundDebt = this.debts.find((d) => d.title === debt.readableType);
          handleFieldConditions(debt);
          foundDebt.debts.push(debt);
          break;
        case "Overdraft":
          debt.limitLabel = "Overdraft Limit";
          debt.bureauLimitLabel = "Credit Bureau Overdraft Limit";
          foundDebt = this.debts.find((d) => d.title === debt.readableType);
          handleFieldConditions(debt);
          foundDebt.debts.push(debt);
          break;
        case "Margin Loan":
          debt.limitLabel = "Credit Limit";
          foundDebt = this.debts.find((d) => d.title === debt.readableType);
          handleFieldConditions(debt);
          foundDebt.debts.push(debt);
          break;
        case "Other Loan":
          foundDebt = this.debts.find((d) => d.title === debt.readableType);
          handleFieldConditions(debt);
          foundDebt.debts.push(debt);
          break;
        case "Other Limit Liability":
          foundDebt = this.debts.find((d) => d.title === debt.readableType);
          handleFieldConditions(debt);
          foundDebt.debts.push(debt);
          break;
        default:
          break;
      }
    });

    //Remove any section that doesnt have any debts so we dont loop through
    this.debts = this.debts.filter((el) => el.debts.length > 0);

    // Sort Home Loans and Line of Credit
    ["Home Loan", "Line of Credit"].forEach((title) => {
      const liability = this.debts.find((d) => d.title === title);
      if (liability?.debts?.length) {
        liability.debts = this._sortHomeLoC(liability.debts);
      }
    });
  }

  _sortHomeLoC(debts) {
    return debts.sort((a, b) => {
      //refinanced loans first
      if (a.hasRefinance !== b.hasRefinance) {
        return a.hasRefinance ? -1 : 1;
      }

      //sort by linkedProperty existence
      const hasPropertyA = a.linkedProperty?.length > 0 && a.showLinkedProperty;
      const hasPropertyB = b.linkedProperty?.length > 0 && b.showLinkedProperty;
      if (hasPropertyA !== hasPropertyB) {
        return hasPropertyA ? -1 : 1;
      }
      if (!hasPropertyA || !hasPropertyB) {
        return 0;
      }

      //sort by property name
      const aLinkedProperty = a.linkedProperty?.[0] || "";
      const bLinkedProperty = b.linkedProperty?.[0] || "";
      const propertyComparison = aLinkedProperty.localeCompare(bLinkedProperty);
      if (propertyComparison !== 0) {
        return propertyComparison;
      }

      //sort by property array size
      const sizeA = a.linkedProperty?.length || 0;
      const sizeB = b.linkedProperty?.length || 0;
      return sizeB - sizeA;
    });
  }

  setTimestamp(timestamp) {
    //Create timestamp for last updated
    let lastModified = new Date(timestamp);
    lastModified =
      lastModified.getDate() +
      " " +
      lastModified.toLocaleString("en-AU", {
        month: "long"
      }) +
      " " +
      lastModified.getFullYear() +
      " | " +
      lastModified.toLocaleString("en-AU", {
        hour: "numeric",
        minute: "numeric",
        hour12: true
      });
    return lastModified;
  }

  handleAddDebt() {
    SopAddDebtsContainer.open({
      size: "medium",
      recordId: this.recordId,
      parties: this.sopPartiesData,
      refinancedAssets: this.debtsData.refinancedAssets,
      propertyAssets: this.debtsData.propertyAssets
    });
  }

  handleEditDebt(e) {
    let debtId = e.target.dataset.id;
    let debtData = this.debtsData.debts.find((debt) => debt.uid === debtId);
    SopEditDebtsContainer.open({
      size: "medium",
      recordId: this.recordId,
      debtData: debtData,
      debtType: debtData.type,
      parties: this.sopPartiesData,
      refinancedAssets: this.debtsData.refinancedAssets,
      propertyAssets: this.debtsData.propertyAssets
    });
  }

  handleDeleteClick(e) {
    let debtId = e.target.dataset.id;
    let debtData = this.debtsData.debts.find((debt) => debt.uid === debtId);
    let allowDeleteRecord = true;

    SopFinanceDeleteModal.open({
      size: "small",
      recordDetails: debtData,
      isDeletionAllowed: allowDeleteRecord,
      sopType: "Debt",
      recordId: this.recordId
    });
  }
}
