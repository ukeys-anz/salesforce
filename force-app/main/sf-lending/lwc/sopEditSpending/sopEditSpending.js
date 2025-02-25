import { api, wire } from "lwc";
import { handleErrorShowToast, showToast } from "c/utils";
import { publish, MessageContext } from "lightning/messageService";

import LightningModal from "lightning/modal";
import RefreshSOP from "@salesforce/messageChannel/RefreshSOP__c";
import editExpense from "@salesforce/apex/SOPController.editExpense";

export default class MyModal extends LightningModal {
  @api content;
  @api recordId;
  @api sop;

  @wire(MessageContext)
  messageContext;

  updatedExpenses = [];
  componentSpinner = false;

  get expense() {
    return JSON.parse(this.content);
  }

  get expenses() {
    return this.hasExpenseChildren
      ? this.expense.children
      : [{ ...this.expense, isLevel2: true }];
  }

  get hasExpenseChildren() {
    return this.expense.children && this.expense.children.length > 0;
  }

  _haveExpensesChanged() {
    return (
      JSON.stringify(this.updatedExpenses) !== JSON.stringify(this.expenses)
    );
  }

  _buildExpenseModel() {
    const monthlyExpenses = this.updatedExpenses.map((expense) => {
      return {
        ...expense,
        name: expense.sopName
      };
    });

    //Expense model for the edit
    const SOPExpenseEditModel = {
      parent: this.sop,
      monthlyExpenses
    };

    return SOPExpenseEditModel;
  }

  connectedCallback() {
    this.updatedExpenses = this.expenses;
  }

  async handleSave() {
    if (
      !this.template.querySelector("c-sop-edit-spending-items").isInputValid()
    ) {
      return false;
    }

    try {
      this.componentSpinner = true;
      if (this._haveExpensesChanged()) {
        await editExpense({
          loanId: this.recordId,
          sopExpenseEditModel: this._buildExpenseModel()
        });
      }
      showToast(
        this,
        "",
        "The changes to the spend category were successfully saved.",
        "",
        "Success",
        ""
      );
      publish(this.messageContext, RefreshSOP, {
        refresh: true
      });
      this.close();
      return true;
    } catch (error) {
      handleErrorShowToast(
        this,
        "",
        null,
        "The monthly spend total didn’t update. Click 'Refresh All Amounts' or refresh the page to see the updated total."
      );
      return false;
    } finally {
      this.componentSpinner = false;
    }
  }

  handleUpdateExpense(event) {
    const { detail } = event;
    this.updatedExpenses = this.updatedExpenses.map((expense) => {
      return expense.sopName === detail.sopName ? detail : expense;
    });
  }

  handleClose() {
    this.close();
  }
}
