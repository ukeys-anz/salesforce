import { api, LightningElement } from "lwc";

export default class SopSpendingsL1Item extends LightningElement {
  @api expenseDataL1;
  @api recordId;
  @api sop;

  isL1ExpensesVisible = true;
  isL2ExpensesVisible = false;
  selectedExpense;

  //Conditionally render L2
  showL2Expenses(event) {
    const section = event.currentTarget.dataset.id;

    this.selectedExpense = this.expenseDataL1.find(
      (expense) => expense.name === section
    );
    this.toggleExpenseLevelVisibility();
    this.setSpendingContainer();
  }

  //Hide L2
  hideL2Expenses() {
    this.toggleExpenseLevelVisibility();
    this.setSpendingContainer();
  }

  //Toggle values for visiblity of all levels
  toggleExpenseLevelVisibility() {
    this.isL1ExpensesVisible = !this.isL1ExpensesVisible;
    this.isL2ExpensesVisible = !this.isL2ExpensesVisible;
  }

  //To send communication to root for container visibility
  setSpendingContainer() {
    const event = new CustomEvent("expenseselect");
    // Dispatch the event
    this.dispatchEvent(event);
  }
}
