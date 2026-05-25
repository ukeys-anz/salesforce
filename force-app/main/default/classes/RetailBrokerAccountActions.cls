/**
 * @author Lance Shi
 * @since  04/2026
 * @description Retail Broker Account related trigger actions class
 * @runTests  RetailBrokerAccountActionsTest
 */

public with sharing class RetailBrokerAccountActions {
  private static final RetailAccountMergeRepository ACCOUNT_REPOSITORY = (RetailAccountMergeRepository) Lib_InstanceProvider.forType(
    RetailAccountMergeRepository.class
  );

  /**
   * @description Process account merge event
   * @param records list of new version of accounts from trigger context
   * @param accountsNewMap map of New version of accounts from trigger context
   * @param accountsOldMap map of old version of accounts from trigger context
   */
  public static void accountMergeEvent(
    List<Account> records,
    Map<Id, Account> accountsNewMap,
    Map<Id, Account> accountsOldMap
  ) {
    // Only process merge if current user is the OCV GCP integration user
    String currentUsername = UserInfo.getUsername();
    if (
      currentUsername == null ||
      !currentUsername.contains('ocvgcp.integrationuser')
    ) {
      return;
    }

    List<Account> filteredVictimAccountList = filterVictimAccounts(
      records,
      accountsOldMap
    );

    Set<String> survivorExternalIdList = ListUtil.getStrings(
      filteredVictimAccountList,
      Account.Survivor_Party_ID__c
    );
    List<Account> survivorAccountsList = ACCOUNT_REPOSITORY.queryAccountRecordsByExternalIds(
      survivorExternalIdList
    );

    processDataMerge(filteredVictimAccountList, survivorAccountsList);
  }

  /**
   * @description Process the data merge event
   * @param victimAccountsList List<Account> List of Victim Accounts
   * @param survivorAccountsList List<Account> List of survivor Accounts
   */
  public static void processDataMerge(
    List<Account> victimAccountsList,
    List<Account> survivorAccountsList
  ) {
    List<Account> allAccountsList = new List<Account>(victimAccountsList);
    allAccountsList.addAll(survivorAccountsList);

    Map<String, Account> accountMap = (Map<String, Account>) ListUtil.mapBy(
      allAccountsList,
      Account.External_Id__c
    );

    try {
      for (Account victim : victimAccountsList) {
        Account survivor = accountMap.get(victim.Survivor_Party_ID__c);
        if (survivor == null) {
          continue;
        }
        survivor.Survivor_Party_ID__c = victim.Survivor_Party_ID__c;
        survivor.Victim_External_ID__c = victim.Victim_External_ID__c;

        Database.MergeResult result = Database.merge(survivor, victim, false);

        if (result.isSuccess()) {
          continue;
        }
        Logger.error(
            'Account Merge failed for following accounts ' +
              survivor.Id +
              ' and ' +
              victim.Id +
              ' Error_Message: ',
            result
          )
          .save();
      }
    } catch (Exception ex) {
      Logger.error('Account Merge Failed due to : ', ex).save();
    }
  }

  /**
   * @description filter records based on updation of Survivor and Victim party Ids
   * @param records records from trigger context
   * @param accountsOldMap map of old version of accounts from trigger context
   * @return List<Account> list of filtered account records based on updation of Survivor and Victim party Ids
   */
  public static List<Account> filterVictimAccounts(
    List<Account> records,
    Map<Id, Account> accountsOldMap
  ) {
    Set<SObjectField> fieldsToValidateChange = new Set<SObjectField>{
      Account.Survivor_Party_ID__c,
      Account.Victim_External_ID__c
    };

    Set<String> victimIdsSet = ListUtil.getStrings(
      records,
      Account.Victim_External_ID__c
    );
    List<Account> filteredVictimRecords = ListUtil.filter(
        records,
        accountsOldMap
      )
      .anyChanged(fieldsToValidateChange)
      .isNotBlank(Account.Survivor_Party_ID__c)
      .isNotBlank(Account.Victim_External_ID__c)
      .equals(Account.External_Id__c, victimIdsSet)
      .toList();

    return filteredVictimRecords;
  }
}
