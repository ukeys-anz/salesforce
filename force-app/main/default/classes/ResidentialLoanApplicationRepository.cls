/**
 * @description repository class for Residential Loan Application
 * @author @fangl6
 * @since 24/06/2024
 */
public with sharing class ResidentialLoanApplicationRepository {
  /**
   * @description
   * @param loanId loan appklciation id
   * @param propertyIds set of property ids
   * @return  `List<LoanApplicationProperty>` properties related to the RLAs
   */
  public List<LoanApplicationProperty> queryRelatedProperties(
    Id loanId,
    Set<String> propertyIds
  ) {
    if (propertyIds.isEmpty()) {
      return new List<LoanApplicationProperty>();
    }
    return [
      SELECT Id, Name, Property_ID__c, PropertyValue, Address_Details__c
      FROM LoanApplicationProperty
      WHERE
        LoanApplicationId = :loanId
        AND Property_ID__c IN :propertyIds
        AND Property_ID__c != NULL
    ];
  }

  /**
   * @description
   * @param rlaRecordIds set of RLA ids
   * @return  `List<Case>` Cases related to the RLAs
   */
  public List<Case> queryRelatedCreditReferralCases(Set<Id> rlaRecordIds) {
    if (rlaRecordIds.isEmpty()) {
      return new List<Case>();
    }
    return [
      SELECT Id, Loan_Application__c
      FROM Case
      WHERE
        Loan_Application__c IN :rlaRecordIds
        AND RecordTypeId = :RTCase.creditReferral
        AND IsClosed = FALSE
    ];
  }
}
