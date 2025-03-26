/**
 * @author MLCRM Developer
 * @since 07/2024
 * @description This class provide SOQL,DML and mocking helper for class related to Account.
 */
public with sharing class AccountActionsRepository {
  /**
   * @description getAccountByIds method return account associated to the given ids of the account
   * @param idsOfAcc Id of the Account
   * @return Map<Id,Account> account Map
   */
  public Map<Id, Account> getAccountByIds(Set<ID> idsOfAcc) {
    if (idsOfAcc.isEmpty()) {
      return new Map<Id, Account>();
    }
    return new Map<Id, Account>(
      [
        SELECT Id, PersonContactId, Name, Salutation
        FROM Account
        WHERE Id IN :idsOfAcc
        WITH USER_MODE
      ]
    );
  }

  /**
   * @description getCurrentAccountById method return account associated to the given ids of the account
   * @param idOfAcc Id of the Account
   * @return Account account record
   */
  public Account getCurrentAccountById(Id idOfAcc) {
    if (idOfAcc == null) {
      return new Account();
    }
    return [
      SELECT
        Id,
        IsPersonAccount,
        Name,
        Salutation,
        Source_System_ID__c,
        Source_System_Name__c,
        OCV_ID__c,
        OwnerId
      FROM Account
      WHERE Id = :idOfAcc
      WITH USER_MODE
    ] ?? null;
  }

  /**
   * @description check current user is ML User or not
   * @name isCurrentUserML
   * @return Boolean is Current User ML or Not
   */
  public Boolean isCurrentUserML() {
    return UserInfo.getProfileId() == QueryProfile.anzMLStandardUser.Id;
  }
}
