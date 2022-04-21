/**
 *
 * @author David Dawson
 * @since 08/2020
 * @description Common Account Action methods
 */

@SuppressWarnings('PMD.CyclomaticComplexity')
public with sharing class AccountCommonActions {
  // Variable used to store the account Ids into which matching leads were converted into
  // This is used to revert the changes on accounts that resulted from lead conversion process
  private static Set<Id> convertedAccountIds = new Set<Id>();
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
        acc.addError(
          'having multiple records with the Deleted_In_OCV__C flag set in a single transaction is not supported'
        );
      }
    }
  }

  /**
   * @description createEntitlement is called to create an entitlement for the account
   * @param records The Account records passed from Trigger.new()
   */
  @SuppressWarnings('PMD.ApexCRUDViolation')
  public static void createEntitlement(List<Account> records) {
    List<Entitlement> entitlementList = new List<Entitlement>();

    for (Account acc : records) {
      if (acc.ANZx_Customer__c) {
        entitlementList.add(
          createEntitlement(
            acc.id,
            'Basic Subscription',
            'anz plus - basic subscription v1',
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
  @SuppressWarnings('PMD.ApexCRUDViolation, PMD.CyclomaticComplexity')
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
            'anz plus - basic subscription v1',
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

  @SuppressWarnings('PMD.ApexCRUDViolation')
  private static String getSLAId(String processName, String cacheName) {
    String slaId = (String) Cache.Org.get('local.Utility.' + cacheName);
    if (slaId != null) {
      return slaId;
    } else {
      SlaProcess sla = [SELECT Id FROM SlaProcess WHERE Name = :processName];
      Cache.Org.put('local.Utility.' + cacheName, sla.Id);
      return (String) sla.Id;
    }
  }

  @SuppressWarnings('PMD.ExcessiveParameterList')
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
    // Find matching leads
    Map<Id, List<Lead>> matchingLeadsByAccIdMap = AccountCommonActionsHelper.findMatchingLeads(
      records
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
    @SuppressWarnings('PMD.ApexCRUDViolation')
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
          convert.setDoNotCreateOpportunity(true);
          converts.add(convert);
        }
      }
      List<Database.LeadConvertResult> lcResults = Database.convertLead(
        converts
      );

      for (Database.LeadConvertResult lcr : lcResults) {
        if (!lcr.isSuccess()) {
          lib_systemLog log = new lib_systemLog(
            'AccountCommonActionsHelper',
            'covertLeads'
          );
          log.info(
            'Account_Id: ' +
            lcr.getAccountId() +
            '; Lead_Id: ' +
            lcr.getLeadId() +
            '; Lead Record Type: ANZx' +
            '; Error_Message: ' +
            lcr.getErrors()[0].getMessage()
          );
          log.publishEvent();
        }
      }
    }
  }
}
