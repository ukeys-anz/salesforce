/**
 * @description Provide methods for Databse operations on Expense_Control__c object
 * @author Pooja Kirtishahi
 * @since 05/2025
 */
public with sharing class ExpenseControlRepository {
  /**
   * @description query expense control based on justification codes
   * @param expenseCodeSet set of justification codes
   * @return  `List<Expense_Control__c>` the result of exepense control
   */
  public List<Expense_Control__c> getExpenseControlByExpenseCode(
    Set<String> expenseCodeSet
  ) {
    if (expenseCodeSet.isEmpty()) {
      return new List<Expense_Control__c>();
    }

    return [
      SELECT Id, Justification_Code__c, Justification_Description__c
      FROM Expense_Control__c
      WHERE Justification_Code__c IN :expenseCodeSet
      WITH USER_MODE
    ];
  }
}
