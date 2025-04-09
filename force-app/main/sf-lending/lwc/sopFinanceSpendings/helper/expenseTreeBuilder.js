import {
  CATEGORIES_ICONS_SPENDINGS,
  CATEGORIES_ICONS_SPENDINGS_PARENT,
  CATEGORIES_DESCRIPTION_SPENDINGS,
  CATEGORIES_DESCRIPTION_SPENDINGS_PARENT,
  EXPENSES_WITH_PROMPTS,
  EXPENSES_WITH_PROPERTIES
} from "./import-sf-const";
import { setTimestamp } from "c/utils";

export const ExpenseTreeBuilder = {
  buildTree(spendings) {
    const mapExpenses = {};
    const rootExpenses = [];

    //initialise map and add desc and icon properties
    spendings.sortedExpenses.forEach((exp) => {
      const expenseName = exp.name === "LifeStyle" ? "Lifestyle" : exp.name;

      const prompts = EXPENSES_WITH_PROMPTS.includes(expenseName)
        ? this._assignPrompts(exp)
        : undefined;

      const descriptionVersion = this._getDescriptionVersion(
        spendings.sopSpendingsData.isLegacyExpenseConfigVersion,
        expenseName
      );

      const updatedExpense = {
        ...exp,
        ...prompts,
        name: expenseName,
        description: descriptionVersion,
        icon: CATEGORIES_ICONS_SPENDINGS[expenseName],
        updateTime: setTimestamp(exp.updateTime),
        children: []
      };

      //Adds Lifestyle and Other as it's own child for data structure
      if (["Lifestyle", "Other"].includes(expenseName)) {
        updatedExpense.children.push({ ...updatedExpense, children: [] });
      }

      mapExpenses[exp.sopName] = updatedExpense;
    });

    //Build the tree and add parent desc and icon
    Object.values(mapExpenses).forEach((exp) => {
      if (exp.expenseParent === "") {
        mapExpenses[exp.sopName] = {
          ...exp,
          description: CATEGORIES_DESCRIPTION_SPENDINGS_PARENT[exp.name],
          rootIcon: CATEGORIES_ICONS_SPENDINGS_PARENT[exp.name]
        };

        rootExpenses.push(mapExpenses[exp.sopName]);
      } else {
        const parent = mapExpenses[exp.expenseParent];
        if (!parent || parent.name === "Subscriptions, Phone & Internet") {
          return;
        }
        parent.children.push(mapExpenses[exp.sopName]);
      }
    });
    return this._propagateWarnings(rootExpenses);
  },
  //derrived warning logic
  _assignPrompts(expense) {
    const isWarningControl = expense.control === "EXPENSE_CONTROL_WARNING";
    const isBreachControl = expense.control === "EXPENSE_CONTROL_BREACHED";
    const isJustifiedControl = expense.control === "EXPENSE_CONTROL_JUSTIFIED";
    const isReviewCompleted = expense.review === "EXPENSE_REVIEW_COMPLETED";
    const isReviewRequired = expense.review === "EXPENSE_REVIEW_REQUIRED";

    const LOW_AMOUNT_WARNING =
      "This looks low. You can adjust the number or select a reason";
    const BIT_LOW_WARNING =
      "This looks a bit low. Please make sure it's accurate";

    const mandatoryExpense = {
      isMandatoryExpense: true,
      hasReason: false,
      hasWarning: false,
      warningMessage: undefined
    };

    if (isWarningControl && isReviewCompleted) {
      mandatoryExpense.warningMessage = BIT_LOW_WARNING;
    } else if (isBreachControl && isReviewRequired) {
      mandatoryExpense.hasWarning = true;
      mandatoryExpense.warningMessage = LOW_AMOUNT_WARNING;
    } else if (isJustifiedControl && isReviewCompleted) {
      mandatoryExpense.hasWarning = true;
      mandatoryExpense.hasReason = true;
      mandatoryExpense.warningMessage = LOW_AMOUNT_WARNING;
    }
    return mandatoryExpense;
  },

  //propagate warning to all related expenses if met
  _propagateWarnings(expenses) {
    expenses.forEach((exp) => {
      // Recursively propagate warnings to children first
      if (exp.children.length > 0) {
        this._propagateWarnings(exp.children);
      }

      // If at least one child has a warning
      const containsWarning = exp.children.some(
        (child) => child.hasWarning === true
      );

      if (containsWarning) {
        exp.hasWarning = true;
      }
    });

    return expenses;
  },

  //uses a different description for old expense version
  _getDescriptionVersion(isLegacyExpenseConfigVersion, expenseName) {
    const expenseDescription = CATEGORIES_DESCRIPTION_SPENDINGS[expenseName];
    if (expenseName === "Bills, Insurance & General") {
      return isLegacyExpenseConfigVersion
        ? expenseDescription.version1
        : expenseDescription.version2;
    }
    return expenseDescription;
  },

  sortExpenses(expenses, order) {
    return expenses.sort((x, y) => {
      return (
        order.findIndex((name) => name.toLowerCase() === x.name.toLowerCase()) -
        order.findIndex((name) => name.toLowerCase() === y.name.toLowerCase())
      );
    });
  },

  createAddressItems(expenses) {
    const householdExpense = expenses.find(
      (exp) => exp.name === "Household Costs"
    );

    if (!householdExpense) {
      return expenses;
    }

    const householdSopName = householdExpense.sopName;
    const addressItems = [];
    const updatedExpenses = expenses.map((exp) => {
      if (EXPENSES_WITH_PROPERTIES.includes(exp.name)) {
        const addressItem = {
          ...householdExpense,
          isPropertyAsParentExpense: true,
          sopName: exp.propertyId,
          singleLineAddress: exp.singleLineAddress,
          expenseParent: householdSopName,
          children: []
        };
        if (
          !addressItems.some((item) => item.sopName === addressItem.sopName)
        ) {
          addressItems.push(addressItem);
        }
        return { ...exp, expenseParent: addressItem.sopName, householdSopName };
      }
      return exp;
    });

    return [...updatedExpenses, ...addressItems];
  }
};
