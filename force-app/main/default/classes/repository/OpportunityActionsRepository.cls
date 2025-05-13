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
    return new SystemAction().getOpportunityByLoanappReference(larSet);
  }

  /**
   * @description return OpportunityContactRole using opp Ids
   * @param oppIdSet Loanapp_Reference__c of Opportunity
   * @return List<OpportunityContactRole>
   */
  public List<OpportunityContactRole> getOpportunityContactRolesByOppIds(
    Set<Id> oppIdSet
  ) {
    if (oppIdSet.isEmpty()) {
      return new List<OpportunityContactRole>();
    }
    return [
      SELECT Id, Opportunity.Loanapp_Reference__c, ExternalId__c
      FROM OpportunityContactRole
      WHERE OpportunityId IN :oppIdSet
      WITH USER_MODE
    ];
  }

  /**
   * @description return Opportunity_Contact_Role_Sync__c using ocr Ids
   * @param ocrIdSet Loanapp_Reference__c of Opportunity
   * @return List<Opportunity_Contact_Role_Sync__c>
   */
  public List<Opportunity_Contact_Role_Sync__c> getOCRSyncByOCRIds(
    Set<Id> ocrIdSet
  ) {
    if (ocrIdSet.isEmpty()) {
      return new List<Opportunity_Contact_Role_Sync__c>();
    }
    return [
      SELECT Id, OpportunityContactRoleId__c, ExternalId__c, Role__c
      FROM Opportunity_Contact_Role_Sync__c
      WHERE OpportunityContactRoleId__c IN :ocrIdSet
      WITH USER_MODE
    ];
  }

  /**
   * @description This class take care of Database operation that requires without sharing operation
   */
  private without sharing class SystemAction {
    /**
     * @description return Opportunities using Loanapp_Reference__c
     * using SYSTEM_MODE SOQL to scan through all ML Opportunities
     * @param larSet Loanapp_Reference__c of Opportunity
     * @return List<Opportunity>
     */
    public List<Opportunity> getOpportunityByLoanappReference(
      Set<String> larSet
    ) {
      if (larSet.isEmpty()) {
        return new List<Opportunity>();
      }
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
}
