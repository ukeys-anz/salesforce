/**
 *
 * @author Tan Phan
 * @since 05/2023
 * @description Handle actions on trigger events of FinServ__FinancialAccountRole__c object
 * @runTests CCRMFinancialAccountRoleActionsTest
 */
public with sharing class CCRMFinancialAccountRoleActions {
  private static final String FAR_ROLE_PRIMARYOWNER = 'Primary Owner';
  private static final String FAR_ROLE_ADDITIONAL = 'Additional Owner';

  /**
   * @description Set FAR record type to System or Contact based on External Id and Related Customer
   * @name setRecordType
   * @param records Financial account role records from the trigger.
   */
  public static void setRecordType(
    List<FinServ__FinancialAccountRole__c> records
  ) {
    Financial_Account_Settings__c faSettings = Financial_Account_Settings__c.getOrgDefaults();

    for (FinServ__FinancialAccountRole__c record : records) {
      if (
        record.External_Id__c == null ||
        record.FinServ__RelatedAccount__c == faSettings.System_Customer_Id__c ||
        !record.FinServ__Active__c
      ) {
        record.RecordTypeId = CCRMConstants.FAR_SYSTEM_RT_ID;
      } else {
        record.RecordTypeId = CCRMConstants.FAR_CONTACT_RT_ID;
      }
    }
  }

  /**
   * @description Populate Finserv__Role__c by Role_Type__c
   * @name mapRoleTypeToRole
   * @param records Financial account role records from the trigger.
   */
  public static void mapRoleTypeToRole(
    List<FinServ__FinancialAccountRole__c> records
  ) {
    Map<String, Financial_Account_Role_Type_Mapping__mdt> farRoleTypeMapping = Financial_Account_Role_Type_Mapping__mdt.getAll();

    for (FinServ__FinancialAccountRole__c record : records) {
      if (String.isBlank(record.FinServ__Role__c)) {
        record.FinServ__Role__c = farRoleTypeMapping.containsKey(
            record.Role_Type__c
          )
          ? farRoleTypeMapping.get(record.Role_Type__c).Role__c
          : FAR_ROLE_ADDITIONAL;
      }
    }
  }

  /**
   * @description When a "Primary Owner" FAR record is created, switch the primary owner of the parent FA record to the new account
   * @name updateFinancialAccountOwner
   * @param records Financial account role records from the trigger.
   */
  public static void updateFinancialAccountOwner(
    List<FinServ__FinancialAccountRole__c> records
  ) {
    Financial_Account_Settings__c faSettings = Financial_Account_Settings__c.getOrgDefaults();

    List<FinServ__FinancialAccount__c> financialAccounts = new List<FinServ__FinancialAccount__c>();
    for (FinServ__FinancialAccountRole__c record : records) {
      if (
        record.FinServ__EndDate__c == null &&
        record.FinServ__Role__c == FAR_ROLE_PRIMARYOWNER
      ) {
        financialAccounts.add(
          new FinServ__FinancialAccount__c(
            Id = record.FinServ__FinancialAccount__c,
            Finserv__PrimaryOwner__c = record.FinServ__RelatedAccount__c
          )
        );
      }
    }

    if (!financialAccounts.isEmpty()) {
      DMLUtil.updateRecords(financialAccounts, true, true);
    }
  }

  /**
   * @description Deactive FAR record when an end-date is set
   * @name deactivateEndDatedRecords
   * @param records Financial account role records from the trigger.
   * @param oldMap Map of old Financial account role records from the trigger.
   */
  public static void deactivateEndDatedRecords(
    List<FinServ__FinancialAccountRole__c> records,
    Map<Id, FinServ__FinancialAccountRole__c> oldMap
  ) {
    List<FinServ__FinancialAccountRole__c> recordsToRevertOverridenEndDate = new List<FinServ__FinancialAccountRole__c>();
    for (FinServ__FinancialAccountRole__c record : records) {
      FinServ__FinancialAccountRole__c oldRecord = oldMap.get(record.Id);
      if (
        (record.FinServ__Active__c || oldRecord.FinServ__Active__c) &&
        record.FinServ__EndDate__c != null &&
        oldRecord.FinServ__EndDate__c == null
      ) {
        record.FinServ__Active__c = false;
        recordsToRevertOverridenEndDate.add(
          new FinServ__FinancialAccountRole__c(
            Id = record.Id,
            FinServ__EndDate__c = record.FinServ__EndDate__c
          )
        );
      }
    }

    if (!recordsToRevertOverridenEndDate.isEmpty()) {
      System.enqueueJob(
        new RevertOverridenEndDateQueueable(recordsToRevertOverridenEndDate)
      );
    }
  }

  /**
   * @description Queueable class to update FAR end-date to original value before FS trigger override it with today's date
   * @name RevertOverridenEndDateQueueable
   */
  private class RevertOverridenEndDateQueueable implements Queueable {
    private List<FinServ__FinancialAccountRole__c> records;

    /**
     * @description constructor
     * @param records list of records to update
     */
    private RevertOverridenEndDateQueueable(
      List<FinServ__FinancialAccountRole__c> records
    ) {
      this.records = records;
    }

    /**
     * @description execute method
     * @param context QueueableContext
     */
    public void execute(QueueableContext context) {
      DMLUtil.updateRecords(this.records, true, true);
    }
  }

  /**
   * @description when a non-system primary owner FAR is deactivated, an async job need to check if it was replaced with another FAR
   * @param records Financial account role records from the trigger.
   * @param oldMap Map of old Financial account role records from the trigger.
   */
  public static void checkLastPrimaryOwnerDeactivated(
    List<FinServ__FinancialAccountRole__c> records,
    Map<Id, FinServ__FinancialAccountRole__c> oldMap
  ) {
    Financial_Account_Settings__c faSettings = Financial_Account_Settings__c.getOrgDefaults();
    Set<Id> faIds = new Set<Id>();

    for (FinServ__FinancialAccountRole__c record : records) {
      FinServ__FinancialAccountRole__c oldRecord = oldMap.get(record.Id);
      if (
        record.FinServ__RelatedAccount__c != faSettings.System_Customer_Id__c &&
        record.FinServ__Role__c == FAR_ROLE_PRIMARYOWNER &&
        !record.FinServ__Active__c &&
        oldRecord.FinServ__Active__c
      ) {
        faIds.add(record.FinServ__FinancialAccount__c);
      }
    }

    if (!faIds.isEmpty()) {
      System.enqueueJob(new CheckFaPrimaryOwner(faIds));
    }
  }

  private class CheckFaPrimaryOwner implements Queueable {
    private Set<Id> faIds;

    /**
     * @description constructor
     * @param faIds list of financial account record Ids to check
     */
    private CheckFaPrimaryOwner(Set<Id> faIds) {
      this.faIds = faIds;
    }

    /**
     * @description execute method
     * @param context QueueableContext
     */
    public void execute(QueueableContext context) {
      Financial_Account_Settings__c faSettings = Financial_Account_Settings__c.getOrgDefaults();
      List<FinServ__FinancialAccountRole__c> systemFars = new List<FinServ__FinancialAccountRole__c>();

      for (FinServ__FinancialAccount__c fa : [
        SELECT
          Id,
          (
            SELECT Id
            FROM FinServ__FinancialAccountRoles__r
            WHERE
              FinServ__Role__c = :FAR_ROLE_PRIMARYOWNER
              AND FinServ__Active__c = TRUE
          )
        FROM FinServ__FinancialAccount__c
        WHERE Id IN :this.faIds
        WITH USER_MODE
      ]) {
        if (fa.FinServ__FinancialAccountRoles__r.isEmpty()) {
          systemFars.add(
            new FinServ__FinancialAccountRole__c(
              FinServ__FinancialAccount__c = fa.Id,
              FinServ__RelatedAccount__c = faSettings.System_Customer_Id__c,
              FinServ__Role__c = FAR_ROLE_PRIMARYOWNER
            )
          );
        }
      }
      if (!systemFars.isEmpty()) {
        DMLUtil.insertRecords(systemFars, true, true);
      }
    }
  }
}
