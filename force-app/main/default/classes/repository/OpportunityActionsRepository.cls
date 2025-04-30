/**
 * @author Hitesh Wasdani
 * @since 07/2024
 * @description This class provide SOQL and DML helper for class related to LeadConversionController and LeadConversionHelper.
 * Sharing has been removed since getAccount method needs to run in without sharing as per design
 */
public class OpportunityActionsRepository {
  /**
   * @description return Account using Id
   * @param accId Id of Account
   * @return Account
   */
  public Account getAccount(String accId) {
    if (String.isBlank(accId)) {
      return null;
    }
    return [
      SELECT PersoncontactId
      FROM Account
      WHERE Id = :accId
      WITH SYSTEM_MODE
    ];
  }

  /**
   * @description return Opportunities using Ids
   * @param oppIds Ids of Opportunity
   * @return List<Opportunity>
   */
  public List<Opportunity> getOpportunity(Set<Id> oppIds) {
    if (oppIds.isEmpty()) {
      return new List<Opportunity>();
    }
    return [
      SELECT Id, OwnerId, Account.personcontactId, recordTypeId
      FROM Opportunity
      WHERE Id IN :oppIds
      WITH USER_MODE
    ];
  }

  /**
   * @description return Opportunities using Loanapp_Reference__c
   * using SYSTEM_MODE SOQL to scan through all ML Opportunities
   * @param larSet Loanapp_Reference__c of Opportunity
   * @return List<Opportunity>
   */
  public List<Opportunity> getOpportunityByLoanappReference(
    Set<String> larSet
  ) {
    return [
      SELECT Id, Loanapp_Reference__c
      FROM Opportunity
      WHERE
        Loanapp_Reference__c IN :larSet
        AND RecordTypeId = :RTOpportunity.mlOpportunity
      WITH SYSTEM_MODE
    ];
  }
}
