/**
 * @description Repository class for Lending Case
 * @author Jaya Srivastava
 * @since Jan 2025
 */

public with sharing class LendingCaseRepository {
  /**
   * @description Query Case fields
   * @param recordId Id
   * @return  Case
   */
  public Case queryCaseByRecordId(Id recordId) {
    return [
      SELECT
        Id,
        Account.OCV_ID__c,
        Status,
        Loan_Account_Change_Number__c,
        FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c,
        Verified_By__c
      FROM Case
      WHERE Id = :recordId
      WITH USER_MODE
      LIMIT 1
    ] ?? null;
  }

  /**
   * @description Query Case fields using Loan account change name
   * @param changeNames List<String>
   * @return  List<Case>
   */
  public List<Case> queryCaseByChangeName(List<String> changeNames) {
    if (changeNames.isEmpty()) {
      return new List<Case>();
    }

    return [
      SELECT
        Id,
        Loan_Account_Change_Number__c,
        Sub_Type__c,
        Verified_By__c,
        Verified_By__r.name,
        caseNumber,
        Status
      FROM Case
      WHERE
        Loan_Account_Change_Number__c IN :changeNames
        AND Recordtype.Name = :'Lending'
      WITH USER_MODE
    ];
  }

  /**
   * @description Query Case fields using case Id
   * @param recordId Id
   * @return  Case
   */
  public Case queryCaseRLAById(Id recordId) {
    return [
      SELECT
        Id,
        Loan_Application__c,
        Loan_Application__r.Application_Progress__c
      FROM Case
      WHERE Id = :recordId
      WITH USER_MODE
      LIMIT 1
    ] ?? null;
  }
}
