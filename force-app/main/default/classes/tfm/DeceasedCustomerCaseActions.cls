/**
 *
 * @author Akshat Khandelwal
 * @since 08/2025
 * @description DeceasedCustomerCaseActions class is to handle all the actions taken for Deceased Customer Cases
 */
public with sharing class DeceasedCustomerCaseActions {
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  /**
   * @description Check if Case is closed and Update Deceased Estate Status field on Parent Account record
   * @param cases List of Cases
   * @param oldMap oldMap of Cases
   */
  public static void checkValidityAndUpdateAccount(
    List<Case> cases,
    Map<Id, SObject> oldMap
  ) {
    List<Case> validCases = (List<Case>) ListUtil.filter(cases, oldMap)
      .changedTo(Case.Status, 'Closed')
      .toList();
    updateDeceasedEstateStatusOnAccount(validCases, 'Completed');
  }

  /**
   * @description Update Deceased Estate Status field on Parent Account record
   * @param validCases List of Cases
   * @param accountDeceasedEstateStatus Deceased Estate Status to be updated on Account
   */
  public static void updateDeceasedEstateStatusOnAccount(
    List<Case> validCases,
    String accountDeceasedEstateStatus
  ) {
    //getting the set of accounts to get the unique AccountIds
    Set<Id> accountsIds = ListUtil.getIds(validCases, Case.AccountId);
    List<Account> accountsToBeUpdated = new List<Account>();
    for (Id idValue : accountsIds) {
      Account newAccount = new Account(
        Id = idValue,
        DeceasedEstateStatus__c = accountDeceasedEstateStatus
      );
      accountsToBeUpdated.add(newAccount);
    }
    //using withoutSharing because FraudX Agents don't have access to update Accounts
    DML_REPOSITORY.doUpdate(
      accountsToBeUpdated,
      new DmlConfig().allowPartial().withoutSharing()
    );
  }
}
