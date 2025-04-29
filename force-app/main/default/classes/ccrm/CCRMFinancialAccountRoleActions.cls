/**
 *
 * @author Tan Phan
 * @since 05/2023
 * @description Handle actions on trigger events of FinServ__FinancialAccountRole__c object
 * @runTests CCRMFinancialAccountRoleActionsTest
 */
public with sharing class CCRMFinancialAccountRoleActions {
  private static final String FAR_ROLE_PRIMARYOWNER = 'Primary Owner';
  private static final String FAR_ROLE_OTHER = 'Other';

  public static final Set<SObjectField> FIELD_SET = new Set<SObjectField>{
    FinServ__FinancialAccountRole__c.FinServ__RelatedAccount__c,
    FinServ__FinancialAccountRole__c.FinServ__FinancialAccount__c
  };

  private static final FinancialAccountRoleRepository FAR_REPOSITORY = (FinancialAccountRoleRepository) Lib_InstanceProvider.forType(
    FinancialAccountRoleRepository.class
  );

  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  private static final FinancialAccountRepository FINANCIAL_ACCOUNT_REPOSITORY = (FinancialAccountRepository) Lib_InstanceProvider.forType(
    FinancialAccountRepository.class
  );

  /**
   * @description Set FAR record type to System or Contact based on External Id and Related Customer
   * @name setRecordType
   * @param records Financial account role records from the trigger.
   */
  public static void setRecordType(
    List<FinServ__FinancialAccountRole__c> records
  ) {
    Financial_Account_Settings__c faSettings = Financial_Account_Settings__c.getOrgDefaults();
    List<FinServ__FinancialAccountRole__c> recordsToCheck = new List<FinServ__FinancialAccountRole__c>();
    Set<Id> accountIds = new Set<Id>();

    for (FinServ__FinancialAccountRole__c record : records) {
      if (
        record.External_Id__c == null ||
        record.FinServ__RelatedAccount__c == faSettings.System_Customer_Id__c ||
        !record.FinServ__Active__c
      ) {
        record.RecordTypeId = CCRMConstants.FAR_SYSTEM_RT_ID;
        record.External_Id__c = null;
      } else {
        recordsToCheck.add(record);
        accountIds.add(record.FinServ__RelatedAccount__c);
      }
    }
    if (recordsToCheck.isEmpty()) {
      return;
    }

    Map<Id, Account> mapAccounts = new Map<Id, Account>(
      [SELECT IsPersonAccount FROM Account WHERE Id IN :accountIds]
    );

    for (FinServ__FinancialAccountRole__c record : recordsToCheck) {
      record.RecordTypeId = mapAccounts.get(record.FinServ__RelatedAccount__c)
          ?.IsPersonAccount == true
        ? CCRMConstants.FAR_CONTACT_RT_ID
        : CCRMConstants.FAR_ACCOUNT_RT_ID;
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
          : FAR_ROLE_OTHER;
      }
    }
  }

  /**
   * @description When a "Primary Owner" FAR record is created, switch the primary owner of the parent FA record to the new account
   * @param records Financial account role records from the trigger.
   */
  public static void updateFinancialAccountOwner(
    List<FinServ__FinancialAccountRole__c> records
  ) {
    Set<Id> relatedFinancialAccountsIDs = ListUtil.getIds(
      records,
      FinServ__FinancialAccountRole__c.FinServ__FinancialAccount__c
    );
    Map<Id, FinServ__FinancialAccount__c> financialAccountsMap = FINANCIAL_ACCOUNT_REPOSITORY.getFinancialAccountsWithPrimaryOwner(
      relatedFinancialAccountsIDs
    );
    List<FinServ__FinancialAccountRole__c> filteredRecords = ListUtil.filter(
        records
      )
      .isNull(FinServ__FinancialAccountRole__c.FinServ__EndDate__c)
      .equals(
        FinServ__FinancialAccountRole__c.FinServ__Role__c,
        FAR_ROLE_PRIMARYOWNER
      )
      .toList();
    List<FinServ__FinancialAccount__c> finAccountsToUpdate = getFinancialAccountsToUpdate(
      filteredRecords,
      financialAccountsMap
    );
    DML_REPOSITORY.doUpdate(finAccountsToUpdate);
  }

  /**
   * @description get the financial accounts to be updated with new Primary Owner
   * @param records Financial account role records from the trigger.
   * @param financialAccountsMap Map of related Financial account records
   * @return List<FinServ__FinancialAccount__c> The Financial account records that needs to be updated.
   */
  @TestVisible
  private static List<FinServ__FinancialAccount__c> getFinancialAccountsToUpdate(
    List<FinServ__FinancialAccountRole__c> records,
    Map<Id, FinServ__FinancialAccount__c> financialAccountsMap
  ) {
    List<FinServ__FinancialAccount__c> finAccountsToUpdate = new List<FinServ__FinancialAccount__c>();
    for (FinServ__FinancialAccountRole__c record : records) {
      FinServ__FinancialAccount__c finAccount = financialAccountsMap.get(
        record.FinServ__FinancialAccount__c
      );
      if (
        finAccount == null ||
        record.FinServ__RelatedAccount__c == finAccount.Finserv__PrimaryOwner__c
      ) {
        continue;
      }
      finAccount.Finserv__PrimaryOwner__c = record.FinServ__RelatedAccount__c;
      finAccountsToUpdate.add(finAccount);
    }
    return finAccountsToUpdate;
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
   * @description Deactive existing duplicate FAR record
   * @name deactivateDuplicateRecords
   * @param records Financial account role records from the trigger.
   * @param oldMap Map of old Financial account role records from the trigger.
   */
  public static void deactivateDuplicateRecords(
    List<FinServ__FinancialAccountRole__c> records,
    Map<Id, FinServ__FinancialAccountRole__c> oldMap
  ) {
    List<FinServ__FinancialAccountRole__c> filterActiveRecords = new List<FinServ__FinancialAccountRole__c>();

    filterActiveRecords = ListUtil.filter(records, oldMap)
      .changedTo(FinServ__FinancialAccountRole__c.FinServ__Active__c, true)
      .toList();

    Set<Id> recordIds = ListUtil.getIds(
      filterActiveRecords,
      FinServ__FinancialAccountRole__c.Id
    );
    Set<Id> relatedAccountIds = ListUtil.getIds(
      filterActiveRecords,
      FinServ__FinancialAccountRole__c.FinServ__RelatedAccount__c
    );
    Set<Id> relatedFinancialAccountIds = ListUtil.getIds(
      filterActiveRecords,
      FinServ__FinancialAccountRole__c.FinServ__FinancialAccount__c
    );
    List<FinServ__FinancialAccountRole__c> existingActiveRecords = FAR_REPOSITORY.getActiveFinancialAccountRoleRecords(
      relatedAccountIds,
      relatedFinancialAccountIds
    );
    Set<String> relatedAccountIdFinancialIdUniqueKey = getUniqueKeySet(
      recordIds,
      existingActiveRecords
    );
    List<FinServ__FinancialAccountRole__c> existingRecordsToDeactivate = getRecordsToDeactivateList(
      recordIds,
      relatedAccountIdFinancialIdUniqueKey,
      existingActiveRecords
    );
    DML_REPOSITORY.doUpdate(existingRecordsToDeactivate);
  }
  /**
   * @description Generate and return unique key using CustomerId and AccountKey
   * @name getUniqueKeySet
   * @param recordIds Financial account role record Ids.
   * @param activeRecords Financial account role records
   * @return Set<String>
   */
  private static Set<String> getUniqueKeySet(
    Set<Id> recordIds,
    List<FinServ__FinancialAccountRole__c> activeRecords
  ) {
    Set<String> relatedAccountIdFinancialIdUniqueKey = new Set<String>();
    for (FinServ__FinancialAccountRole__c record : activeRecords) {
      if (recordIds.contains(record.Id)) {
        String uniqueKey = generateCustomerIdAccountKeyUniqueKey(
          record.FinServ__RelatedAccount__r.External_Id__c,
          record.FinServ__FinancialAccount__r.Account_Key__c
        );
        relatedAccountIdFinancialIdUniqueKey.add(uniqueKey);
      }
    }
    return relatedAccountIdFinancialIdUniqueKey;
  }
  /**
   * @description Deactive existing duplicate FAR record
   * @name deactivateDuplicateRecords
   * @param recordIds Financial account role record Ids.
   * @param relatedAccountIdFinancialIdUniqueKey Set of Unique keys.
   * @param existingActiveRecords Existing Active Financial account role records
   * @return List<FinServ__FinancialAccountRole__c>
   */
  private static List<FinServ__FinancialAccountRole__c> getRecordsToDeactivateList(
    Set<Id> recordIds,
    Set<String> relatedAccountIdFinancialIdUniqueKey,
    List<FinServ__FinancialAccountRole__c> existingActiveRecords
  ) {
    List<FinServ__FinancialAccountRole__c> existingRecordsToDeactivate = new List<FinServ__FinancialAccountRole__c>();
    for (FinServ__FinancialAccountRole__c record : existingActiveRecords) {
      String tempUniqueKey = generateCustomerIdAccountKeyUniqueKey(
        record.FinServ__RelatedAccount__r.External_Id__c,
        record.FinServ__FinancialAccount__r.Account_Key__c
      );
      if (recordIds.contains(record.Id)) {
        continue;
      }
      if (relatedAccountIdFinancialIdUniqueKey.contains(tempUniqueKey)) {
        existingRecordsToDeactivate.add(
          new FinServ__FinancialAccountRole__c(
            Id = record.Id,
            FinServ__Active__c = false,
            FinServ__EndDate__c = Date.today()
          )
        );
      }
    }
    return existingRecordsToDeactivate;
  }
  /**
   * @description Generate and return unique key using CustomerId and AccountKey
   * @name generateCustomerIdAccountKeyUniqueKey
   * @param customerId  Related Account's External Id from FAR.
   * @param accountKey Financial Account's Account Key value from FAR.
   * @return String
   */
  private static String generateCustomerIdAccountKeyUniqueKey(
    String customerId,
    String accountKey
  ) {
    return customerId + '_' + accountKey;
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
