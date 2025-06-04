/**
 * @description       :
 * @author            : Madhuri Edke | Salesforce
 * @group             :
 * @last modified on  : 05-28-2025
 * @last modified by  : Madhuri Edke | Salesforce
 **/

public with sharing class AssociatedLoanApplicationRepository {
  /**
   * @description to get related loan application record count
   * @author Madhuri Edke | Salesforce | 13-05-2025
   * @param interactionIds Set of Interaction Ids
   * @return  List<AggregateResult> getLoanApplicationsCount
   **/

  public List<AggregateResult> getLoanApplicationsCount(
    Set<Id> interactionIds
  ) {
    if (interactionIds.isEmpty()) {
      return new List<AggregateResult>();
    }

    return [
      SELECT Interaction__c, COUNT(Id) appCount
      FROM Associated_Loan_Application__c
      WHERE Interaction__c IN :interactionIds
      GROUP BY Interaction__c
    ];
  }

  /**
   * @description to get related loan applications
   * @author Madhuri Edke | Salesforce | 13-05-2025
   * @param interactionIds Set of Interaction Ids
   * @return  List<Associated_Loan_Application__c> List of Associated_Loan_Application__c
   **/

  public List<Associated_Loan_Application__c> getRelatedLoanApplication(
    Set<Id> interactionIds
  ) {
    if (interactionIds.isEmpty()) {
      return new List<Associated_Loan_Application__c>();
    }
    return [
      SELECT Id, Residential_Loan_Application__c, Interaction__c
      FROM Associated_Loan_Application__c
      WHERE Interaction__c IN :interactionIds
    ];
  }
}
