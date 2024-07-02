/**
 * @author Peter Charalambous
 * @since Mon Jun 24 2024
 * @description Provides SOQL and DML helpers for LoanApplicationPropertyController
 */
public with sharing class LoanApplicationPropertyRepository {
  /**
   * @description Retrieves the Property details based on record id
   * @param recordId Record id of property to query
   * @return Loan application property details
   */
  public LoanApplicationProperty getLoanAppProperty(String recordId) {
    PermissionUtils.canQuery('LoanApplicationProperty');
    return [
      SELECT Id, Collateral_Assessment_ID__c, LoanApplication.Account.OCV_ID__c
      FROM LoanApplicationProperty
      WHERE Id = :recordId
    ];
  }

  /**
   * @description
   * @param recordTypeId case record type id
   * @param applicationIds set of residential loan application ids
   * @return  `List<Case>` cases related to the RLAs
   */
  public List<Case> queryRelatedCase(Id recordTypeId, Set<Id> applicationIds) {
    PermissionUtils.canQuery('Case');
    if (applicationIds.isEmpty()) {
      return new List<Case>();
    }
    return [
      SELECT Id, Loan_Application__c, Property_Valuation_Id__c
      FROM Case
      WHERE
        RecordTypeId = :recordTypeId
        AND Loan_Application__c IN :applicationIds
    ];
  }
}
