/**
 * @author Ayushi Gupta
 * @since  08/2024
 * @description This class contains public repository for all queries used in CommercialOpportunityctions
 */
public with sharing class CommercialOpportunityRepository {
  private static final String CLG = 'Customer Lending Group';
  /**
   * @description getUsers to get user records
   * @param userIds set of user ids
   * @return List<User> user list
   */
  public List<User> getUsers(List<Id> userIds) {
    if (userIds.isEmpty() || !PermissionUtils.canQuery('User')) {
      return new List<User>();
    }
    return [SELECT Id, Commercial_Segment__c FROM User WHERE Id IN :userIds];
  }

  /**
   * @description getOpenTasksOnClosedOpportunity to get open tasks
   * @param oppIds set of oppportunity ids
   * @return List<Map<String, Object>> tasks list
   */
  public List<Map<String, Object>> getOpenTasksOnClosedOpportunity(
    Set<Id> oppIds
  ) {
    List<Map<String, Object>> result = new List<Map<String, Object>>();

    if (oppIds.isEmpty()) {
      return result;
    }
    for (AggregateResult ar : [
      SELECT WhatId
      FROM Task
      WHERE
        WhatId IN :oppIds
        AND Status != :CCRMConstants.STATUS_COMPLETED
        AND Status != :CCRMConstants.STATUS_NOT_REQUIRED
      WITH USER_MODE
      GROUP BY WhatId
    ]) {
      result.add(ar.getPopulatedFieldsAsMap());
    }
    return result;
  }

  /**
   * @description It will fetch the user Profile Id
   * @return Id Profile Id of the current user
   */
  public Id getUserProfileId() {
    return UserInfo.getProfileId();
  }

  /**
   * @description getLostAFPRelatedToOpportunity gets lost AFP's related to opp
   * @param oppIds set of oppportunity ids
   * @return List<ApplicationFormProduct> app form products list
   */
  public List<ApplicationFormProduct> getLostAFPRelatedToOpportunity(
    Set<Id> oppIds
  ) {
    if (oppIds.isEmpty()) {
      return new List<ApplicationFormProduct>();
    }

    return [
      SELECT
        Id,
        Name,
        ApplicationForm.OpportunityId,
        Stage,
        Lost_reason__c,
        Lost_Reason_Detail__c,
        Won_from_Lost_to__c
      FROM ApplicationFormProduct
      WHERE
        ApplicationForm.OpportunityId IN :oppIds
        AND (Stage = :CCRMConstants.OPP_LOST
        OR Stage = :CCRMConstants.OPP_WON)
      WITH USER_MODE
    ];
  }

  /**
   * @description to query account account relationship records
   * @name getAccountAccountRelations
   * @param accountIdsSet set of Account Ids
   * @return List<FinServ__AccountAccountRelation__c>
   */
  public List<FinServ__AccountAccountRelation__c> getAccountAccountRelations(
    Set<Id> accountIdsSet
  ) {
    if (accountIdsSet.isEmpty()) {
      return new List<FinServ__AccountAccountRelation__c>();
    }

    return [
      SELECT
        Id,
        Name,
        Relationship__c,
        FinServ__Account__c,
        FinServ__RelatedAccount__c,
        FinServ__RelatedAccount__r.RecordTypeId,
        FinServ__RelatedAccount__r.CLG__c
      FROM FinServ__AccountAccountRelation__c
      WHERE
        FinServ__Account__c IN :accountIdsSet
        AND Relationship__c = :CLG
        AND FinServ__RelatedAccount__r.RecordTypeId = :RTAccount.clgAccount
      WITH USER_MODE
    ];
  }

  /**
   * @description to query account records
   * @name getAccountMap
   * @param accountIdsSet set of Account Ids
   * @return Map<Id, Account>
   */
  public Map<Id, Account> getAccountMap(Set<Id> accountIdsSet) {
    if (accountIdsSet.isEmpty()) {
      return new Map<Id, Account>();
    }

    return new Map<Id, Account>(
      [
        SELECT
          Id,
          Name,
          RecordTypeId,
          FinServ__Status__c,
          CLG__c,
          CPID__c,
          Controlling_Post__c,
          Controlling_Post__r.OwnerId,
          RecordType.Name
        FROM Account
        WHERE Id IN :accountIdsSet
        WITH USER_MODE
      ]
    );
  }

  /**
   * @description getAFPRelatedToOpportunity gets lost AFP's related to opp
   * @param oppIds set of oppportunity ids
   * @return List<ApplicationFormProduct> app form products list
   */
  public List<ApplicationFormProduct> getAFPRelatedToOpportunity(
    Set<Id> oppIds
  ) {
    if (oppIds.isEmpty()) {
      return new List<ApplicationFormProduct>();
    }

    return [
      SELECT
        Id,
        Name,
        ApplicationForm.OpportunityId,
        ProductId,
        Stage,
        Lost_reason__c,
        Lost_Reason_Detail__c,
        Won_from_Lost_to__c,
        Opportunity_Product__c
      FROM ApplicationFormProduct
      WHERE ApplicationForm.OpportunityId IN :oppIds
      WITH USER_MODE
    ];
  }

  /**
   * @description getOppProductsForOpportunity gets OLI related to opp
   * @param oppIds set of oppportunity ids
   * @return List<OpportunityLineItem> OLI list
   */
  public List<OpportunityLineItem> getOppProductsForOpportunity(
    Set<Id> oppIds
  ) {
    if (oppIds.isEmpty()) {
      return new List<OpportunityLineItem>();
    }

    return [
      SELECT Id, OpportunityId, Product2Id
      FROM OpportunityLineItem
      WHERE OpportunityId IN :oppIds
      WITH USER_MODE
    ];
  }
}
