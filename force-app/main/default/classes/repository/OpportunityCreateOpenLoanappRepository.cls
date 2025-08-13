/**
 * @author Prahlad Bhadani
 * @since  November 2024
 * @group MLCRM (Mobile Lending CRM)
 * @description Repository for OpportunityCreateOpenLoanappController
 */
public with sharing class OpportunityCreateOpenLoanappRepository {
  /**
   * @description fetch Opportunity details
   * @param recordId String
   * @return Opportunity
   */
  public Opportunity getOpportunity(String recordId) {
    if (String.isBlank(recordId)) {
      return null;
    }
    return [
      SELECT
        Id,
        Name,
        Opportunity_ID__c,
        Servicing_Branch__c,
        AccountId,
        Account.Source_System_Id__c,
        Account.OCV_ID__c,
        Account.ANZx_Customer__c,
        AIP_Requested__c,
        OwnerId,
        Owner.Lan_Id__c,
        Owner.FirstName,
        Owner.LastName,
        Owner.Email,
        TPMI__c,
        Customer_Needs__c,
        Amount,
        Expected_Settlement_Date__c,
        Loanapp_Reference__c,
        Application_Key__c,
        Territory__c,
        (
          SELECT
            Id,
            Contact.FirstName,
            Contact.LastName,
            Contact.AccountId,
            Contact.BirthDate,
            Contact.Gender__c,
            Role,
            Source_System_Id__c
          FROM opportunityContactRoles
          ORDER BY CreatedDate
        )
      FROM Opportunity
      WHERE Id = :recordId
      WITH USER_MODE
      LIMIT 1
    ] ?? null;
  }

  /**
   * @description fetch user territory details
   * @param ownerId String
   * @param territoryId String
   * @return User_Territory__c
   */
  public User_Territory__c getUserTerritory(
    String ownerId,
    String territoryId
  ) {
    if (String.isBlank(ownerId) || String.isBlank(territoryId)) {
      return null;
    }
    return [
      SELECT Id, SAO__c
      FROM User_Territory__c
      WHERE User__c = :ownerId AND Territory__c = :territoryId
      WITH USER_MODE
      LIMIT 1
    ] ?? null;
  }
}
