/**
 *
 * @author David Dawson
 * @since 08/2020
 * @description Common Account Action methods
 */

public with sharing class AccountCommonActions {
  // Variable used to store the account Ids into which matching leads were converted into
  // This is used to revert the changes on accounts that resulted from lead conversion process
  private static Set<Id> convertedAccountIds = new Set<Id>();
  private static final String DELETED_IN_OCV_FLAG_ERROR_MSG = 'having multiple records with the Deleted_In_OCV__C flag set in a single transaction is not supported';
  /**
   * @description checkForAccountDeletion is called to check if the Deleted_In_OCV__c flag is updated for deletion
   * @param records The Account records passed from Trigger.new()
   */
  public static void checkForAccountDeletion(List<Account> records) {
    List<Account> accList = new List<Account>();

    for (Account acc : records) {
      if (acc.Deleted_In_OCV__c == true) {
        accList.add(acc);
      }
    }
    if (accList.size() == 1) {
      System.enqueuejob(new QueueAccountDeletion(accList[0]));
    } else if (accList.size() > 1) {
      for (Account acc : accList) {
        acc.addError(DELETED_IN_OCV_FLAG_ERROR_MSG);
      }
    }
  }

  /**
   * @description createEntitlement is called to create an entitlement for the account
   * @param records The Account records passed from Trigger.new()
   */
  public static void createEntitlement(List<Account> records) {
    List<Entitlement> entitlementList = new List<Entitlement>();

    for (Account acc : records) {
      if (acc.ANZx_Customer__c) {
        entitlementList.add(
          createEntitlement(
            acc.id,
            'Basic Subscription',
            'anz plus - basic subscription',
            'anzPlusBasic'
          )
        );
      }
    }

    if (!entitlementList.isEmpty()) {
      if (
        Entitlement.sObjectType.getDescribe().isCreateable() &&
        Schema.sObjectType.Entitlement.fields.AccountId.isCreateable() &&
        Schema.sObjectType.Entitlement.fields.Name.isCreateable() &&
        Schema.sObjectType.Entitlement.fields.SlaProcessId.isCreateable() &&
        Schema.sObjectType.Entitlement.fields.StartDate.isCreateable()
      ) {
        insert entitlementList;
      } else {
        CommonUtil.logAndThrowIAE(
          'AccountCommonActions',
          'createEntitlement',
          'Not enough permissions to create Entitlement.'
        );
      }
    }
  }

  /**
   * @description updateEntitlement is called to create or remove an entitlement for the account
   * based on whether or not it is shifting to or from ANZx
   * @param records The Account records passed from Trigger.new()
   * @param oldMap old trigger values
   */
  public static void updateEntitlement(
    List<Account> records,
    Map<Id, SObject> oldMap
  ) {
    List<Entitlement> entitlementList = new List<Entitlement>();
    List<Id> idList = new List<Id>();

    for (Account acc : records) {
      Account oldAccount = (Account) oldMap.get(acc.Id);
      //Check if its a new ANZx account and created entitlement
      if (acc.ANZx_Customer__c && !oldAccount.ANZx_Customer__c) {
        entitlementList.add(
          createEntitlement(
            acc.id,
            'Basic Subscription',
            'anz plus - basic subscription',
            'anzPlusBasic'
          )
        );
      } else if (
        acc.ANZx_Customer__c != true &&
        oldAccount.ANZx_Customer__c == true
      ) {
        //If account is moving away from ANZx add to idList
        idList.add(acc.Id);
      }
    }

    //If account shifts away from ANZx, end the entitlement
    if (
      !idList.isEmpty() && Entitlement.sObjectType.getDescribe().isQueryable()
    ) {
      List<Entitlement> entList = [
        SELECT Id
        FROM Entitlement
        WHERE AccountId IN :idList
      ];

      for (Entitlement ent : entList) {
        ent.EndDate = System.today();
      }
      if (
        Entitlement.sObjectType.getDescribe().isUpdateable() &&
        Schema.sObjectType.Entitlement.fields.EndDate.isUpdateable()
      ) {
        update entList;
      } else {
        CommonUtil.logAndThrowIAE(
          'AccountCommonActions',
          'updateEntitlement',
          'Not enough permissions to update Entitlement.'
        );
      }
    }

    if (!entitlementList.isEmpty()) {
      if (
        Entitlement.sObjectType.getDescribe().isCreateable() &&
        Schema.sObjectType.Entitlement.fields.AccountId.isCreateable() &&
        Schema.sObjectType.Entitlement.fields.Name.isCreateable() &&
        Schema.sObjectType.Entitlement.fields.SlaProcessId.isCreateable() &&
        Schema.sObjectType.Entitlement.fields.StartDate.isCreateable()
      ) {
        insert entitlementList;
      } else {
        CommonUtil.logAndThrowIAE(
          'AccountCommonActions',
          'updateEntitlement',
          'Not enough permissions to create Entitlement.'
        );
      }
    }
  }

  private static String getSLAId(String processName, String cacheName) {
    String slaId = (String) Cache.Org.get('local.Utility.' + cacheName);
    if (slaId != null) {
      return slaId;
    } else {
      SlaProcess sla = [
        SELECT Id
        FROM SlaProcess
        WHERE
          Name = :processName
          AND IsVersionDefault = TRUE
          AND IsActive = TRUE
      ];
      Cache.Org.put('local.Utility.' + cacheName, sla.Id);
      return (String) sla.Id;
    }
  }

  private static Entitlement createEntitlement(
    Id accountId,
    String entitlementName,
    String slaProcessName,
    String cacheName
  ) {
    Entitlement ent = new Entitlement();
    ent.AccountId = accountId;
    ent.Name = entitlementName;
    ent.SlaProcessId = getSLAId(slaProcessName, cacheName);
    ent.StartDate = System.today();

    return ent;
  }

  /**
   * @description findAndConvertLead find leads with matching details and convert them
   * @param records The Account records passed from Trigger.new()
   */
  public static void findAndConvertLead(List<Account> records) {
    Map<Id, List<Lead>> matchingLeadsByAccIdMap = new Map<Id, List<Lead>>();
    // Find matching ANZx leads
    matchingLeadsByAccIdMap.putAll(
      AccountCommonActionsHelper.findMatchingLeads(records)
    );
    // Find matching CCRM leads
    matchingLeadsByAccIdMap.putAll(
      CCRMAccountActions.findMatchingLeads(records)
    );

    // Convert matching leads into accounts
    if (matchingLeadsByAccIdMap.size() > 0) {
      LeadDMLOperator dmlOperator = new LeadDMLOperator();
      dmlOperator.convertLeads(matchingLeadsByAccIdMap);
    }
  }

  /**
   * @description revertAccountChanges revert any changes on the account that are not from OCV Integration User
   * @param records The Account records passed from Trigger.new()
   * @param oldMap old trigger values
   */
  public static void revertAccountChanges(
    List<Account> records,
    Map<Id, SObject> oldMap
  ) {
    if (convertedAccountIds.size() == 0) {
      return;
    }
    for (Account rec : records) {
      if (convertedAccountIds.contains(rec.Id)) {
        Account oldRec = (Account) oldMap.get(rec.Id);
        AccountCommonActionsHelper.revertAccountFieldChanges(rec, oldRec);
      }
    }
  }

  /**
   * @description private without sharing class to bypass lead sharing setting in lead conversion process
   */
  private without sharing class LeadDMLOperator {
    /**
     * @description convertLeads convert leads into their matching accounts
     * @param matchingLeadsByAccIdMap A map fo leads to be converted and their corresponding account Ids
     */
    private void convertLeads(Map<Id, List<Lead>> matchingLeadsByAccIdMap) {
      convertedAccountIds = matchingLeadsByAccIdMap.keySet();
      List<Database.LeadConvert> converts = new List<Database.LeadConvert>();
      LeadStatus convertedStatus = [
        SELECT MasterLabel
        FROM LeadStatus
        WHERE IsConverted = TRUE
        LIMIT 1
      ];
      for (String accountId : matchingLeadsByAccIdMap.keySet()) {
        for (Lead l : matchingLeadsByAccIdMap.get(accountId)) {
          Database.LeadConvert convert = new Database.LeadConvert();
          convert.setLeadId(l.Id);
          convert.setAccountId(accountId);
          convert.setConvertedStatus(convertedStatus.MasterLabel);
          convert.setDoNotCreateOpportunity(
            CCRMLeadUtil.isCCRMLeadType(l) ? false : true
          );
          converts.add(convert);
        }
      }
      List<Database.LeadConvertResult> lcResults = Database.convertLead(
        converts
      );
      ccrmLeadConversionActions(matchingLeadsByAccIdMap, lcResults);
      for (Database.LeadConvertResult lcr : lcResults) {
        if (!lcr.isSuccess()) {
          Logger.error(
            'Account_Id: ' +
            lcr.getAccountId() +
            '; Lead_Id: ' +
            lcr.getLeadId() +
            '; Lead Record Type: ANZx' +
            '; Error_Message: ' +
            lcr.getErrors()[0].getMessage()
          );
        }
      }
      Logger.saveLog();
    }

    /**
     * @description Post lead conversion actions for CCRM leads
     * @param matchingLeadsByAccIdMap account and lead records map from lead conversion
     * @param lcResults Lead conversion result
     */
    private void ccrmLeadConversionActions(
      Map<Id, List<Lead>> matchingLeadsByAccIdMap,
      List<Database.LeadConvertResult> lcResults
    ) {
      Set<Id> leadIds = new Set<Id>();
      Map<Id, Id> mapOfAccountId = new Map<Id, Id>();
      List<Contact> contactList = new List<Contact>();
      for (Database.LeadConvertResult lcr : lcResults) {
        if (lcr.isSuccess()) {
          for (Lead l : matchingLeadsByAccIdMap.get(lcr.getAccountId())) {
            if (CCRMLeadUtil.isCCRMLeadType(l)) {
              leadIds.add(l.Id);
              contactList.add(new Contact(Id = lcr.getContactId()));
              mapOfAccountId.put(l.Id, lcr.getAccountId());
            }
          }
        }
      }
      if (!leadIds.isEmpty()) {
        createOpportunities(leadIds, mapOfAccountId);
        deleteAutoCreatedContacts(contactList);
      }
    }

    /**
     * @description Post lead conversion actions for CCRM leads
     * @param leadIds set of lead ids from lead conversion
     * @param mapOfAccountId map of lead and account id
     */
    private void createOpportunities(
      Set<Id> leadIds,
      Map<Id, Id> mapOfAccountId
    ) {
      Map<Id, Id> mapOfOpportunityId = new Map<Id, Id>();
      Map<Id, Opportunity> mapOfLeadsWithOpportunities = new CCRMLeadMappingEngine()
        .mapLeadToOpportunityFields(leadIds, mapOfAccountId);
      if (mapOfLeadsWithOpportunities.size() > 0) {
        insert mapOfLeadsWithOpportunities.values();
      }
      for (Id leadId : leadIds) {
        mapOfOpportunityId.put(
          leadId,
          mapOfLeadsWithOpportunities.get(leadId).Id
        );
      }
      CCRMLeadPlatformEventActions.sendUpdateToUnicaOrAdobeOnLeadConversion(
        leadIds,
        mapOfOpportunityId
      );
      transferTasksToOpportunity(mapOfOpportunityId);
    }

    /**
     * @description transfer tasks from lead to opportunity by updating WhatId
     * @param mapOfOpportunityId map of opportunity id with lead id
     */
    private void transferTasksToOpportunity(Map<Id, Id> mapOfOpportunityId) {
      if (!CCRMLeadPlatformEventHelper.leadTask.isEmpty()) {
        for (Task taskRecord : CCRMLeadPlatformEventHelper.leadTask) {
          if (mapOfOpportunityId.containsKey(taskRecord.WhoId)) {
            taskRecord.WhatId = mapOfOpportunityId.get(taskRecord.WhoId);
            taskRecord.WhoId = null;
          }
        }
        List<Database.SaveResult> results = Database.update(
          CCRMLeadPlatformEventHelper.leadTask,
          false
        );
        Logger.error(
          'Error occured while updating tasks during lead conversion.',
          results
        );
        Logger.saveLog();
      }
    }

    /**
     * @description delete auto created contacts post lead conversion
     * @param contactList list of contacts from lead conversion
     */
    private void deleteAutoCreatedContacts(List<Contact> contactList) {
      DMLUtil.deleteRecords(
        contactList,
        DMLUtil.NOT_ALLOW_PARTIAL_UPDATE,
        DMLUtil.USER_MODE
      );
    }
  }
  /**
   * @description populateFieldsValue to update field values
   * exp: if Bankrupt_Date__c is not null, it will make BankruptCheckBox__c to be true
   * @param records All the account records
   */
  public static void populateFieldsValue(List<Account> records) {
    for (Account record : records) {
      record.BankruptCheckBox__c = record.Bankrupt_Date__c != null;
    }
  }
}
