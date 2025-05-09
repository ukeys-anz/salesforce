/**
 * @author Pooja Kirtishahi
 * @since Nov 2024
 * @description Repository class for Loan Preference
 */

public with sharing class LoanApplicationFinancialRepository {
  /**
   * @description Query LoanApplicationFinancial fields
   * @param loanRecordId Loan record Id
   * @return LoanApplicationFinancial record
   */
  public LoanApplicationFinancial queryLAFByRLAId(Id loanRecordId) {
    return [
      SELECT
        Id,
        Name,
        LoanExclFinMortInsAmt,
        Current_Loan_Balance__c,
        Borrow_Additional_Funds__c,
        Last_Updated_Date__c,
        Interest_Rate_Type__c,
        Loan_Term_in_Months__c,
        Loan_Repayment_Type__c,
        Loan_Term__c,
        Loan_Margin__c,
        Offset__c,
        Loan_Repayment_Frequency__c,
        LoanApplication.Account.OCV_ID__c,
        LoanApplication.ApplicationExtIdentifier,
        LoanApplication.Property_Use__c,
        Percentage_Deductible__c,
        E_Tag__c,
        FinancialExtIdentifier
      FROM LoanApplicationFinancial
      WHERE LoanApplicationId = :loanRecordId
      WITH USER_MODE
      LIMIT 1
    ] ?? null;
  }
}
