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
}
