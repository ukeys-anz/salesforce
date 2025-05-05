import { api, wire, LightningElement } from "lwc";
import sopEditSpending from "c/sopEditSpending";
import hasAddPermission from "@salesforce/customPermission/SOP_Add";
import hasEditPermission from "@salesforce/customPermission/SOP_Edit";
import { getRecord } from "lightning/uiRecordApi";

import STATUS_FIELD from "@salesforce/schema/ResidentialLoanApplication.Status";

export default class SopSpendingsL2Item extends LightningElement {
  @api expenseDataL2;
  @api recordId;
  @api sop;

  expense;
  hasAddEditPermission;

  @wire(getRecord, { recordId: "$recordId", fields: [STATUS_FIELD] })
  wiredProject({ data }) {
    if (data) {
      this.hasAddEditPermission =
        (hasAddPermission || hasEditPermission) &&
        data.fields.Status.value === "STATE_REFERRED";
    }
  }

  connectedCallback() {
    if (!this.expenseDataL2) return;
    this.expense = [
      ...this.expenseDataL2.children.map((exp) => {
        return {
          ...exp,
          isCollapsed: true,
          isHousehold: exp.name === "Household Costs",
          serializedExpense: JSON.stringify(exp) // To pass the data to child component
        };
      })
    ];
  }
  // To show L3 sections of each category
  toggleL3Expenses(event) {
    const expenseName = event.currentTarget.dataset.id;
    // Only proceed if the section exists
    if (this.expense.some((exp) => exp.name === expenseName)) {
      this.expense = this.expense.map((exp) => {
        if (exp.name === expenseName) {
          return { ...exp, isCollapsed: !exp.isCollapsed };
        }
        return exp;
      });
    }
  }

  //Method to communicate to parent to go back to parent screen from child.
  goBackToRootExpenses() {
    const event = new CustomEvent("expenseselectl2");
    // Dispatch the event
    this.dispatchEvent(event);
  }

  handleClick(event) {
    const expense = event.currentTarget.dataset.expense;
    sopEditSpending.open({
      size: "medium",
      content: expense,
      recordId: this.recordId,
      sop: this.sop
    });
  }
}
