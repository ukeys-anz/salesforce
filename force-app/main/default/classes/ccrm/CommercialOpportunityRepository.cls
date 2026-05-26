/**
 * @author Ayushi Gupta
 * @since  08/2024
 * @description This class contains public repository for all queries used in CommercialOpportunityctions
 */
public with sharing class CommercialOpportunityRepository {
  private static final String STATUS_COMPLETED = 'Completed';
  private static final String STATUS_NOT_REQUIRED = 'Not required';
  private static final String OPP_WON = 'Opportunity Won';
  private static final String OPP_LOST = 'Opportunity Lost';
  private static final String CLG = 'Customer Lending Group';
  public static final String RECIPROCAL_ROLE_FOR_CLG = 'CG';
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
        AND Status != :STATUS_COMPLETED
        AND Status != :STATUS_NOT_REQUIRED
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
        AND (Stage = :OPP_LOST
        OR Stage = :OPP_WON)
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
   * @description to query account records
   * @name getClosedAccountMap
   * @param accountIdsSet set of Account Ids
   * @return Map<Id, Account>
   */
  public Map<Id, Account> getClosedAccountMap(Set<Id> accountIdsSet) {
    if (accountIdsSet.isEmpty()) {
      return new Map<Id, Account>();
    }

    return new Map<Id, Account>(
      [
        SELECT Id, Name, RecordTypeId, FinServ__Status__c
        FROM Account
        WHERE
          Id IN :accountIdsSet
          AND FinServ__Status__c IN (
            'Closed',
            'Deceased',
            'Unknown',
            'Prospect'
          )
        WITH USER_MODE
      ]
    );
  }

  /**
   * @description getLostAFPRelatedToOpportunity gets lost AFP's related to opp
   * @param oppIds set of oppportunity ids
   * @return List<ApplicationFormProduct> app form products list
   */
  public List<Opportunity> getOpportunity(Set<Id> oppIds) {
    if (oppIds.isEmpty()) {
      return new List<Opportunity>();
    }

    return [
      SELECT Id, AccountId, Lead_Converted__c, Name, Opp_Id__c, recordtypeId
      FROM Opportunity
      WHERE Id IN :oppIds
      WITH USER_MODE
    ];
  }

  /**
   * @description getLostAFPRelatedToOpportunity gets lost AFP's related to opp
   * @param accountIds set of oppportunity ids
   * @return List<ApplicationFormProduct> app form products list
   */
  public List<FinServ__AccountAccountRelation__c> getAccountAccountRelationsForCLG(
    Set<Id> accountIds
  ) {
    if (accountIds.isEmpty()) {
      return new List<FinServ__AccountAccountRelation__c>();
    }

    List<FinServ__ReciprocalRole__c> roleId = [
      SELECT Id
      FROM FinServ__ReciprocalRole__c
      WHERE Name = :RECIPROCAL_ROLE_FOR_CLG
      WITH USER_MODE
      LIMIT 1
    ];

    if (roleId.isEmpty()) {
      return new List<FinServ__AccountAccountRelation__c>();
    }
    return [
      SELECT FinServ__Account__c, FinServ__RelatedAccount__c
      FROM FinServ__AccountAccountRelation__c
      WHERE
        FinServ__Account__c IN :accountIds
        AND FinServ__Role__c = :roleId[0].Id
      WITH USER_MODE
    ];
  }

  /**
   * @description getAFRelatedToOpportunity gets AF's related to opp
   * @param oppIdsSet set of oppportunity ids
   * @return List<ApplicationForm> app form list
   */
  public List<ApplicationForm> getAFRelatedToOpportunity(Set<Id> oppIdsSet) {
    if (oppIdsSet.isEmpty()) {
      return new List<ApplicationForm>();
    }

    return [
      SELECT Id, Name, OpportunityId, OwnerId
      FROM ApplicationForm
      WHERE OpportunityId IN :oppIdsSet
      WITH USER_MODE
    ];
  }

  /**
   * @description getAFShareRelatedToOpportunity gets AF's share related to opp
   * @param oppIdsSet set of oppportunity ids
   * @param oldOwnerIdsSet set of old owner ids
   * @return List<ApplicationFormShare> app form share list
   */
  public List<ApplicationFormShare> getAFShareRelatedToOpportunity(
    Set<Id> oppIdsSet,
    Set<Id> oldOwnerIdsSet
  ) {
    if (oppIdsSet.isEmpty() || oldOwnerIdsSet.isEmpty()) {
      return new List<ApplicationFormShare>();
    }

    return [
      SELECT
        Id,
        ParentId,
        UserOrGroupId,
        AccessLevel,
        RowCause,
        Parent.OpportunityId
      FROM ApplicationFormShare
      WHERE
        Parent.OpportunityId IN :oppIdsSet
        AND UserOrGroupId IN :oldOwnerIdsSet
        AND RowCause = 'Manual'
        AND AccessLevel = 'Edit'
      WITH SYSTEM_MODE
    ];
  }
  /**
   * @description getOpportunityDetails to retrieve the list if opportunities where id found in a set of ids
   * @author  A M Vikash | Salesforce | 28-10-2025
   * @param oppIds set of new opportunity  ids
   * @return List<Opportunity> A list of Opportunity records matching the provided Ids.
   */
  public List<opportunity> getOpportunityDetails(Set<Id> oppIds) {
    if (oppIds.isEmpty()) {
      return new List<opportunity>();
    }
    return [
      SELECT
        Id,
        Name,
        ownerid,
        AccountId,
        Broker_Name__c,
        Account.External_Id__c,
        Account.Source_System_Id__c,
        Opp_Id__c
      FROM opportunity
      WHERE Id IN :oppIds
      WITH USER_MODE
    ];
  }
  /**
   * @author A M Vikash | Salesforce | 02-11-2025
   * @description getApplicationFormsAndProducts to get ApplicationForms & ApplicationFormsProducts records related to AMBIT RT of AF to create Oppoerunity and Opportunity Products
   * @param filteredOptyIds List of Opportunity records to check.
   * @return List<ApplicationForm> app forms list
   */
  public List<ApplicationForm> getApplicationFormsAndProducts(
    Set<Id> filteredOptyIds
  ) {
    if (filteredOptyIds.isEmpty()) {
      return new List<ApplicationForm>();
    }
    return [
      SELECT
        Id,
        OpportunityId,
        (
          SELECT Id
          FROM ApplicationFormProducts
          WHERE Reference_Number__c != NULL
        )
      FROM ApplicationForm
      WHERE
        OpportunityId IN :filteredOptyIds
        AND RecordTypeId = :RTApplicationForm.ambitApplication
      WITH USER_MODE
    ];
  }
  /**
   * @description Retrieves the Standard Pricebook record used for Opportunity Product creation.
   *              Assumes there is always one standard pricebook in the org.
   * @return Pricebook2 record where IsStandard = TRUE
   * @author
   *   A M Vikash | Salesforce | 13-11-2025
   */
  public Pricebook2 getStandardPricebook() {
    return [
      SELECT Id, Name, IsStandard
      FROM Pricebook2
      WHERE IsStandard = TRUE
      WITH USER_MODE
      LIMIT 1
    ];
  }

  /**
   * @description Retrieves lead details for verification in System Mode
   * @param leadIds Lead IDs
   * @param oppIds set of Opportunity IDs
   * @return List<Lead>
   */
  public List<Lead> getReferralLeadDetails(
    Set<String> leadIds,
    Set<Id> oppIds
  ) {
    if (leadIds.isEmpty()) {
      return new List<Lead>();
    }
    return [
      SELECT Id, External_Id__c, RecordTypeId, Lead_Auto_Number__c, Channel__c
      FROM Lead
      WHERE
        Lead_Auto_Number__c IN :leadIds
        AND External_Id__c != NULL
        AND ConvertedOpportunityId IN :oppIds
      WITH SYSTEM_MODE
    ];
  }
}
