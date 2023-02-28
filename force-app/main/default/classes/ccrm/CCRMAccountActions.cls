/**
 * @author Emmanuel Yap
 * @since  05/2022
 * @group CCRM (Commercial CRM)
 * @description CCRMAccountActions is class to handle all the CCRM Account Actions
 * @runTests CCRMAccountActionsTest
 */
public with sharing class CCRMAccountActions {
  /**
   * @description This method will update Controlling Post field depending on the CPID provided in Account.
   * @name setControllingPost
   * @param records from the trigger
   * @param oldMap This Map<Id, SObject> contains the map which holds the previous values which can be used to check what value has changed in afterUpdate.
   */
  public static void setControllingPost(
    List<Account> records,
    Map<Id, Account> oldMap
  ) {
    System.debug('Fake change');
    Map<String, List<Account>> mappedAccounts = mapAccountsToCPID(
      records,
      oldMap
    );

    Set<String> cpids = mappedAccounts.keySet();

    if (cpids.isEmpty()) {
      return;
    }

    try {
      List<Controlling_Post__c> cps = [
        SELECT Id, CPID__c
        FROM Controlling_Post__c
        WHERE CPID__c != NULL AND CPID__c IN :cpids
        WITH SECURITY_ENFORCED
      ];

      for (Controlling_Post__c cp : cps) {
        List<Account> accounts = mappedAccounts.get(cp.CPID__c);
        for (Account account : accounts) {
          account.Controlling_Post__c = cp.id;
        }
      }
    } catch (System.QueryException qe) {
      Logger.error('InsufficientAccessException', qe);
      Logger.saveLog();
    }
  }

  /**
   * @description Returns a map of Accounts with CPID as key
   * @name mapAccountsToCPID
   * @param records from the trigger
   * @param oldMap This Map<Id, SObject> contains the map which holds the previous values which can be used to check what value has changed in afterUpdate.
   * @return `Map<String, List<Account>>` Return map of Accounts with CPID as key
   */
  private static Map<String, List<Account>> mapAccountsToCPID(
    List<Account> records,
    Map<Id, Account> oldMap
  ) {
    Map<String, List<Account>> mappedAccounts = new Map<String, List<Account>>();
    for (Account record : records) {
      Account oldRec = oldMap != null ? oldMap.get(record.id) : null;
      if (oldMap == null || isCPIDChanged(record, oldRec)) {
        if (record.CPID__c == null) {
          record.Controlling_Post__c = null;
          continue;
        }
        if (mappedAccounts.containsKey(record.CPID__c)) {
          mappedAccounts.get(record.CPID__c).add(record);
        } else {
          mappedAccounts.put(record.CPID__c, new List<Account>{ record });
        }
      }
    }
    return mappedAccounts;
  }

  /**
   * @description Returns true if this Account record CPID was changed, returns false otherwise
   * @name isCPIDChanged
   * @param record Account record
   * @param oldRec old Account record from trigger
   * @return `Boolean` True if the CPID is updated otherwise false.
   */
  private static Boolean isCPIDChanged(Account record, Account oldRec) {
    if (oldRec != null && record.CPID__c != oldRec.CPID__c) {
      return true;
    }
    return false;
  }

  /**
   * @description revertAccountChanges revert any changes on the account that are not from OCV Integration User
   * @name revertAccountChanges
   * @param records The Account records passed from Trigger.new()
   * @param oldMap old trigger values
   */
  public static void revertAccountChanges(
    List<Account> records,
    Map<Id, SObject> oldMap
  ) {
    for (Account rec : records) {
      if (
        !rec.Is_Prospect__c &&
        UserInfo.getProfileId() ==
        CommonUtil.getProfileByName('ANZ Standard User').Id
      ) {
        Account oldRec = (Account) oldMap.get(rec.Id);
        AccountCommonActionsHelper.revertAccountFieldChanges(rec, oldRec);
      }
    }
  }

  /**
   * @description findMatchingLeads finds the leads that have matching details with the newly created account
   * @param newRecs The account records from Trigger.new()
   * @return Map<Id, List<Lead>> A map fo leads to be converted and their corresponding account Ids
   */
  public static Map<Id, List<Lead>> findMatchingLeads(List<Account> newRecs) {
    Map<String, Account> accountByCapcisIdMap = new Map<String, Account>();
    Map<Id, List<Lead>> matchingLeadsByAccIdMap = new Map<Id, List<Lead>>();
    Set<Id> leadIds = new Set<Id>();
    for (Account acc : newRecs) {
      if (isValidCCRMAccount(acc)) {
        accountByCapcisIdMap.put(acc.Source_System_ID__c, acc);
      }
    }
    AccountCommonActionsHelper.LeadRetriever lr = new AccountCommonActionsHelper.LeadRetriever();
    for (
      Lead l : lr.getPotentialMatchingCCRMLeads(accountByCapcisIdMap.keySet())
    ) {
      AccountCommonActionsHelper.putLeadsInMapByAccId(
        l,
        matchingLeadsByAccIdMap,
        accountByCapcisIdMap.get(l.CAPCIS_ID__c)
      );
      leadIds.add(l.Id);
    }
    if (!leadIds.isEmpty()) {
      CCRMLeadPlatformEventHelper.leadTask = getRelatedTasks(leadIds);
    }

    return matchingLeadsByAccIdMap;
  }

  /**
   * @description getRelatedTasks get related tasks associated with leads before lead conversion
   * @param leadIds set of related leadids
   * @return List<Task> list of task records associated with leads
   */
  private static List<Task> getRelatedTasks(Set<Id> leadIds) {
    List<Task> taskList = [
      SELECT Response_Type__r.Unica_Lead_SubStatus__c, WhoId
      FROM Task
      WHERE WhoId = :leadIds
      WITH SECURITY_ENFORCED
      ORDER BY createddate DESC
    ];
    return taskList;
  }

  /**
   * @description Check if the account record is eligible for finding and converting CCRM leads
   * @name isValidCCRMAccount
   * @param record The record from account trigger
   * @return `Boolean` True if the the record source is CAP and not a person account
   */
  private static Boolean isValidCCRMAccount(Account record) {
    if (
      record.Source_System_Name__c == System.Label.CCRM_Source_System_Name &&
      String.isNotBlank(record.Source_System_ID__c) &&
      !record.IsPersonAccount
    ) {
      return true;
    }
    return false;
  }

  /**
   * @description This method returns map of account with source system id
   * @name getMapOfSourceSystemIdsByRelatedParties
   * @param leadList List of leads
   * @return Map<Id, Account> Map of account
   */
  public static Map<Id, Account> getMapOfSourceSystemIdsByRelatedParties(
    List<Lead> leadList
  ) {
    Set<Id> accountIds = new Set<Id>();
    for (Lead record : leadList) {
      accountIds.add(record.FinServ__RelatedAccount__c);
    }
    Map<Id, Account> mapOfSourceSystemIds = new Map<Id, Account>(
      [
        SELECT
          Id,
          Source_System_ID__c,
          Source_System_Name__c,
          Name,
          RecordTypeId
        FROM Account
        WHERE
          Source_System_Name__c = :System.Label.CCRM_Source_System_Name
          AND Id IN :accountIds
      ]
    );
    return mapOfSourceSystemIds;
  }

  /**
   * @description Validate and format ABN/ACN/ARBN of prospect customers
   * @name validateAndFormatProspectAbnAcnArbn
   * @param records from the trigger
   * @param oldMap This Map<Id, SObject> contains the map which holds the previous values which can be used to check what value has changed in afterUpdate.
   */
  public static void validateAndFormatProspectAbnAcnArbn(
    List<Account> records,
    Map<Id, Account> oldMap
  ) {
    for (Account record : records) {
      Account oldRecord = oldMap?.get(record.Id);
      if (
        !String.isBlank(record.ABN__c) && record.ABN__c != oldRecord?.ABN__c
      ) {
        AbnAcnUtil.validateAndFormatRecordABN(record, 'ABN__c');
      }
      if (
        !String.isBlank(record.ACN__c) && record.ACN__c != oldRecord?.ACN__c
      ) {
        AbnAcnUtil.validateAndFormatRecordACN(record, 'ACN__c');
      }
      if (
        !String.isBlank(record.ARBN__c) && record.ARBN__c != oldRecord?.ARBN__c
      ) {
        AbnAcnUtil.validateAndFormatRecordARBN(record, 'ARBN__c');
      }
    }
  }

  /**
   * @description Extract prospect customers from a list of accounts
   * @name extractProspectAccounts
   * @param records from the trigger
   * @return List<Account> the list of prospect customers
   */
  public static List<Account> extractProspectAccounts(List<Account> records) {
    List<Account> prospects = new List<Account>();
    for (Account record : records) {
      if (record.Is_Prospect__c) {
        prospects.add(record);
      }
    }

    return prospects;
  }

  /**
   * @description Filter a list of account IDs to return those that are prospect customers
   * @name extractProspectIds
   * @param accountIds The ID of accounts to check
   * @return Set<Id> - The ID of accounts that are prospect customer
   */
  public static Set<Id> extractProspectIds(Set<Id> accountIds) {
    return new Map<Id, Account>(
        [
          SELECT Id
          FROM Account
          WHERE Id IN :accountIds AND Is_Prospect__c = TRUE
          WITH SECURITY_ENFORCED
        ]
      )
      .keySet();
  }
}
