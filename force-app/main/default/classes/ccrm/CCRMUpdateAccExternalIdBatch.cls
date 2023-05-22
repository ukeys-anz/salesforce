/**
 * @author Boobalakrishnan Duraisamy
 * @since 03/2023
 * @description Temporary batch class to transform and update external id field in account object.
 */

public with sharing class CCRMUpdateAccExternalIdBatch implements Database.Batchable<sObject> {
  /**
   * @description Get all account records where external id is not null
   * @param bc Database.BatchableContext
   * @return Database.QueryLocator scope
   */
  public Database.QueryLocator start(Database.BatchableContext bc) {
    return Database.getQueryLocator(
      [
        SELECT Id, External_Id__c, Temporary_External_Id__c
        FROM Account
        WHERE External_ID__c != NULL AND Temporary_External_ID__c = NULL
      ]
    );
  }

  /**
   * @description  copies the external id into a temporary field, transform the external id and updates the account object
   * @param bc Database.BatchableContext
   * @param accountRecords from start method
   */

  public void execute(
    Database.BatchableContext bc,
    List<Account> accountRecords
  ) {
    if (Account.sObjectType.getDescribe().isUpdateable()) {
      for (Account acc : accountRecords) {
        acc.Temporary_External_Id__c = acc.External_Id__c;
        acc.External_Id__c = acc.External_Id__c.substringAfter('_');
      }
      List<Database.saveResult> result = Database.update(accountRecords, false);
      Logger.error('', result);
      Logger.saveLog();
    }
  }

  /**
   * @description To execute any post processing steps
   * @param bc Database.BatchableContext
   */
  public void finish(Database.BatchableContext bc) {
  }
}
