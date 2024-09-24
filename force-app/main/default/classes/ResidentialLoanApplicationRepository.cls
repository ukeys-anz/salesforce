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
   * @description get RLA by id
   * @param recordId RLA recordId
   * @return  `ResidentialLoanApplication`
   */
  public ResidentialLoanApplication queryRLAById(String recordId) {
    if (
      String.isBlank(recordId) ||
      !PermissionUtils.canQuery('ResidentialLoanApplication')
    ) {
      return null;
    }

    return [
      SELECT
        Id,
        Assessment_Outcome__c,
        Status,
        Credit_ID__c,
        SOP_Id__c,
        Name,
        Account.OCV_ID__c,
        Credit_Reassess_Required__c
      FROM ResidentialLoanApplication
      WHERE Id = :recordId
    ];
  }
}
