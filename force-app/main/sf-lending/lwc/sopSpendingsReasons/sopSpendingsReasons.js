import { api, LightningElement } from "lwc";
import EXPENSE_QUESTION from "@salesforce/resourceUrl/SOP_Expense_Question";

export default class SopSpendingsReasons extends LightningElement {
  expenseQuestionIcon = EXPENSE_QUESTION;
  @api expenseReasonsData;

  get expenseReason() {
    return this.expenseReasonsData.reason !== "Other"
      ? this.expenseReasonsData.reason
      : `${this.expenseReasonsData.reason} - ${this.expenseReasonsData.otherJustificationText}`;
  }
}
