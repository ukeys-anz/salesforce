/**
 * @author Mairaj Haider
 * @since  06/2022
 * @group CCRM (Commercial CRM)
 * @description CCRMLegalEntityActions is class to handle all the CCRM Legal Entity Actions
 */
public with sharing class CCRMLegalEntityActions {
  @testVisible
  public static final String INCORRECT_LEGAL_ENTITY = 'Please choose only the Legal Entity related to the CLG account in the Opportunity. Please also note that CLG cannot be used as a borrower.';
  @testVisible
  public static final String INCORRECT_ACCOUNT_ON_LEGAL_ENTITY = 'Please use the same Legal Entity name as Customer in the Opportunity for your first product.';
  public static final String ACCOUNT_FIELD_NAME = 'Account__c';
  /**
   * @description This method will validate number of Entities added to opportunity product
   * should not be more than 20
   * @name validateAccount
   * @param records List of legal Entity records
   * @param oldMap Map of old records of Legal Entity
   */
  @SuppressWarnings('PMD.CyclomaticComplexity')
  public static void validateAccount(
    List<Legal_Entity__c> records,
    Map<Id, Legal_Entity__c> oldMap
  ) {
    Set<Id> oppProductsIds = new Set<Id>();
    Set<Id> accountIds = new Set<Id>();
    Map<Id, Id> mapoli = new Map<Id, Id>();
    Map<Id, Id> mapOfOliWithOpportunity = new Map<Id, Id>();
    Map<Id, Id> mapOfOliWithOpportunityAccount = new Map<Id, Id>();

    for (Legal_Entity__c record : records) {
      oppProductsIds.add(record.Opportunity_Product__c);
      accountIds.add(record.Account__c);
    }
    //Get Opportunity parent account stored in CLG__c field
    if (Schema.sObjectType.OpportunityLineItem.isQueryable()) {
      for (OpportunityLineItem oli : [
        SELECT Id, Opportunity.CLG__c, Opportunity.Id, Opportunity.AccountId
        FROM OpportunityLineItem
        WHERE Id IN :oppProductsIds
      ]) {
        mapoli.put(oli.Id, oli.Opportunity.CLG__c);
        mapOfOliWithOpportunity.put(oli.Id, oli.Opportunity.Id);
        mapOfOliWithOpportunityAccount.put(oli.Id, oli.Opportunity.AccountId);
      }
    }

    checkAccountOnFirstLegalEntity(
      records,
      mapOfOliWithOpportunity,
      mapOfOliWithOpportunityAccount
    );

    //Get Legal Entity Parent Account
    Map<Id, Id> mapOfAccountWithParentAccount = new Map<Id, Id>();
    if (Schema.sObjectType.Account.isQueryable()) {
      for (Account account : [
        SELECT Id, ParentId
        FROM Account
        WHERE Id IN :accountIds
      ]) {
        mapOfAccountWithParentAccount.put(account.Id, account.ParentId);
      }
    }

    //Compare Opportunity Account - Parent Account WITH Legal Entity Account - Parent Account
    for (Legal_Entity__c record : records) {
      if (
        mapoli.containsKey(record.Opportunity_Product__c) &&
        mapOfAccountWithParentAccount.containsKey(record.Account__c)
      ) {
        Id oppParentAccount = mapoli.get(record.Opportunity_Product__c);
        Id legalParentAccount = mapOfAccountWithParentAccount.get(
          record.Account__c
        );
        if (oppParentAccount != legalParentAccount) {
          record.addError(ACCOUNT_FIELD_NAME, INCORRECT_LEGAL_ENTITY);
        }
      }
    }
  }

  /**
   * @description This method will validate only first entity.
   * Validation : Legal Entity Account = Opportunity Account
   * @name checkAccountOnFirstLegalEntity
   * @param records List of legal Entity records
   * @param mapOfOliWithOpportunity Map of opportunity product with opportunity ids
   * @param mapOfOliWithOpportunityAccount Map of opportunity product with opportunity accounts
   */
  private static void checkAccountOnFirstLegalEntity(
    List<Legal_Entity__c> records,
    Map<Id, Id> mapOfOliWithOpportunity,
    Map<Id, Id> mapOfOliWithOpportunityAccount
  ) {
    //Get all Legal Entities based on opportunity Id's
    Map<id, Id> mapOpportunityWithEntity = new Map<id, Id>();
    if (Schema.sObjectType.Legal_Entity__c.isQueryable()) {
      for (Legal_Entity__c entity : [
        SELECT Account__c, Opportunity_Product__c
        FROM Legal_Entity__c
        WHERE opportunity_id__c IN :mapOfOliWithOpportunity.values()
      ]) {
        mapOpportunityWithEntity.put(entity.Opportunity_Product__c, entity.Id);
      }
    }

    for (Legal_Entity__c record : records) {
      if (
        //No Legal Entity exist. Validate the first entity : Legal Entity Account = Opportunity Account
        mapOpportunityWithEntity.isEmpty()
      ) {
        Id oppAccountId = mapOfOliWithOpportunityAccount.get(
          record.Opportunity_Product__c
        );
        //If opportunity account not equals to Legal Entity account then throw error
        if (oppAccountId != record.Account__c) {
          record.addError(
            ACCOUNT_FIELD_NAME,
            INCORRECT_ACCOUNT_ON_LEGAL_ENTITY
          );
        }
      }
    }
  }

  /**
   * @description This method will update Has_Legal_Entity__c field on opportunity product
   * @name updateHasLegalEntity
   * @param records List of legal Entity records
   * @param oldMap Map of old records of Legal Entity
   */
  public static void updateHasLegalEntity(
    List<Legal_Entity__c> records,
    Map<Id, Legal_Entity__c> oldMap
  ) {
    Set<Id> oppProductsIds = new Set<Id>();

    for (Legal_Entity__c record : records) {
      oppProductsIds.add(record.Opportunity_Product__c);
    }

    //Get Opportunity Line Items
    List<OpportunityLineItem> oliList = [
      SELECT Id
      FROM OpportunityLineItem
      WHERE Id IN :oppProductsIds
    ];

    for (OpportunityLineItem record : oliList) {
      record.Has_Legal_Entity__c = true;
    }
    if (Schema.sObjectType.OpportunityLineItem.isUpdateable()) {
      update oliList;
    }
  }

  /**
   * @description This method will update Has_Legal_Entity__c field on opportunity product
   * @name populateEntityFields
   * @param records List of legal Entity records
   * @param oldMap Map of old records of Legal Entity
   */
  public static void populateEntityFields(
    List<Legal_Entity__c> records,
    Map<Id, Legal_Entity__c> oldMap
  ) {
    Set<Id> oppProductsIds = new Set<Id>();
    Map<Id, Id> mapoli = new Map<Id, Id>();

    for (Legal_Entity__c record : records) {
      oppProductsIds.add(record.Opportunity_Product__c);
    }

    //Create map of Opportunity Product with Opportunity
    if (Schema.sObjectType.OpportunityLineItem.isQueryable()) {
      for (OpportunityLineItem oli : [
        SELECT Id, OpportunityId
        FROM OpportunityLineItem
        WHERE Id IN :oppProductsIds
      ]) {
        mapoli.put(oli.Id, oli.OpportunityId);
      }
    }

    for (Legal_Entity__c record : records) {
      Id opportunityId = mapoli.get(record.Opportunity_Product__c);
      record.Opportunity_Id__c = opportunityId;
    }
  }

  /**
   * @description This method will populate opportunity id field on Entity which is used for
   * updating opportunity account when multiple entities have different child account
   * @name updateAccountOnOpportunity
   * @param records List of legal Entity records
   * @param oldMap Map of old records of Legal Entity
   */
  public static void updateAccountOnOpportunity(
    List<Legal_Entity__c> records,
    Map<Id, Legal_Entity__c> oldMap
  ) {
    Set<Id> entitiesId = new Set<Id>();
    Set<Id> oppIds = new Set<Id>();
    List<Legal_Entity__c> entitiesList = new List<Legal_Entity__c>();

    //Get all legal entities for an opportunity
    for (Legal_Entity__c record : records) {
      entitiesId.add(record.Opportunity_Id__c);
    }
    if (Schema.sObjectType.Legal_Entity__c.isQueryable()) {
      entitiesList = [
        SELECT Id, Opportunity_Id__r.AccountId, Account__c, Opportunity_Id__c
        FROM Legal_Entity__c
        WHERE Opportunity_Id__c IN :entitiesId
      ];
    }

    //Opportunity account is NOT updated for single entity. Only when multiple entity exist AND
    //when opportunity account and entity account is different
    for (Legal_Entity__c entity : entitiesList) {
      if (entity.Opportunity_Id__r.AccountId != entity.Account__c) {
        oppIds.add(entity.Opportunity_Id__c);
      }
    }

    updateOpportunity(oppIds);
  }

  /**
   * @description This method will populate opportunity account
   * @name updateOpportunity
   * @param oppIds Set of Opportunities Ids
   */
  private static void updateOpportunity(Set<Id> oppIds) {
    //Get all opportunities which need to be updated
    if (!oppIds.isEmpty() && Schema.sObjectType.Opportunity.isQueryable()) {
      List<Opportunity> oppList = [
        SELECT Id, Account.ParentId
        FROM Opportunity
        WHERE Id IN :oppIds
      ];
      for (Opportunity opp : oppList) {
        opp.AccountId = opp.Account.ParentId;
      }

      if (Schema.sObjectType.Opportunity.isUpdateable() && !oppList.isEmpty()) {
        List<Database.saveResult> results = Database.update(oppList, false);
        Logger.error('', results);
        Logger.saveLog();
      }
    }
  }
}
