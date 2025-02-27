import { LightningElement, api } from "lwc";

export default class SopEditSpendingItems extends LightningElement {
  @api expenseItem;

  @api isInputValid = () => {
    const inputs = this.template.querySelectorAll("lightning-input");
    let isValid = true;

    inputs.forEach((input) => {
      input.reportValidity();
      if (!input.checkValidity()) {
        isValid = false;
      }
    });

    return isValid;
  };

  get headerTitle() {
    return this.isNotLevel2Expense ? this.expenseItem.name : "Spend Details";
  }

  get isNotLevel2Expense() {
    return !this.expenseItem.isLevel2;
  }

  handleMonthlySpendChange(event) {
    const { value } = event.target;
    // Dispatch the updated expenses
    this.dispatchEvent(
      new CustomEvent("updateexpense", {
        detail: { ...this.expenseItem, monthlySpend: value || 0 }
      })
    );
  }

  preventInvalidInputs(component) {
    const { key, target } = component;
    const value = target.value;

    const isInvalidKey = ["k", "m", "b", "t", "e"].includes(key);
    const isMultipleFullstops = key === "." && value.split(".").length > 1;
    const isExceedingTwoDecimals =
      value.includes(".") &&
      value.split(".")[1].length >= 2 &&
      key !== "Backspace";

    if (isInvalidKey || isMultipleFullstops || isExceedingTwoDecimals) {
      component.preventDefault();
    }
  }
}
