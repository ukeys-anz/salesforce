/**
 * @author Ashwin Mohan
 * @since 04/2025
 * @description This class provide SOQL Repository for OpportunityContactRoleSyncActions & OpportunityContactRoleSyncActionsHelper class
 * Running this class in Without Sharing context, as per the current sharing setup, any user with the role
 * ANZx does not have access to classic customers (Where ANZ Plus Customer checkbox is not checked)
 * To avoid creating a sharing rule to grant access to Loan App GCP Integration User to all the accounts.
 * As this user is not solely being used for Simpology eventing functionality.
 */
public without sharing class OCRSyncActionsRepository {
  /**
   * @description return OCR records using Id
   * @name getOpportunityContactRoles
   * @param recordIds Set<Id>
   * @return List<OpportunityContactRole>
   */
  public List<OpportunityContactRole> getOpportunityContactRoles(
    Set<Id> recordIds
  ) {
    if (recordIds.isEmpty()) {
      return new List<OpportunityContactRole>();
    }
    return [
      SELECT Id, ContactId, OpportunityId, Role, ExternalId__c
      FROM OpportunityContactRole
      WHERE Id IN :recordIds
      WITH USER_MODE
    ];
  }

  /**
   * @description get opportunity from loanapp reference
   * @name getOpportunityFromLoanAppRef
   * @param loanAppRefSet Set of Loanapp Reference
   * @return List<Opportunity>
   */
  public List<Opportunity> getOpportunityFromLoanAppRef(
    Set<String> loanAppRefSet
  ) {
    if (loanAppRefSet.isEmpty()) {
      return new List<Opportunity>();
    }
    return [
      SELECT Id, Loanapp_Reference__c
      FROM Opportunity
      WHERE Loanapp_Reference__c IN :loanAppRefSet
      WITH USER_MODE
    ];
  }

  /**
   * @description get Customer from Source system External Id
   * @name getCustomerFromCapId
   * @param capIdSet Set of Cap Id
   * @return List<Account>
   */
  public List<Account> getCustomerFromCapId(Set<String> capIdSet) {
    if (capIdSet.isEmpty()) {
      return new List<Account>();
    }
    return [
      SELECT Id, PersonContactId, External_Id__c
      FROM Account
      WHERE External_Id__c IN :capIdSet
      WITH SYSTEM_MODE
    ];
  }
}
