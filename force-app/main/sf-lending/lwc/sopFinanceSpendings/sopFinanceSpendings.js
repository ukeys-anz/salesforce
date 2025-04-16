import { api, LightningElement } from "lwc";
import EXPENSE_CALCULATOR from "@salesforce/resourceUrl/SOP_Expense_Calculator";
import { ExpenseTreeBuilder } from "./helper/expenseTreeBuilder";
import {
  CATEGORIES_DESCRIPTION_SPENDINGS_PARENT as parentMap,
  CATEGORIES_DESCRIPTION_SPENDINGS as itemMap
} from "./helper/import-sf-const";

export default class SopFinanceSpendings extends LightningElement {
  expenseCalculator = EXPENSE_CALCULATOR;

  @api recordId;

  @api
  get sopSpendingsData() {
    return this._sopSpendingsData;
  }

  set sopSpendingsData(value) {
    this._sopSpendingsData = value;
    this.loadSOPSpendingsData();
  }

  _sopSpendingsData;

  sopSpendingsTree;
  sortedExpenses;
  spendingsContainer = true;

  sortOrderFromMaps = [
    ...new Set([...Object.keys(parentMap), ...Object.keys(itemMap)])
  ];

  loadSOPSpendingsData() {
    this.sortedExpenses = ExpenseTreeBuilder.sortExpenses(
      ExpenseTreeBuilder.createAddressItems([
        ...this.sopSpendingsData.monthlyExpenses
      ]),
      this.sortOrderFromMaps
    );
    this.sopSpendingsTree = ExpenseTreeBuilder.buildTree(this);
  }

  //Conditionally render spendingsContainer
  hideSpendingsContainer() {
    this.spendingsContainer = !this.spendingsContainer;
  }
}
