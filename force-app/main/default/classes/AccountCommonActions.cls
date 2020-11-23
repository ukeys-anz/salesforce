/**
 *
 * @author David Dawson
 * @since 08/2020
 * @description Common Account Action methods
 */

public with sharing class AccountCommonActions {
  private static final Non_Prod_Settings__c NON_PROD_SETTINGS = Non_Prod_Settings__c.getInstance(
    UserInfo.getUserId()
  );

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
        Entitlement ent = new Entitlement();
        ent.AccountId = acc.Id;
        ent.Name = 'Basic Subscription';
        ent.SlaProcessId = getSLAId('general inquiries', 'generalInquirySlaId');
        ent.StartDate = System.today();
        entitlementList.add(ent);
      }
    }

    if (
      !entitlementList.isEmpty() &&
      Entitlement.sObjectType.getDescribe().isCreateable()
    ) {
      insert entitlementList;
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
        Entitlement ent = new Entitlement();
        ent.AccountId = acc.Id;
        ent.Name = 'Basic Subscription';
        ent.SlaProcessId = getSLAId('general inquiries', 'generalInquirySlaId');
        ent.StartDate = System.today();
        entitlementList.add(ent);
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
      if (Entitlement.sObjectType.getDescribe().isUpdateable()) {
        update entList;
      }
    }

    if (
      !entitlementList.isEmpty() &&
      Entitlement.sObjectType.getDescribe().isCreateable()
    ) {
      insert entitlementList;
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
}
