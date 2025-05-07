/**
 * @author Jaya Srivastava
 * @since Nov 2024
 * @description Repository class for Additional Funds
 */
public with sharing class AdditionalFundsRepository {
  /**
   * @description Query AdditionalFunds fields
   * @param resLoanAppRecordId record Id
   * @return List<Additional_Fund__c> list of Additional Funds
   */

  public List<Additional_Fund__c> queryAddFundByRLAWithoutRefinance(
    Id resLoanAppRecordId
  ) {
    if (resLoanAppRecordId == null) {
      return new List<Additional_Fund__c>();
    }

    return [
      SELECT Id, Amount__c, Other_Reason__c, Purpose__c
      FROM Additional_Fund__c
      WHERE
        Loan_Application_Financial__r.LoanApplicationId = :resLoanAppRecordId
        AND Purpose__c != 'LENDING_PURPOSE_REFINANCE'
      WITH USER_MODE
    ];
  }
}
